-- Headless smoke test. Renders tests/fixture.md and checks every mdx feature drew something.
--   MDX_MODE=integrated  render-markdown (with this config's opts) drives mdx as its handler
--   MDX_MODE=standalone  mdx draws on its own
-- Run with: make test-md
local here = vim.fs.dirname(vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p"))
local root = vim.fs.dirname(here) -- mdx.nvim
local config_dir = vim.fs.dirname(root) -- ~/.config/nvim
local lazy = vim.fn.stdpath("data") .. "/lazy"
local mode = vim.env.MDX_MODE or "integrated"

vim.opt.rtp:prepend(root)
vim.o.columns, vim.o.lines = 120, 60
vim.cmd("filetype on")

local failures = 0
local function check(ok, what)
  io.stdout:write((ok and "  ok   " or "  FAIL ") .. what .. "\n")
  if not ok then failures = failures + 1 end
end

require("mdx").setup({})

if mode == "integrated" then
  vim.opt.rtp:prepend(lazy .. "/render-markdown.nvim")
  vim.opt.rtp:prepend(lazy .. "/nvim-web-devicons")
  local spec
  for _, s in ipairs(dofile(config_dir .. "/lua/plugins/markdown.lua")) do
    if s[1] == "MeanderingProgrammer/render-markdown.nvim" then spec = s end
  end
  require("render-markdown").setup(spec.opts)
end

vim.cmd.edit(here .. "/fixture.md")
local buf = vim.api.nvim_get_current_buf()
vim.treesitter.start(buf, "markdown")
vim.api.nvim_win_set_cursor(0, { 1, 0 })
if mode == "integrated" then require("render-markdown").render({ buf = buf }) end

---Every virtual text/line string in the buffer, per row
local function rendered()
  local rows = {}
  for _, m in ipairs(vim.api.nvim_buf_get_extmarks(buf, -1, 0, -1, { details = true })) do
    local row, d = m[2], m[4]
    local parts = {}
    for _, chunk in ipairs(d.virt_text or {}) do parts[#parts + 1] = chunk[1] end
    for _, line in ipairs(d.virt_lines or {}) do
      for _, chunk in ipairs(line) do parts[#parts + 1] = chunk[1] end
      parts[#parts + 1] = "\n"
    end
    rows[row] = (rows[row] or "") .. table.concat(parts)
  end
  return rows
end

local function find(text)
  for row, s in pairs(rendered()) do
    if s:find(text, 1, true) then return row end
  end
end

local function line_of(pattern)
  for i, l in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    if l:find(pattern, 1, true) then return i - 1 end
  end
end

io.stdout:write("mdx smoke test (" .. mode .. ")\n")
vim.wait(1500, function() return find("2/4") ~= nil end, 50)

if mode == "integrated" then check(require("mdx").integrated[buf] == true, "render-markdown calls the mdx handler") end
check((rendered()[line_of("## Tasks")] or ""):find("2/4", 1, true) ~= nil, "progress 2/4 on the Tasks heading")
local bars = 0
for _, pat in ipairs({ "`/v2/charge`", "`/v2/refund`", "`/v2/status`" }) do
  if (rendered()[line_of(pat)] or ""):find("▆", 1, true) then bars = bars + 1 end
end
check(bars == 3, "bars drawn on all 3 table rows")
check(find("max 650") ~= nil, "table summary shows max 650")
check(find("◇ mermaid") ~= nil and find("Client") ~= nil and find("Ledger") ~= nil, "mermaid drawn as text")

vim.wait(1500, function() return #vim.diagnostic.get(buf, { namespace = require("mdx.links").ns }) > 0 end, 50)
local msgs = {}
for _, d in ipairs(vim.diagnostic.get(buf, { namespace = require("mdx.links").ns })) do msgs[#msgs + 1] = d.message end
table.sort(msgs)
check(vim.deep_equal(msgs, { "Missing file docs/runbook.md", "No heading #nope" }),
  "link diagnostics: " .. table.concat(msgs, "; "))

local done
-- buffer 0, as <leader>mx passes it
require("mdx.run").run_at(0, line_of("for n in range"), require("mdx.config").options.run, function(r) done = r end)
vim.wait(5000, function() return done ~= nil end, 50)
vim.wait(1000, function() return find("exit 0") ~= nil end, 50)
check(done and done.code == 0, "python block exits 0")
check(find("exit 0") ~= nil and (rendered()[find("exit 0")] or ""):find("4 16", 1, true) ~= nil, "run output shown under the block")

if mode == "integrated" then
  check(#vim.api.nvim_buf_get_extmarks(buf, require("mdx").ns, 0, -1, {}) == 0, "no duplicate standalone marks")
end

-- editing the block makes its output stale, so it disappears
vim.wait(300) -- let mdx's trailing render land, as it would before you type
local row = line_of("print(n")
vim.api.nvim_buf_set_lines(buf, row, row + 1, false, { "    print(n * 2)" })
if mode == "integrated" then require("render-markdown").render({ buf = buf }) else require("mdx").draw(buf) end
vim.wait(1000, function() return find("exit 0") == nil end, 50)
check(find("exit 0") == nil, "edited block hides stale output")

vim.fn.chdir(here)
local items = require("mdx.links").check_project()
check(#items == 2, "project link check finds 2 problems (got " .. #items .. ")")
local tasks
for _, e in ipairs(require("mdx.outline").entries(here)) do
  if e.text == "Tasks" then tasks = e end
end
check(tasks and tasks.done == 2 and tasks.total == 4, "outline lists Tasks with 2/4")

io.stdout:write(failures == 0 and "all passed\n" or (failures .. " failed\n"))
vim.cmd(failures == 0 and "qa!" or "cq!")

-- mdx: markdown extras on top of render-markdown.nvim
--   progress  task progress after headings
--   tables    bars and a summary for numeric table columns
--   run       run code blocks on demand, output under the block
--   links     broken links/anchors as diagnostics
--   mermaid   flowcharts drawn as text
--   outline   telescope picker over every heading in the project
--
-- With render-markdown, mdx runs as its custom markdown handler, so marks get the same
-- raw-on-cursor-line and insert-mode behaviour. Without it, mdx draws on its own.
local config = require("mdx.config")
local util = require("mdx.util")

local M = {}

M.ns = vim.api.nvim_create_namespace("mdx")

---Buffers render-markdown has called our handler for
M.integrated = {}

local FEATURES = { "progress", "tables", "run", "mermaid" }

local function enabled(name)
  local o = config.options[name]
  if name == "mermaid" then return o.mode ~= false end
  return o.enabled
end

---All marks for one markdown tree, in render-markdown's mark format
function M.marks(buf, root)
  local marks = {}
  for _, name in ipairs(FEATURES) do
    if enabled(name) then
      local ok, res = pcall(require("mdx." .. name).marks, buf, root, config.options[name])
      if ok then vim.list_extend(marks, res)
      else util.warn_once(name, name .. " failed: " .. tostring(res)) end
    end
  end
  return marks
end

---render-markdown custom handler: custom_handlers = { markdown = require("mdx").handler() }
function M.handler()
  return {
    extends = true, -- keep render-markdown's own markdown rendering
    parse = function(ctx)
      if not M.integrated[ctx.buf] then
        M.integrated[ctx.buf] = true
        -- the standalone fallback may have drawn before render-markdown got here
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(ctx.buf) then vim.api.nvim_buf_clear_namespace(ctx.buf, M.ns, 0, -1) end
        end)
      end
      return M.marks(ctx.buf, ctx.root)
    end,
  }
end

---Standalone drawing, used when render-markdown isn't driving this buffer
function M.draw(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  vim.api.nvim_buf_clear_namespace(buf, M.ns, 0, -1)
  local ok, parser = pcall(vim.treesitter.get_parser, buf, "markdown")
  if not ok or not parser then return end
  local tree = parser:parse()[1]
  for _, m in ipairs(M.marks(buf, tree:root())) do
    pcall(vim.api.nvim_buf_set_extmark, buf, M.ns, m.start_row, m.start_col, m.opts)
  end
end

---Redraw after state outside the text changed (a code block finished running)
function M.refresh(buf)
  if buf == 0 then buf = vim.api.nvim_get_current_buf() end
  if M.integrated[buf] and package.loaded["render-markdown"] then
    local render = function()
      if vim.api.nvim_buf_is_valid(buf) then require("render-markdown").render({ buf = buf }) end
    end
    render()
    -- render-markdown drops renders that arrive within its debounce window (100 ms by
    -- default) of the previous one, so a fast "running" -> "done" pair would lose "done"
    vim.defer_fn(render, 250)
  else
    M.draw(buf)
  end
end

local function highlights()
  local links = {
    MdxProgress = "DiagnosticInfo",
    MdxDone = "DiagnosticOk",
    MdxDim = "LineNr",
    MdxBar = "DiagnosticInfo",
    MdxBarWarn = "DiagnosticWarn",
    MdxBarError = "DiagnosticError",
    MdxError = "DiagnosticError",
    MdxOutput = "Normal",
    MdxBox = "DiagnosticInfo",
    MdxBoxAlt = "DiagnosticWarn",
    MdxLabel = "Title",
    MdxEdge = "LineNr",
  }
  for group, target in pairs(links) do
    vim.api.nvim_set_hl(0, group, { link = target, default = true })
  end
end

function M.run() require("mdx.run").run_at(0, vim.api.nvim_win_get_cursor(0)[1] - 1, config.options.run) end

local function attach(buf)
  if vim.b[buf].mdx_attached then return end
  vim.b[buf].mdx_attached = true
  local group = vim.api.nvim_create_augroup("mdx_buf_" .. buf, { clear = true })

  if config.options.run.enabled then
    vim.keymap.set("n", "<leader>mx", M.run, { buffer = buf, desc = "Run code block" })
  end

  if config.options.links.enabled then
    local check = util.debounce(300, function() require("mdx.links").check_buffer(buf) end)
    vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave", "TextChanged", "BufWritePost" },
      { group = group, buffer = buf, callback = function() check() end })
    check()
  end

  -- If render-markdown hasn't called our handler shortly after the buffer opens, draw ourselves
  local redraw = util.debounce(150, function()
    if not M.integrated[buf] then M.draw(buf) end
  end)
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "InsertLeave", "BufWinEnter" },
    { group = group, buffer = buf, callback = function() redraw() end })
  vim.defer_fn(function()
    if not M.integrated[buf] then M.draw(buf) end
  end, 300)

  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group,
    buffer = buf,
    callback = function()
      M.integrated[buf] = nil
      require("mdx.run").results[buf] = nil
      pcall(vim.api.nvim_del_augroup_by_id, group)
    end,
  })
end

local commands = {
  run = M.run,
  clear = function() require("mdx.run").clear(vim.api.nvim_get_current_buf()) end,
  links = function() require("mdx.links").check_project() end,
  outline = function() require("mdx.outline").open() end,
  refresh = function() M.refresh(vim.api.nvim_get_current_buf()) end,
}

function M.setup(opts)
  config.set(opts)
  highlights()
  vim.api.nvim_create_autocmd("ColorScheme", { group = vim.api.nvim_create_augroup("mdx", { clear = true }), callback = highlights })
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("mdx_attach", { clear = true }),
    pattern = "markdown",
    callback = function(args) attach(args.buf) end,
  })
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "markdown" then attach(buf) end
  end

  vim.api.nvim_create_user_command("Mdx", function(cmd)
    local fn = commands[cmd.args]
    if not fn then return vim.notify("mdx: unknown subcommand " .. cmd.args, vim.log.levels.ERROR) end
    fn()
  end, {
    nargs = 1,
    desc = "mdx: run | clear | links | outline | refresh",
    complete = function(arg)
      return vim.tbl_filter(function(c) return c:find(arg, 1, true) == 1 end, vim.tbl_keys(commands))
    end,
  })
end

return M

-- Run the fenced code block under the cursor and show its output under the block.
-- Nothing runs on its own: only :Mdx run / <leader>mx.
local util = require("mdx.util")
local M = {}

---results[buf][hash of lang+code] = { state, code, ms, lines }
---Keyed by content, so editing a block hides its now-stale output.
M.results = {}

local function key(lang, code) return vim.fn.sha256(lang .. "\0" .. code) end

local function python()
  local venv = vim.env.VIRTUAL_ENV -- set by config.pipenv for Pipfile projects
  local py = venv and venv .. "/bin/python"
  return (py and vim.fn.executable(py) == 1) and py or "python3"
end

local function tmpdir()
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir, "p")
  return dir
end

---@return string[]? cmd, string? cleanup_dir, string? err
local runners = {
  python = function(code) return { python(), "-c", code } end,
  py = function(code) return { python(), "-c", code } end,
  bash = function(code) return { "bash", "-c", code } end,
  sh = function(code) return { "sh", "-c", code } end,
  zsh = function(code) return { "zsh", "-c", code } end,
  lua = function(code)
    local dir = tmpdir()
    vim.fn.writefile(vim.split(code, "\n"), dir .. "/main.lua")
    return { vim.v.progpath, "-l", dir .. "/main.lua" }, dir
  end,
  go = function(code)
    if vim.fn.executable("go") == 0 then return nil, nil, "go isn't on $PATH" end
    local dir = tmpdir()
    -- a bare snippet gets wrapped in main(); goimports then adds the imports it needs
    if not code:match("^%s*package%s") and not code:match("\npackage%s") then
      code = "package main\n\nfunc main() {\n" .. code .. "\n}\n"
    end
    vim.fn.writefile(vim.split(code, "\n"), dir .. "/main.go")
    if vim.fn.executable("goimports") == 1 then
      vim.system({ "goimports", "-w", dir .. "/main.go" }):wait()
    end
    return { "go", "run", "main.go" }, dir
  end,
}
runners.golang = runners.go
runners.shell = runners.bash

function M.supported(lang) return lang and runners[lang] ~= nil end

local function block_at(buf, row)
  local parser = vim.treesitter.get_parser(buf, "markdown")
  local tree = parser:parse()[1]
  for _, f in ipairs(util.fences(buf, tree:root())) do
    if row >= f.first and row <= f.last then return f end
  end
end

function M.run_at(buf, row, opts, on_done)
  if buf == 0 then buf = vim.api.nvim_get_current_buf() end
  local f = block_at(buf, row)
  if not f then return vim.notify("mdx: the cursor isn't in a code block", vim.log.levels.INFO) end
  if not M.supported(f.lang) then
    return vim.notify("mdx: no runner for " .. (f.lang and ("`" .. f.lang .. "`") or "blocks without a language"),
      vim.log.levels.INFO)
  end
  local cmd, cleanup, err = runners[f.lang](f.code)
  local results = M.results[buf] or {}
  M.results[buf] = results
  local k = key(f.lang, f.code)
  if not cmd then
    results[k] = { state = "done", code = -1, ms = 0, lines = { { err, true } }, lang = f.lang }
    return require("mdx").refresh(buf)
  end
  results[k] = { state = "running", lang = f.lang }
  require("mdx").refresh(buf)

  local file = vim.api.nvim_buf_get_name(buf)
  local cwd = cleanup or (file ~= "" and vim.fs.dirname(file)) or vim.fn.getcwd()
  local t0 = vim.uv.hrtime()
  local ok, proc = pcall(vim.system, cmd, { cwd = cwd, text = true, timeout = opts.timeout }, function(res)
    local ms = math.floor((vim.uv.hrtime() - t0) / 1e6)
    local lines = {}
    for _, stream in ipairs({ { res.stdout, false }, { res.stderr, true } }) do
      local text = vim.trim(stream[1] or "")
      if text ~= "" then
        for l in vim.gsplit(text, "\n") do lines[#lines + 1] = { l, stream[2] } end
      end
    end
    if res.signal == 15 or res.code == 124 then lines[#lines + 1] = { "timed out after " .. opts.timeout .. " ms", true } end
    results[k] = { state = "done", code = res.code, ms = ms, lines = lines, lang = f.lang }
    vim.schedule(function()
      if cleanup then vim.fn.delete(cleanup, "rf") end -- vim.fn isn't allowed in this callback directly
      if vim.api.nvim_buf_is_valid(buf) then require("mdx").refresh(buf) end
      if on_done then on_done(results[k]) end
    end)
  end)
  if not ok then
    results[k] = { state = "done", code = -1, ms = 0, lines = { { tostring(proc), true } }, lang = f.lang }
    require("mdx").refresh(buf)
  end
end

function M.clear(buf)
  if buf == 0 then buf = vim.api.nvim_get_current_buf() end
  M.results[buf] = nil
  require("mdx").refresh(buf)
end

function M.marks(buf, root, opts)
  local results = M.results[buf]
  if not results then return {} end
  local marks = {}
  for _, f in ipairs(util.fences(buf, root)) do
    local r = f.lang and results[key(f.lang, f.code)]
    if r then
      local lines
      if r.state == "running" then
        lines = { { { "  ◌ running " .. r.lang .. "…", "MdxDim" } } }
      else
        lines = { { { string.format("  ▶ %s · exit %d · %d ms", r.lang, r.code, r.ms), r.code == 0 and "MdxDone" or "MdxError" } } }
        for i, l in ipairs(r.lines) do
          if i > opts.max_lines then
            lines[#lines + 1] = { { "  │ ", "MdxDim" }, { "… " .. (#r.lines - opts.max_lines) .. " more lines", "MdxDim" } }
            break
          end
          lines[#lines + 1] = { { "  │ ", "MdxDim" }, { l[1], l[2] and "MdxError" or "MdxOutput" } }
        end
      end
      marks[#marks + 1] = { conceal = false, start_row = f.last, start_col = 0, opts = { virt_lines = lines } }
    end
  end
  return marks
end

return M

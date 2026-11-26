-- Project lint rules: when a Go project has a golangci-lint config, its rules are enforced here.
--   * diagnostics: `golangci-lint run` with that config, shown like any LSP diagnostic (on open and save)
--   * formatting:  `golangci-lint fmt` (v2) when the config has a `formatters:` section, so the project's
--                  own formatters (gofumpt, gci, goimports, ...) win over the defaults
-- Projects without a config keep the default goimports + golines and get no golangci-lint diagnostics.
local CONFIGS = { ".golangci.yml", ".golangci.yaml", ".golangci.toml", ".golangci.json" }

local M = {}

-- Path of the nearest golangci-lint config above `path`, or nil
function M.config_for(path)
  local dir = vim.fs.dirname(path)
  local found = vim.fs.find(CONFIGS, { path = dir, upward = true, type = "file", limit = 1 })[1]
  return found
end

local function has_formatters(config)
  if not config or config:match("%.json$") then
    return config ~= nil and (table.concat(vim.fn.readfile(config), "\n")):find('"formatters"', 1, true) ~= nil
  end
  for _, line in ipairs(vim.fn.readfile(config)) do
    if line:match("^%s*formatters%s*[:=]") or line:match("^%[formatters") then
      return true
    end
  end
  return false
end

local function version_2()
  if M._v2 == nil then
    local out = vim.system({ "golangci-lint", "--version" }, { text = true }):wait()
    M._v2 = out.code == 0 and (out.stdout or ""):match("version v?(%d+)") == "2"
  end
  return M._v2
end

-- Lint ---------------------------------------------------------------------------------------

local ns = vim.api.nvim_create_namespace("golangci_lint")
local running = {} -- buf -> vim.SystemObj

local function severity(s)
  return ({ error = vim.diagnostic.severity.ERROR, warning = vim.diagnostic.severity.WARN, info = vim.diagnostic.severity.INFO })[s]
    or vim.diagnostic.severity.WARN
end

function M.lint(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(buf)
  if file == "" or vim.bo[buf].filetype ~= "go" or vim.fn.executable("golangci-lint") ~= 1 then
    return
  end
  local config = M.config_for(file)
  if not config then
    vim.diagnostic.reset(ns, buf)
    return
  end
  local root = vim.fs.dirname(config)
  local dir = vim.fs.dirname(file)
  local rel = dir == root and "." or dir:sub(#root + 2)
  local args = { "golangci-lint", "run", "--config", config, "./" .. rel }
  if version_2() then
    vim.list_extend(args, { "--output.json.path=stdout", "--output.text.path=", "--show-stats=false", "--issues-exit-code=0" })
  else
    vim.list_extend(args, { "--out-format=json", "--issues-exit-code=0" })
  end
  if running[buf] then
    pcall(function() running[buf]:kill(15) end)
  end
  running[buf] = vim.system(args, { cwd = root, text = true }, function(res)
    vim.schedule(function()
      running[buf] = nil
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      -- the JSON report is one line, possibly after log lines
      local json
      for line in (res.stdout or ""):gmatch("[^\n]+") do
        if line:sub(1, 1) == "{" then
          json = line
        end
      end
      local ok, report = pcall(vim.json.decode, json or "")
      if not ok or type(report) ~= "table" then
        if res.code ~= 0 then
          vim.notify("golangci-lint failed:\n" .. vim.trim(res.stderr or ""), vim.log.levels.WARN)
        end
        return
      end
      local diags = {}
      for _, issue in ipairs(report.Issues or {}) do
        local pos = issue.Pos or {}
        local path = pos.Filename and vim.fs.normalize(vim.fs.joinpath(root, pos.Filename))
        if path == vim.fs.normalize(file) then
          local lnum, col = (pos.Line or 1) - 1, math.max((pos.Column or 1) - 1, 0)
          diags[#diags + 1] = {
            lnum = lnum,
            col = col,
            end_lnum = lnum,
            end_col = col + 1,
            severity = severity(issue.Severity),
            source = "golangci-lint",
            code = issue.FromLinter,
            message = issue.Text,
          }
        end
      end
      vim.diagnostic.set(ns, buf, diags)
    end)
  end)
end


function M.setup()
  local group = vim.api.nvim_create_augroup("golangci_lint", { clear = true })
  vim.api.nvim_create_autocmd({ "FileType", "BufWritePost" }, {
    group = group,
    pattern = { "go", "*.go" },
    callback = function(args) M.lint(args.buf) end,
  })
end

-- conform.nvim: the project's formatters if it configures any, else the defaults
M.formatter = {
  command = "golangci-lint",
  args = function(_, ctx) return { "fmt", "--config", M.config_for(ctx.filename), "--stdin" } end,
  cwd = function(_, ctx)
    local config = M.config_for(ctx.filename)
    return config and vim.fs.dirname(config) or nil
  end,
  stdin = true,
}

function M.go_formatters(buf)
  local config = M.config_for(vim.api.nvim_buf_get_name(buf))
  if config and version_2() and has_formatters(config) then
    return { "golangci_fmt" }
  end
  return { "goimports", "golines" }
end

return M

-- Pipenv: if the cwd has a Pipfile, activate its virtualenv (VIRTUAL_ENV + PATH) so pyright,
-- dap-python, neotest and :terminal all use it. Runs before plugins so LSP starts with it.
vim.filetype.add({ filename = { Pipfile = "toml", ["Pipfile.lock"] = "json" } })

local base_path = vim.env.PATH
local base_venv = vim.env.VIRTUAL_ENV

-- Cheap lookup that avoids spawning pipenv (~1s): in-project .venv, or a venv under
-- WORKON_HOME whose .project file points back at this directory.
local function find_pipenv_venv(dir)
  if vim.uv.fs_stat(dir .. "/.venv/bin/python") then
    return dir .. "/.venv"
  end
  local home = vim.env.WORKON_HOME or (vim.env.HOME .. "/.local/share/virtualenvs")
  local name = vim.fs.basename(dir):gsub("[^%w_%-]", "_")
  for _, venv in ipairs(vim.fn.glob(home .. "/" .. name .. "-*", false, true)) do
    local f = io.open(venv .. "/.project")
    if f then
      local project = vim.trim(f:read("*a"))
      f:close()
      if project == dir then
        return venv
      end
    end
  end
end

local function set_python_venv(venv)
  if vim.env.VIRTUAL_ENV == venv then
    return
  end
  vim.env.VIRTUAL_ENV = venv
  vim.env.PATH = venv and (venv .. "/bin:" .. base_path) or base_path
  -- Point already-running pyright clients at the new interpreter
  local python = venv and (venv .. "/bin/python") or vim.fn.exepath("python3")
  for _, client in ipairs(vim.lsp.get_clients({ name = "pyright" })) do
    client.settings = vim.tbl_deep_extend("force", client.settings or {}, {
      python = { pythonPath = python },
    })
    client:notify("workspace/didChangeConfiguration", { settings = client.settings })
  end
  if venv then
    vim.notify("Pipenv: " .. vim.fs.basename(venv), vim.log.levels.INFO)
  end
end

local function load_pipenv(dir)
  if not vim.uv.fs_stat(dir .. "/Pipfile") then
    set_python_venv(base_venv)
    return
  end
  local venv = find_pipenv_venv(dir)
  if venv then
    set_python_venv(venv)
  elseif vim.fn.executable("pipenv") == 1 then
    vim.system({ "pipenv", "--venv" }, { cwd = dir, text = true }, vim.schedule_wrap(function(out)
      if out.code == 0 and vim.uv.cwd() == dir then
        set_python_venv(vim.trim(out.stdout))
      end
    end))
  end
end

load_pipenv(vim.uv.cwd())
vim.api.nvim_create_autocmd("DirChanged", {
  group = vim.api.nvim_create_augroup("pipenv_venv", { clear = true }),
  callback = function()
    load_pipenv(vim.uv.cwd())
  end,
})

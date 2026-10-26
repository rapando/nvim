-- Auto-cd to project root when opening files
vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("auto_project_root", { clear = true }),
  nested = true, -- let the chdir fire DirChanged, so the Pipenv loader re-runs
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" then
      return
    end
    local root = vim.fs.root(args.buf, { "Pipfile", "go.mod", ".git" })
    if root and root ~= vim.fn.getcwd() then
      pcall(vim.fn.chdir, root)
    end
  end,
})

-- Live reload: show changes other programs (Claude, git, formatters) make to open files.
-- 'autoread' reloads a file that changed on disk if the buffer has no unsaved edits;
-- with unsaved edits Neovim asks which version to keep instead.
vim.o.autoread = true

-- Neovim only checks the disk on focus or :checktime, so watch each open file as well
local watchers = {}

local function unwatch(buf)
  local w = watchers[buf]
  if not w then
    return
  end
  w.handle:stop()
  w.handle:close()
  w.timer:stop()
  w.timer:close()
  watchers[buf] = nil
end

local function watch(buf)
  unwatch(buf)
  local file = vim.api.nvim_buf_get_name(buf)
  if vim.bo[buf].buftype ~= "" or file == "" or not vim.uv.fs_stat(file) then
    return
  end
  local handle, timer = vim.uv.new_fs_event(), vim.uv.new_timer()
  watchers[buf] = { handle = handle, timer = timer }
  handle:start(file, {}, function()
    -- writes come in bursts; check once they settle
    timer:start(100, 0, vim.schedule_wrap(function()
      if not vim.api.nvim_buf_is_valid(buf) then
        return unwatch(buf)
      end
      vim.cmd.checktime(buf)
      -- most tools save by writing a new file and renaming it over the old one, which
      -- ends this watch, so start a fresh one on whatever file is there now
      watch(buf)
    end))
  end)
end

local live_reload = vim.api.nvim_create_augroup("live_reload", { clear = true })
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "BufFilePost" }, {
  group = live_reload,
  callback = function(args)
    watch(args.buf)
  end,
})
vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
  group = live_reload,
  callback = function(args)
    unwatch(args.buf)
  end,
})
-- Fallback for files that weren't on disk yet when opened, or a watch that was lost
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  group = live_reload,
  callback = function(args)
    if vim.bo[args.buf].buftype == "" and vim.fn.getcmdwintype() == "" then
      vim.cmd.checktime(args.buf)
      if not watchers[args.buf] then
        watch(args.buf)
      end
    end
  end,
})

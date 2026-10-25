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

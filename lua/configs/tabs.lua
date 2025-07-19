vim.api.nvim_create_autocmd("TabEnter", {
    callback = function()
        require("neo-tree.sources.manager").refresh("filesystem")
    end,
})

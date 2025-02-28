-- disable the default tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- nvim-tree settings
require("nvim-tree").setup({
    view = {
        width = 30,
        side = "left",
    },
    filters = {
        dotfiles = false, -- show all dotfiles by default
    },
    git = {
        ignore = false, -- Show gitignored files
    },
    renderer = {
        -- root_folder_label = false,
        icons = {
            show = {
                file = true,
                folder = true,
                folder_arrow = true,
            },
        },
    },
})


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


-- <leader-n> opens/closes nvim-tree
vim.api.nvim_set_keymap("n", "<leader>n", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

-- Mapping to open file in a vertical split to the right
vim.api.nvim_set_keymap('n', '<leader>v', ':vsplit <A-R>=expand("%:p:h")<CR>/<A-R>=expand("%:t")<CR><CR>',
    { noremap = true, silent = true })


-- Mapping to open file in a vertical split to the left
vim.api.nvim_set_keymap('n', '<leader>V', ':leftabove vsplit<CR>', { noremap = true, silent = true })

-- Mapping to search for a file before opening it
vim.api.nvim_set_keymap('n', '<leader>o', "<cmd>lua require('telescope.builtin').find_files()<CR>",
    { noremap = true, silent = true })

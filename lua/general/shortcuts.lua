--[[
This file contains all used keyboard shortcuts.
The reason for this is to make it easier to learn/add shortcuts.
--]]


local default_keymap_setting = { noremap = true, silent = true }

-- Manual formatting.
vim.keymap.set('n', 'gq', 'gq', default_keymap_setting)
-- Open LazyGit
vim.keymap.set('n', '<leader>gg', ':LazyGit<CR>', default_keymap_setting)
-- Livegrep feature for searching for files.
vim.api.nvim_set_keymap('n', '<leader>f', ':Telescope live_grep<CR>', default_keymap_setting)
-- search with spectre
vim.keymap.set("n", "<leader>S", '<cmd>lua require("spectre").toggle()<CR>', { desc = "Toggle Spectre" })
-- Search current word.
vim.keymap.set("n", "<leader>sw", '<cmd>lua require("spectre").open_visual({select_word=true})<CR>',
    { desc = "Search current word" })
-- <leader-n> opens/closes nvim-tree
vim.api.nvim_set_keymap("n", "<leader>n", ":NvimTreeToggle<CR>", default_keymap_setting)
-- Mapping to open file in a vertical split to the right
vim.api.nvim_set_keymap('n', '<leader>v', ':vsplit <A-R>=expand("%:p:h")<CR>/<A-R>=expand("%:t")<CR><CR>',
    default_keymap_setting)


-- Mapping to open file in a vertical split to the left
vim.api.nvim_set_keymap('n', '<leader>V', ':leftabove vsplit<CR>', default_keymap_setting)

-- Mapping to search for a file before opening it
vim.api.nvim_set_keymap('n', '<leader>o', "<cmd>lua require('telescope.builtin').find_files()<CR>",
    default_keymap_setting)

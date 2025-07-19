-- All keybindings are here.

-- force redraw with leader+r
vim.api.nvim_set_keymap('n', '<leader>r', ':redraw!<CR>', { noremap = true, silent = true })

-- manual formatting
vim.keymap.set('n', 'gq', 'gq', { noremap = true, silent = true })

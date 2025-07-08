-- All keybindings are here.

-- force redraw with leader+r
vim.api.nvim_set_keymap('n', '<leader>r', ':redraw!<CR>', { noremap = true, silent = true })

-- manual formatting
vim.keymap.set('n', 'gq', 'gq', { noremap = true, silent = true })


-- map M-o to C-o  because it's also a zellij shortcut.
vim.keymap.set('n', '<M-o>', '<C-o>', { noremap = true, silent = true })


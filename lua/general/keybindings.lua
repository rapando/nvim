-- All keybindings are here.

-- force redraw with leader+r
vim.api.nvim_set_keymap('n', '<leader>r', ':redraw!<CR>', { noremap = true, silent = true })

-- manual formatting
vim.keymap.set('n', 'gq', 'gq', { noremap = true, silent = true })

-- when using zellij, I want to remap C-o and C-t 
if os.getenv('ZELLIJ') then
  -- Disable default C-t/C-o in Zellij
  vim.keymap.set({'n', 'i'}, '<C-t>', '<Nop>')
  vim.keymap.set({'n', 'i'}, '<C-o>', '<Nop>')

  -- Remap original functions to Alt+key
  vim.keymap.set('n', '<M-t>', '<C-t>')  -- Tag stack jump → ⌥+t
  vim.keymap.set('n', '<M-o>', '<C-o>')  -- Jump list → ⌥+o
end

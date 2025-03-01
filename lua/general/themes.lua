-- set dark background
vim.o.background = "dark"
-- enable the tabline
vim.g['airline#extensions#tabline#enabled'] = 1
vim.g['airline#extensions#tabline#left_sep'] = ' '
vim.g['airline#extensions#tabline#left_alt_sep'] = '|'

-- set colorscheme
vim.cmd("colorscheme onedark_dark")
-- vim.opt.background = "dark"

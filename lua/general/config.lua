-- General Configs that apply everywhere.

vim.opt.tabstop = 4
vim.opt.mouse = "a"
vim.opt.cursorline = true
vim.opt.number = true
vim.opt.shiftwidth = 4
vim.opt.expandtab = false
-- vim.opt.guicursor = ""
vim.opt.softtabstop = 4
vim.opt.showtabline = 4
vim.cmd("filetype plugin indent on")
vim.cmd("syntax enable")
vim.opt.clipboard:append("unnamedplus")
-- Add fzf to the runtime path (rtp)
vim.opt.rtp:append('/opt/homebrew/opt/fzf')
vim.opt.incsearch = true            -- shows matches when you type
vim.opt.textwidth = 0               -- disable wrap
vim.opt.wrap = false
vim.opt.formatoptions:append('cro') -- auto wrap comments
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.lazyredraw = true

-- change font
vim.o.guifont = "Monaspace Argon:h16"
vim.o.lazyredraw = false

-- disable word wrap
vim.o.wrap = false

-- Change leader.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"


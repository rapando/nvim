--[[
General Neovim Settings.
This file contains all settings that pertain to neovim,
regardless of language or tool.
--]]

vim.opt.tabstop       = 4             -- 4 spaces for tab.
vim.opt.mouse         = "a"           -- enable mouse in all modes.
vim.opt.cursorline    = true          -- highlight current line.
vim.opt.number        = true          -- enable numbered lines.
vim.opt.shiftwidth    = 4             -- 4 spaces for indents.
vim.opt.softtabstop   = 4             -- Pressing tab inserts 4 spaces.
vim.opt.expandtab     = true          -- tab inserts 4 spaces instead of \t
vim.opt.showtabline   = 2             -- always show tabline
vim.opt.incsearch     = true          -- show matches when you type.
vim.opt.textwidth     = 80            -- hard word wrap at 80 characters.
vim.opt.wrap          = false         -- disable soft wrap
vim.opt.termguicolors = true          -- use better colors.
vim.opt.lazyredraw    = false
vim.o.guifont         = "Cousine:h14" -- set font and size.
vim.g.mapleader       = " "           -- space is the leader

-- Indent different file types appropriately.
vim.cmd("filetype plugin indent on")
vim.cmd("syntax enable")
-- Use the system clipboard.
vim.opt.clipboard:append("unnamedplus")
-- Add fzf to the runtime path (rtp)
vim.opt.rtp:append('/opt/homebrew/opt/fzf')
-- Autowrap comments
vim.opt.formatoptions:append('cro')

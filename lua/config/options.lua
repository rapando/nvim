-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.softtabstop = 4
vim.opt.wrap = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.termguicolors = true
vim.opt.guicursor = "n-v-c-sm-o-r-cr-ve:hor20,i-ci:hor20-blinkwait300-blinkon200-blinkoff150"
vim.opt.scrolloff = 8
vim.opt.colorcolumn = "100"

-- Folding (nvim-ufo)
vim.opt.foldcolumn = "1"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
-- Chevrons instead of nesting-level digits in the 1-wide fold column
vim.opt.fillchars = { foldopen = "\u{f47c}", foldclose = "\u{f460}", fold = " ", foldsep = " ", foldinner = " ", eob = " " }

-- Diagnostics: Neovim 0.11+ ships with virtual_text off, so errors are only a gutter letter
vim.diagnostic.config({
  severity_sort = true,
  virtual_text = { spacing = 2, prefix = "●" },
  float = { border = "rounded", source = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "\u{f057} ",
      [vim.diagnostic.severity.WARN] = "\u{f071} ",
      [vim.diagnostic.severity.INFO] = "\u{f05a} ",
      [vim.diagnostic.severity.HINT] = "\u{f0335} ",
    },
  },
})

-- Splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false

-- Clipboard (deferred: resolving the clipboard provider costs ~10-20ms at startup)
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

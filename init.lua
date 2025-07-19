--[[
-- Rapando's Neovim Configs.
-- This file is the entry point. All plugins and settings are in lua.
-- All configs are in the same place as the installation of the plugin.
--
--]]

-- Load lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Load general settings.
require("general.config")

-- Load Lazy
require("lazy").setup({
  spec = {
    import = "plugins"
  },
  install = { colorscheme = { "habamax" } },
  checker = { enabled = true },
})


-- Load General keybindings
require("general.keybindings")

-- Load configs
require("configs.debugging")
require("configs.floating")
require("configs.git")
require("configs.lsp")
require("configs.outline")
require("configs.themes")
require("configs.tree")

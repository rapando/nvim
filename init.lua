--[[
Load Lazy plug Manager. It allows loading settings and plugins lazilly.
--]]
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


-- Load general neovim configs
require("general.configs")

-- Load plugins lazilly
require("lazy").setup({
    spec = { import = "plugins" },
    install = { colorscheme = { "habamaz" } },
    checker = { enabled = true },
})

-- Load Keyboard Shortcuts
require("general.shortcuts")

-- Load more settings
require("general.lsp")
require("general.themes")
require("general.tree")

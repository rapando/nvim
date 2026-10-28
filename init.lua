-- Neovim Configuration
-- Modern setup with LSP, completion, and fuzzy finding

-- Leader key (before any mappings or plugins)
vim.g.mapleader = " "

require("config.options")
-- Runs before plugins so the LSP starts with the project's virtualenv
require("config.pipenv")
require("config.lazy")
require("config.autocmds")
require("config.keymaps")
-- Floating terminal with split panes (<C-\>)
require("config.floatterm").setup()

return {
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate", -- Ensures automatic updates
        config = function()
            require("mason").setup()
        end
    },
    -- Highlight the current word and line efficiently
    {
        "yamatsum/nvim-cursorline",
        event = { "BufReadPost", "BufNewFile" }, -- Load only when opening a file
        config = function()
            require("nvim-cursorline").setup({
                cursorline = {
                    enable = true,
                    timeout = 500,
                    number = false,
                },
                cursorword = {
                    enable = true,
                    min_length = 3,
                    hl = { underline = true, bg = "#3c3836" }
                }
            })
        end
    },

    -- Auto-close brackets and quotes while typing
    {
        "jiangmiao/auto-pairs",
        event = "InsertEnter", -- Load only when entering insert mode
    },

    -- LSP support for multiple languages
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        event = "BufReadPre", -- Load when opening a file
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = { "pyright" }, -- Ensure Python LSP is installed
            })
            local lspconfig = require("lspconfig")
            lspconfig.tsserver.setup({}) -- JavaScript/TypeScript LSP
            lspconfig.pyright.setup({})  -- Python LSP
        end
    },

    -- Autocompletion setup for various sources (LSP, snippets, paths, buffers)
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",          -- Load when entering insert mode
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",     -- LSP-based completion
            "onsails/lspkind-nvim",     -- Icons for completion suggestions
            "L3MON4D3/LuaSnip",         -- Snippet support
            "saadparwaiz1/cmp_luasnip", -- LuaSnip completion source
            "hrsh7th/cmp-buffer",       -- Buffer-based completion
            "hrsh7th/cmp-path",         -- Path-based completion
        },
        config = function()
            local cmp = require("cmp")
            local lspkind = require("lspkind")
            cmp.setup({
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                sources = {
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "path" },
                },
                formatting = {
                    format = lspkind.cmp_format({
                        mode = "symbol_text",
                        maxwidth = 50,
                    }),
                },
                mapping = cmp.mapping.preset.insert({
                    ["<Tab>"] = cmp.mapping.select_next_item(),
                    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                }),
            })
        end,
    },

    -- Go language support
    {
        "fatih/vim-go",
        build = ":GoUpdateBinaries",
        ft = { "go" }, -- Load only for Go files
    },

    -- Rust language support
    {
        "simrat39/rust-tools.nvim",
        ft = { "rust" }, -- Load only for Rust files
    },

    -- Treesitter for syntax highlighting and better code parsing
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = "BufReadPost",
        opts = {
            ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },
            highlight = { enable = true },
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end,
    },

    -- Code commenting support
    {
        "terrortylor/nvim-comment",
        event = "BufReadPost", -- Load when opening a file
    },
    {
        "JoosepAlviste/nvim-ts-context-commentstring",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        event = "BufReadPost",
    },

    -- JavaScript and TypeScript syntax highlighting
    {
        "yuezk/vim-js",
        ft = { "javascript", "typescript" }, -- Load only for JS/TS files
    },
    {
        "HerringtonDarkholme/yats.vim",
        ft = { "typescript" }, -- Load only for TypeScript files
    },
    {
        "maxmellon/vim-jsx-pretty",
        ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" }, -- Load only for React files
    },

    -- Markdown preview and rendering support
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        ft = { "markdown" }, -- Load only for Markdown files
        opts = {},
    },

    -- Show symbol outlines
    {
        "simrat39/symbols-outline.nvim",
        config = function()
            require("symbols-outline").setup({
                highlight_hovered_item = true,
                show_guides = true,
                auto_preview = true,
                position = 'right',
                relative_width = true,
            })
        end
    },

    -- Better syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
        build = ":TSUpdate",
    },
    -- Lint
    {
        "mfussenegger/nvim-lint",
        config = function()
            require('lint').linters_by_ft = {
                python = { 'flake8', 'pylint' },
                lua = { 'luacheck' },
                go = { 'golangci-lint' },
                rust = { 'clippy' },
            }

            -- Automatically lint on save
            vim.api.nvim_create_autocmd({ "BufWritePost" }, {
                callback = function()
                    require("lint").try_lint()
                end,
            })
        end
    }

}

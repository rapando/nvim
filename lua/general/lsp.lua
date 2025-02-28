-- Load LSP configuration
local lspconfig = require("lspconfig")

-- ========================
-- Language Server Configs
-- ========================

-- JavaScript/TypeScript
lspconfig.ts_ls.setup {}

-- Python
lspconfig.pyright.setup {}

-- Go
lspconfig.gopls.setup {
    on_attach = function(client, bufnr)
        local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
        local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

        -- Enable omnifunc completion
        buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Keybindings for LSP navigation and actions
        local opts = { noremap = true, silent = true }
        buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
        buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)          -- Jump to definition
        buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)                -- Show documentation
        buf_set_keymap('n', '<A-k>', '<Cmd>lua vim.lsp.buf.signature_help()<CR>', opts)   -- Show parameter info
        buf_set_keymap('n', '<leader>rn', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)      -- Rename symbol
        buf_set_keymap('n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)          -- Find references
        buf_set_keymap('n', '<leader>ca', '<Cmd>lua vim.lsp.buf.code_action()<CR>', opts) -- Show code actions
    end,
    flags = {
        debounce_text_changes = 150,
    }
}

-- Format command
vim.cmd [[ command! Format execute 'lua vim.lsp.buf.formatting()' ]]

-- ========================
-- Linting Configuration
-- ========================
local lint = require('lint')

-- Configure linters per filetype
require('lint').linters_by_ft = {
    go = { 'golangcilint' },
}

-- Auto-run linting on file save
vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = { "*.go", "*.py", "*.js", "*.rs", "*.c", "*.ts", "*.css", "*.html" },
    callback = function()
        lint.try_lint()
    end,
})

-- ========================
-- Auto-completion Setup
-- ========================
local cmp = require 'cmp'

cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    mapping = {
        ['<A-Space>'] = cmp.mapping.complete(),
        ['<A-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
        ['<A-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Confirm selection
        ['<Tab>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 's' }),
    },
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    }, {
        { name = 'buffer' },
    })
})

-- Enable auto-completion in command-line
cmp.setup.cmdline(':', {
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})

-- ========================
-- Rust-Specific Setup
-- ========================
local rt = require("rust-tools")
rt.setup({
    tools = {
        autoSetHints = true,
        inlay_hints = {
            show_parameter_hints = true,
            parameter_hints_prefix = "<- ",
            other_hints_prefix = "=> ",
        },
    },
    server = {
        on_attach = function(client, bufnr)
            local bufopts = { noremap = true, silent = true, buffer = bufnr }
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
            vim.keymap.set("n", "<Leader>c", rt.code_action_group.code_action_group, bufopts)
        end,
        settings = {
            ["rust-analyzer"] = {
                diagnostics = { enable = true, disabled = { "warnings" } },
                cargo = { watch = false },
                checkOnSave = { command = "clippy" },
                memory = { max = 2048 },
            },
        },
    },
})

-- ========================
-- Miscellaneous Plugins
-- ========================

-- Commenting plugin
require('nvim_comment').setup({
    hook = function()
        require('ts_context_commentstring.internal').update_commentstring()
    end,
})

-- Highlight similar symbols
require("nvim-cursorline").setup {
    cursorline = { enable = true, timeout = 1000 },
    cursorword = { enable = true, min_length = 3, hl = { underline = true } }
}

-- Markdown rendering
require('render-markdown').setup({
    render_modes = true,
    anti_conceal = { enabled = true }
})

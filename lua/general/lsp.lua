local lspconfig = require("lspconfig")

-- JS setup
lspconfig.ts_ls.setup {}

-- Python LSP
lspconfig.pyright.setup {}

-- Go LSP
lspconfig.gopls.setup {
    on_attach = function(client, bufnr)
        local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
        local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

        buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

        local opts = { noremap = true, silent = true }
        buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
        buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)    -- Equivalent of Ctrl+Click
        buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)          -- Function documentation
        buf_set_keymap('n', '<A-k>', '<Cmd>lua vim.lsp.buf.signature_help()<CR>', opts) -- Parameter info
        buf_set_keymap('n', 'gi', '<Cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        buf_set_keymap('n', '<leader>wa', '<Cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
        buf_set_keymap('n', '<leader>wr', '<Cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
        buf_set_keymap('n', '<leader>wl', '<Cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
        buf_set_keymap('n', '<leader>D', '<Cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
        buf_set_keymap('n', '<leader>rn', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)
        buf_set_keymap('n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
        buf_set_keymap('n', '<leader>ca', '<Cmd>lua vim.lsp.buf.code_action()<CR>', opts)
        buf_set_keymap('n', '<leader>e', '<Cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
        buf_set_keymap('n', '[d', '<Cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
        buf_set_keymap('n', ']d', '<Cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
        buf_set_keymap('n', '<leader>q', '<Cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
        buf_set_keymap('n', '<leader>so', [[<Cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>]], opts)
    end,

    flags = {
        debounce_text_changes = 150,
    }
}



vim.cmd [[ command! Format execute 'lua vim.lsp.buf.formatting()' ]]

-- Go Linting
require('lint').linters_by_ft = {
    go = { 'golangcilint' },
}


-- Linting for different languages
local lint = require('lint')

vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.go",
    callback = function()
        lint.try_lint()
    end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.py",
    callback = function()
        lint.try_lint()
    end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.js",
    callback = function()
        lint.try_lint()
    end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.rs",
    callback = function()
        lint.try_lint()
    end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.c",
    callback = function()
        lint.try_lint()
    end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.ts",
    callback = function()
        lint.try_lint()
    end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.css",
    callback = function()
        lint.try_lint()
    end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.html",
    callback = function()
        lint.try_lint()
    end,
})


-- CMP Configs
local cmp = require 'cmp'

cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    mapping = {
        ['<A-Space'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<A-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
        ['<A-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
        -- ['<A-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
        ['<A-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<A-y>` mapping.
        ['<A-e>'] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
        }),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ['<Tab>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 's' }),
    },
    sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
        },
        {
            { name = 'buffer' },
            { name = 'vsnip' },
        })
})

cmp.setup.cmdline('/', {
    sources = {
        { name = 'buffer' }
    }
})

cmp.setup.cmdline('?', {
    sources = {
        { name = 'buffer' }
    }
})

cmp.setup.cmdline(':', {
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})

local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
require('lspconfig')['gopls'].setup {
    capabilities = capabilities
}


-- comments settings
require('nvim_comment').setup({
    hook = function()
        require('ts_context_commentstring.internal').update_commentstring()
    end,
})

-- RUST
local rt = require("rust-tools")

-- delay alerts
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    timeout = 5000, -- 5 seconds
})

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
            -- Keybindings for LSP
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
            vim.keymap.set("n", "<Leader>c", rt.code_action_group.code_action_group, bufopts)
            vim.keymap.set("n", "<Leader>rr", rt.runnables.runnables, bufopts)
            vim.keymap.set("n", "<Leader>rf", function()
                vim.lsp.buf.format({ async = false })
            end)
            vim.keymap.set("n", "<Leader>ru", function()
                vim.lsp.buf.code_action({
                    only = { 'source.organizeImports' },
                })
            end)
        end,
        settings = {
            ["rust-analyzer"] = {
                diagnostics = {
                    enable = true,
                    disabled = { "warnings" },
                },
                cargo = { watch = false },
                checkOnSave = { command = "clippy" },
                memory = { max = 2048 },
            },
        },
    },
})



-- treesitter settings for rust and any other language
-- require("nvim-treesitter.configs").setup({
-- ensure_installed = { "rust" },
-- highlight = { enable = true },
-- })

-- Javascript
-- Coc.nvim global extensions for TypeScript, TSLint, Prettier, and more
vim.g.coc_global_extensions = {
    'coc-tslint-plugin', 'coc-tsserver', 'coc-css', 'coc-html', 'coc-json', 'coc-prettier'
}

-- note taking
require('render-markdown').setup({
    render_modes = true,
    anti_conceal = {
        enabled = true,
    }
})

-- highlight similar symbols
require("nvim-cursorline").setup {
    cursorline = {
        enable = true,
        timeout = 1000,
        number = false,
    },
    cursorword = {
        enable = true,
        min_length = 3,
        hl = { underline = true },
    }
}

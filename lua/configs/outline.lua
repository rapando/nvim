-- symbol separator
require("nvim-navic").setup({
    highlight = true,
    separator = " > ",
})


local navic = require("nvim-navic")
require("lspconfig").gopls.setup({
    on_attach = function(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
            navic.attach(client, bufnr)
        end
    end,
})

-- show breadcrumbs on statusline
require("lualine").setup({
    options = {
        theme = "auto",
        globalstatus = true,
    },
    sections = {
        lualine_c = {
            { "filename" },
            { require("nvim-navic").get_location, cond = require("nvim-navic").is_available },
        },
    },
})

--  code outliner.
require("aerial").setup({
    backends = { "lsp", "treesitter", "markdown" },
    show_guides = true,
})
vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>", { desc = "Toggle Aerial (Code Outline)" })

-- todo comments.
require("todo-comments").setup()
vim.keymap.set("n", "<leader>t", "<cmd>TodoTelescope<CR>", { desc = "Search TODOs" })

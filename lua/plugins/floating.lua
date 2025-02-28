--[[
Here lies any plugins that are floating.
--]]
return {
    {
        "Bekaboo/dropbar.nvim",
        dependencies = {
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" } -- FIXED
        }
    },
    {
        "MunifTanjim/nui.nvim",
    },
    {
        "folke/noice.nvim",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
        config = function()
            require("noice").setup({
                cmdline = {
                    enabled = true,
                    view = "cmdline_popup", -- Ensures popup appears
                },
                popupmenu = {
                    enabled = true,
                    backend = "nui",
                },
                messages = {
                    enabled = true,
                    view = "mini", -- Optional: floating mini messages
                },
                lsp = {
                    progress = { enabled = true },
                    hover = { enabled = true },
                    signature = { enabled = true },
                },
                notify = {
                    enabled = true,
                    view = "notify",
                },
                presets = {
                    bottom_search = true,   -- Bottom search
                    command_palette = true, -- Command palette view
                },
            })
        end
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {},
        keys = {
            {
                "<leader>?",
                function()
                    require("which-key").show({ global = false })
                end,
                desc = "Buffer Local Keymaps (which-key)"
            },
        },
    },
}

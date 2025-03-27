return {
    {
        "MunifTanjim/nui.nvim",
    },
    {
        "folke/noice.nvim",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		config =  function()
			require("noice").setup({
				cmdline = {
					view = "cmdline_popup",
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

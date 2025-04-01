return {
    {
        "MunifTanjim/nui.nvim",
    },
    {
        "folke/noice.nvim",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-cmdline", 
		},
		config =  function()
			
			require("noice").setup({
				cmdline = {
					view = "cmdline_popup",
				},
				views = {
				cmdline_popup = {
				  position = {
					row = 10,  -- Adjust vertical position (higher = moves down)
					col = "50%",  -- Centered horizontally
				  },
				  size = {
					width = 60,  -- Set width of popup
					height = "auto",
				  },
				},
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

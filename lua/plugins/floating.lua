return {
	{
		"MunifTanjim/nui.nvim",
	},
	{
		"rcarriga/nvim-notify",
		lazy = true,
		config = function()
			require("notify").setup({
				stages = "fade",
				timeout = 1500,
				render = "default",
				background_colour = "#000000",
				top_down = false,
			})
			vim.notify = require("notify")
		end
	},
	{
		"folke/noice.nvim",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-cmdline",
		},
		config = function()
			require("noice").setup({
				cmdline = {
					view = "cmdline_popup",
				},
				views = {
					cmdline_popup = {
						position = {
							row = 5, -- Adjust vertical position (higher = moves down)
							col = "50%", -- Centered horizontally
						},
						size = {
							width = 80, -- Set width of popup
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

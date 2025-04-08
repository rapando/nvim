return {
	{ "vim-airline/vim-airline" }, -- status line at the bottom
    { "vim-airline/vim-airline-themes" },
	{
		"lukas-reineke/virt-column.nvim",
		config = function()
			require("virt-column").setup({ char = "|", virtcolumn = "100" })
		end
	},
	-- themes
	{
		"folke/tokyonight.nvim",
		lazy = true,
		priority = 0
	},
	{
		"catppuccin/nvim",
		lazy = true,
		priority = 0
	},
	{
		"olimorris/onedarkpro.nvim",
		priority = 0,
		lazy = true
	},
	{
		"i3d/vim-jimbothemes",
		priority = 1000,
		lazy = false
	}
}

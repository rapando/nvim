return {
	{ "vim-airline/vim-airline" }, -- status line at the bottom
    { "vim-airline/vim-airline-themes" },
	{
		"lukas-reineke/virt-column.nvim",
		config = function()
			require("virt-column").setup({ char = ".", virtcolumn = "100,120" })
		end
	},
	-- themes
	{
		"folke/tokyonight.nvim",
		lazy = true, 
		priority = 1000
	},
	{
		"catppuccin/nvim",
		lazy = true,
		priority = 1000
	},
	{
		"olimorris/onedarkpro.nvim",
		priority = 1000,
		lazy = true,
	},
	{
		"i3d/vim-jimbothemes",
		priority = 1000,
		lazy = true,
	},
	{
		"sainnhe/gruvbox-material",
		priority = 1000,
		lazy = true,
	},
	{
		"Mofiqul/dracula.nvim",
		name = "chadracula",
		priority = 1000,
		lazy = true,
	}
}

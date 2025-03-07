return {
	{ "vim-airline/vim-airline" }, -- status line at the bottom
    { "vim-airline/vim-airline-themes" },
	{
		"lukas-reineke/virt-column.nvim",
		config = function()
			require("virt-column").setup({ char = "|", virtcolumn = "120" })
		end
	},
	-- themes
	{
		"navarasu/onedark.nvim",
		lazy = false,
		priority = 1000,
	},
}

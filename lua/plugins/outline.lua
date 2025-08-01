
return {
    {
        "simrat39/symbols-outline.nvim",
        config = function()
            require("symbols-outline").setup({
                    width = 15,
                })
        end,
    },
	{
		"nvim-lualine/lualine.nvim",
		dependencies=  {
			"nvim-tree/nvim-web-devicons"
		}
	},
	{
		"SmiteshP/nvim-navic",
		dependencies = {
			"neovim/nvim-lspconfig"
		}
	},
	{
		"stevearc/aerial.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter"
		}
	},
	{
		"folke/todo-comments.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim"
		}
	}
}

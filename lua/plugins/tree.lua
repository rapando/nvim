return {
	{
		"nvim-tree/nvim-tree.lua",
		require = {
			"kyazdani42/nvim-web-devicons",
		},
	},
	{
		"willothy/nvim-tree-tab-sync",
		dependencies = { "nvim-tree/nvim-tree.lua" },
		config = true,
	}
	--[[
	{
		"akinsho/bufferline.nvim",
		require = {
			"kyazdani42/nvim-web-devicons",
		},
	} ]]
}

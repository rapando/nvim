return {
    { "nvim-lua/plenary.nvim" },
    {
      "nvim-telescope/telescope.nvim",
      tag = "0.1.8",
      dependencies = { "nvim-lua/plenary.nvim" }
    },
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release"
    },
    {
        "mg979/vim-visual-multi",
        branch = "master",
        init = function()
            vim.g.VM_default_mappings = 0 
            vim.g.VM_maps = {
                ["Find Under"]          = "<leader>m",  -- multi-cursor with leader+m
                ["Find Subword Under"]  = "<leader>M"   -- optional, for subword matches 
            }
        end,
    },
	{
		"nvim-pack/nvim-spectre",
	},
	{
		 "folke/flash.nvim",
		  event = "VeryLazy",
		  ---@type Flash.Config
		  opts = {},
		  -- stylua: ignore
		  keys = {
			{ "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
			{ "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
			{ "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
			{ "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
			{ "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
		  },
	}

}

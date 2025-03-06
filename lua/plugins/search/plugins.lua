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
	}

}

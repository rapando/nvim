return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui", -- UI for debugging.
			"nvim-telescope/telescope-dap.nvim", -- Virtual text for debugging.
			"nvim-telescope/telescope-dap.nvim", -- Telescope integration
		},
		config = function()
			require("dapui").setup()
			require("nvim-dap-virtual-text").setup()
		end
	}
}

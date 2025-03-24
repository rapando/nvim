return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui", -- UI for debugging.
			"theHamsta/nvim-dap-virtual-text", -- Virtual text for debugging.
			"nvim-telescope/telescope-dap.nvim", -- Telescope integration
			"nvim-neotest/nvim-nio",
		},
		config = function()
			require("dapui").setup()
			require("nvim-dap-virtual-text").setup()
		end
	}
}

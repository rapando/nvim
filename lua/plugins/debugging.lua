return {
    {
        "mfussenegger/nvim-dap",               -- Debug Adapter Protocol
        dependencies = {
            "rcarriga/nvim-dap-ui",            -- UI for DAP
            "jay-babu/mason-nvim-dap.nvim",    -- Ensure debuggers are installed
            "williamboman/mason.nvim",         -- Package manager
            "theHamsta/nvim-dap-virtual-text", -- Virtual text in code
            "nvim-neotest/nvim-nio",
        },
        config = function()
            require("mason").setup()
            require("mason-nvim-dap").setup({
                ensure_installed = { "delve", "codelldb" }, -- Install debuggers automatically
                automatic_setup = true,
            })
        end,
    }
}

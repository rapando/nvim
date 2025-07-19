--******* DEBUGGING
local dap = require("dap")
local dapui = require("dapui")

-- Setup UI
dapui.setup()
require("nvim-dap-virtual-text").setup()

-- Open UI automatically
dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end

-- 🦦 Go Debugging (Delve)
dap.adapters.delve = {
    type = "server",
    port = "${port}",
    executable = {
        command = "dlv",
        args = { "dap", "-l", "127.0.0.1:${port}" },
    },
}

dap.configurations.go = {
    {
        type = "delve",
        name = "Debug",
        request = "launch",
        program = "${file}",
    },
}



-- C Debugging (lldb)
dap.adapters.lldb = {
    type = "executable",
    command = "/usr/bin/lldb-vscode",
    name = "lldb"
}

dap.configurations.c = {
    {
        name = "Launch",
        type = "lldb",
        request = "launch",
        program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "%{workspaceFolder}",
        stopOnEntry = false,
        args = {},
    }
}

-- 🎮 Keybindings
vim.keymap.set("n", "<leader>db", function() dap.continue() end, { desc = "Start Debugging" })
vim.keymap.set("n", "<leader>do", function() dap.step_over() end, { desc = "Step Over" })
vim.keymap.set("n", "<leader>di", function() dap.step_into() end, { desc = "Step Into" })
vim.keymap.set("n", "<leader>dx", function() dap.step_out() end, { desc = "Step Out" })
vim.keymap.set("n", "<Leader>b", function() dap.toggle_breakpoint() end, { desc = "Toggle Breakpoint" })
vim.keymap.set("n", "<Leader>dr", function() dap.repl.open() end, { desc = "Open Debug Console" })
vim.keymap.set("n", "<Leader>du", function() dapui.toggle() end, { desc = "Toggle DAP UI" })

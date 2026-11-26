return {
  -- Debugger (Go, Python, C/C++)
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "leoluz/nvim-dap-go",
      "mfussenegger/nvim-dap-python",
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "DAP continue" },
      { "<leader>ds", function() require("dap").step_over() end, desc = "Step over" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
      { "<leader>do", function() require("dap").step_out() end, desc = "Step out" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()
      require("dap-go").setup()
      -- debugpy adapter: dedicated ~/.virtualenvs/debugpy venv (see README), a `debugpy-adapter` on PATH,
      -- else python3 (the active venv's, if it has debugpy). The debuggee runs with the active venv's python.
      local debugpy_python = vim.fn.expand("~/.virtualenvs/debugpy/bin/python")
      require("dap-python").setup(
        vim.fn.executable(debugpy_python) == 1 and debugpy_python
          or vim.fn.executable("debugpy-adapter") == 1 and "debugpy-adapter"
          or "python3"
      )

      -- C / C++ through lldb-dap (ships with LLVM: `brew install llvm`, or recent Xcode)
      local lldb = vim.fn.exepath("lldb-dap")
      if lldb == "" then
        for _, path in ipairs({ "/opt/homebrew/opt/llvm/bin/lldb-dap", "/usr/local/opt/llvm/bin/lldb-dap" }) do
          if vim.fn.executable(path) == 1 then
            lldb = path
            break
          end
        end
      end
      if lldb == "" then
        lldb = vim.fn.glob("/usr/lib/llvm-*/bin/lldb-dap", false, true)[1] or "" -- Debian/Ubuntu
      end
      if lldb == "" then
        local out = vim.system({ "xcrun", "-f", "lldb-dap" }, { text = true }):wait()
        lldb = out.code == 0 and vim.trim(out.stdout or "") or ""
      end
      if lldb == "" then
        lldb = vim.fn.exepath("lldb-vscode") -- older LLVM name
      end
      if lldb ~= "" then
        dap.adapters.lldb = { type = "executable", command = lldb, name = "lldb" }
        local launch = {
          {
            name = "Launch executable",
            type = "lldb",
            request = "launch",
            program = function()
              return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
            args = {},
          },
        }
        dap.configurations.c, dap.configurations.cpp = launch, launch
      end

      require("config.explorer_debug").attach() -- call trail + inline values when stopped

      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
    end,
  },
}

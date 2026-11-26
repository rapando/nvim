return {
  -- Neotest (inline test runner)
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "fredrikaverpil/neotest-golang",
      "nvim-neotest/neotest-python",
      "orjangj/neotest-ctest",
    },
    keys = {
      { "<leader>kd", function() require("config.explorer_debug").debug_last_failure() end, desc = "Debug last failing test" },
      { "<leader>tt", function() require("neotest").run.run() end, desc = "Run nearest test" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run file tests" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle test summary" },
      { "<leader>to", function() require("neotest").output.open({ enter = true }) end, desc = "Test output" },
    },
    config = function()
      -- C/C++ tests run through CTest (gtest, Catch2, doctest, CppUTest); the debug strategy uses the
      -- "lldb" adapter defined in debug.lua
      require("neotest-ctest").setup({
        dap_adapter = "lldb",
        -- foo_test.cpp, foo_tests.cpp, test_foo.cpp, or any C++ file under a tests/ directory
        is_test_file = function(file)
          local stem, ext = file:match("([^/]+)%.(%w+)$")
          if not stem or not vim.list_contains({ "cpp", "cc", "cxx" }, ext) then
            return false
          end
          return stem:match("_tests?$") ~= nil or stem:match("^tests?_") ~= nil or file:match("/tests?/") ~= nil
        end,
      })
      -- A debug run has no CTest report to read; without this neotest-ctest raises an error when the
      -- debugger exits
      local ctest = require("neotest-ctest")
      local ctest_results = ctest.results
      ctest.results = function(...)
        local ok, results = pcall(ctest_results, ...)
        return ok and results or {}
      end
      require("neotest").setup({
        consumers = { code_explorer = require("config.explorer_debug").consumer },
        adapters = {
          require("neotest-golang")({}),
          require("neotest-python")({ runner = "pytest" }),
          require("neotest-ctest"),
        },
      })
    end,
  },
}

return {
  -- Auto-formatting on save
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>cf",
        function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
        mode = { "n", "v" },
        desc = "Format file",
      },
    },
    opts = {
      formatters_by_ft = {
        go = { "goimports", "golines" },
        python = { "ruff_organize_imports", "ruff_format" },
        lua = { "stylua" },
        markdown = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
      },
    },
  },
}

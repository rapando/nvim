return {
  -- LSP
  {
    "neovim/nvim-lspconfig",
    event = "FileType",
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      -- Go
      vim.lsp.config("gopls", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })
      vim.lsp.enable("gopls")

      -- Python (pyright for types/navigation, ruff for lint + quick fixes)
      vim.lsp.config("pyright", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
        before_init = function(_, config)
          -- Use the active venv (set by the Pipfile loader above), else whatever python3 is on PATH
          local venv = vim.env.VIRTUAL_ENV
          config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
            python = { pythonPath = venv and (venv .. "/bin/python") or vim.fn.exepath("python3") },
          })
        end,
      })
      vim.lsp.config("ruff", {
        on_attach = function(client)
          client.server_capabilities.hoverProvider = false -- leave hover to pyright
        end,
      })
      vim.lsp.enable({ "pyright", "ruff" })

      -- Buffer-local keybindings, only where a server is attached (K is defined below so it
      -- can peek folds first). `gr` is left alone: it's the prefix of the built-in grr/gra/grn/gri.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp_keymaps", { clear = true }),
        callback = function(args)
          local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = desc })
          end
          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("<leader>cr", vim.lsp.buf.rename, "Rename")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
        end,
      })
    end,
  },
}

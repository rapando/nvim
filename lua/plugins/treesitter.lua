return {
  -- Treesitter (main branch: parsers are compiled with the tree-sitter CLI)
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")
      ts.install({
        "go", "gomod", "gosum", "gowork", "python", "toml", "lua", "vim", "vimdoc", "query",
        "markdown", "markdown_inline", "json", "sql", "yaml", "bash", "html",
      })

      local available = {}
      for _, lang in ipairs(ts.get_available()) do
        available[lang] = true
      end

      local function attach(buf, lang)
        if not pcall(vim.treesitter.start, buf, lang) then
          return
        end
        if lang ~= "markdown" then
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter_attach", { clear = true }),
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match)
          if not lang or not available[lang] then
            return
          end
          if vim.list_contains(ts.get_installed(), lang) then
            attach(args.buf, lang)
          else
            -- auto-install missing parsers, then attach
            ts.install(lang):await(vim.schedule_wrap(function()
              if vim.api.nvim_buf_is_valid(args.buf) then
                attach(args.buf, lang)
              end
            end))
          end
        end,
      })
    end,
  },
}

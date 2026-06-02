-- Neovim Configuration
-- Modern setup with LSP, completion, and fuzzy finding

-- Leader key
vim.g.mapleader = " "

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.softtabstop = 4
vim.opt.smartindent = true
vim.opt.wrap = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.termguicolors = true
vim.opt.guicursor = "n-v-c-r:under-blinkwait700-blinkon400-blinkoff250,i:under-blinkwait700-blinkon400-blinkoff250"
vim.opt.scrolloff = 8
vim.opt.colorcolumn = "100"

-- Splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false

-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
  -- Theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({ flavour = "mocha" })
      vim.cmd([[colorscheme catppuccin]])
    end,
  },

  -- Additional themes (lazy loaded)
  { "folke/tokyonight.nvim",   lazy = true },
  { "doums/darcula",           lazy = true },
  { "rose-pine/neovim",        name = "rose-pine", lazy = true },
  { "rebelot/kanagawa.nvim",   lazy = true },
  { "sainnhe/gruvbox-material", lazy = true },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
    },
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")

      telescope.setup({
        defaults = {
          previewer = true,
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              preview_width = 0.55,
            },
          },
          preview = {
            treesitter = false,
          },
        },
        pickers = {
          find_files = {
            previewer = true,
            hidden = true,
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      })

      telescope.load_extension("fzf")

      -- Keybindings
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep (project)" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
      vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "Search in file" })
    end,
  },

  -- Build fzf native
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    cond = function()
      return vim.fn.executable("make") == 1
    end,
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Go
      vim.lsp.config("gopls", {
        capabilities = capabilities,
      })
      vim.lsp.enable("gopls")

      -- C
      vim.lsp.config("clangd", {
        capabilities = capabilities,
      })
      vim.lsp.enable("clangd")

      -- Python
      vim.lsp.config("pyright", {
        capabilities = capabilities,
        settings = {
          python = {
            venvPath = vim.fn.getcwd(),
          },
        },
      })
      vim.lsp.enable("pyright")

      -- Keybindings
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
      vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Go to references" })
      vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
      vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostics" })
    end,
  },

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- Auto-closing brackets
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({
        check_ts = true,
        map_cr = true,
        map_bs = true,
      })
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- Auto-formatting on save
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local conform = require("conform")

      conform.setup({
        formatters_by_ft = {
          go = { "goimports", "golines" },
          python = { "black", "isort" },
          c = { "clang-format" },
          lua = { "stylua" },
          markdown = { "prettier" },
          json = { "prettier" },
          yaml = { "prettier" },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })

      vim.keymap.set({ "n", "v" }, "<leader>cf", function()
        conform.format({ async = true, lsp_fallback = true })
      end, { desc = "Format file" })
    end,
  },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = {
          width = 30,
        },
        filters = {
          dotfiles = false,
          git_ignored = false,
        },
      })
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
    end,
  },

  -- Lazygit integration
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },

  -- Markdown inline rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown" },
    config = function()
      require("render-markdown").setup({})
    end,
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local ok, ts = pcall(require, "nvim-treesitter.configs")
      if ok then
        ts.setup({
          ensure_installed = { "go", "c", "python", "lua", "vim", "markdown", "json" },
          auto_install = true,
          highlight = {
            enable = true,
            additional_vim_regex_highlighting = { "markdown" },
          },
          indent = {
            enable = true,
          },
        })
      end
    end,
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "catppuccin",
        },
      })
    end,
  },

  -- Floating UI for vim.ui.select and vim.ui.input
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    config = function()
      require("dressing").setup({
        select = {
          backend = { "telescope", "builtin" },
          telescope = require("telescope.themes").get_dropdown({ previewer = false }),
        },
        input = {
          relative = "editor",
          prefer_width = 0.4,
          win_options = { winblend = 0 },
        },
      })
    end,
  },

  -- Virtual environment support for Python
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = { "neovim/nvim-lspconfig", "mfussenegger/nvim-dap-python" },
    config = function()
      require("venv-selector").setup({
        auto_initialize = true,
      })
      vim.keymap.set("n", "<leader>vs", ":VenvSelect<CR>", { desc = "Select virtual environment" })
    end,
  },
})

-- Auto-cd to project root when opening files
local function find_git_root()
  local git_dir = vim.fn.finddir(".git", vim.fn.expand("%:p:h") .. ";")
  if git_dir ~= "" then
    return vim.fn.fnamemodify(git_dir, ":p:h:h")
  end
  return vim.fn.getcwd()
end

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    local git_root = find_git_root()
    if git_root ~= vim.fn.getcwd() then
      vim.fn.chdir(git_root)
    end
  end,
})

-- Python pipenv support
local function load_pipenv()
  local pipenv_dir = vim.fn.getcwd()
  local pipenv_file = pipenv_dir .. "/Pipfile"
  if vim.fn.filereadable(pipenv_file) == 1 then
    local venv_path = vim.fn.system("pipenv --venv 2>/dev/null")
    if vim.v.shell_error == 0 then
      venv_path = vim.fn.trim(venv_path)
      vim.env.VIRTUAL_ENV = venv_path
      vim.env.PATH = venv_path .. "/bin:" .. vim.env.PATH
    end
  end
end

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.py",
  callback = load_pipenv,
})

-- Split navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom split" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top split" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })

vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Split horizontally" })
vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Split vertically" })
vim.keymap.set("n", "<leader>sc", "<C-w>c", { desc = "Close split" })

-- Theme picker
local themes = {
  { label = "Catppuccin Latte",     cs = "catppuccin-latte",     lualine = "catppuccin" },
  { label = "Catppuccin Frappe",    cs = "catppuccin-frappe",    lualine = "catppuccin" },
  { label = "Catppuccin Macchiato", cs = "catppuccin-macchiato", lualine = "catppuccin" },
  { label = "Catppuccin Mocha",     cs = "catppuccin-mocha",     lualine = "catppuccin" },
  { label = "Tokyo Night",          cs = "tokyonight",           lualine = "tokyonight" },
  { label = "Tokyo Night Storm",    cs = "tokyonight-storm",     lualine = "tokyonight" },
  { label = "Tokyo Night Moon",     cs = "tokyonight-moon",      lualine = "tokyonight" },
  { label = "Tokyo Night Day",      cs = "tokyonight-day",       lualine = "tokyonight" },
  { label = "Darcula",              cs = "darcula",              lualine = "auto" },
  { label = "Rose Pine",            cs = "rose-pine",            lualine = "rose-pine" },
  { label = "Rose Pine Moon",       cs = "rose-pine-moon",       lualine = "rose-pine" },
  { label = "Rose Pine Dawn",       cs = "rose-pine-dawn",       lualine = "rose-pine" },
  { label = "Kanagawa Wave",        cs = "kanagawa-wave",        lualine = "kanagawa" },
  { label = "Kanagawa Dragon",      cs = "kanagawa-dragon",      lualine = "kanagawa" },
  { label = "Kanagawa Lotus",       cs = "kanagawa-lotus",       lualine = "kanagawa" },
  { label = "Gruvbox Material",     cs = "gruvbox-material",     lualine = "gruvbox_material" },
}

vim.keymap.set("n", "<leader>th", function()
  local original_cs = vim.g.colors_name
  local original_lualine = require("lualine").get_config().options.theme
  local confirmed = false

  local function apply_theme(t)
    pcall(vim.cmd, "colorscheme " .. t.cs)
    pcall(require("lualine").setup, { options = { theme = t.lualine } })
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  pickers.new({}, {
    prompt_title = "Select Theme",
    finder = finders.new_table({
      results = themes,
      entry_maker = function(t)
        return { value = t, display = t.label, ordinal = t.label }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      local function preview()
        local sel = action_state.get_selected_entry()
        if sel then apply_theme(sel.value) end
      end

      local function move_next()
        actions.move_selection_next(prompt_bufnr)
        preview()
      end
      local function move_prev()
        actions.move_selection_previous(prompt_bufnr)
        preview()
      end

      map("i", "<Down>", move_next)
      map("i", "<Up>", move_prev)
      map("i", "<C-n>", move_next)
      map("i", "<C-p>", move_prev)
      map("n", "j", move_next)
      map("n", "k", move_prev)

      actions.select_default:replace(function()
        local sel = action_state.get_selected_entry()
        if sel then
          confirmed = true
          apply_theme(sel.value)
        end
        actions.close(prompt_bufnr)
      end)

      local function cancel()
        actions.close(prompt_bufnr)
        if not confirmed then
          pcall(vim.cmd, "colorscheme " .. original_cs)
          pcall(require("lualine").setup, { options = { theme = original_lualine } })
        end
      end

      map("i", "<Esc>", cancel)
      map("n", "<Esc>", cancel)
      map("i", "<C-c>", cancel)
      map("n", "q", cancel)

      return true
    end,
  }):find()
end, { desc = "Theme picker" })

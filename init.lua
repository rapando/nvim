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
vim.opt.guicursor = "n-v-c-sm-o-r-cr-ve:hor20,i-ci:hor20-blinkwait300-blinkon200-blinkoff150"
vim.api.nvim_create_autocmd("VimLeave", {
  callback = function() io.write("\27[0 q") end,
})
vim.opt.scrolloff = 8
vim.opt.colorcolumn = "100"

-- Folding (nvim-ufo)
vim.opt.foldcolumn = "1"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true

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
  -- Default theme
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    config = function()
      require("rose-pine").setup({ variant = "moon" })
      vim.cmd([[colorscheme rose-pine]])
    end,
  },

  -- Additional themes (lazy loaded)
  { "catppuccin/nvim",                name = "catppuccin", lazy = true },
  { "folke/tokyonight.nvim",          lazy = true },
  { "doums/darcula",                  lazy = true },
  { "rebelot/kanagawa.nvim",          lazy = true },
  { "sainnhe/gruvbox-material",       lazy = true },
  { "EdenEast/nightfox.nvim",         lazy = true },
  { "navarasu/onedark.nvim",          lazy = true },
  { "Mofiqul/dracula.nvim",           lazy = true },
  { "sainnhe/everforest",             lazy = true },
  { "shaunsingh/nord.nvim",           lazy = true },
  { "nyoom-engineering/oxocarbon.nvim", lazy = true },

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
          ensure_installed = { "go", "c", "python", "lua", "vim", "markdown", "json", "sql" },
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
    dependencies = { "nvim-tree/nvim-web-devicons", "rose-pine/neovim" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "rose-pine",
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

  -- Debugger (Go, Python, C)
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "leoluz/nvim-dap-go",
      "mfussenegger/nvim-dap-python",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()
      require("dap-go").setup()
      require("dap-python").setup("python3")

      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
      vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "DAP continue" })
      vim.keymap.set("n", "<leader>ds", dap.step_over, { desc = "Step over" })
      vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step into" })
      vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "Step out" })
      vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Toggle DAP UI" })
    end,
  },

  -- Git signs & inline blame
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local gs = require("gitsigns")
      gs.setup({
        signs = {
          add          = { text = "▎" },
          change       = { text = "▎" },
          delete       = { text = "" },
          topdelete    = { text = "" },
          changedelete = { text = "▎" },
        },
      })
      vim.keymap.set("n", "]h", gs.next_hunk, { desc = "Next hunk" })
      vim.keymap.set("n", "[h", gs.prev_hunk, { desc = "Prev hunk" })
      vim.keymap.set("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
      vim.keymap.set("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
      vim.keymap.set("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
      vim.keymap.set("n", "<leader>gb", gs.toggle_current_line_blame, { desc = "Toggle line blame" })
    end,
  },

  -- Which-key (shows available keybindings)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup()
    end,
  },

  -- Harpoon v2 (file bookmarks)
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()
      vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = "Harpoon add file" })
      vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu" })
      vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "Harpoon file 1" })
      vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "Harpoon file 2" })
      vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "Harpoon file 3" })
      vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "Harpoon file 4" })
    end,
  },

  -- Flash (2-keystroke jump anywhere)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    config = function()
      require("flash").setup()
      vim.keymap.set({ "n", "x", "o" }, "s", function() require("flash").jump() end, { desc = "Flash jump" })
      vim.keymap.set({ "n", "x", "o" }, "S", function() require("flash").treesitter() end, { desc = "Flash treesitter" })
    end,
  },

  -- Surround (ys/cs/ds)
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup()
    end,
  },

  -- Commenting (gcc / gc)
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("Comment").setup()
    end,
  },

  -- Go extra tooling
  {
    "ray-x/go.nvim",
    dependencies = { "ray-x/guihua.lua", "neovim/nvim-lspconfig", "nvim-treesitter/nvim-treesitter" },
    ft = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()',
    config = function()
      require("go").setup()
      vim.keymap.set("n", "<leader>gt", "<cmd>GoTest<CR>", { desc = "Go test" })
      vim.keymap.set("n", "<leader>gf", "<cmd>GoFillStruct<CR>", { desc = "Go fill struct" })
      vim.keymap.set("n", "<leader>gi", "<cmd>GoImpl<CR>", { desc = "Go implement interface" })
      vim.keymap.set("n", "<leader>gat", "<cmd>GoAddTag<CR>", { desc = "Go add struct tags" })
    end,
  },

  -- clangd extensions (C inlay hints)
  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp" },
    config = function()
      require("clangd_extensions").setup({
        inlay_hints = { inline = true },
      })
    end,
  },

  -- Neotest (inline test runner)
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-go",
      "nvim-neotest/neotest-python",
    },
    config = function()
      local neotest = require("neotest")
      neotest.setup({
        adapters = {
          require("neotest-go"),
          require("neotest-python"),
        },
      })
      vim.keymap.set("n", "<leader>tt", function() neotest.run.run() end, { desc = "Run nearest test" })
      vim.keymap.set("n", "<leader>tf", function() neotest.run.run(vim.fn.expand("%")) end, { desc = "Run file tests" })
      vim.keymap.set("n", "<leader>ts", function() neotest.summary.toggle() end, { desc = "Toggle test summary" })
      vim.keymap.set("n", "<leader>to", function() neotest.output.open({ enter = true }) end, { desc = "Test output" })
    end,
  },

  -- Trouble (diagnostics panel)
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("trouble").setup()
      vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Toggle trouble" })
      vim.keymap.set("n", "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "Buffer diagnostics" })
      vim.keymap.set("n", "<leader>xl", "<cmd>Trouble loclist toggle<CR>", { desc = "Location list" })
      vim.keymap.set("n", "<leader>xq", "<cmd>Trouble qflist toggle<CR>", { desc = "Quickfix list" })
    end,
  },

  -- Toggleterm (floating terminal)
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<C-\>]],
        direction = "float",
        float_opts = { border = "curved" },
      })
    end,
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("ibl").setup({
        indent = { char = "│" },
        scope = { enabled = true },
      })
    end,
  },

  -- Noice (prettier cmdline & notifications)
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    config = function()
      require("noice").setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
        },
      })
    end,
  },

  -- Smooth scrolling
  {
    "karb94/neoscroll.nvim",
    config = function()
      require("neoscroll").setup()
    end,
  },

  -- Startup dashboard
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local dashboard = require("alpha.themes.dashboard")
      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file",    "<cmd>Telescope find_files<CR>"),
        dashboard.button("r", "  Recent files", "<cmd>Telescope oldfiles<CR>"),
        dashboard.button("g", "  Live grep",    "<cmd>Telescope live_grep<CR>"),
        dashboard.button("l", "  Lazy",         "<cmd>Lazy<CR>"),
        dashboard.button("q", "  Quit",         "<cmd>qa<CR>"),
      }
      require("alpha").setup(dashboard.config)
    end,
  },

  -- Fun
  {
    "eandrju/cellular-automaton.nvim",
    cmd = "CellularAutomaton",
    keys = {
      { "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>", desc = "Make it rain" },
      { "<leader>ml", "<cmd>CellularAutomaton game_of_life<CR>", desc = "Game of life" },
    },
  },

  -- TODO / FIXME / NOTE highlights
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("todo-comments").setup()
      vim.keymap.set("n", "]t", function() require("todo-comments").jump_next() end, { desc = "Next TODO" })
      vim.keymap.set("n", "[t", function() require("todo-comments").jump_prev() end, { desc = "Prev TODO" })
      vim.keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<CR>", { desc = "Find TODOs" })
    end,
  },

  -- Highlight other uses of word under cursor
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("illuminate").configure({
        delay = 200,
        large_file_cutoff = 2000,
      })
    end,
  },

  -- Undo history tree
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    keys = {
      { "<leader>u", "<cmd>UndotreeToggle<CR>", desc = "Toggle undotree" },
    },
  },

  -- Project-wide find & replace
  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>sr", function() require("spectre").open() end, desc = "Search & replace" },
      { "<leader>sw", function() require("spectre").open_visual({ select_word = true }) end, desc = "Replace word under cursor" },
    },
  },

  -- Better folding
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    config = function()
      require("ufo").setup({
        provider_selector = function()
          return { "treesitter", "indent" }
        end,
      })
      vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
      vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
    end,
  },

  -- Buffer tabs
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          diagnostics = "nvim_lsp",
          offsets = {
            { filetype = "NvimTree", text = "Files", separator = true },
          },
        },
      })
      vim.keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Prev buffer" })
      vim.keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
      vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Close buffer" })
    end,
  },

  -- Code outline / symbols panel
  {
    "stevearc/aerial.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    config = function()
      require("aerial").setup({
        on_attach = function(bufnr)
          vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr, desc = "Aerial prev symbol" })
          vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr, desc = "Aerial next symbol" })
        end,
      })
      vim.keymap.set("n", "<leader>as", "<cmd>AerialToggle!<CR>", { desc = "Toggle symbols outline" })
    end,
  },

  -- Breadcrumbs in winbar
  {
    "utilyre/barbecue.nvim",
    name = "barbecue",
    version = "*",
    dependencies = { "SmiteshP/nvim-navic", "nvim-tree/nvim-web-devicons" },
    config = function()
      require("barbecue").setup({
        attach_navic = false, -- attached manually via LspAttach autocmd
      })
    end,
  },

  -- Inline color preview (#hex, rgb(), etc.)
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("colorizer").setup({
        user_default_options = {
          RGB = true,
          RRGGBB = true,
          names = false,
          css = true,
          mode = "background",
        },
      })
    end,
  },

  -- Claude AI (avante.nvim) — set ANTHROPIC_API_KEY in your shell
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false,
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = { file_types = { "markdown", "Avante" } },
        ft = { "markdown", "Avante" },
      },
    },
    opts = {
      provider = "claude",
      providers = {
        claude = {
          endpoint = "https://api.anthropic.com",
          model = "claude-sonnet-4-6",
          timeout = 30000,
          extra_request_body = {
            temperature = 0,
            max_tokens = 8192,
          },
        },
      },
    },
  },

  -- OpenCode AI agent — install CLI: brew install opencode
  {
    "nickjvandyke/opencode.nvim",
    version = "*",
    config = function()
      vim.g.opencode_opts = {}
      vim.o.autoread = true
      vim.keymap.set({ "n", "x" }, "<leader>oa", function()
        require("opencode").ask("@this: ")
      end, { desc = "Ask OpenCode" })
      vim.keymap.set({ "n", "x" }, "<leader>os", function()
        require("opencode").select()
      end, { desc = "Select OpenCode action" })
      vim.keymap.set({ "n", "x" }, "go", function()
        return require("opencode").operator("@this ")
      end, { desc = "Append range to OpenCode", expr = true })
      vim.keymap.set("n", "goo", function()
        return require("opencode").operator("@this ") .. "_"
      end, { desc = "Append line to OpenCode", expr = true })
      vim.keymap.set("n", "<S-C-u>", function()
        require("opencode").command("session.half.page.up")
      end, { desc = "Scroll OpenCode up" })
      vim.keymap.set("n", "<S-C-d>", function()
        require("opencode").command("session.half.page.down")
      end, { desc = "Scroll OpenCode down" })
    end,
  },

  -- Animated pets at the bottom
  {
    "giusgad/pets.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "edluffy/hologram.nvim" },
    config = function()
      require("pets").setup({
        row = 1,
        col = 0,
        speed_multiplier = 1,
        default_pet = "dog",
        default_style = "brown",
        random = true,
        death_animation = true,
      })
      vim.keymap.set("n", "<leader>pa", function()
        local pet_type = vim.fn.input("Pet type (dog/slime/cockatiel/zappy/rocky/clippy/crab/rubber-duck/snake): ")
        if pet_type == "" then return end
        local pet_style = vim.fn.input("Pet style (e.g. dog: beige/black/brown/gray): ")
        if pet_style == "" then return end
        local pet_name = vim.fn.input("Pet name: ")
        if pet_name == "" then return end
        vim.cmd("PetsNewCustom " .. pet_type .. " " .. pet_style .. " " .. pet_name)
      end, { desc = "New pet" })
      vim.keymap.set("n", "<leader>pk", "<cmd>PetsKillAll<CR>", { desc = "Kill all pets" })
      vim.keymap.set("n", "<leader>ps", "<cmd>PetsList<CR>", { desc = "List pets" })
    end,
  },
})

-- Auto-cd to project root when opening files
local function find_git_root()
  local path = vim.fn.expand("%:p:h")
  if path == "" then return vim.fn.getcwd() end
  local git_dir = vim.fn.finddir(".git", path .. ";")
  if git_dir ~= "" then
    return vim.fn.fnamemodify(git_dir, ":p:h:h")
  end
  return vim.fn.getcwd()
end

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    local git_root = find_git_root()
    if git_root ~= vim.fn.getcwd() then
      pcall(vim.fn.chdir, git_root)
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

-- Attach nvim-navic on LSP connect (powers barbecue breadcrumbs)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then
      pcall(require("nvim-navic").attach, client, args.buf)
    end
  end,
})

-- K: peek folded lines first, fall back to LSP hover
vim.keymap.set("n", "K", function()
  local ok, ufo = pcall(require, "ufo")
  if ok then
    local winid = ufo.peekFoldedLinesUnderCursor()
    if winid then return end
  end
  vim.lsp.buf.hover()
end, { desc = "Hover / peek fold" })

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
  { label = "Nightfox",             cs = "nightfox",             lualine = "nightfox" },
  { label = "Dayfox",               cs = "dayfox",               lualine = "dayfox" },
  { label = "Dawnfox",              cs = "dawnfox",              lualine = "dawnfox" },
  { label = "Duskfox",              cs = "duskfox",              lualine = "duskfox" },
  { label = "Nordfox",              cs = "nordfox",              lualine = "nordfox" },
  { label = "Carbonfox",            cs = "carbonfox",            lualine = "carbonfox" },
  { label = "Terafox",              cs = "terafox",              lualine = "terafox" },
  { label = "OneDark",              cs = "onedark",              lualine = "onedark" },
  { label = "Dracula",              cs = "dracula",              lualine = "dracula-nvim" },
  { label = "Everforest",           cs = "everforest",           lualine = "everforest" },
  { label = "Nord",                 cs = "nord",                 lualine = "nord" },
  { label = "Oxocarbon",            cs = "oxocarbon",            lualine = "auto" },
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

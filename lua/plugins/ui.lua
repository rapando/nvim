return {
  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons", "rose-pine/neovim" },
    opts = {
      options = {
        theme = "auto", -- follow whichever colorscheme is active
        globalstatus = true,
      },
      sections = {
        lualine_x = {
          {
            function() return "\u{e73c} " .. vim.fs.basename(vim.env.VIRTUAL_ENV) end,
            cond = function() return vim.env.VIRTUAL_ENV ~= nil end,
          },
          "lsp_status",
          "filetype",
        },
      },
      -- Open buffers, since <S-h>/<S-l> cycle them but nothing shows which are open
      tabline = {
        lualine_a = {
          {
            "buffers",
            show_filename_only = true,
            symbols = { alternate_file = "" },
            -- lualine always draws the focused buffer, even unlisted panels; name them readably
            filetype_names = {
              NvimTree = "Explorer",
              TelescopePrompt = "Telescope",
              trouble = "Trouble",
              aerial = "Outline",
              toggleterm = "Terminal",
              lazy = "Lazy",
              appearance = "Appearance",
            },
          },
        },
      },
    },
  },

  -- Floating cmdline for ":" (messages/notifications left on the defaults)
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      cmdline = {
        enabled = true,
        view = "cmdline_popup",
      },
      views = {
        cmdline_popup = {
          position = {
            row = 3,
            col = "50%",
          },
          size = {
            width = 60,
            height = "auto",
          },
        },
      },
      messages = { enabled = false },
      popupmenu = { enabled = false },
      notify = { enabled = false },
      lsp = {
        progress = { enabled = false }, -- pyright reports progress on every edit, stacking up messages
        hover = { enabled = false },
        signature = { enabled = false },
      },
    },
  },

  -- Which-key (shows available keybindings)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>a", group = "outline" },
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>d", group = "debug" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>h", group = "harpoon" },
        { "<leader>m", group = "markdown" },
        { "<leader>s", group = "search/replace" },
        { "<leader>t", group = "test" },
        { "<leader>u", group = "ui" },
        { "<leader>w", group = "window" },
        { "<leader>x", group = "diagnostics" },
      },
    },
  },

  -- Trouble (diagnostics panel)
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Toggle trouble" },
      { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer diagnostics" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<CR>", desc = "Location list" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<CR>", desc = "Quickfix list" },
    },
  },

  -- Toggleterm (floating terminal)
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = "ToggleTerm",
    keys = { { [[<C-\>]], desc = "Toggle terminal" } },
    opts = {
      open_mapping = [[<C-\>]],
      direction = "float",
      float_opts = { border = "curved" },
    },
  },

  -- TODO / FIXME / NOTE highlights
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next TODO" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Prev TODO" },
      { "<leader>ft", "<cmd>TodoTelescope<CR>", desc = "Find TODOs" },
    },
  },

  -- Highlight other uses of word under cursor
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("illuminate").configure({
        delay = 200,
        large_file_cutoff = 2000,
        filetypes_denylist = { "NvimTree", "TelescopePrompt", "aerial", "Trouble", "markdown" },
      })
    end,
  },
}

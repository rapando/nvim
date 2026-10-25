return {
  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    version = "*",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
    },
    keys = {
      { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Find files" },
      { "<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Live grep (project)" },
      { "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Find buffers" },
      { "<leader>fh", function() require("telescope.builtin").help_tags() end, desc = "Help tags" },
      { "<leader>/", function() require("telescope.builtin").current_buffer_fuzzy_find() end, desc = "Search in file" },
    },
    config = function()
      local telescope = require("telescope")

      telescope.setup({
        defaults = {
          previewer = true,
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              preview_width = 0.55,
            },
          },
        },
        pickers = {
          find_files = {
            previewer = true,
            -- --hidden makes fd walk .git/ too; exclude it explicitly
            find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" },
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

      pcall(telescope.load_extension, "fzf")
    end,
  },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeFindFile" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle file explorer" },
    },
    init = function()
      -- Open the explorer on startup only for `nvim` / `nvim <dir>`, not `nvim <file>`
      vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("nvim_tree_autoopen", { clear = true }),
        callback = function(data)
          local is_dir = vim.fn.isdirectory(data.file) == 1
          local no_args = data.file == "" and vim.bo[data.buf].buftype == ""
          if not is_dir and not no_args then
            return
          end
          if is_dir then
            vim.cmd.cd(data.file)
            -- Replace the empty directory buffer with a scratch one
            vim.cmd.enew()
            vim.cmd.bwipeout(data.buf)
          end
          require("nvim-tree.api").tree.open()
        end,
      })
    end,
    opts = {
      view = {
        width = 30,
      },
      filters = {
        dotfiles = false,
        git_ignored = false,
      },
    },
    config = function(_, opts)
      require("nvim-tree").setup(opts)
      -- Open newly created files (`a` in the tree) in the editor window, so you don't keep
      -- typing into the unnamed scratch buffer (no filetype -> no highlighting, :w fails)
      local api = require("nvim-tree.api")
      api.events.subscribe(api.events.Event.FileCreated, function(data)
        vim.schedule(function()
          vim.cmd.wincmd("p")
          if vim.bo.filetype == "NvimTree" then
            vim.cmd.vsplit()
          end
          vim.cmd.edit(vim.fn.fnameescape(data.fname))
        end)
      end)
    end,
  },

  -- Harpoon v2 (file bookmarks)
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ha", function() require("harpoon"):list():add() end, desc = "Harpoon add file" },
      {
        "<leader>hh",
        function()
          local harpoon = require("harpoon")
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = "Harpoon menu",
      },
      { "<leader>1", function() require("harpoon"):list():select(1) end, desc = "Harpoon file 1" },
      { "<leader>2", function() require("harpoon"):list():select(2) end, desc = "Harpoon file 2" },
      { "<leader>3", function() require("harpoon"):list():select(3) end, desc = "Harpoon file 3" },
      { "<leader>4", function() require("harpoon"):list():select(4) end, desc = "Harpoon file 4" },
    },
    config = function()
      require("harpoon"):setup()
    end,
  },

  -- Flash (2-keystroke jump anywhere)
  {
    "folke/flash.nvim",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
    },
  },

  -- Code outline / symbols panel
  {
    "stevearc/aerial.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    event = { "BufReadPost", "BufNewFile" },
    keys = {
      { "<leader>as", "<cmd>AerialToggle!<CR>", desc = "Toggle symbols outline" },
    },
    opts = {
      on_attach = function(bufnr)
        vim.keymap.set("n", "[[", "<cmd>AerialPrev<CR>", { buffer = bufnr, desc = "Aerial prev symbol" })
        vim.keymap.set("n", "]]", "<cmd>AerialNext<CR>", { buffer = bufnr, desc = "Aerial next symbol" })
      end,
    },
  },
}

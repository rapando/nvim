# Plugins

This project uses [lazy.nvim](https://github.com/folke/lazy.nvim) as the plugin manager. Below is a table of all configured plugins and their purposes.

| Plugin | Description | Key Config |
|--------|-------------|-----------|
| `rose-pine/neovim` | Default theme (rose-pine, moon variant) | `variant = "moon"`, `colorscheme rose-pine` |
| `catppuccin/nvim` | Additional themes (lazy loaded) | — |
| `folke/tokyonight.nvim` | Additional themes (lazy loaded) | — |
| `doums/darcula` | Additional themes (lazy loaded) | — |
| `rebelot/kanagawa.nvim` | Additional themes (lazy loaded) | — |
| `sainnhe/gruvbox-material` | Additional themes (lazy loaded) | — |
| `EdenEast/nightfox.nvim` | Additional themes (lazy loaded) | — |
| `navarasu/onedark.nvim` | Additional themes (lazy loaded) | — |
| `Mofiqul/dracula.nvim` | Additional themes (lazy loaded) | — |
| `sainnhe/everforest` | Additional themes (lazy loaded) | — |
| `shaunsingh/nord.nvim` | Additional themes (lazy loaded) | — |
| `nyoom-engineering/oxocarbon.nvim` | Additional themes (lazy loaded) | — |
| `nvim-telescope/telescope.nvim` | Fuzzy finder with extensions for files, live_grep, buffers, help_tags, and current_buffer_fuzzy_find | `defaults.previewer`, `defaults.layout_strategy`, `defaults.layout_config`, `pickers.find_files`, `pickers.find_files.hidden`, `extensions.fzf.*` |
| `nvim-telescope/telescope-fzf-native.nvim` | FZF native extension (built with `make`) | `build = "make"`, `cond = vim.fn.executable("make") == 1` |
| `neovim/nvim-lspconfig` | LSP configuration for gopls, clangd, pyright, terraformls, ansiblels | `capabilities = require("cmp_nvim_lsp").default_capabilities()`, `vim.lsp.config("gopls", ...)`, `vim.lsp.enable("gopls")`, etc. |
| `hrsh7th/nvim-cmp` | Completion engine with snippet support, LuaSnip integration, and multiple sources | `snippet.expand = luasnip.lsp_expand`, `mapping = cmp.mapping.preset.insert(...)`, `sources = { "nvim_lsp", "luasnip", "buffer", "path" }` |
| `hrsh7th/cmp-nvim-lsp` | LSP source for nvim-cmp | — |
| `hrsh7th/cmp-buffer` | Buffer source for nvim-cmp | — |
| `hrsh7th/cmp-path` | Path source for nvim-cmp | — |
| `L3MON4D3/LuaSnip` | Snippet engine | — |
| `saadparwaiz1/cmp_luasnip` | Luasnip source for nvim-cmp | — |
| `windwp/nvim-autopairs` | Auto-closing brackets with treesitter support | `check_ts = true`, `map_cr = true`, `map_bs = true`, `event = "InsertEnter"` |
| `stevearc/conform.nvim` | Auto-formting on save for multiple languages | `formatters_by_ft = { go = { "goimports", "golines" }, python = { "black", "isort" }, ... }`, `format_on_save = { timeout_ms = 500, lsp_fallback = true }` |
| `nvim-tree/nvim-tree.lua` | File explorer with toggle mapping | `view.width = 30`, `filters.dotfiles = false`, `filters.git_ignored = false`, `vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")` |
| `nvim-tree/nvim-web-devicons` | Icons for file explorer and other plugins | — |
| `kdheepak/lazygit.nvim` | Lazygit integration with `LazyGit`, `LazyGitConfig`, `LazyGitCurrentFile` commands | `cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile" }`, `keys = { { "<leader>gg", "<cmd>LazyGit<cr>" } }` |
| `MeanderingProgrammer/render-markdown.nvim` | Markdown inline rendering with Treesitter support | `ft = { "markdown" }`, dependencies = { "nvim-treesitter", "nvim-web-devicons" } |
| `nvim-treesitter/nvim-treesitter` | Syntax highlighting, indentation, and text objects | `ensure_installed = { "go", "c", "python", "lua", "vim", "markdown", "json", "sql", "hcl", "yaml" }`, `auto_install = true`, `highlight.enable = true`, `indent.enable = true` |
| `nvim-lualine/lualine.nvim` | Status line with rose-pine theme | `theme = "rose-pine"`, dependencies = { "nvim-web-devicons", "rose-pine/neovim" } |
| `stevearc/dressing.nvim` | Floating UI for `vim.ui.select` and `vim.ui.input` | `select.backend = { "telescope", "builtin" }`, `input.relative = "editor"`, `input.prefer_width = 0.4` |
| `linux-cultist/venv-selector.nvim` | Python virtual environment support with auto-initialization | `auto_initialize = true`, `vim.keymap.set("n", "<leader>vs", ":VenvSelect<CR>")` |
| `mfussenegger/nvim-dap` | Debug adapter protocol setup for Go, Python, C | `dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end`, `dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end`, etc. |
| `rcarriga/nvim-dap-ui` | DAP UI integration | `dapui.setup()`, `dapui.open()`/`dapui.close()` on event boundaries |
| `leoluz/nvim-dap-go` | Go debugger integration for nvim-dap | `require("dap-go").setup()` |
| `mfussenegger/nvim-dap-python` | Python debugger integration for nvim-dap | `require("dap-python").setup("python3")` |
| `lewis6991/gitsigns.nvim` | Git signs and inline blame | `signs.add = { text = "▎" }`, `vim.keymap.set("n", "]h", gs.next_hunk)`, `vim.keymap.set("n", "[h", gs.prev_hunk)` |
| `folke/which-key.nvim` | Keybinding popup to show available mappings | `event = "VeryLazy"`, `require("which-key").setup()` |
| `ThePrimeagen/harpoon` | Harpoon v2 file bookmarks | `branch = "harpoon2"`, `vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end)`, `vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)` |
| `folke/flash.nvim` | 2-keystroke jump anywhere with `s` and `S` mappings | `vim.keymap.set({ "n", "x", "o" }, "s", function() require("flash").jump() end)`, `vim.keymap.set({ "n", "x", "o" }, "S", function() require("flash").treesitter() end)` |
| `kylechui/nvim-surround` | `ys`, `cs`, `ds` surround text objects | `event = "VeryLazy"`, `require("nvim-surround").setup()` |
| `numToStr/Comment.nvim` | Commenting with `gcc`, `gc` mappings | `event = { "BufReadPre", "BufNewFile" }`, `require("Comment").setup()` |
| `ray-x/go.nvim` | Go extra tooling (tests, struct filling, implementations) | `ft = { "go", "gomod" }`, `build = ':lua require("go.install").update_all_sync()'`, `vim.keymap.set("n", "<leader>gt", "<cmd>GoTest<CR>")`, etc. |
| `p00f/clangd_extensions.nvim` | clangd inlay hints for C/C++ | `ft = { "c", "cpp" }`, `inlay_hints = { inline = true }` |
| `nvim-neotest/neotest` | Inline test runner with Go and Python adapters | `adapters = { require("neotest-go"), require("neotest-python") }`, `vim.keymap.set("n", "<leader>tt", function() neotest.run.run() end)`, etc. |
| `folke/trouble.nvim` | Diagnostics and quickfix panels | `require("trouble").setup()`, `vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>")`, `vim.keymap.set("n", "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>")`, `vim.keymap.set("n", "<leader>xl", "<cmd>Trouble loclist toggle<CR>")`, `vim.keymap.set("n", "<leader>xq", "<cmd>Trouble qflist toggle<CR>")` |
| `akinsho/toggleterm.nvim` | Floating terminal with `Ctrl+\` mapping | `open_mapping = [[<C-\>]]`, `direction = "float"`, `float_opts = { border = "curved" }` |
| `lukas-reineke/indent-blankline.nvim` | Indent guides with `│` character | `indent.char = "│"`, `scope.enabled = true`, `event = { "BufReadPre", "BufNewFile" }` |
| `folke/noice.nvim` | Prettier cmdline and notifications | `event = "VeryLazy"`, `dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" }`, `setup({ lsp.override = [...], presets = { bottom_search = true, command_palette = true, long_message_to_split = true } })` |
| `karb94/neoscroll.nvim` | Smooth scrolling support | `require("neoscroll").setup()` |
| `goolord/alpha-nvim` | Startup dashboard with quick links | `event = "VimEnter"`, dependencies = { "nvim-web-devicons" }, config = function() ... dashboard section with buttons for find_files, oldfiles, live_grep, Lazy, Quit` |
| `eandrju/cellular-automaton.nvim` | Fun automaton commands (`make_it_rain`, `game_of_life`) | `cmd = "CellularAutomaton"`, `keys = { { "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>" }, { "<leader>ml", "<cmd>CellularAutomaton game_of_life<CR>" } }` |
| `folke/todo-comments.nvim` | TODO/FIXME/NOTE highlights with jump mappings | `event = { "BufReadPre", "BufNewFile" }`, `vim.keymap.set("n", "]t", function() require("todo-comments").jump_next() end)`, `vim.keymap.set("n", "[t", function() require("todo-comments").jump_prev() end)`, `vim.keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<CR>")` |
| `RRethy/vim-illuminate` | Highlight other uses of word under cursor | `delay = 200`, `large_file_cutoff = 2000` |
| `mbbill/undotree` | Undo history tree viewer | `cmd = "UndotreeToggle"`, `keys = { { "<leader>u", "<cmd>UndotreeToggle<CR>" } }` |
| `nvim-pack/nvim-spectre` | Project-wide find & replace | `cmd = "Spectre"`, `keys = { { "<leader>sr", function() require("spectre").open() end, desc = "Search & replace" }, { "<leader>sw", function() require("spectre").open_visual({ select_word = true }) end, desc = "Replace word under cursor" } }` |
| `kevinhwang91/nvim-ufo` | Foldable text with ufo provider | `provider_selector = function() return { "treesitter", "indent" } end`, `vim.keymap.set("n", "zR", require("ufo").openAllFolds)`, `vim.keymap.set("n", "zM", require("ufo").closeAllFolds)` |
| `akinsho/bufferline.nvim` | Buffer tabs at the top | `version = "*"`, `dependencies = { "nvim-web-devicons" }`, `options = { diagnostics = "nvim_lsp", offsets = { { filetype = "NvimTree", text = "Files", separator = true } } }`, `vim.keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>)`, `vim.keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>)`, `vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>)` |
| `stevearc/aerial.nvim` | Code outline / symbols panel | `dependencies = { "nvim-treesitter", "nvim-web-devicons" }`, `vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>)`, `vim.keymap.set("n", "}", "<cmd>AerialNext<CR>)`, `vim.keymap.set("n", "<leader>as", "<cmd>AerialToggle!<CR>)"` |
| `utilyre/barbecue.nvim` | Breadcrumbs in winbar | `name = "barbecue"`, `dependencies = { "nvim-navic", "nvim-web-devicons" }`, `config = function() require("barbecue").setup({ attach_navic = false }) end` |
| `NvChad/nvim-colorizer.lua` | Inline color preview (#hex, rgb(), etc.) | `event = { "BufReadPre", "BufNewFile" }`, `require("colorizer").setup({ user_default_options = { RGB = true, RRGGBB = true, names = false, css = true, mode = "background" } })` |
| `yetone/avante.nvim` | Claude AI integration | `event = "VeryLazy"`, `version = false`, `build = "make"`, `provider = "claude"`, `opts = { provider = "claude", providers = { claude = { endpoint = "https://api.anthropic.com", model = "claude-sonnet-4-6", timeout = 30000, extra_request_body = { temperature = 0, max_tokens = 8192 } } }` |
| `nickjvandyke/opencode.nvim` | OpenCode AI agent CLI integration | `version = "*"`, `vim.g.opencode_opts = {}`, `vim.o.autoread = true`, `vim.keymap.set({ "n", "x" }, "<leader>oa", function() require("opencode").ask("@this: ") end)`, `vim.keymap.set({ "n", "x" }, "<leader>os", function() require("opencode").select() end)`, `vim.keymap.set("n", "go", function() return require("opencode").operator("@this ") end, { desc = "Append range to OpenCode", expr = true })`, `vim.keymap.set("n", "goo", function() return require("opencode").operator("@this ") .. "_" end, { desc = "Append line to OpenCode", expr = true })`, `vim.keymap.set("n", "<S-C-u>", function() require("opencode").command("session.half.page.up") end)`, `vim.keymap.set("n", "<S-C-d>", function() require("opencode").command("session.half.page.down") end)` |
| `giusgad/pets.nvim` | Animated pets at the bottom | `dependencies = { "MunifTanjim/nui.nvim", "edluffy/hologram.nvim" }`, `row = 1`, `col = 0`, `speed_multiplier = 1`, `default_pet = "dog"`, `default_style = "brown"`, `random = true`, `vim.keymap.set("n", "<leader>pa", function() ... end)`, `vim.keymap.set("n", "<leader>pk", "<cmd>PetsKillAll<CR>)`, `vim.keymap.set("n", "<leader>ps", "<cmd>PetsList<CR>)"` |
# Neovim Configuration

A focused Neovim setup for Go development with LSP, autocomplete, fuzzy finding, and debugging.

## Install

Requirements: Neovim >= 0.10.0, Git, curl, make, a [Nerd Font](https://www.nerdfonts.com/).

```bash
# LSP, formatters, debugger
go install github.com/golang/tools/gopls@latest
go install golang.org/x/tools/cmd/goimports@latest
go install github.com/dinkur/golines@latest
go install github.com/go-delve/delve/cmd/dlv@latest
brew install stylua prettier fd ripgrep lazygit   # macOS; use apt/dnf equivalents on Linux
```

```bash
git clone https://github.com/Rapando/nvim-config ~/.config/nvim
nvim   # lazy.nvim bootstraps and installs plugins on first launch (1-2 min)
```

Inside Neovim: `:TSUpdate` to install Treesitter parsers, `:LspInfo` / `:Lazy` / `:checkhealth` to verify.

Update later with `:Lazy update` and `:TSUpdate`. Uninstall with `rm -rf ~/.config/nvim ~/.local/share/nvim`.

## Features

- **LSP**: gopls (Go)
- **Completion**: nvim-cmp — sources are LSP, LuaSnip snippets, buffer words, and file paths, in that priority order. `<C-Space>` opens the menu manually, `<Tab>`/`<S-Tab>` cycle, `<CR>` confirms.
- **Auto-pairs**: nvim-autopairs closes `()`, `[]`, `{}`, `""`, `''`, `` `` `` as you type, treesitter-aware, and cooperates with completion confirm.
- **Auto-format on save**: conform.nvim — `goimports`+`golines` (Go), `stylua` (Lua), `prettier` (Markdown/JSON/YAML). Manual format: `<leader>cf`. Falls back to LSP formatting if no dedicated formatter is found.
- **Treesitter**: syntax highlighting, indentation, folds.
- **Project root**: auto-`cd`s to the enclosing `.git` root on buffer enter.

### Navigation & Search
- **Telescope** (+ fzf-native): fuzzy finder for files, grep, buffers, help.
- **Harpoon**: bookmark up to 4 files per project.
- **Flash**: 2-keystroke jump anywhere on screen.
- **Aerial**: sidebar symbols outline.
- **Bufferline**: open buffers as tabs at the top.

### Editing
- **Surround**: `ys`/`cs`/`ds` to add/change/delete surrounding brackets or quotes.
- **Comment.nvim**: `gcc`/`gc` to toggle comments.
- **Spectre**: project-wide find & replace with diff preview.
- **Undotree**: visual branching undo history.
- **nvim-ufo**: LSP/treesitter-aware folding; `K` peeks fold content before falling back to hover.

### Debugging & Testing
- **nvim-dap** + **nvim-dap-go**: full debugger with UI for Go (delve). UI opens/closes automatically with the session.
- **Neotest** + **neotest-go**: inline test runner, pass/fail shown in the gutter.

### Git
- **Lazygit**: full git TUI.
- **Gitsigns**: gutter indicators, inline blame, hunk staging.

### UI & Diagnostics
- **which-key**: shows available bindings after `<leader>`.
- **todo-comments**: highlights `TODO`/`FIXME`/`NOTE`/`HACK`.
- **vim-illuminate**: highlights other occurrences of the word under the cursor.
- **Trouble**: structured panel for diagnostics, quickfix, loclist.
- **Toggleterm**: floating terminal.

## Plugins

| Plugin | Purpose |
|--------|---------|
| `rose-pine/neovim` | Theme (moon variant) |
| `nvim-telescope/telescope.nvim` + `telescope-fzf-native.nvim` | Fuzzy finder |
| `neovim/nvim-lspconfig` | LSP config for gopls |
| `hrsh7th/nvim-cmp` + `cmp-nvim-lsp`, `cmp-buffer`, `cmp-path`, `L3MON4D3/LuaSnip`, `saadparwaiz1/cmp_luasnip` | Completion engine + sources + snippets |
| `windwp/nvim-autopairs` | Auto-closing brackets |
| `stevearc/conform.nvim` | Format on save |
| `nvim-tree/nvim-tree.lua` + `nvim-web-devicons` | File explorer |
| `kdheepak/lazygit.nvim` | Lazygit integration |
| `MeanderingProgrammer/render-markdown.nvim` | Markdown inline rendering |
| `nvim-treesitter/nvim-treesitter` | Syntax highlighting/indent/folds |
| `nvim-lualine/lualine.nvim` | Status line |
| `mfussenegger/nvim-dap` + `nvim-dap-ui`, `leoluz/nvim-dap-go` | Debugger (Go) |
| `lewis6991/gitsigns.nvim` | Git signs & blame |
| `folke/which-key.nvim` | Keybinding popup |
| `ThePrimeagen/harpoon` (branch `harpoon2`) | File bookmarks |
| `folke/flash.nvim` | Jump motion |
| `kylechui/nvim-surround` | Surround text objects |
| `numToStr/Comment.nvim` | Line/block commenting |
| `nvim-neotest/neotest` + `neotest-go` | Test runner (Go) |
| `folke/trouble.nvim` | Diagnostics panel |
| `akinsho/toggleterm.nvim` | Floating terminal |
| `folke/todo-comments.nvim` | TODO/FIXME highlights |
| `RRethy/vim-illuminate` | Cursor-word highlighting |
| `mbbill/undotree` | Undo tree viewer |
| `nvim-pack/nvim-spectre` | Find & replace |
| `kevinhwang91/nvim-ufo` + `promise-async` | Folding |
| `akinsho/bufferline.nvim` | Buffer tabs |
| `stevearc/aerial.nvim` | Symbols outline |

Full spec (config options, dependencies, build steps) lives in `init.lua` — the table above is a map for finding your way there, not a duplicate of it.

## Shortcuts

`<leader>` is **Space**.

**Splits/Windows**: `<C-h/j/k/l>` move · `<leader>sh`/`sv` split horiz/vert · `<leader>sc` close

**Buffers**: `<S-h>`/`<S-l>` prev/next tab · `<leader>bd` close

**Files & Search**: `<leader>ff` find files · `<leader>fg` live grep · `<leader>fb` buffers · `<leader>fh` help tags · `<leader>/` fuzzy search in file

**Navigation**: `s`/`S` Flash jump / treesitter jump · `<leader>ha` harpoon add · `<leader>hh` harpoon menu · `<leader>1-4` harpoon jump · `<leader>as` aerial outline · `{`/`}` prev/next symbol

**LSP**: `gd` definition · `gr` references · `K` hover (or peek fold) · `<leader>rn` rename · `<leader>ca` code action · `<leader>ld` diagnostics float

**Completion**: `<C-Space>` trigger · `<Tab>`/`<S-Tab>` next/prev · `<CR>` confirm · `<C-e>` abort

**Editing**: `gcc`/`gc` comment · `ys{motion}{char}`/`cs{old}{new}`/`ds{char}` surround · `<leader>cf` format · `<leader>u` undotree

**Folding**: `zR` open all · `zM` close all

**Search & Replace**: `<leader>sr` Spectre · `<leader>sw` replace word under cursor

**Debugging**: `<leader>db` breakpoint · `<leader>dc` continue · `<leader>ds`/`di`/`do` step over/into/out · `<leader>du` toggle DAP UI

**Testing**: `<leader>tt` run nearest · `<leader>tf` run file · `<leader>ts` summary · `<leader>to` output

**Git**: `<leader>gg` Lazygit · `<leader>gb` toggle blame · `<leader>hs`/`hr`/`hp` stage/reset/preview hunk · `]h`/`[h` next/prev hunk

**Diagnostics**: `<leader>xx` toggle Trouble · `<leader>xd` buffer diagnostics · `<leader>xl` loclist · `<leader>xq` quickfix

**TODO comments**: `]t`/`[t` next/prev · `<leader>ft` search all

**Terminal**: `<C-\>` toggle floating terminal

**File explorer**: `<leader>e` toggle nvim-tree

## Adding another language later

This config only wires up Go. To bring back a language, add:
1. An LSP block in the `nvim-lspconfig` config (`vim.lsp.config(...)` + `vim.lsp.enable(...)`).
2. A formatter entry under `formatters_by_ft` in the `conform.nvim` config.
3. Its treesitter parser to `ensure_installed`.
4. Any language-specific plugin (debugger adapter, test adapter, etc.) as its own `lazy.nvim` spec.

## Troubleshooting

| Problem | Fix |
|---------|-----|
| LSP not working | `which gopls`, then `:LspInfo` |
| Completion not appearing | Confirm LSP is running (`:LspInfo`), try `<C-Space>` manually |
| Auto-pairs not working | Check `:Lazy` shows `nvim-autopairs` loaded; try a new line or after whitespace |
| Formatter not found | Install it, verify with `which <formatter>`, restart Neovim |
| Formatting too slow / times out | Raise `timeout_ms` in the `conform.setup()` call, or format manually with `<leader>cf` |
| Plugins not installing | `rm -rf ~/.local/share/nvim/lazy`, reopen Neovim |
| Telescope finds nothing | Install `fd`; make sure you're inside a git repo/directory |
| Colors wrong | Use a true-color terminal (iTerm2, Kitty, Alacritty); set `TERM=xterm-256color` |
| DAP not stopping at breakpoints | Ensure `dlv` is installed and on `$PATH` |

Run `:checkhealth` inside Neovim for a full diagnostic.

## License

MIT License — Copyright (c) 2025 Samson Rapando

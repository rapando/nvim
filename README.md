# Neovim Configuration

A modern Neovim setup for Go, C, and Python development with LSP, autocomplete, fuzzy finding, debugging, AI assistance, and more.

## Contents

- [Installation](INSTALL.md) — prerequisites, setup steps, post-install configuration
- [Shortcuts](SHORTCUTS.md) — full keybindings reference

## Features

### Core
- **LSP**: gopls (Go), clangd (C), pyright (Python)
- **Completion**: nvim-cmp with LSP, snippets, buffer, and path sources
- **Auto-format on save**: goimports + golines (Go), black + isort (Python), clang-format (C), stylua (Lua), prettier (MD/JSON/YAML)
- **Auto-pairs**: brackets, quotes, and parens closed automatically
- **Treesitter**: enhanced syntax highlighting and indentation
- **Project root**: auto-cd to `.git` root on buffer enter
- **Pipenv**: auto-activates virtualenv for Python projects with a `Pipfile`

### Navigation & Search
- **Telescope**: fuzzy finder with fzf-native for files, grep, buffers, help
- **Harpoon**: bookmark up to 4 files per project, jump instantly with `<leader>1-4`
- **Flash**: type `s` + 2 chars to jump anywhere on screen in 2 keystrokes
- **Aerial**: sidebar symbols outline for functions/types/methods
- **Bufferline**: open buffers shown as tabs at the top; cycle with `<S-h>`/`<S-l>`

### Editing
- **Surround**: `ys`, `cs`, `ds` to add, change, and delete surrounding brackets/quotes
- **Comments**: `gcc` to toggle line comment; handles C block comments correctly
- **Spectre**: project-wide regex find & replace with diff preview before applying
- **Undotree**: visual branching undo history
- **Folding**: nvim-ufo with LSP/treesitter-aware folds; `K` peeks fold content before hover

### Debugging
- **nvim-dap**: full debugger with UI — delve (Go), debugpy (Python), lldb (C)
- Debug UI opens automatically when a session starts and closes on exit

### Testing
- **Neotest**: inline test runner for Go and Python; pass/fail shown in gutter

### Git
- **Lazygit**: full git TUI (`<leader>gg`)
- **Gitsigns**: add/change/delete indicators in gutter, inline line blame, hunk staging

### Language-specific
- **go.nvim**: GoFillStruct, GoImpl, GoAddTag, GoTest
- **clangd_extensions**: inlay hints showing parameter types inline for C

### UI
- **Noice**: replaces cmdline and notifications with a cleaner floating UI
- **Barbecue**: winbar breadcrumb trail showing your position in the file
- **Indent guides**: visual indent level lines (indent-blankline)
- **Colorizer**: renders `#hex`, `rgb()`, `hsl()` as inline colored backgrounds
- **Which-key**: pause after `<leader>` to see all available bindings in a popup
- **Smooth scrolling**: animated scroll (neoscroll)
- **Dashboard**: alpha-nvim startup screen with quick-access buttons
- **Themes**: 24 themes with live preview picker (`<leader>th`)
- **Todo comments**: highlights `TODO`/`FIXME`/`NOTE`/`HACK` in code with colors
- **Illuminate**: auto-highlights all other occurrences of the word under the cursor

### AI
- **Avante.nvim**: Claude Sonnet sidebar — ask questions, edit code, chat (`<leader>aa`)

### Diagnostics & Terminal
- **Trouble**: structured panel for diagnostics, quickfix, and loclist
- **Toggleterm**: floating terminal that persists across toggles (`<C-\>`)

### Fun
- **Pets**: animated companions that live at the bottom of your editor
- **Cellular Automaton**: `<leader>mr` make it rain, `<leader>ml` game of life

## Troubleshooting

| Problem | Fix |
|---------|-----|
| LSP not working | `which gopls/clangd/pyright`, then `:LspInfo` |
| Plugins not installing | `rm -rf ~/.local/share/nvim/lazy`, reopen Neovim |
| Telescope empty | Install `fd`; ensure you're in a git repo |
| Formatter not found | Install it, verify with `which <formatter>`, restart Neovim |
| Colors wrong | Use a true-color terminal (iTerm2, Kitty, Alacritty); set `TERM=xterm-256color` |
| DAP not stopping | Ensure `dlv`/`debugpy` is installed and on `$PATH` |
| Avante not responding | Check `ANTHROPIC_API_KEY` is set in your shell |
| Pets not showing images | Requires Kitty or iTerm2 with image protocol support |

Run `:checkhealth` inside Neovim for a full diagnostic.

## License

MIT License — Copyright (c) 2025 Samson Rapando

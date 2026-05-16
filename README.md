# Neovim Configuration

A modern Neovim setup for Go, C, and Python development with LSP, autocomplete, fuzzy finding, and auto-formatting.

## Prerequisites

- Neovim >= 0.9.0
- Git, curl, make

**LSP servers:**
```bash
go install github.com/golang/tools/gopls@latest          # Go
brew install llvm                                          # C (macOS)
pip install pyright                                        # Python
```

**Formatters:**
```bash
go install golang.org/x/tools/cmd/goimports@latest
go install github.com/dinkur/golines@latest
pip install black isort
brew install clang-format stylua prettier
```

**Optional (recommended):**
```bash
brew install fd ripgrep   # faster file search
brew install lazygit      # git TUI
```

## Installation

Clone or copy config to `~/.config/nvim/`, then open Neovim — lazy.nvim bootstraps and installs all plugins automatically on first launch.

## Key Bindings

### Navigation
| Key | Action |
|-----|--------|
| `<C-h/j/k/l>` | Move between splits |
| `<leader>sh/sv` | Split horizontal / vertical |
| `<leader>sc` | Close split |

### Files & Search
| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Find open buffers |
| `<leader>/` | Search in current file |

### LSP
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover docs |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>e` | Show diagnostics |

### Completion
| Key | Action |
|-----|--------|
| `<C-Space>` | Trigger completion |
| `<Tab>/<S-Tab>` | Next / prev item |
| `<CR>` | Confirm |
| `<C-e>` | Abort |

### Other
| Key | Action |
|-----|--------|
| `<leader>gg` | Open Lazygit |
| `<leader>cf` | Format file / selection |
| `<leader>e` | Toggle file explorer |
| `<leader>vs` | Select Python venv |

## Features

- **LSP**: gopls (Go), clangd (C), pyright (Python)
- **Completion**: nvim-cmp with LSP, snippets, buffer, and path sources
- **Auto-format on save**: goimports + golines (Go), black + isort (Python), clang-format (C), stylua (Lua), prettier (MD/JSON/YAML)
- **Auto-pairs**: brackets, quotes, and parens closed automatically
- **File explorer**: nvim-tree (shows hidden files)
- **Fuzzy finder**: Telescope with fzf-native
- **Markdown**: inline rendering via render-markdown.nvim
- **Lazygit**: full git TUI via `<leader>gg` (requires `lazygit` installed)
- **Treesitter**: enhanced syntax highlighting
- **Project root**: auto-cd to `.git` root on buffer enter
- **Pipenv**: auto-activates virtualenv for Python projects with a `Pipfile`

## Troubleshooting

| Problem | Fix |
|---------|-----|
| LSP not working | `which gopls/clangd/pyright`, then `:LspInfo` |
| Plugins not installing | `rm -rf ~/.local/share/nvim/lazy`, reopen Neovim |
| Telescope empty | Install `fd`; ensure you're in a git repo |
| Formatter not found | Install it, verify with `which <formatter>`, restart Neovim |
| Colors wrong | Use a true-color terminal (iTerm2, Kitty, Alacritty); set `TERM=xterm-256color` |

Run `:checkhealth` inside Neovim for a full diagnostic.

## License

MIT License

Copyright (c) 2025 Samson Rapando

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

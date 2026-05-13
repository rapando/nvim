# Neovim Configuration

A modern Neovim setup for Go, C, and Python development with LSP support, fuzzy finding, and autocomplete.

## Features

- **Language Support**: Go, C, Python (with pipenv support)
- **LSP**: Go (gopls), C (clangd), Python (pyright)
- **Fuzzy Finding**: Telescope for file and project search
- **Autocomplete**: LSP-powered with snippet support
- **File Explorer**: nvim-tree for easy navigation
- **Split Support**: Horizontal and vertical splits
- **Python Virtual Environments**: Auto-detect pipenv environments
- **Syntax Highlighting**: Treesitter for all supported languages

## Installation

### Prerequisites

Make sure you have the following LSP servers installed:

```bash
# Go
go install github.com/golang/tools/gopls@latest

# C
brew install llvm  # macOS - includes clangd

# Python
pip install pyright

# Neovim >= 0.9.0
nvim --version
```

### First Run

When you open Neovim for the first time, lazy.nvim will automatically:
1. Clone itself to `~/.local/share/nvim/lazy/lazy.nvim`
2. Install all plugins
3. Compile plugins (may take a minute on first launch)

Just be patient and let it finish. Everything will be set up automatically.

## Keyboard Shortcuts

### Navigation

| Shortcut | Action |
|----------|--------|
| `<C-h>` | Move to left split |
| `<C-j>` | Move to bottom split |
| `<C-k>` | Move to top split |
| `<C-l>` | Move to right split |

### Splits

| Shortcut | Action |
|----------|--------|
| `<leader>sh` | Split horizontally |
| `<leader>sv` | Split vertically |
| `<leader>sc` | Close current split |

### File & Project Search

| Shortcut | Action |
|----------|--------|
| `<leader>ff` | Find files in project |
| `<leader>fg` | Live grep (search project) |
| `<leader>fb` | Find open buffers |
| `<leader>/` | Search in current file |
| `<leader>fh` | Search help tags |

### Code Navigation & Editing

| Shortcut | Action |
|----------|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Show hover documentation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action (e.g., quick fixes) |
| `<leader>e` | Show diagnostics |

### File Explorer

| Shortcut | Action |
|----------|--------|
| `<leader>e` | Toggle file explorer (nvim-tree) |

*Note: This conflicts with showing diagnostics. Use `K` for hover info first, or press `<leader>e` twice to use the explorer.*

### Completion

| Shortcut | Action |
|----------|--------|
| `<C-Space>` | Trigger completion menu |
| `<Tab>` | Select next item / expand snippet |
| `<S-Tab>` | Select previous item / jump back in snippet |
| `<C-b>` | Scroll completion menu up |
| `<C-f>` | Scroll completion menu down |
| `<C-e>` | Abort completion |
| `<CR>` | Confirm completion |

### Python Virtual Environments

| Shortcut | Action |
|----------|--------|
| `<leader>vs` | Manually select virtual environment |

**Automatic Detection**: If your Python project has a `Pipfile`, the pipenv environment is automatically activated when you open Python files.

## Configuration

### Default Settings

- **Tab size**: 4 spaces (expandtab enabled)
- **Line numbers**: Absolute with relative line numbers
- **Auto-indent**: Smart indent enabled
- **Split behavior**: New splits open to the right/bottom
- **Color scheme**: TokyoNight (dark theme)
- **Text wrapping**: Disabled (line wrapping disabled)
- **Scroll offset**: 8 lines (keeps cursor away from edges)

### Customization

Edit `~/.config/nvim/init.lua` to customize:

- **Color scheme**: Search for `vim.cmd([[colorscheme` and change to your preferred theme
- **Tab size**: Change `vim.opt.tabstop = 4` to your preferred size
- **LSP settings**: Modify language server configs in the LSP section
- **Keybindings**: Add/modify in the keymaps sections

## Project Detection

The configuration automatically:

1. **Detects project root**: Uses `.git` directory to find the project root
2. **Changes working directory**: Automatically cd's to project root when opening files
3. **Loads pipenv**: Automatically activates pipenv virtual environment for Python projects

## Tips & Tricks

### Large Project Performance

For very large projects, telescope might be slow initially. You can:

1. Make sure you have `fd` installed: `brew install fd`
2. The config uses fzf-native which is faster than default sorting
3. Use `.gitignore` - telescope respects it and won't search ignored files

### Using Telescope

- Type to filter results
- `<C-j>` / `<C-k>` to navigate results
- `<CR>` to open the selected file
- `<C-x>` to split horizontally
- `<C-v>` to split vertically
- `<C-t>` to open in a new tab

### Go Development

The gopls server supports:

- Code completion
- Definition jumping
- References
- Hover documentation
- Rename
- Format on save (add custom keybinding if desired)

### C Development

clangd provides:

- Intelligent completion
- Definition/reference jumping
- Include path resolution
- Diagnostics

### Python Development

pyright supports:

- Type checking
- Auto-completion
- Definition jumping
- Virtual environment detection
- Pipenv support (automatic)

## Troubleshooting

### LSP not working

1. Check if the language server is installed: `which gopls` / `which clangd` / `which pyright`
2. Open a file of that type
3. Run `:LspInfo` to see LSP status
4. Check `:messages` for error messages

### Plugins not installing

1. Close Neovim completely
2. Delete `~/.local/share/nvim/lazy` directory
3. Reopen Neovim and let it reinstall

### Telescope finding nothing

1. Make sure you have `fd` installed: `brew install fd`
2. Check if you're in a Git repository (telescope respects `.git`)
3. Try `:Telescope live_grep` and type manually to search

### Pipenv not loading

1. Make sure you have a `Pipfile` in your project root
2. Run `:messages` to see if there are any errors
3. Manually select environment with `<leader>vs`

## Color Scheme

The default color scheme is **TokyoNight (dark)**. To change it:

1. Open `init.lua`
2. Find the theme section (folke/tokyonight)
3. Replace with your preferred theme from [awesome-neovim](https://github.com/rockerBOO/awesome-neovim#colorscheme)

Popular alternatives:
- `catppuccin/nvim` - Warm pastels
- `gruvbox-community/gruvbox` - Warm, retro colors
- `dracula/vim` - Dark vampire theme

## Plugin Management

This config uses **lazy.nvim** for plugin management. To update plugins:

```bash
# From within Neovim
:Lazy update
```

## Support

For issues with:

- **Neovim config**: Check `init.lua` and `:messages`
- **Language servers**: Run `:LspInfo` to diagnose
- **Lazy.nvim**: Run `:Lazy` to see plugin status
- **Telescope**: Try `:checkhealth` for debugging

## Resources

- [Neovim Documentation](https://neovim.io)
- [LSP Configurations](https://github.com/neovim/nvim-lspconfig)
- [Telescope Docs](https://github.com/nvim-telescope/telescope.nvim)
- [Lazy.nvim Guide](https://github.com/folke/lazy.nvim)

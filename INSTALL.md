# Installation Guide

Complete setup guide for this Neovim configuration.

## Requirements

- **Neovim >= 0.10.0** (uses the new `vim.lsp.config` API)
- **Git, curl, make**
- A [Nerd Font](https://www.nerdfonts.com/) set in your terminal for icons (JetBrainsMono Nerd Font recommended)

Check your Neovim version:
```bash
nvim --version
```

Install or upgrade Neovim:
```bash
brew install neovim          # macOS
sudo apt-get install neovim  # Ubuntu/Debian
sudo dnf install neovim      # Fedora
```

## System Dependencies

### LSP Servers

```bash
# Go
go install github.com/golang/tools/gopls@latest

# C (macOS — also provides clangd)
brew install llvm
export PATH="/usr/local/opt/llvm/bin:$PATH"  # add to ~/.zshrc

# C (Linux)
sudo apt-get install clangd        # Ubuntu/Debian
sudo dnf install clang-tools-extra # Fedora

# Python
pip install pyright
```

### Formatters

```bash
go install golang.org/x/tools/cmd/goimports@latest
go install github.com/dinkur/golines@latest
pip install black isort
brew install clang-format stylua prettier   # macOS
```

### Debuggers

```bash
go install github.com/go-delve/delve/cmd/dlv@latest   # Go (delve)
pip install debugpy                                     # Python
brew install lldb                                       # C (macOS)
```

### Search Tools (strongly recommended)

```bash
brew install fd ripgrep    # macOS
sudo apt install fd-find ripgrep  # Ubuntu/Debian
```

### Git TUI

```bash
brew install lazygit    # macOS
sudo apt install lazygit  # Ubuntu/Debian (check version — needs >= 0.40)
```

## Installation

Clone or copy config to `~/.config/nvim/`:

```bash
git clone https://github.com/Rapando/nvim-config ~/.config/nvim
# or copy manually:
cp -r /path/to/this/repo ~/.config/nvim
```

Open Neovim. On first launch, lazy.nvim bootstraps itself and installs all plugins automatically. This takes 1–2 minutes — do not interrupt it.

```bash
nvim
```

After plugins install, run inside Neovim to install Treesitter parsers:
```vim
:TSUpdate
```

## Post-install: Claude AI

Avante.nvim uses Claude Sonnet via the Anthropic API. Add your API key to your shell config:

```bash
# ~/.zshrc or ~/.bashrc
export ANTHROPIC_API_KEY="sk-ant-..."
```

Then reload: `source ~/.zshrc`. Use `<leader>aa` to open the AI sidebar.

To get an API key: [console.anthropic.com](https://console.anthropic.com)

## Post-install: go.nvim Tools

On first use of a Go file, go.nvim may prompt to install its companion tools. You can also trigger this manually:

```vim
:GoInstallBinaries
```

## Post-install: Pets (image rendering)

Pets show animated images on terminals that support the terminal graphics protocol. Without it they fall back to text/ASCII mode.

- **Kitty** — works out of the box
- **iTerm2** — enable *Allow inline images* in Preferences → Profiles → Terminal

## Verify Everything Works

Run these inside Neovim after setup:

```vim
:LspInfo        " Check active LSP servers
:Lazy           " Check plugin status
:checkhealth    " Full diagnostic across all plugins
```

## Updating

```vim
:Lazy update    " Update all plugins
:TSUpdate       " Update Treesitter parsers
```

## Uninstalling

```bash
mv ~/.config/nvim ~/.config/nvim.backup   # backup
rm -rf ~/.local/share/nvim                # remove plugins and cache
```

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Plugins not installing | `rm -rf ~/.local/share/nvim/lazy`, reopen Neovim |
| LSP not attaching | `:LspInfo`; verify `which gopls` / `which clangd` / `which pyright` |
| Telescope finds nothing | Install `fd`; must be inside a directory |
| Formatter not running | `which <formatter>`, install it, restart Neovim |
| Colors wrong | Use a true-color terminal; set `TERM=xterm-256color` in shell config |
| DAP not hitting breakpoints | Confirm `dlv` (Go) or `debugpy` (Python) is on `$PATH` |
| Avante not responding | Run `echo $ANTHROPIC_API_KEY`; ensure key is exported in your shell |
| avante build fails | Needs `make` and internet access to download binaries on first build |
| Pets show no images | Requires Kitty or iTerm2 with inline image protocol enabled |
| go.nvim commands missing | Run `:GoInstallBinaries` once inside a Go file |
| Completion not appearing | Confirm LSP is running (`:LspInfo`), try `<C-Space>` to trigger manually |
| Pipenv env not loading | Confirm `Pipfile` exists at project root; run `:VenvSelect` to pick manually |

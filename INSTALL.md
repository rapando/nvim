# Installation Guide

Complete step-by-step guide to set up this Neovim configuration.

## Prerequisites

### Neovim
You need Neovim >= 0.9.0. Check your version:

```bash
nvim --version
```

If you don't have it or need to upgrade:

**macOS (Homebrew)**
```bash
brew install neovim
```

**Linux (Ubuntu/Debian)**
```bash
sudo apt-get install neovim
```

**Linux (Fedora)**
```bash
sudo dnf install neovim
```

**From Source**
```bash
git clone https://github.com/neovim/neovim
cd neovim && make CMAKE_BUILD_TYPE=Release
sudo make install
```

### Basic Dependencies
Some plugins need additional tools. Install these first:

**macOS**
```bash
brew install git curl wget
```

**Linux (Ubuntu/Debian)**
```bash
sudo apt-get install git curl wget build-essential
```

**Linux (Fedora)**
```bash
sudo dnf install git curl wget gcc g++ make
```

## Installation Steps

### Step 1: Copy Configuration

The config should already be in place at `~/.config/nvim/init.lua`. If not:

```bash
# Create the directory if it doesn't exist
mkdir -p ~/.config/nvim

# Verify the files are there
ls ~/.config/nvim/
# Should show: init.lua, README.md, INSTALL.md
```

### Step 2: Install Language Servers

Choose which languages you'll be using and install the corresponding servers.

#### Go Development

```bash
go install github.com/golang/tools/gopls@latest
```

Verify:
```bash
gopls version
```

#### C Development

**macOS**
```bash
brew install llvm
# Add to your shell config (~/.zshrc or ~/.bashrc):
export PATH="/usr/local/opt/llvm/bin:$PATH"
```

**Linux (Ubuntu/Debian)**
```bash
sudo apt-get install clangd
```

**Linux (Fedora)**
```bash
sudo dnf install clang-tools-extra
```

Verify:
```bash
clangd --version
```

#### Python Development

First, install pyright:

```bash
pip install pyright
```

Or with pip3:
```bash
pip3 install pyright
```

Verify:
```bash
pyright --version
```

**Optional: Pipenv Support**

If you use pipenv for Python projects:

```bash
pip install pipenv
```

### Step 3: Optional Dependencies

These aren't required but improve performance and features.

#### FZF (Better Fuzzy Finder)

The config uses telescope's built-in fzf support. For best performance, install the native fzf:

**macOS**
```bash
brew install fzf fd
```

**Linux (Ubuntu/Debian)**
```bash
sudo apt-get install fzf fd-find
```

**Linux (Fedora)**
```bash
sudo dnf install fzf fd
```

#### Ripgrep (Faster Searching)

Optional but recommended for better grep performance:

**macOS**
```bash
brew install ripgrep
```

**Linux (Ubuntu/Debian)**
```bash
sudo apt-get install ripgrep
```

**Linux (Fedora)**
```bash
sudo dnf install ripgrep
```

### Step 4: First Launch

Open Neovim:

```bash
nvim
```

On first launch, lazy.nvim will:
1. Clone itself automatically
2. Install all plugins
3. Compile native components

This may take 1-2 minutes depending on your internet speed and machine. You'll see progress messages. **Don't interrupt this process.**

Once done, you should see:
- The TokyoNight color scheme applied
- Status line at the bottom with file info
- No error messages

### Step 5: Verify Installation

Check that everything is working:

```bash
# In Neovim, run these commands:
:LspInfo              # Shows LSP status
:Lazy                 # Shows plugin status
:checkhealth          # Comprehensive health check
```

All should show as working or "ok".

## Post-Installation Configuration

### Environment Variables

If you installed clangd via Homebrew on macOS, add this to your shell config:

**~/.zshrc** (Zsh - default on modern macOS)
```bash
export PATH="/usr/local/opt/llvm/bin:$PATH"
```

**~/.bashrc** (Bash)
```bash
export PATH="/usr/local/opt/llvm/bin:$PATH"
```

Then reload:
```bash
source ~/.zshrc  # or ~/.bashrc
```

### Python Path Setup (Optional)

If you have Python installed in a non-standard location, you can configure it in `init.lua`:

1. Find the Python LSP config section:
```lua
lspconfig.pyright.setup({
  capabilities = capabilities,
  settings = {
    python = {
      venvPath = vim.fn.getcwd(),
    },
  },
})
```

2. Modify `venvPath` to match your setup if needed.

## Troubleshooting

### Plugins Not Installing

**Problem**: Lazy.nvim doesn't seem to be working, or plugins aren't downloading.

**Solution**:
```bash
# Close Neovim completely
# Delete the plugin cache
rm -rf ~/.local/share/nvim/lazy

# Reopen Neovim - plugins will reinstall
nvim
```

### LSP Not Working

**Problem**: Language server errors or `:LspInfo` shows "not running"

**Step 1**: Verify the language server is installed:
```bash
which gopls    # for Go
which clangd   # for C
which pyright  # for Python
```

**Step 2**: Check Neovim messages:
```bash
# In Neovim, run:
:messages
```

**Step 3**: Verify the correct file type:
```bash
# In Neovim, run:
:set filetype
# Should be: go, c, python, etc.
```

**Step 4**: Manually start LSP:
```bash
# In Neovim, run:
:LspStart
```

### Telescope Not Finding Files

**Problem**: Telescope returns no results or is very slow.

**Solution**:
1. Install `fd` (faster file finder):
   ```bash
   brew install fd        # macOS
   sudo apt-get install fd-find  # Linux
   ```

2. Make sure you're in a Git repository:
   ```bash
   git init  # if needed
   ```

3. Check `.gitignore` - telescope respects it, so large ignored directories won't be searched.

### Completion Not Working

**Problem**: Autocomplete isn't showing up.

**Solution**:
1. Make sure an LSP is running: `:LspInfo`
2. Try manually triggering completion: `<C-Space>`
3. Check you're in a recognized file type: `:set filetype`

### Pipenv Environment Not Loading

**Problem**: Python virtual environment isn't being activated.

**Solution**:
1. Verify pipenv is installed:
   ```bash
   pipenv --version
   ```

2. Verify you have a `Pipfile` in your project root:
   ```bash
   ls Pipfile
   ```

3. Manually select environment:
   ```bash
   # In Neovim, run:
   :VenvSelect
   ```

4. Check Python path being used:
   ```bash
   :!which python
   ```

## Uninstallation

If you need to remove the configuration:

```bash
# Backup (optional)
mv ~/.config/nvim ~/.config/nvim.backup

# Remove plugins
rm -rf ~/.local/share/nvim/lazy

# Remove cache
rm -rf ~/.local/share/nvim
```

## Updating

To keep plugins up to date:

```bash
# In Neovim, run:
:Lazy update
```

Or from the command line:
```bash
nvim --cmd "source ~/.config/nvim/init.lua" -c "Lazy update" -c "qa"
```

## Common Issues & Solutions

### "Command not found: gopls/clangd/pyright"

The language server isn't in your PATH. Make sure it's installed and reload your shell:

```bash
# After installing, reload shell
exec $SHELL

# Or source your config
source ~/.zshrc  # or ~/.bashrc
```

### "Telescope executable 'fd' not found"

Install fd:
```bash
brew install fd      # macOS
sudo apt install fd-find  # Ubuntu/Debian
```

### Colors Look Wrong

This is usually a terminal theme issue. The config uses true color (24-bit). Make sure your terminal supports it:

1. Set `TERM=xterm-256color` in your shell config
2. Or use a modern terminal: iTerm2, Alacritty, Kitty, etc.

### Performance Issues on Large Projects

For very large projects (100k+ files):

1. Install `ripgrep`:
   ```bash
   brew install ripgrep  # macOS
   ```

2. Create a `.gitignore` to exclude build directories:
   ```bash
   echo "node_modules/" >> .gitignore
   echo "build/" >> .gitignore
   echo ".venv/" >> .gitignore
   ```

3. Run telescope with a smaller initial directory

## Getting Help

- **Neovim Documentation**: `:help` in Neovim
- **LSP Issues**: `:LspInfo` to diagnose
- **Plugin Status**: `:Lazy` to check plugin health
- **Health Check**: `:checkhealth` for comprehensive diagnosis

See `README.md` for feature documentation and keyboard shortcuts.

# Auto-Formatting on Save

## Overview

Auto-formatting automatically formats your code when you save the file. This ensures consistent code style across your project without manual intervention.

## How It Works

The `conform.nvim` plugin:

1. **Detects file type** when you save (Go, Python, C, Lua, etc.)
2. **Runs appropriate formatter** for that language
3. **Formats the file** in-place
4. **Falls back to LSP** if dedicated formatter isn't available

## Supported Languages

| Language | Formatter(s) | Auto-Format |
|----------|--------------|------------|
| Go | goimports, golines | ✅ Yes |
| Python | black, isort | ✅ Yes |
| C | clang-format | ✅ Yes |
| Lua | stylua | ✅ Yes |
| Markdown | prettier | ✅ Yes |
| JSON | prettier | ✅ Yes |
| YAML | prettier | ✅ Yes |

### How Formatters Work

Each language uses a specific formatter:

- **Go**: `goimports` (organize imports), `golines` (line length)
- **Python**: `black` (code style), `isort` (import sorting)
- **C**: `clang-format` (code formatting)
- **Lua**: `stylua` (Lua formatter)
- **Markdown/JSON/YAML**: `prettier` (multi-language formatter)

## Manual Formatting

To format without saving:

```vim
<leader>cf    " Format current file
```

Or in visual mode to format selection:

```vim
<leader>cf    " Format selected lines
```

## Installation of Formatters

For formatters to work, you need to install them on your system:

### Go

```bash
go install github.com/dinkur/golines@latest
go install golang.org/x/tools/cmd/goimports@latest
```

### Python

```bash
pip install black isort
```

### C

```bash
# macOS
brew install clang-format

# Linux
apt-get install clang-format
```

### Lua

```bash
cargo install stylua
# or
brew install stylua
```

### Markdown/JSON/YAML

```bash
npm install -g prettier
# or
brew install prettier
```

## Configuration

Edit the `conform.setup()` call in `init.lua` to customize:

### Add More Languages

```lua
conform.setup({
  formatters_by_ft = {
    go = { "goimports", "golines" },
    python = { "black", "isort" },
    -- Add more:
    ruby = { "prettier" },
    rust = { "rustfmt" },
  },
})
```

### Disable Auto-Format on Save

To manually format only (not on save):

```lua
format_on_save = {
  timeout_ms = 500,
  lsp_fallback = true,
},
```

Comment out or remove this section entirely.

### Change Timeout

If formatting is too slow, increase timeout (in milliseconds):

```lua
format_on_save = {
  timeout_ms = 1000,  -- Wait up to 1 second before timeout
  lsp_fallback = true,
}
```

### Disable for Specific Filetypes

```lua
format_on_save = {
  timeout_ms = 500,
  lsp_fallback = true,
  ignore_filetypes = { "markdown", "text" },  -- Don't format these
}
```

## LSP Fallback

If no dedicated formatter is installed for a language, `conform.nvim` falls back to the LSP server's formatting capabilities (if available).

To disable LSP fallback:

```lua
format_on_save = {
  timeout_ms = 500,
  lsp_fallback = false,  -- Don't use LSP formatting
}
```

## Troubleshooting

### Formatter Not Found

If you see an error like `Formatter "black" not found`:

1. **Install the formatter**: See [Installation of Formatters](#installation-of-formatters) section
2. **Verify it's in PATH**:
   ```bash
   which black    # Should show the path
   ```
3. **Restart Neovim** after installing

### Formatting Takes Too Long

1. Increase the timeout in config:
   ```lua
   timeout_ms = 2000,  -- 2 seconds
   ```
2. Or disable auto-format on save and use `<leader>cf` manually

### File Format Changed Unexpectedly

1. This is usually correct behavior (formatter fixing style)
2. Check the formatter's rules for your language
3. You can revert with `u` (undo) if unwanted

### Conflict Between Formatters

If multiple formatters modify the file differently:

1. Remove the conflicting formatter from `formatters_by_ft`
2. Or adjust formatter configuration files (`.prettierrc`, `setup.cfg`, etc.)

Example: Don't use both `black` and `isort` if they conflict:

```lua
python = { "black" },  -- Remove "isort" if it causes issues
```

## Formatter Configuration Files

Formatters respect project-level configuration:

- **Go**: No config needed (uses defaults)
- **Python**: `.black.toml`, `setup.cfg`, `pyproject.toml` for black
- **C**: `.clang-format` file
- **Lua**: `.stylua.toml` or `stylua.toml`
- **Prettier**: `.prettierrc`, `.prettierrc.json`, `prettier.config.js`

Create these files in your project root to customize formatter behavior.

## Tips & Tricks

1. **Check What Changed**: After auto-format, use `git diff` to see what the formatter changed
2. **Pre-commit Hook**: Use formatters in git pre-commit hooks to ensure consistency
3. **Format on Key Combination**: Already mapped to `<leader>cf` for manual formatting
4. **Disable for Certain Files**: Create `.stylua.toml` (or similar) with exclusion patterns

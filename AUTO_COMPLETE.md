# Auto-Complete & Auto-Closing Brackets

## Overview

Your Neovim config includes two complementary features for efficient code editing:

1. **Auto-complete (nvim-cmp)**: Provides intelligent code suggestions from LSP, snippets, and buffers
2. **Auto-closing brackets (nvim-autopairs)**: Automatically closes brackets, parentheses, and quotes

## Auto-Complete (nvim-cmp)

### How It Works

nvim-cmp is an auto-completion engine that aggregates suggestions from multiple sources:

- **LSP (Language Server Protocol)**: Smart suggestions from gopls, clangd, pyright, etc.
- **Snippets (LuaSnip)**: Expandable code templates
- **Buffer**: Words from the current file
- **Path**: File paths for imports

### Triggering Auto-Complete

Auto-complete appears automatically as you type. You can also manually trigger it:

```vim
<C-Space>     " Manually open completion menu
```

### Navigation & Selection

Once the completion menu is open:

```vim
<C-f>         " Scroll completion docs down
<C-b>         " Scroll completion docs up
<Tab>         " Select next item / jump to next snippet placeholder
<S-Tab>       " Select previous item / jump to previous snippet placeholder
<C-e>         " Close completion menu
<CR>          " Confirm selected completion
```

### Sources Priority

Completions are provided in this order (first source takes priority):

1. LSP completions (from language servers)
2. Snippet completions (from LuaSnip)
3. Buffer completions (from open files)
4. Path completions (file system)

### Customizing Auto-Complete

To modify completion behavior, edit the `cmp.setup()` call in `init.lua`:

```lua
cmp.setup({
  -- Add new sources
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "path" },
    -- Add more: { name = "calc" }, { name = "emoji" }, etc.
  }),
})
```

To add more completion sources, install the corresponding plugin and add it to `sources`.

## Auto-Closing Brackets (nvim-autopairs)

### How It Works

nvim-autopairs automatically closes pairs when you type an opening character:

| Input | Result |
|-------|--------|
| `(` | `()` cursor inside |
| `[` | `[]` cursor inside |
| `{` | `{}` cursor inside |
| `"` | `""` cursor inside |
| `'` | `''` cursor inside |
| `` ` `` | ``` `` ``` cursor inside |

### Integration with Completion

When you confirm a completion with `<CR>`, autopairs:

1. Inserts the selected completion
2. Automatically handles bracket pairing
3. Respects Treesitter syntax understanding (if enabled)

Example: Type `func` → select function completion → press `<CR>` → autopairs adds proper closing brackets

### Customizing Auto-Closing

Edit the `nvim-autopairs` config in `init.lua`:

```lua
require("nvim-autopairs").setup({
  check_ts = true,   -- Use Treesitter for smarter pairing
  map_cr = true,     -- Enable <CR> mapping for completion
  map_bs = true,     -- Enable <BS> (backspace) mapping
  -- Customize pairs:
  disable_filetype = { "TelescopePrompt" },  -- Disable in certain filetypes
})
```

### Escape Auto-Pairing

To avoid auto-pairing in specific situations:

```vim
Ctrl-v (                " Insert literal ( without auto-pairing (on some configs)
```

Or manually delete the pair:

```vim
)        " Move outside the pair without deleting it
```

## Troubleshooting

### Completion not appearing

1. Check that the language server is running: `:LspInfo`
2. Ensure the file type is recognized: `:set filetype?`
3. Manually trigger with `<C-Space>`

### Auto-pairs not working

1. Verify nvim-autopairs is installed: `:Lazy` and look for `nvim-autopairs`
2. Check if disabled for current filetype in setup
3. Try in a new line or after whitespace

### Conflicts with custom keybindings

If `<Tab>` or `<CR>` conflicts with other plugins:

Edit the keymapping section in `init.lua` under `cmp.setup()`:

```lua
mapping = cmp.mapping.preset.insert({
  -- Change keybindings here
  ["<C-j>"] = cmp.mapping.select_next_item(),  -- Use Ctrl-j instead of Tab
  ["<C-k>"] = cmp.mapping.select_prev_item(),  -- Use Ctrl-k instead of S-Tab
}),
```

## Tips & Tricks

1. **Snippet Expansion**: Type a snippet prefix (like `for` in Go) and press `<Tab>` to expand
2. **Path Completion**: Start typing a path in an import and `<C-Space>` will suggest files
3. **LSP Hover**: Press `K` after selecting a completion to see full documentation
4. **Undo Auto-Pair**: If autopairs adds unwanted brackets, press `<BS>` (backspace) once to delete the pair

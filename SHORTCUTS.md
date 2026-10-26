# Keyboard Shortcuts

`<leader>` is **Space**. Press `<leader>` and wait to see every group in which-key.

## Splits/Windows

| Key | Action |
|-----|--------|
| `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` | Move to the left / lower / upper / right window |
| `<leader>wh` | Split horizontally |
| `<leader>wv` | Split vertically |
| `<leader>wc` | Close window |

## Buffers

| Key | Action |
|-----|--------|
| `<S-h>` | Previous buffer (shown as tabs at the top) |
| `<S-l>` | Next buffer |
| `<leader>bd` | Close buffer |

## Files & Search

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>fh` | Help tags |
| `<leader>/` | Fuzzy search in current file |

## Navigation

| Key | Action |
|-----|--------|
| `s` | Flash jump |
| `S` | Flash treesitter jump |
| `<leader>ha` | Harpoon: add file |
| `<leader>hh` | Harpoon: menu |
| `<leader>1` – `<leader>4` | Harpoon: jump to file 1–4 |
| `<leader>as` | Aerial outline |
| `[[` / `]]` | Previous / next symbol |

## LSP

Only in buffers with a language server attached.

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `grr` | References |
| `gri` | Implementation |
| `K` | Hover (or peek fold) |
| `<leader>cr` | Rename |
| `<leader>ca` | Code action |
| `<leader>cd` | Diagnostics float |

## Completion

| Key | Action |
|-----|--------|
| `<C-Space>` | Trigger completion |
| `<Tab>` / `<S-Tab>` | Next / previous item |
| `<CR>` | Confirm selected item |
| `<C-e>` | Abort |

## Editing

| Key | Action |
|-----|--------|
| `gcc` | Comment line |
| `gc{motion}` | Comment motion / selection |
| `ys{motion}{char}` | Add surround |
| `cs{old}{new}` | Change surround |
| `ds{char}` | Delete surround |
| `<leader>cf` | Format buffer |
| `<leader>uu` | Undotree |

## Markdown

| Key | Action |
|-----|--------|
| `<leader>mr` | Toggle in-buffer render |
| `<leader>mp` | Toggle browser preview (markdown files only) |
| `<leader>mx` | Run the code block under the cursor (markdown files only) |
| `<leader>ml` | Check links in every markdown file in the project |
| `<leader>mo` | Outline of every heading in the project |

## Folding

| Key | Action |
|-----|--------|
| `zR` | Open all folds |
| `zM` | Close all folds |

## Search & Replace

| Key | Action |
|-----|--------|
| `<leader>sr` | Spectre |
| `<leader>sw` | Replace word under cursor |

## Debugging

| Key | Action |
|-----|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue |
| `<leader>ds` | Step over |
| `<leader>di` | Step into |
| `<leader>do` | Step out |
| `<leader>du` | Toggle DAP UI |

## Testing

| Key | Action |
|-----|--------|
| `<leader>tt` | Run nearest test |
| `<leader>tf` | Run file |
| `<leader>ts` | Toggle summary |
| `<leader>to` | Show output |

## Git

| Key | Action |
|-----|--------|
| `<leader>gg` | Lazygit |
| `<leader>gb` | Toggle line blame |
| `<leader>gs` | Stage hunk |
| `<leader>gr` | Reset hunk |
| `<leader>gp` | Preview hunk |
| `]h` / `[h` | Next / previous hunk |

## Diagnostics

| Key | Action |
|-----|--------|
| `<leader>xx` | Toggle Trouble |
| `<leader>xd` | Buffer diagnostics |
| `<leader>xl` | Location list |
| `<leader>xq` | Quickfix list |

## TODO comments

| Key | Action |
|-----|--------|
| `]t` / `[t` | Next / previous TODO |
| `<leader>ft` | Search all TODOs |

## Terminal

| Key | Action |
|-----|--------|
| `<C-\>` | Toggle floating terminal |

## Appearance

| Key | Action |
|-----|--------|
| `<leader>ua` | Open the Appearance window |
| `<leader>ut` | Pick theme |
| `<leader>uf` | Pick terminal font |

Inside the Appearance window:

| Key | Action |
|-----|--------|
| `t` | Pick theme |
| `f` | Pick font |
| `-` / `+` | Decrease / increase font size |
| `q` / `<Esc>` | Close |

## File explorer

| Key | Action |
|-----|--------|
| `<leader>e` | Toggle nvim-tree |

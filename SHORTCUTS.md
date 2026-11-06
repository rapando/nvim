# Keyboard Shortcuts

`<leader>` is **Space**. Press `<leader>` and wait to see every group in which-key.

The **Mac** column spells out what to press: `Ctrl+h` means hold Control and press h, and keys separated by spaces are pressed one after another (`Space f f` is Space, then f, then f).

## Splits/Windows

| Key | Mac | Action |
|-----|-----|--------|
| `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` | `Ctrl+h` / `Ctrl+j` / `Ctrl+k` / `Ctrl+l` | Move to the left / lower / upper / right window |
| `<leader>wh` | `Space w h` | Split horizontally |
| `<leader>wv` | `Space w v` | Split vertically |
| `<leader>wc` | `Space w c` | Close window |

## Buffers

| Key | Mac | Action |
|-----|-----|--------|
| `<S-h>` | `Shift+h` | Previous buffer (open files are listed at the bottom; click one to open it) |
| `<S-l>` | `Shift+l` | Next buffer |
| `<C-^>` | `Ctrl+6` | Jump back to the previous file |
| `<leader>bd` | `Space b d` | Close buffer |

## Files & Search

| Key | Mac | Action |
|-----|-----|--------|
| `<leader>ff` | `Space f f` | Find files |
| `<leader>fg` | `Space f g` | Live grep |
| `<leader>fb` | `Space f b` | Buffers |
| `<leader>fh` | `Space f h` | Help tags |
| `<leader>/` | `Space /` | Fuzzy search in current file |

## Navigation

| Key | Mac | Action |
|-----|-----|--------|
| `s` | `s` | Flash jump |
| `S` | `Shift+s` | Flash treesitter jump |
| `<leader>ha` | `Space h a` | Harpoon: add file |
| `<leader>hh` | `Space h h` | Harpoon: menu |
| `<leader>1` – `<leader>4` | `Space 1` – `Space 4` | Harpoon: jump to file 1–4 |
| `<leader>as` | `Space a s` | Aerial outline |
| `[[` / `]]` | `[ [` / `] ]` | Previous / next symbol |

## LSP

Only in buffers with a language server attached.

| Key | Mac | Action |
|-----|-----|--------|
| `gd` | `g d` | Go to definition |
| `grr` | `g r r` | References |
| `gri` | `g r i` | Implementation |
| `K` | `Shift+k` | Hover (or peek fold) |
| `<leader>cr` | `Space c r` | Rename |
| `<leader>ca` | `Space c a` | Code action |
| `<leader>cd` | `Space c d` | Diagnostics float |

## Completion

| Key | Mac | Action |
|-----|-----|--------|
| `<C-Space>` | `Ctrl+Space` | Trigger completion |
| `<Tab>` / `<S-Tab>` | `Tab` / `Shift+Tab` | Next / previous item |
| `<CR>` | `Return` | Confirm selected item |
| `<C-e>` | `Ctrl+e` | Abort |

## Editing

| Key | Mac | Action |
|-----|-----|--------|
| `gcc` | `g c c` | Comment line |
| `gc{motion}` | `g c {motion}` | Comment motion / selection |
| `ys{motion}{char}` | `y s {motion} {char}` | Add surround |
| `cs{old}{new}` | `c s {old} {new}` | Change surround |
| `ds{char}` | `d s {char}` | Delete surround |
| `<leader>cf` | `Space c f` | Format buffer |
| `<leader>uu` | `Space u u` | Undotree |

## Markdown

| Key | Mac | Action |
|-----|-----|--------|
| `<leader>mr` | `Space m r` | Toggle in-buffer render |
| `<leader>mp` | `Space m p` | Toggle browser preview (markdown files only) |
| `<leader>mx` | `Space m x` | Run the code block under the cursor (markdown files only) |
| `<leader>ml` | `Space m l` | Check links in every markdown file in the project |
| `<leader>mo` | `Space m o` | Outline of every heading in the project |

## Folding

| Key | Mac | Action |
|-----|-----|--------|
| `zR` | `z Shift+r` | Open all folds |
| `zM` | `z Shift+m` | Close all folds |

## Search & Replace

| Key | Mac | Action |
|-----|-----|--------|
| `<leader>sr` | `Space s r` | Spectre |
| `<leader>sw` | `Space s w` | Replace word under cursor |

## Debugging

| Key | Mac | Action |
|-----|-----|--------|
| `<leader>db` | `Space d b` | Toggle breakpoint |
| `<leader>dc` | `Space d c` | Continue |
| `<leader>ds` | `Space d s` | Step over |
| `<leader>di` | `Space d i` | Step into |
| `<leader>do` | `Space d o` | Step out |
| `<leader>du` | `Space d u` | Toggle DAP UI |

## Testing

| Key | Mac | Action |
|-----|-----|--------|
| `<leader>tt` | `Space t t` | Run nearest test |
| `<leader>tf` | `Space t f` | Run file |
| `<leader>ts` | `Space t s` | Toggle summary |
| `<leader>to` | `Space t o` | Show output |

## Git

| Key | Mac | Action |
|-----|-----|--------|
| `<leader>gg` | `Space g g` | Lazygit |
| `<leader>gb` | `Space g b` | Toggle line blame |
| `<leader>gs` | `Space g s` | Stage hunk |
| `<leader>gr` | `Space g r` | Reset hunk |
| `<leader>gp` | `Space g p` | Preview hunk |
| `]h` / `[h` | `] h` / `[ h` | Next / previous hunk |

## Diagnostics

| Key | Mac | Action |
|-----|-----|--------|
| `<leader>xx` | `Space x x` | Toggle Trouble |
| `<leader>xd` | `Space x d` | Buffer diagnostics |
| `<leader>xl` | `Space x l` | Location list |
| `<leader>xq` | `Space x q` | Quickfix list |

## TODO comments

| Key | Mac | Action |
|-----|-----|--------|
| `]t` / `[t` | `] t` / `[ t` | Next / previous TODO |
| `<leader>ft` | `Space f t` | Search all TODOs |

## Terminal

| Key | Mac | Action |
|-----|-----|--------|
| `<C-\>` | `Ctrl+\` | Toggle floating terminal (hides and restores every pane) |
| `<C-Space>` | `Ctrl+Space` | Leave terminal mode, so the keys below work (`i` goes back to typing in the shell) |
| `<leader>wv` | `Space w v` | Split the current pane side by side |
| `<leader>wh` | `Space w h` | Split the current pane top and bottom |
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | `Ctrl+h` `Ctrl+j` `Ctrl+k` `Ctrl+l` | Move to the pane left / below / above / right |
| `<leader>wc` | `Space w c` | Close the current pane (`exit` in the shell does the same) |
| `<C-c>` | `Ctrl+c` | Stop the running process, as in any terminal. Also works after `<C-Space>`, and puts you back in the shell |

Inside the floating terminal these keys act on its panes. Everywhere else they split and move between editor windows as usual.

## Appearance

| Key | Mac | Action |
|-----|-----|--------|
| `<leader>ua` | `Space u a` | Open the Appearance window |
| `<leader>ut` | `Space u t` | Pick theme |
| `<leader>uf` | `Space u f` | Pick terminal font |

Inside the Appearance window:

| Key | Mac | Action |
|-----|-----|--------|
| `t` | `t` | Pick theme |
| `f` | `f` | Pick font |
| `-` / `+` | `-` / `+` | Decrease / increase font size |
| `q` / `<Esc>` | `q` / `Esc` | Close |

## File explorer

| Key | Mac | Action |
|-----|-----|--------|
| `<leader>e` | `Space e` | Toggle nvim-tree |

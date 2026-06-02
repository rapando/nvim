# Keyboard Shortcuts

`<leader>` is the **Space** key.

## Splits & Windows

| Key | Action |
|-----|--------|
| `<C-h>` / `<C-l>` | Move to left / right split |
| `<C-j>` / `<C-k>` | Move to bottom / top split |
| `<leader>sh` | Split horizontal |
| `<leader>sv` | Split vertical |
| `<leader>sc` | Close split |

## Buffers

| Key | Action |
|-----|--------|
| `<S-h>` / `<S-l>` | Prev / next buffer tab |
| `<leader>bd` | Close current buffer |

## Files & Search (Telescope)

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep (search project) |
| `<leader>fb` | Find open buffers |
| `<leader>fh` | Search help tags |
| `<leader>/` | Fuzzy search in current file |

## Navigation

| Key | Action |
|-----|--------|
| `s` | Flash: jump to any label on screen |
| `S` | Flash: treesitter-aware jump |
| `<leader>ha` | Harpoon: bookmark current file |
| `<leader>hh` | Harpoon: open bookmarks menu |
| `<leader>1` | Jump to harpoon bookmark 1 |
| `<leader>2` | Jump to harpoon bookmark 2 |
| `<leader>3` | Jump to harpoon bookmark 3 |
| `<leader>4` | Jump to harpoon bookmark 4 |
| `<leader>as` | Toggle symbols outline (aerial) |
| `{` / `}` | Prev / next symbol in aerial |

## LSP

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover docs; peeks folded lines if cursor is on a fold |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>e` | Show diagnostics float |

## Completion

| Key | Action |
|-----|--------|
| `<C-Space>` | Trigger completion |
| `<Tab>` / `<S-Tab>` | Next / prev item |
| `<CR>` | Confirm selection |
| `<C-e>` | Abort completion |

## Editing

| Key | Action |
|-----|--------|
| `gcc` | Toggle line comment |
| `gc` (visual) | Toggle comment on selection |
| `ys{motion}{char}` | Add surrounding character |
| `cs{old}{new}` | Change surrounding character |
| `ds{char}` | Delete surrounding character |
| `<leader>cf` | Format file or selection |
| `<leader>u` | Toggle undo history tree |

## Folding

| Key | Action |
|-----|--------|
| `zR` | Open all folds |
| `zM` | Close all folds |

## Search & Replace

| Key | Action |
|-----|--------|
| `<leader>sr` | Open Spectre (project-wide find & replace) |
| `<leader>sw` | Replace word under cursor (Spectre) |

## Debugging

| Key | Action |
|-----|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue |
| `<leader>ds` | Step over |
| `<leader>di` | Step into |
| `<leader>do` | Step out |
| `<leader>du` | Toggle debug UI panel |

## Testing (Neotest)

| Key | Action |
|-----|--------|
| `<leader>tt` | Run nearest test |
| `<leader>tf` | Run all tests in file |
| `<leader>ts` | Toggle test summary panel |
| `<leader>to` | Open test output |

## Git

| Key | Action |
|-----|--------|
| `<leader>gg` | Open Lazygit |
| `<leader>gb` | Toggle inline line blame |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hp` | Preview hunk |
| `]h` / `[h` | Next / prev hunk |

## Diagnostics (Trouble)

| Key | Action |
|-----|--------|
| `<leader>xx` | Toggle trouble panel |
| `<leader>xd` | Buffer diagnostics |
| `<leader>xl` | Location list |
| `<leader>xq` | Quickfix list |

## TODO Comments

| Key | Action |
|-----|--------|
| `]t` / `[t` | Next / prev TODO comment |
| `<leader>ft` | Search all TODOs with Telescope |

## Terminal

| Key | Action |
|-----|--------|
| `<C-\>` | Toggle floating terminal |

## Go (go.nvim)

| Key | Action |
|-----|--------|
| `<leader>gt` | Run tests |
| `<leader>gf` | Fill struct fields |
| `<leader>gi` | Implement interface |
| `<leader>gat` | Add struct tags |

## AI (Claude / Avante)

| Key | Action |
|-----|--------|
| `<leader>aa` | Toggle Avante AI sidebar |
| `<leader>ae` | Edit selection with AI instruction |
| `<leader>ar` | Refresh Avante |
| `<leader>af` | Focus Avante window |

## File Explorer

| Key | Action |
|-----|--------|
| `<leader>e` | Toggle file explorer (nvim-tree) |

## Python

| Key | Action |
|-----|--------|
| `<leader>vs` | Select Python virtual environment |

## Themes

| Key | Action |
|-----|--------|
| `<leader>th` | Open theme picker (scroll to preview, Enter to confirm, Esc to cancel) |

## Pets

| Key | Action |
|-----|--------|
| `<leader>pa` | Spawn a new pet |
| `<leader>pk` | Kill all pets |
| `<leader>ps` | List active pets |

## Fun

| Key | Action |
|-----|--------|
| `<leader>mr` | Make it rain |
| `<leader>ml` | Game of life |

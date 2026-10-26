# mdx.nvim

Markdown extras for Neovim, built on top of [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim). It lives inside this config for now and is laid out as a standalone plugin, so it can move to its own repo unchanged.

| Feature | What you see |
|---------|--------------|
| Task progress | `━━━━━───── 2/4` after any heading whose section has checkboxes. A heading whose tasks all sit in one subsection is skipped. |
| Table bars | A bar after each row for the rightmost numeric column, plus `min · max · mean · rows` under the table |
| Run code blocks | `<leader>mx` runs the block under the cursor and shows exit code, time and output under it. Editing the block hides the stale output. |
| Link checks | Broken relative links and `#anchors` become warnings (`vim.diagnostic`, so they show in Trouble) |
| Mermaid as text | ` ```mermaid ` flowcharts (`graph`/`flowchart`, `LR` or `TD`) drawn with box characters under the fence |
| Outline | `<leader>mo`: Telescope picker over every heading in the project's markdown files, with task counts |

## How it draws

render-markdown calls mdx as its custom `markdown` handler (`extends = true`, so render-markdown's own rendering still runs). mdx marks therefore follow render-markdown's rules: they redraw on edits, hide on the cursor line where that makes sense, and clear in insert mode.

If render-markdown isn't loaded, or never calls the handler for a buffer, mdx draws by itself within 300 ms using its own namespace.

## Setup

In this config (`lua/plugins/markdown.lua`):

```lua
{
  dir = vim.fn.stdpath("config") .. "/mdx.nvim",
  name = "mdx",
  ft = { "markdown" },
  cmd = "Mdx",
  opts = {},
},
{
  "MeanderingProgrammer/render-markdown.nvim",
  version = "^8",
  dependencies = { "mdx" },
  opts = {
    custom_handlers = {
      markdown = { extends = true, parse = function(ctx) return require("mdx").handler().parse(ctx) end },
    },
  },
},
```

## Options

```lua
opts = {
  progress = { enabled = true, width = 10 },
  tables = { enabled = true, width = 16, summary = true },
  links = { enabled = true },
  run = { enabled = true, timeout = 10000, max_lines = 30 },
  -- "auto": skip diagrams snacks.nvim draws as images (mmdc installed + Ghostty/kitty)
  -- "text": always draw; false: never
  mermaid = { mode = "auto", max_label = 24, max_nodes = 40 },
}
```

### Per-table settings

Put an HTML comment directly above a table (render-markdown hides it):

```markdown
<!-- mdx: col=p99 warn=150 error=500 -->
| Endpoint | p50 | p99 |
```

- `col=` picks the column by header name or number.
- `warn=`/`error=` colour bars at or above those values.
- `<!-- mdx: off -->` turns bars and the summary off for that table.

## Running code

Code only runs when you ask (`<leader>mx` or `:Mdx run`), never when a file opens.

| Fence | Runs with |
|-------|-----------|
| `python`, `py` | `$VIRTUAL_ENV/bin/python` if set (the Pipfile venv from `config.pipenv`), else `python3` |
| `go`, `golang` | `go run` in a temp dir. A snippet without `package` is wrapped in `func main()`, and `goimports` adds imports. |
| `bash`, `sh`, `zsh`, `shell` | that shell with `-c` |
| `lua` | `nvim -l` |

Python and shell blocks run in the markdown file's directory. Runs time out after `run.timeout` ms. `:Mdx clear` removes all output.

## Commands

`:Mdx run` · `:Mdx clear` · `:Mdx links` (project check into quickfix/Trouble) · `:Mdx outline` · `:Mdx refresh`

`:checkhealth mdx` shows whether it is drawing through render-markdown and which runners are available.

## Limits

- **Mermaid:** subgraphs, edge labels and styles are ignored, and other diagram types (sequence, gantt, …) show a one-line note. Cycles are drawn without their back edge.
- **Outline and project link check:** these read files line by line instead of through treesitter. Headings in front matter or HTML blocks may be miscounted.
- **Highlights:** colours link to `Diagnostic*`, `LineNr` and `Title`, so they follow the theme. Override any `Mdx*` group to change them.

## Tests

```sh
make test-md   # from the config root
```

`make test-md` renders `tests/fixture.md` headlessly twice, once through render-markdown with this config's options and once standalone. It checks every feature, then exits non-zero on failure. Run it after `:Lazy update`.

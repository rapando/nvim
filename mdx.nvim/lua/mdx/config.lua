local M = {}

---@class mdx.Config
M.defaults = {
  -- "2/4" with a bar after any heading whose section contains task checkboxes
  progress = { enabled = true, width = 10 },
  -- Bars after each row for the rightmost numeric column, plus a summary line.
  -- Per table: <!-- mdx: col=p99 warn=150 error=500 --> or <!-- mdx: off --> right above it
  tables = { enabled = true, width = 16, summary = true },
  -- Broken relative links and #anchors as diagnostics
  links = { enabled = true },
  -- Code blocks run only on demand (<leader>mx); output shows under the block
  run = {
    enabled = true,
    timeout = 10000, -- ms
    max_lines = 30,
  },
  -- Text-drawn flowcharts under ```mermaid fences.
  -- "auto": skip when snacks.nvim can draw the real diagram (mmdc installed + Ghostty/kitty)
  -- "text": always draw; false: never
  mermaid = { mode = "auto", max_label = 24, max_nodes = 40 },
}

---@type mdx.Config
M.options = vim.deepcopy(M.defaults)

function M.set(opts)
  M.options = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), opts or {})
end

return M

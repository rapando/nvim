-- Telescope picker over every heading in the project's markdown files, with task progress
local util = require("mdx.util")
local M = {}

function M.entries(root)
  local out = {}
  for _, file in ipairs(util.md_files(root)) do
    local buf = vim.fn.bufnr(file)
    local lines = (buf ~= -1 and vim.api.nvim_buf_is_loaded(buf)) and vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      or vim.fn.readfile(file)
    local rel = vim.fs.relpath(root, file) or file
    for _, h in ipairs(util.scan(lines).headings) do
      out[#out + 1] = { file = file, rel = rel, row = h.row, level = h.level, text = h.text, done = h.done, total = h.total }
    end
  end
  table.sort(out, function(a, b)
    if a.rel ~= b.rel then return a.rel < b.rel end
    return a.row < b.row
  end)
  return out
end

function M.open()
  local ok = pcall(require, "telescope")
  if not ok then return vim.notify("mdx: the outline needs telescope.nvim", vim.log.levels.WARN) end
  local pickers, finders = require("telescope.pickers"), require("telescope.finders")
  local conf = require("telescope.config").values
  local entry_display = require("telescope.pickers.entry_display")

  local root = vim.fn.getcwd()
  local entries = M.entries(root)
  if #entries == 0 then return vim.notify("mdx: no markdown headings under " .. root) end

  local file_w = 0
  for _, e in ipairs(entries) do file_w = math.max(file_w, #e.rel) end
  local displayer = entry_display.create({
    separator = "  ",
    items = { { width = math.min(file_w, 32) }, { remaining = true }, { width = 6, right_justify = true } },
  })

  pickers.new({}, {
    prompt_title = "Markdown outline",
    finder = finders.new_table({
      results = entries,
      entry_maker = function(e)
        local progress = e.total > 0 and (e.done .. "/" .. e.total) or ""
        return {
          value = e,
          ordinal = e.rel .. " " .. e.text,
          filename = e.file,
          lnum = e.row + 1,
          col = 1,
          display = function()
            return displayer({
              { e.rel, "TelescopeResultsComment" },
              { string.rep("  ", e.level - 1) .. e.text, e.level <= 2 and "Title" or "Normal" },
              { progress, e.total > 0 and e.done == e.total and "MdxDone" or "MdxDim" },
            })
          end,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = conf.grep_previewer({}),
  }):find()
end

return M

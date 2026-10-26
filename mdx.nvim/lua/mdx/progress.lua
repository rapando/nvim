-- "━━━━━───── 2/4" after headings whose section (including subsections) has checkboxes.
-- A heading whose tasks all sit in one subsection is skipped: that subsection already shows them.
local M = {}

local tasks

local function bar(heading, done, total, width)
  local full = math.floor(done / total * width + 0.5)
  local hl = done == total and "MdxDone" or "MdxProgress"
  return {
    conceal = true,
    start_row = heading:start(),
    start_col = 0,
    opts = {
      virt_text = {
        { "  " },
        { string.rep("━", full), hl },
        { string.rep("─", width - full) .. " ", "MdxDim" },
        { done .. "/" .. total, done == total and "MdxDone" or "MdxDim" },
      },
      virt_text_pos = "eol",
      hl_mode = "combine",
    },
  }
end

---@return integer done, integer total
local function walk(section, buf, opts, marks)
  local done, total, direct, children = 0, 0, 0, 0
  local heading
  for child in section:iter_children() do
    local t = child:type()
    if t == "atx_heading" then
      heading = child
    elseif t == "section" then
      local d, n = walk(child, buf, opts, marks)
      done, total = done + d, total + n
      if n > 0 then children = children + 1 end
    elseif child:named() then
      for _, task in tasks:iter_captures(child, buf) do
        total, direct = total + 1, direct + 1
        if task:type() == "task_list_marker_checked" then done = done + 1 end
      end
    end
  end
  if heading and total > 0 and (direct > 0 or children > 1) then
    marks[#marks + 1] = bar(heading, done, total, opts.width)
  end
  return done, total
end

function M.marks(buf, root, opts)
  tasks = tasks or vim.treesitter.query.parse("markdown",
    "[(task_list_marker_checked) (task_list_marker_unchecked)] @task")
  local marks = {}
  for child in root:iter_children() do
    if child:type() == "section" then walk(child, buf, opts, marks) end
  end
  return marks
end

return M

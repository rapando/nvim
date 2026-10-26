-- Bars after each row for one numeric column, and a min/max/mean line under the table
local util = require("mdx.util")
local M = {}

local query

---"41 ms" -> 41, "1,250" -> 1250, "12%" -> 12; nil when the cell isn't a number
local function number(cell)
  local s = vim.trim(cell:gsub("[`*_]", ""):gsub(",", ""))
  local n = s:match("^([%-+]?%d*%.?%d+)%s*[%a%%µ]*$")
  return tonumber(n)
end

local function cells(row, buf)
  local out = {}
  for child in row:iter_children() do
    if child:type() == "pipe_table_cell" then out[#out + 1] = vim.trim(util.text(child, buf)) end
  end
  return out
end

---Settings from an <!-- mdx: key=value ... --> comment right above the table
local function directive(tbl, buf)
  local prev = tbl:prev_named_sibling()
  if not prev or prev:type() ~= "html_block" or util.last_row(prev) ~= tbl:start() - 1 then return {} end
  local body = util.text(prev, buf):match("<!%-%-%s*mdx:(.-)%-%->")
  if not body then return {} end
  local d = { off = body:match("%f[%w]off%f[%W]") ~= nil }
  for k, v in body:gmatch("(%w+)=(%S+)") do d[k] = tonumber(v) or v end
  return d
end

function M.marks(buf, root, opts)
  query = query or vim.treesitter.query.parse("markdown", "(pipe_table) @table")
  local marks = {}
  local line_count = vim.api.nvim_buf_line_count(buf)
  for _, tbl in query:iter_captures(root, buf) do
    local d = directive(tbl, buf)
    if not d.off then
      local header, rows = {}, {}
      for child in tbl:iter_children() do
        if child:type() == "pipe_table_header" then header = cells(child, buf)
        elseif child:type() == "pipe_table_row" then rows[#rows + 1] = { row = child:start(), cells = cells(child, buf) } end
      end

      -- column: named by the directive, else the rightmost column that is numeric in every row
      local col
      if d.col then
        for i, h in ipairs(header) do
          if h:lower() == tostring(d.col):lower() or tonumber(d.col) == i then col = i end
        end
      else
        for i = #header, 1, -1 do
          local ok = #rows > 0
          for _, r in ipairs(rows) do
            if not (r.cells[i] and number(r.cells[i])) then ok = false; break end
          end
          if ok then col = i; break end
        end
      end

      if col then
        local values, max, min, sum = {}, -math.huge, math.huge, 0
        for i, r in ipairs(rows) do
          local v = number(r.cells[col] or "")
          values[i] = v
          if v then max = math.max(max, v); min = math.min(min, v); sum = sum + v end
        end
        local count = #vim.tbl_keys(values)
        if count > 0 then
          if min >= 0 and max > 0 then
            for i, r in ipairs(rows) do
              local v = values[i]
              if v then
                local hl = "MdxBar"
                if d.error and v >= d.error then hl = "MdxBarError"
                elseif d.warn and v >= d.warn then hl = "MdxBarWarn" end
                local n = v > 0 and math.max(1, math.floor(v / max * opts.width + 0.5)) or 0
                marks[#marks + 1] = {
                  conceal = false,
                  start_row = r.row,
                  start_col = 0,
                  opts = {
                    virt_text = { { "  " .. string.rep("▆", n), hl }, { " " .. r.cells[col], "MdxDim" } },
                    virt_text_pos = "eol",
                    hl_mode = "combine",
                  },
                }
              end
            end
          end
          if opts.summary then
            local text = string.format("  %s · min %s · max %s · mean %s · %d rows",
              header[col] or ("column " .. col), util.num(min), util.num(max), util.num(sum / count), #rows)
            -- under the table's bottom border. render-markdown draws that border over the blank
            -- line after the table when there is one, otherwise as a virtual line under the last row
            local last = util.last_row(tbl)
            local next_blank = last + 1 < line_count
              and vim.trim(vim.api.nvim_buf_get_lines(buf, last + 1, last + 2, false)[1] or "") == ""
            marks[#marks + 1] = {
              conceal = false,
              start_row = next_blank and last + 1 or last,
              start_col = 0,
              opts = { virt_lines = { { { text, "MdxDim" } } } },
            }
          end
        end
      end
    end
  end
  return marks
end

return M

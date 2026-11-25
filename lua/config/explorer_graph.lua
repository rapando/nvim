-- Import graph for code explorer mode (Python).
--   <leader>kg  graph of the module in the current buffer: importers on the left, imports on the right
-- Scans `import` / `from ... import` lines (no language server needed), finds cycles, and counts
-- the files and tests a change can reach.
local M = {}

local ns = vim.api.nvim_create_namespace("code_explorer_graph")
local cache = {} -- root -> graph

-- Build ---------------------------------------------------------------------------------------

local function module_names(rel)
  local name = rel:gsub("%.py$", ""):gsub("/__init__$", "")
  local names = { (name:gsub("/", ".")) }
  for _, prefix in ipairs({ "src/", "lib/", "app/" }) do
    if vim.startswith(name, prefix) then
      names[#names + 1] = (name:sub(#prefix + 1):gsub("/", "."))
    end
  end
  return names
end

local function package_of(rel)
  local dir = vim.fs.dirname(rel)
  if rel:match("/__init__%.py$") or rel == "__init__.py" then
    dir = vim.fs.dirname(rel)
  end
  return (dir == "." and "" or dir)
end

function M.build(root)
  local out = vim.system({ "git", "-C", root, "ls-files", "--cached", "--others", "--exclude-standard", "*.py" }, { text = true }):wait()
  local files = vim.split(out.stdout or "", "\n", { trimempty = true })
  local by_name = {}
  for _, rel in ipairs(files) do
    for _, name in ipairs(module_names(rel)) do
      by_name[name] = by_name[name] or rel
    end
  end

  local g = { root = root, files = files, imports = {}, importers = {}, lines = {} }
  for _, rel in ipairs(files) do
    g.imports[rel], g.importers[rel] = {}, {}
  end

  local function resolve(name)
    while name ~= "" do
      if by_name[name] then
        return by_name[name]
      end
      name = name:match("^(.*)%.[^.]+$") or ""
    end
  end

  local function add(from, name, lnum)
    local to = resolve(name)
    if to and to ~= from and not g.imports[from][to] then
      g.imports[from][to] = lnum
      g.importers[to][from] = lnum
    end
  end

  for _, rel in ipairs(files) do
    local f = io.open(root .. "/" .. rel)
    if f then
      local base = package_of(rel):gsub("/", ".")
      local lnum = 0
      for line in f:lines() do
        lnum = lnum + 1
        local mod, names = line:match("^%s*from%s+([%.%w_]+)%s+import%s+(.*)$")
        if mod then
          local dots = #mod:match("^%.*")
          local rest = mod:sub(dots + 1)
          local prefix = rest
          if dots > 0 then
            local pkg = base
            for _ = 2, dots do
              pkg = pkg:match("^(.*)%.[^.]+$") or ""
            end
            prefix = (pkg ~= "" and rest ~= "") and (pkg .. "." .. rest) or (pkg .. rest)
          end
          local hit = false
          for item in names:gsub("#.*", ""):gsub("[()]", ""):gmatch("[%w_]+") do
            if item ~= "as" and by_name[prefix .. "." .. item] then
              add(rel, prefix .. "." .. item, lnum)
              hit = true
            end
          end
          if not hit then
            add(rel, prefix, lnum)
          end
        else
          local list = line:match("^%s*import%s+([%w_%.,%s]+)")
          for item in (list or ""):gmatch("[%w_%.]+") do
            if item ~= "as" then
              add(rel, item, lnum)
            end
          end
        end
      end
      f:close()
    end
  end

  -- strongly connected components (Tarjan): a component of 2+ files is an import cycle
  local index, stack, on, idx, low, comp = 0, {}, {}, {}, {}, {}
  local function strong(v)
    index = index + 1
    idx[v], low[v] = index, index
    stack[#stack + 1] = v
    on[v] = true
    for w in pairs(g.imports[v]) do
      if not idx[w] then
        strong(w)
        low[v] = math.min(low[v], low[w])
      elseif on[w] then
        low[v] = math.min(low[v], idx[w])
      end
    end
    if low[v] == idx[v] then
      local members = {}
      repeat
        local w = table.remove(stack)
        on[w] = false
        members[#members + 1] = w
      until w == v
      for _, w in ipairs(members) do
        comp[w] = members
      end
    end
  end
  for _, rel in ipairs(files) do
    if not idx[rel] then
      strong(rel)
    end
  end
  g.comp = comp
  return g
end

function M.get(root, rebuild)
  if rebuild or not cache[root] then
    cache[root] = M.build(root)
  end
  return cache[root]
end

function M.fan_in(root, rel)
  local g = M.get(root)
  local n = 0
  for _ in pairs(g.importers[rel] or {}) do
    n = n + 1
  end
  return g.importers[rel] and n or nil
end

local function in_cycle(g, rel)
  return g.comp[rel] and #g.comp[rel] > 1
end

local function display(rel)
  return (rel:gsub("%.py$", ""):gsub("/__init__$", ""):gsub("^src/", ""):gsub("/", "."))
end

local function sorted_keys(set)
  local keys = vim.tbl_keys(set)
  table.sort(keys)
  return keys
end

-- Shortest import cycle through `rel`, as a list of files starting and ending with it
local function find_cycle(g, rel)
  if not in_cycle(g, rel) then
    return nil
  end
  local members = {}
  for _, m in ipairs(g.comp[rel]) do
    members[m] = true
  end
  local prev, queue = { [rel] = false }, { rel }
  local head = 1
  while head <= #queue do
    local v = queue[head]
    head = head + 1
    for _, w in ipairs(sorted_keys(g.imports[v])) do
      if members[w] then
        if w == rel then
          local rev, cur = {}, v
          while cur do
            table.insert(rev, 1, cur)
            cur = prev[cur]
          end
          rev[#rev + 1] = rel
          return rev
        elseif prev[w] == nil then
          prev[w] = v
          queue[#queue + 1] = w
        end
      end
    end
  end
end

local function blast_radius(g, rel)
  local seen, queue, head = { [rel] = true }, { rel }, 1
  local files, tests = 0, 0
  while head <= #queue do
    local v = queue[head]
    head = head + 1
    for w in pairs(g.importers[v]) do
      if not seen[w] then
        seen[w] = true
        queue[#queue + 1] = w
        local lower = w:lower()
        if lower:find("test") then
          tests = tests + 1
        else
          files = files + 1
        end
      end
    end
  end
  return files, tests
end

-- Render --------------------------------------------------------------------------------------

-- A line is a list of { text, hl, path }; compile to text, highlight spans and click targets
local function compile(rows)
  local lines, spans, targets = {}, {}, {}
  for i, segs in ipairs(rows) do
    local text, col = "", 0
    for _, seg in ipairs(segs) do
      if seg[2] then
        spans[#spans + 1] = { i - 1, col, col + #seg[1], seg[2] }
      end
      if seg[3] then
        targets[i] = targets[i] or {}
        table.insert(targets[i], { col, col + #seg[1], seg[3] })
      end
      text, col = text .. seg[1], col + #seg[1]
    end
    lines[i] = text
  end
  return lines, spans, targets
end

local function pad(text, width)
  return text .. string.rep(" ", math.max(0, width - vim.fn.strdisplaywidth(text)))
end

local function connector(first, last, row, mid, is_item, side)
  if row < first or row > last then
    return " "
  end
  if first == last then
    return "─"
  end
  local top, bottom, between, cross
  if side == "left" then
    top, bottom, between, cross = "┐", "┘", "┤", "┼"
  else
    top, bottom, between, cross = "┌", "└", "├", "┼"
  end
  if row == first then
    return (row == mid) and between or top
  elseif row == last then
    return (row == mid) and between or bottom
  elseif is_item then
    return (row == mid) and cross or between
  end
  return (row == mid) and between or "│"
end

local function build_rows(g, focus, opts)
  local imps, importers = sorted_keys(g.imports[focus]), sorted_keys(g.importers[focus])
  if opts.cycles_only then
    local keep = function(list)
      return vim.tbl_filter(function(r) return g.comp[r] == g.comp[focus] and in_cycle(g, r) end, list)
    end
    imps, importers = keep(imps), keep(importers)
  end
  local count = math.max(#imps, #importers, 1)
  local mid = math.ceil(count / 2)
  local off_l, off_r = math.floor((count - #importers) / 2), math.floor((count - #imps) / 2)
  local first_l, last_l = off_l + 1, off_l + #importers
  local first_r, last_r = off_r + 1, off_r + #imps

  local wl, wr = 12, 12
  for _, r in ipairs(importers) do
    wl = math.max(wl, #display(r) + 2)
  end
  local right_text = {}
  for i, r in ipairs(imps) do
    local text = display(r) .. (in_cycle(g, r) and " ↻" or "")
    right_text[i] = text
    wr = math.max(wr, #text)
  end

  local title = " " .. display(focus) .. (in_cycle(g, focus) and " ↻" or "") .. " "
  local rows = {
    { { pad(" IMPORTED BY", wl + 7), "Comment" }, { pad("FOCUS", #title + 6), "Comment" }, { "IMPORTS", "Comment" } },
    { { "" } },
  }
  for row = 1, count do
    local li, ri = row - off_l, row - off_r
    local left_item = importers[li]
    local right_item = imps[ri]
    local segs = { { " " } }
    if left_item and li >= 1 then
      local name = display(left_item) .. (in_cycle(g, left_item) and " ↻" or "")
      segs[#segs + 1] = { pad(name, wl), in_cycle(g, left_item) and "DiagnosticError" or nil, left_item }
      segs[#segs + 1] = { " ─" }
    else
      segs[#segs + 1] = { string.rep(" ", wl + 2) }
    end
    segs[#segs + 1] = { connector(first_l, last_l, row, mid, left_item ~= nil and li >= 1, "left"), "Comment" }
    if row == mid then
      segs[#segs + 1] = { "─▶ " }
      segs[#segs + 1] = { title, "TabLineSel", focus }
      segs[#segs + 1] = { " ─" }
    else
      segs[#segs + 1] = { string.rep(" ", 4 + #title + 2) }
    end
    segs[#segs + 1] = { connector(first_r, last_r, row, mid, right_item ~= nil and ri >= 1, "right"), "Comment" }
    if right_item and ri >= 1 then
      segs[#segs + 1] = { "─▶ " }
      segs[#segs + 1] = { right_text[ri], in_cycle(g, right_item) and "DiagnosticError" or nil, right_item }
      if opts.depth >= 2 then
        local deeper = vim.tbl_filter(function(r) return r ~= focus end, sorted_keys(g.imports[right_item]))
        if #deeper > 0 then
          local names = vim.tbl_map(display, vim.list_slice(deeper, 1, 3))
          local more = #deeper > 3 and (" +" .. (#deeper - 3)) or ""
          segs[#segs + 1] = { string.rep(" ", wr - #right_text[ri]) .. "  ─▶ " .. table.concat(names, ", ") .. more, "Comment" }
        end
      end
    end
    rows[#rows + 1] = segs
  end

  -- details
  local files, tests = blast_radius(g, focus)
  rows[#rows + 1] = { { "" } }
  rows[#rows + 1] = { { " Blast radius", "Title" } }
  rows[#rows + 1] = { { ("  a change here can reach %d file%s and %d test file%s"):format(files, files == 1 and "" or "s", tests, tests == 1 and "" or "s") } }
  local cycle = find_cycle(g, focus)
  rows[#rows + 1] = { { "" } }
  if cycle then
    rows[#rows + 1] = { { " Import cycle", "DiagnosticError" } }
    local names = vim.tbl_map(display, cycle)
    rows[#rows + 1] = { { "  " .. table.concat(names, " → ") } }
    for i = 1, #cycle - 1 do
      local lnum = g.imports[cycle[i]][cycle[i + 1]]
      rows[#rows + 1] = {
        { ("   %s:%d  imports %s"):format(cycle[i], lnum, display(cycle[i + 1])), "Comment", cycle[i] },
      }
    end
    rows[#rows + 1] = { { "  Move what the files share into a third module that both import.", "Comment" } }
  else
    rows[#rows + 1] = { { " No import cycles", "Comment" } }
  end
  return rows, #imps, #importers
end

-- Window --------------------------------------------------------------------------------------

local state

function M.close()
  if state and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state = nil
end

local function render()
  local g = state.g
  local rows, n_imports, n_importers = build_rows(g, state.focus, state)
  local lines, spans, targets = compile(rows)
  state.targets = targets
  local buf = state.buf
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for _, s in ipairs(spans) do
    vim.api.nvim_buf_set_extmark(buf, ns, s[1], s[2], { end_col = s[3], hl_group = s[4], strict = false })
  end
  local title = (" graph: %s  depth %d%s "):format(display(state.focus), state.depth, state.cycles_only and "  cycles only" or "")
  vim.api.nvim_win_set_config(state.win, {
    title = title,
    title_pos = "center",
    footer = (" %d importers · %d imports   d depth  c cycles  f refocus  ⏎ open  r rescan  q close "):format(n_importers, n_imports),
    footer_pos = "center",
  })
end

local function target_at_cursor()
  local pos = vim.api.nvim_win_get_cursor(0)
  local list = state.targets[pos[1]]
  if not list then
    return nil
  end
  for _, t in ipairs(list) do
    if pos[2] >= t[1] and pos[2] < t[2] then
      return t[3]
    end
  end
  return list[#list][3]
end

function M.open(root, rel)
  M.close()
  local g = M.get(root)
  if not g.imports[rel] then
    vim.notify("Import graph supports Python files for now", vim.log.levels.WARN)
    return
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden, vim.bo[buf].buftype, vim.bo[buf].filetype = "wipe", "nofile", "explorer-graph"
  local width, height = math.floor(vim.o.columns * 0.9), math.floor(vim.o.lines * 0.7)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2) - 1,
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
  })
  vim.wo[win].cursorline, vim.wo[win].wrap = true, false
  state = { g = g, buf = buf, win = win, focus = rel, depth = 1, cycles_only = false, root = root }
  render()

  local function map(lhs, fn)
    vim.keymap.set("n", lhs, fn, { buffer = buf, nowait = true })
  end
  local function go(path)
    local file = state.root .. "/" .. path
    M.close()
    vim.cmd.edit(vim.fn.fnameescape(file))
  end
  map("q", M.close)
  map("<Esc>", M.close)
  map("d", function()
    state.depth = state.depth == 1 and 2 or 1
    render()
  end)
  map("c", function()
    state.cycles_only = not state.cycles_only
    render()
  end)
  map("f", function()
    local path = target_at_cursor()
    if path and state.g.imports[path] then
      state.focus = path
      vim.api.nvim_win_set_cursor(state.win, { 1, 0 })
      render()
    end
  end)
  map("<CR>", function()
    local path = target_at_cursor()
    if path then
      go(path)
    end
  end)
  map("r", function()
    state.g = M.get(state.root, true)
    if not state.g.imports[state.focus] then
      M.close()
      return
    end
    render()
  end)
end

function M.open_current()
  local name = vim.api.nvim_buf_get_name(0)
  local out = vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true }):wait()
  local root = vim.trim(out.stdout or "")
  if out.code ~= 0 or root == "" then
    root = vim.uv.cwd()
  end
  if not vim.startswith(name, root .. "/") then
    vim.notify("Open a file inside the project first", vim.log.levels.WARN)
    return
  end
  M.open(root, name:sub(#root + 2))
end

return M

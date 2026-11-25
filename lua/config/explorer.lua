-- Code explorer mode: turns the window into a project map (left), your code (middle) and a
-- context panel (right) that follows the cursor.
--   <leader>kk  toggle the mode
-- Left: file tree with edit counts from the last 30 days (git).
-- Right: for the symbol under the cursor, who calls it, what it calls, and the tests among its
-- callers. Comes from the language server's call hierarchy (pyright, gopls, ...).
local M = {}

local ns = vim.api.nvim_create_namespace("code_explorer")
local S -- state while the mode is open

-- Helpers -------------------------------------------------------------------------------------

local function project_root()
  local out = vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true }):wait()
  local root = vim.trim(out.stdout or "")
  return (out.code == 0 and root ~= "") and root or vim.uv.cwd()
end

local function relpath(root, path)
  if vim.startswith(path, root .. "/") then
    return path:sub(#root + 2)
  end
  return vim.fn.fnamemodify(path, ":~")
end

local function is_test(rel)
  rel = rel:lower()
  return rel:find("/tests?/") ~= nil or rel:find("^tests?/") ~= nil or rel:find("test_[^/]*$") ~= nil or rel:find("_test%.[^/]*$") ~= nil
end

local function git_lines(root, args)
  local cmd = vim.list_extend({ "git", "-C", root }, args)
  local out = vim.system(cmd, { text = true }):wait()
  if out.code ~= 0 then
    return nil
  end
  return vim.split(out.stdout or "", "\n", { trimempty = true })
end

local function scratch(name)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "explorer"
  vim.api.nvim_buf_set_name(buf, "explorer://" .. name)
  return buf
end

local function panel_window(buf, side, width)
  local win = vim.api.nvim_open_win(buf, false, { split = side, win = -1, width = width })
  local wo = vim.wo[win]
  wo.number, wo.relativenumber, wo.signcolumn, wo.wrap = false, false, "no", false
  wo.cursorline, wo.winfixwidth, wo.foldcolumn, wo.list = true, true, "0", false
  wo.statuscolumn, wo.spell = "", false
  vim.w[win].explorer = true
  return win
end

-- Render a list of { text, hl, entry } into a buffer; entries are what <CR> opens
local function draw(buf, rows)
  local lines, entries = {}, {}
  for i, row in ipairs(rows) do
    lines[i] = row[1]
    entries[i] = row[3]
  end
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for i, row in ipairs(rows) do
    if row[2] and #row[1] > 0 then
      vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, { end_col = #row[1], hl_group = row[2] })
    end
    for _, span in ipairs(row[4] or {}) do
      vim.api.nvim_buf_set_extmark(buf, ns, i - 1, span[1], { end_col = math.min(span[2], #lines[i]), hl_group = span[3], strict = false })
    end
  end
  return entries
end

local function open_entry(entry)
  if not entry or not entry.path or not S or not vim.api.nvim_win_is_valid(S.center) then
    return
  end
  vim.api.nvim_set_current_win(S.center)
  vim.cmd.edit(vim.fn.fnameescape(entry.path))
  if entry.line then
    vim.api.nvim_win_set_cursor(0, { entry.line, entry.col or 0 })
    vim.cmd("normal! zz")
  end
end

-- Project map ---------------------------------------------------------------------------------

local function build_tree(files)
  local root = { name = "", children = {}, dir = true, files = 0 }
  for _, f in ipairs(files) do
    local node = root
    local parts = vim.split(f, "/", { plain = true })
    for i, part in ipairs(parts) do
      local last = i == #parts
      local key = last and part or (part .. "/")
      if not node.children[key] then
        node.children[key] = { name = part, path = table.concat(parts, "/", 1, i), children = {}, dir = not last, files = 0 }
      end
      node = node.children[key]
      if not last then
        node.files = node.files + 1
      end
    end
    root.files = root.files + 1
  end
  return root
end

local function sorted_children(node)
  local list = vim.tbl_values(node.children)
  table.sort(list, function(a, b)
    if a.dir ~= b.dir then
      return a.dir
    end
    return a.name < b.name
  end)
  return list
end

local function load_project()
  local files = git_lines(S.root, { "ls-files", "--cached", "--others", "--exclude-standard" })
  if not files then
    files = vim.fn.globpath(S.root, "**/*", false, true)
    files = vim.tbl_map(function(p) return relpath(S.root, p) end, vim.tbl_filter(function(p) return vim.fn.isdirectory(p) == 0 end, files))
  end
  S.tree = build_tree(files)
  local ok, graph = pcall(function() return require("config.explorer_graph").get(S.root) end)
  S.graph = ok and #graph.files > 0 and graph or nil
  S.edits = {}
  local log = git_lines(S.root, { "log", "--since=30.days", "--name-only", "--pretty=format:" })
  for _, f in ipairs(log or {}) do
    S.edits[f] = (S.edits[f] or 0) + 1
  end
end

local function expand_to(rel)
  local parts = vim.split(rel, "/", { plain = true })
  for i = 1, #parts - 1 do
    S.expanded[table.concat(parts, "/", 1, i)] = true
  end
end

local function render_map(keep_row)
  if not S or not vim.api.nvim_buf_is_valid(S.map_buf) then
    return
  end
  local rows = { { " Project map", "Title" }, { " " .. vim.fn.fnamemodify(S.root, ":t") .. "/", "Directory" } }
  local current = relpath(S.root, vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(S.center)))
  S.current_row = nil
  local function walk(node, depth)
    for _, child in ipairs(sorted_children(node)) do
      local pad = string.rep("  ", depth + 1)
      if child.dir then
        local open = S.expanded[child.path]
        local fan = S.graph and S.graph.importers[child.path] and vim.tbl_count(S.graph.importers[child.path]) or 0
        local count = fan > 0 and ("←%d  %d"):format(fan, child.files) or tostring(child.files)
        local text = ("%s%s %s"):format(pad, open and "▾" or "▸", child.name)
        rows[#rows + 1] = { text .. string.rep(" ", math.max(1, S.map_width - vim.fn.strdisplaywidth(text) - vim.fn.strdisplaywidth(count) - 1)) .. count, "Directory", child, { { #text, #text + 50, "Comment" } } }
        if open then
          walk(child, depth + 1)
        end
      else
        local n = S.edits[child.path]
        local fan = S.graph and S.graph.importers[child.path] and vim.tbl_count(S.graph.importers[child.path]) or 0
        local text = pad .. "  " .. child.name
        local row = { text, nil, child }
        if n or fan > 0 then
          local tail = (fan > 0 and (" ←%d"):format(fan) or "") .. (n and (" %s%d"):format(n >= 4 and "●" or "·", n) or "")
          row[1] = text .. string.rep(" ", math.max(1, S.map_width - vim.fn.strdisplaywidth(text) - vim.fn.strdisplaywidth(tail))) .. tail
          row[4] = { { #text, #row[1], n and n >= 10 and "DiagnosticError" or n and n >= 4 and "DiagnosticWarn" or "Comment" } }
        end
        if child.path == current then
          row[2] = "Visual"
          S.current_row = #rows + 1
        end
        rows[#rows + 1] = row
      end
    end
  end
  walk(S.tree, 0)

  local hot = {}
  for path, n in pairs(S.edits) do
    if vim.uv.fs_stat(S.root .. "/" .. path) then
      hot[#hot + 1] = { path = path, n = n }
    end
  end
  table.sort(hot, function(a, b) return a.n > b.n end)
  if #hot > 0 then
    rows[#rows + 1] = { "" }
    rows[#rows + 1] = { " Hot spots (edits, 30d)", "Title" }
    for i = 1, math.min(3, #hot) do
      local name = vim.fn.fnamemodify(hot[i].path, ":t")
      rows[#rows + 1] = { (" ● %-20s %d"):format(name:sub(1, 20), hot[i].n), nil, { path = S.root .. "/" .. hot[i].path }, { { 1, 4, i == 1 and "DiagnosticError" or "DiagnosticWarn" } } }
    end
  end
  S.map_entries = draw(S.map_buf, rows)
  -- follow the open file, except when the user is working in the map (fold/unfold)
  local row = keep_row or S.current_row
  if row and vim.api.nvim_win_is_valid(S.map_win) then
    pcall(vim.api.nvim_win_set_cursor, S.map_win, { row, 0 })
  end
end

local function map_activate()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local node = S.map_entries[row]
  if not node then
    return
  end
  if node.dir then
    S.expanded[node.path] = not S.expanded[node.path] or nil
    render_map(row)
  elseif node.path then
    open_entry({ path = node.path:sub(1, 1) == "/" and node.path or (S.root .. "/" .. node.path) })
  end
end

-- Context panel -------------------------------------------------------------------------------

local function render_context(data)
  if not S or not vim.api.nvim_buf_is_valid(S.ctx_buf) then
    return
  end
  local rows = {}
  local function section(title, n)
    rows[#rows + 1] = { "" }
    rows[#rows + 1] = { (" %s%s"):format(title, n and ("  " .. n) or ""), "Title" }
  end
  if not data then
    rows = { { " Context", "Title" }, { "" }, { " No symbol under the cursor", "Comment" } }
  elseif data.message then
    rows = { { " Context", "Title" }, { "" }, { " " .. data.message, "Comment" } }
  else
    rows[#rows + 1] = { " Context · " .. data.name, "Title" }
    rows[#rows + 1] = { (" %s:%d"):format(data.rel, data.line), "Directory", { path = data.path, line = data.line } }
    if data.detail and data.detail ~= "" then
      rows[#rows + 1] = { " " .. data.detail:sub(1, S.ctx_width - 2), "Comment" }
    end
    if data.age then
      rows[#rows + 1] = { " changed " .. data.age:sub(1, S.ctx_width - 10), "Comment" }
    end
    local callers, tests = {}, {}
    for _, e in ipairs(data.incoming) do
      table.insert(is_test(e.rel) and tests or callers, e)
    end
    local function list(items, empty)
      if #items == 0 then
        rows[#rows + 1] = { "  " .. empty, "Comment" }
      end
      for _, e in ipairs(items) do
        local left = "  " .. e.label
        local right = e.rel:match("[^/]+$") .. ":" .. e.line
        local pad = math.max(1, S.ctx_width - vim.fn.strdisplaywidth(left) - #right - 1)
        rows[#rows + 1] = { left .. string.rep(" ", pad) .. right, nil, e, { { #left, #left + pad + #right, "Comment" } } }
      end
    end
    section("Called by", #callers)
    list(callers, "no callers found")
    section("Calls", #data.outgoing)
    list(data.outgoing, "calls nothing")
    section("Tests", #tests)
    list(tests, "no tests call it directly")
  end
  S.ctx_entries = draw(S.ctx_buf, rows)
  if data and not data.message then
    local callers = 0
    for _, e in ipairs(data.incoming) do
      callers = callers + (is_test(e.rel) and 0 or 1)
    end
    S.summary = ("%s › %s   ↑%d callers  ↓%d callees  %d tests"):format(
      data.rel, data.name, callers, #data.outgoing, #data.incoming - callers
    )
  else
    S.summary = nil
  end
  M.update_winbar()
end

function M.update_winbar()
  if not S or not vim.api.nvim_win_is_valid(S.center) then
    return
  end
  local text = (S.summary or relpath(S.root, vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(S.center)))):gsub("%%", "%%%%")
  vim.wo[S.center].winbar = "%#TabLineSel# EXPLORE %#TabLineFill# %<" .. text
end

-- Calls into the standard library or installed packages only add noise to the panel
local function in_project(root, entry)
  local path = entry.path
  return vim.startswith(path, root .. "/")
    and not path:find("/%.?venv/")
    and not path:find("site%-packages", 1, false)
    and not path:find("/node_modules/", 1, true)
end

local function to_entry(root, item, range_key)
  local path = vim.uri_to_fname(item.uri)
  local pos = (item[range_key] or item.range).start
  return {
    label = item.name,
    path = path,
    rel = relpath(root, path),
    line = pos.line + 1,
    col = pos.character,
  }
end

local function refresh_context()
  if not S or not vim.api.nvim_win_is_valid(S.center) then
    return
  end
  local buf = vim.api.nvim_win_get_buf(S.center)
  if vim.bo[buf].buftype ~= "" or vim.api.nvim_buf_get_name(buf) == "" then
    return
  end
  local pos = vim.api.nvim_win_get_cursor(S.center)
  local key = ("%d:%d:%d:%s"):format(buf, pos[1], pos[2], vim.fn.expand("<cword>"))
  if key == S.last_key then
    return
  end
  S.last_key = key
  S.seq = S.seq + 1
  local seq = S.seq

  local client = vim.lsp.get_clients({ bufnr = buf, method = "textDocument/prepareCallHierarchy" })[1]
  if not client then
    render_context({ message = "No language server with call hierarchy for this file" })
    return
  end
  local params = vim.lsp.util.make_position_params(S.center, client.offset_encoding)
  client:request("textDocument/prepareCallHierarchy", params, function(err, result)
    if not S or seq ~= S.seq then
      return
    end
    local item = not err and result and result[1]
    if not item then
      render_context(nil)
      return
    end
    local data = to_entry(S.root, item, "selectionRange")
    data.name, data.detail, data.incoming, data.outgoing = item.name, item.detail, nil, nil
    local pending = 2
    local function done()
      pending = pending - 1
      if pending > 0 or not S or seq ~= S.seq then
        return
      end
      render_context(data)
      vim.system({ "git", "-C", S.root, "log", "-1", "--format=%ar · %s", "--", data.path }, { text = true }, function(out)
        vim.schedule(function()
          local age = vim.trim(out.stdout or "")
          if S and seq == S.seq and age ~= "" then
            data.age = age
            render_context(data)
          end
        end)
      end)
    end
    client:request("callHierarchy/incomingCalls", { item = item }, function(_, res)
      local root = S and S.root or ""
      data.incoming = vim.tbl_filter(function(e) return in_project(root, e) end, vim.tbl_map(function(c) return to_entry(root, c.from, "selectionRange") end, res or {}))
      done()
    end, buf)
    client:request("callHierarchy/outgoingCalls", { item = item }, function(_, res)
      local root = S and S.root or ""
      data.outgoing = vim.tbl_filter(function(e) return in_project(root, e) end, vim.tbl_map(function(c) return to_entry(root, c.to, "selectionRange") end, res or {}))
      done()
    end, buf)
  end, buf)
end

local function schedule_refresh()
  if not S then
    return
  end
  if S.timer then
    S.timer:stop()
  else
    S.timer = vim.uv.new_timer()
  end
  S.timer:start(150, 0, vim.schedule_wrap(refresh_context))
end

-- Open / close --------------------------------------------------------------------------------

local function panel_keys(buf, activate)
  local function map(lhs, fn)
    vim.keymap.set("n", lhs, fn, { buffer = buf, nowait = true })
  end
  map("<CR>", activate)
  map("<2-LeftMouse>", activate)
  map("q", M.close)
  map("<Tab>", M.cycle_focus)
end

-- <Tab> moves between the columns from the code window too (this shadows <C-i> there while
-- the mode is open)
local function map_tab(buf)
  if S and not S.tab_mapped[buf] then
    S.tab_mapped[buf] = true
    vim.keymap.set("n", "<Tab>", M.cycle_focus, { buffer = buf, desc = "Explorer: next column" })
  end
end

function M.cycle_focus()
  if not S then
    return
  end
  local order = vim.tbl_filter(vim.api.nvim_win_is_valid, { S.map_win, S.center, S.ctx_win })
  local current = vim.api.nvim_get_current_win()
  for i, w in ipairs(order) do
    if w == current then
      local nxt = order[i % #order + 1]
      if vim.api.nvim_win_is_valid(nxt) then
        vim.api.nvim_set_current_win(nxt)
      end
      return
    end
  end
end

function M.close()
  if not S then
    return
  end
  local state = S
  S = nil
  if state.timer then
    state.timer:stop()
    state.timer:close()
  end
  pcall(vim.api.nvim_del_augroup_by_name, "code_explorer")
  for buf in pairs(state.tab_mapped) do
    if vim.api.nvim_buf_is_valid(buf) then
      pcall(vim.keymap.del, "n", "<Tab>", { buffer = buf })
    end
  end
  if vim.api.nvim_win_is_valid(state.center) then
    vim.wo[state.center].winbar = state.winbar
  end
  for _, win in ipairs({ state.map_win, state.ctx_win }) do
    if vim.api.nvim_win_is_valid(win) then
      if #vim.api.nvim_tabpage_list_wins(0) > 1 then
        vim.api.nvim_win_close(win, true)
      else
        -- the last window left (the code window was closed): give it a normal empty buffer
        vim.api.nvim_win_set_buf(win, vim.api.nvim_create_buf(true, false))
        vim.w[win].explorer = nil
        vim.wo[win].winfixwidth, vim.wo[win].cursorline = false, false
        vim.wo[win].number = vim.o.number
        vim.wo[win].signcolumn = vim.o.signcolumn
      end
    end
  end
end

function M.open()
  if S then
    return
  end
  local center = vim.api.nvim_get_current_win()
  if vim.w[center].explorer or vim.api.nvim_win_get_config(center).relative ~= "" then
    vim.notify("Explorer mode needs an ordinary editor window", vim.log.levels.WARN)
    return
  end
  pcall(function() require("nvim-tree.api").tree.close() end)
  local narrow = vim.o.columns < 140
  S = {
    center = center,
    root = project_root(),
    seq = 0,
    expanded = {},
    map_width = narrow and 28 or 34,
    ctx_width = narrow and 36 or 44,
    winbar = vim.wo[center].winbar,
    tab_mapped = {},
  }
  load_project()
  expand_to(relpath(S.root, vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(center))))

  S.map_buf, S.ctx_buf = scratch("map"), scratch("context")
  S.map_win = panel_window(S.map_buf, "left", S.map_width)
  S.ctx_win = panel_window(S.ctx_buf, "right", S.ctx_width)
  panel_keys(S.map_buf, map_activate)
  panel_keys(S.ctx_buf, function()
    open_entry(S.ctx_entries[vim.api.nvim_win_get_cursor(0)[1]])
  end)
  vim.api.nvim_set_current_win(center)
  map_tab(vim.api.nvim_win_get_buf(center))
  render_map()
  render_context(nil)

  local group = vim.api.nvim_create_augroup("code_explorer", { clear = true })
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorHold" }, {
    group = group,
    callback = function()
      if S and vim.api.nvim_get_current_win() == S.center then
        schedule_refresh()
      end
    end,
  })
  vim.api.nvim_create_autocmd({ "BufEnter", "LspAttach" }, {
    group = group,
    callback = function()
      if S and vim.api.nvim_get_current_win() == S.center and vim.bo.buftype == "" then
        map_tab(vim.api.nvim_get_current_buf())
        S.last_key = nil
        expand_to(relpath(S.root, vim.api.nvim_buf_get_name(0)))
        render_map()
        schedule_refresh()
        M.update_winbar()
      end
    end,
  })
  -- closing any of the three windows ends the mode
  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    callback = function(args)
      local win = tonumber(args.match)
      if S and (win == S.center or win == S.map_win or (win == S.ctx_win and not S.ctx_released)) then
        vim.schedule(M.close)
      end
    end,
  })
  schedule_refresh()
end

-- The debug trail takes the context panel's place on the right
function M.release_context()
  if S and not S.ctx_released and vim.api.nvim_win_is_valid(S.ctx_win) then
    S.ctx_released = true
    vim.api.nvim_win_close(S.ctx_win, true)
  end
end

function M.toggle()
  if S then
    M.close()
  else
    M.open()
  end
end

return M

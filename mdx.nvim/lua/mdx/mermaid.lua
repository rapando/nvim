-- Text-drawn mermaid flowcharts (graph/flowchart LR or TD) under the fence.
-- Layered layout: longest-path layers, dummy nodes for long edges, barycenter ordering.
-- Not supported: subgraphs, edge labels (dropped), styles, other diagram types.
local util = require("mdx.util")
local M = {}

local SKIP = { subgraph = true, ["end"] = true, style = true, classDef = true, class = true,
  click = true, linkStyle = true, direction = true }
local CLOSE = { ["["] = "]", ["("] = ")", ["{"] = "}", [">"] = "]" }

---@return { dir: string, nodes: table, order: string[], edges: string[][] }?, string? err
function M.parse(src, max_label)
  local dir, nodes, order, edges = nil, {}, {}, {}
  local function add(id, label, shape)
    if not nodes[id] then
      nodes[id] = { id = id, label = id, shape = "box" }
      order[#order + 1] = id
    end
    if label and label ~= "" then
      label = vim.trim(label:gsub("^[%[%(%{/\\]+", ""):gsub("[%]%)%}/\\]+$", ""):gsub('^"(.*)"$', "%1"))
      if vim.fn.strchars(label) > max_label then label = vim.fn.strcharpart(label, 0, max_label - 1) .. "…" end
      nodes[id].label, nodes[id].shape = label, shape
    end
  end
  for raw in vim.gsplit(src, "\n") do
    for stmt in (raw:gsub("%%%%.*$", "") .. ";"):gmatch("([^;]*);") do
      stmt = vim.trim(stmt)
      if stmt ~= "" then
        if not dir then
          local kind, d = stmt:match("^(%a+)%s*(%a*)")
          if kind ~= "graph" and kind ~= "flowchart" then return nil, "only flowcharts are drawn as text" end
          d = d:upper()
          if d == "" or d == "LR" or d == "RL" then dir = "LR"
          elseif d == "TD" or d == "TB" or d == "BT" then dir = "TD"
          else return nil, "unknown direction " .. d end
        elseif not SKIP[stmt:match("^(%a+)") or ""] then
          local pos, prev = 1, nil
          while pos <= #stmt do
            local _, e, id = stmt:find("^%s*([%w_]+)", pos)
            if not id then break end
            pos = e + 1
            local open = stmt:sub(pos, pos)
            local label, shape
            if CLOSE[open] then
              local depth, i = 0, pos
              while i <= #stmt do
                local ch = stmt:sub(i, i)
                if ch == open then depth = depth + 1
                elseif ch == CLOSE[open] then
                  depth = depth - 1
                  if depth <= 0 then break end
                end
                i = i + 1
              end
              label, shape = stmt:sub(pos + 1, i - 1), open == "{" and "decision" or "box"
              pos = i + 1
            end
            add(id, label, shape)
            if prev then edges[#edges + 1] = { prev, id } end
            prev = id
            -- arrow: --> --- -.-> ==> <--> , optional |label| or "-- label -->"
            local rest = stmt:sub(pos)
            local a = rest:match("^%s*%-%-%s+[^%-]-%s*%-%->") or rest:match("^%s*<?[%-=%.]+>?")
            if not a or not a:match("[%-=]") then break end
            pos = pos + #a
            local lbl = stmt:sub(pos):match("^%s*|[^|]*|")
            if lbl then pos = pos + #lbl end
          end
        end
      end
    end
  end
  if not dir then return nil, "empty diagram" end
  if #order == 0 then return nil, "no nodes" end
  return { dir = dir, nodes = nodes, order = order, edges = edges }
end

---Assign layers and order; returns layers (lists of node ids incl. dummies) and the edge list between adjacent layers
local function layout(g)
  local out, index = {}, {}
  for i, id in ipairs(g.order) do out[id] = {}; index[id] = i end
  -- drop back edges (cycles) found by DFS in declaration order
  local state, dag, cyclic = {}, {}, false
  for _, e in ipairs(g.edges) do table.insert(out[e[1]], e[2]) end
  local function dfs(u)
    state[u] = 1
    for _, v in ipairs(out[u]) do
      if state[v] == 1 then cyclic = true
      else
        if u ~= v then dag[#dag + 1] = { u, v } end
        if not state[v] then dfs(v) end
      end
    end
    state[u] = 2
  end
  for _, id in ipairs(g.order) do if not state[id] then dfs(id) end end

  -- longest-path layering
  local layer = {}
  for _, id in ipairs(g.order) do layer[id] = 0 end
  for _ = 1, #g.order do
    local changed = false
    for _, e in ipairs(dag) do
      if layer[e[2]] < layer[e[1]] + 1 then layer[e[2]] = layer[e[1]] + 1; changed = true end
    end
    if not changed then break end
  end

  -- dummies for edges spanning several layers
  local edges, dummy = {}, 0
  for _, e in ipairs(dag) do
    local u = e[1]
    for l = layer[e[1]] + 1, layer[e[2]] - 1 do
      dummy = dummy + 1
      local d = "\0" .. dummy
      g.nodes[d] = { id = d, dummy = true }
      layer[d] = l
      index[d] = math.huge
      edges[#edges + 1] = { u, d }
      u = d
    end
    edges[#edges + 1] = { u, e[2] }
  end

  local layers = {}
  for id, l in pairs(layer) do
    layers[l + 1] = layers[l + 1] or {}
    table.insert(layers[l + 1], id)
  end
  for _, ids in ipairs(layers) do
    table.sort(ids, function(a, b)
      if index[a] ~= index[b] then return index[a] < index[b] end
      return a < b
    end)
  end

  -- barycenter sweeps to reduce crossings
  local pos = {}
  local function number() for _, ids in ipairs(layers) do for i, id in ipairs(ids) do pos[id] = i end end end
  number()
  local preds, succs = {}, {}
  for _, e in ipairs(edges) do
    preds[e[2]] = preds[e[2]] or {}; table.insert(preds[e[2]], e[1])
    succs[e[1]] = succs[e[1]] or {}; table.insert(succs[e[1]], e[2])
  end
  local function sweep(from, to, step, nb)
    for l = from, to, step do
      local bc = {}
      for _, id in ipairs(layers[l]) do
        local list, s = nb[id], 0
        if list and #list > 0 then
          for _, n in ipairs(list) do s = s + pos[n] end
          bc[id] = s / #list
        else
          bc[id] = pos[id]
        end
      end
      table.sort(layers[l], function(a, b)
        if bc[a] ~= bc[b] then return bc[a] < bc[b] end
        return pos[a] < pos[b]
      end)
      number()
    end
  end
  for _ = 1, 2 do
    sweep(2, #layers, 1, preds)
    sweep(#layers - 1, 1, -1, succs)
  end
  return layers, edges, cyclic
end

-- canvas with line-direction bits so crossings and corners merge into the right glyph
local UP, DOWN, LEFT, RIGHT = 1, 2, 4, 8
local GLYPH = { [1] = "│", [2] = "│", [3] = "│", [4] = "─", [8] = "─", [12] = "─", [10] = "╭", [6] = "╮",
  [9] = "╰", [5] = "╯", [11] = "├", [7] = "┤", [14] = "┬", [13] = "┴", [15] = "┼" }

local function canvas()
  local c = { cells = {}, w = 0, h = 0 }
  local function cell(x, y)
    c.cells[y] = c.cells[y] or {}
    c.cells[y][x] = c.cells[y][x] or {}
    c.w, c.h = math.max(c.w, x + 1), math.max(c.h, y + 1)
    return c.cells[y][x]
  end
  function c.put(x, y, ch, hl)
    local k = cell(x, y)
    k.ch, k.hl, k.bits = ch, hl, nil
  end
  function c.line(x1, y1, x2, y2)
    if x1 == x2 and y1 == y2 then return end
    local horizontal = y1 == y2
    local a, b = horizontal and x1 or y1, horizontal and x2 or y2
    local lo, hi = math.min(a, b), math.max(a, b)
    for t = lo, hi do
      local x, y = horizontal and t or x1, horizontal and y1 or t
      local k = cell(x, y)
      if not k.ch then
        local bits = k.bits or 0
        if t > lo then bits = bit.bor(bits, horizontal and LEFT or UP) end
        if t < hi then bits = bit.bor(bits, horizontal and RIGHT or DOWN) end
        k.bits = bits
      end
    end
  end
  function c.lines(indent)
    local out = {}
    for y = 0, c.h - 1 do
      local row, cur, chunks = c.cells[y] or {}, nil, { { indent } }
      for x = 0, c.w - 1 do
        local k = row[x]
        local ch, hl = " ", "MdxDim"
        if k and k.ch then ch, hl = k.ch, k.hl
        elseif k and k.bits then ch = GLYPH[k.bits] or "┼" end
        if cur and cur[2] == hl then cur[1] = cur[1] .. ch
        else cur = { ch, hl }; chunks[#chunks + 1] = cur end
      end
      out[#out + 1] = chunks
    end
    return out
  end
  return c
end

local function box(c, x, y, w, node)
  local hl = node.shape == "decision" and "MdxBoxAlt" or "MdxBox"
  c.put(x, y, "╭", hl); c.put(x + w - 1, y, "╮", hl)
  c.put(x, y + 2, "╰", hl); c.put(x + w - 1, y + 2, "╯", hl)
  for i = 1, w - 2 do c.put(x + i, y, "─", hl); c.put(x + i, y + 2, "─", hl) end
  c.put(x, y + 1, "│", hl); c.put(x + w - 1, y + 1, "│", hl)
  local label = node.label
  local lw = vim.fn.strdisplaywidth(label)
  local start = x + math.floor((w - lw) / 2)
  for i = 1, w - 2 do c.put(x + i, y + 1, " ", hl) end
  local i = 0
  for ch in label:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
    c.put(start + i, y + 1, ch, "MdxLabel")
    i = i + vim.fn.strdisplaywidth(ch)
  end
end

---@return table[]? virt_lines, string? err
function M.draw(g)
  local layers, edges, cyclic = layout(g)
  local c = canvas()
  local at = {} -- id -> { x, y, w }
  local width = function(id) return vim.fn.strdisplaywidth(g.nodes[id].label) + 4 end

  if g.dir == "LR" then
    local x = 0
    for _, ids in ipairs(layers) do
      local w = 1
      for _, id in ipairs(ids) do if not g.nodes[id].dummy then w = math.max(w, width(id)) end end
      for i, id in ipairs(ids) do at[id] = { x = x, y = (i - 1) * 4, w = w } end
      x = x + w + 6
    end
    for id, p in pairs(at) do
      if g.nodes[id].dummy then c.line(p.x, p.y + 1, p.x + p.w - 1, p.y + 1) else box(c, p.x, p.y, p.w, g.nodes[id]) end
    end
    for _, e in ipairs(edges) do
      local s, d = at[e[1]], at[e[2]]
      local sx, sy = s.x + s.w, s.y + 1
      local dx, dy = d.x - 1, d.y + 1
      local mx = sx + 2
      if g.nodes[e[1]].dummy then sx = s.x + s.w - 1 end
      c.line(sx, sy, mx, sy)
      c.line(mx, sy, mx, dy)
      c.line(mx, dy, dx, dy)
      if g.nodes[e[2]].dummy then c.line(dx, dy, d.x, dy) else c.put(dx, dy, "▶", "MdxEdge") end
    end
  else
    local widths, maxw = {}, 0
    for l, ids in ipairs(layers) do
      local total = 0
      for i, id in ipairs(ids) do total = total + (g.nodes[id].dummy and 1 or width(id)) + (i > 1 and 4 or 0) end
      widths[l] = total
      maxw = math.max(maxw, total)
    end
    for l, ids in ipairs(layers) do
      local x = math.floor((maxw - widths[l]) / 2)
      for _, id in ipairs(ids) do
        local w = g.nodes[id].dummy and 1 or width(id)
        at[id] = { x = x, y = (l - 1) * 6, w = w }
        x = x + w + 4
      end
    end
    for id, p in pairs(at) do
      if g.nodes[id].dummy then c.line(p.x, p.y, p.x, p.y + 2) else box(c, p.x, p.y, p.w, g.nodes[id]) end
    end
    for _, e in ipairs(edges) do
      local s, d = at[e[1]], at[e[2]]
      local sx, sy = s.x + math.floor(s.w / 2), s.y + 3
      local dx, dy = d.x + math.floor(d.w / 2), d.y - 1
      local my = sy + 1
      if g.nodes[e[1]].dummy then sy = s.y + 2 end
      c.line(sx, sy, sx, my)
      c.line(sx, my, dx, my)
      c.line(dx, my, dx, dy)
      if g.nodes[e[2]].dummy then c.line(dx, dy, dx, d.y) else c.put(dx, dy, "▼", "MdxEdge") end
    end
  end

  local lines = { { { "  ◇ mermaid" .. (cyclic and " · cycles not drawn" or ""), "MdxDim" } } }
  vim.list_extend(lines, c.lines("  "))
  return lines
end

local function snacks_draws_it()
  return vim.fn.executable("mmdc") == 1
    and package.loaded["snacks"] ~= nil
    and (vim.env.TERM_PROGRAM == "ghostty" or vim.env.KITTY_WINDOW_ID ~= nil)
end

function M.marks(buf, root, opts)
  if not opts.mode or (opts.mode == "auto" and snacks_draws_it()) then return {} end
  local marks = {}
  for _, f in ipairs(util.fences(buf, root)) do
    if f.lang == "mermaid" then
      local g, err = M.parse(f.code, opts.max_label)
      local lines
      if g and #g.order > opts.max_nodes then g, err = nil, "more than " .. opts.max_nodes .. " nodes" end
      if g then lines = M.draw(g) else lines = { { { "  ◇ mermaid · " .. err, "MdxDim" } } } end
      marks[#marks + 1] = { conceal = false, start_row = f.last, start_col = 0, opts = { virt_lines = lines } }
    end
  end
  return marks
end

return M

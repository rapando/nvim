-- Floating terminal that splits into panes.
--   <C-\>                  toggle it (normal and terminal mode)
--   <C-Space>              leave terminal mode, so the keys below work
--   <leader>wv / <leader>wh  split the current pane side by side / top and bottom
--   <C-h/j/k/l>            move between panes
--   <leader>wc             close the current pane
-- Neovim can't split a floating window inside itself (:vsplit from a float opens an
-- ordinary split behind it), so each pane is its own float and this module tiles them.
local M = {}

-- Layout tree: a leaf is { buf = n }, a split is { dir = "v" | "h", left/top, right/bottom }
local root
local wins = {} -- buf -> window, while shown
local rects = {} -- buf -> { row, col, width, height } including the border
local last -- pane focused last, refocused when the terminal is toggled back
local MIN_WIDTH, MIN_HEIGHT = 20, 4

local function area()
  local lines = vim.o.lines - vim.o.cmdheight
  local width, height = math.floor(vim.o.columns * 0.9), math.floor(lines * 0.85)
  return { row = math.floor((lines - height) / 2), col = math.floor((vim.o.columns - width) / 2), width = width, height = height }
end

local function layout(node, r, out)
  if node.buf then
    out[node.buf] = r
  elseif node.dir == "v" then
    local w = math.floor(r.width / 2)
    layout(node[1], { row = r.row, col = r.col, width = w, height = r.height }, out)
    layout(node[2], { row = r.row, col = r.col + w, width = r.width - w, height = r.height }, out)
  else
    local h = math.floor(r.height / 2)
    layout(node[1], { row = r.row, col = r.col, width = r.width, height = h }, out)
    layout(node[2], { row = r.row + h, col = r.col, width = r.width, height = r.height - h }, out)
  end
  return out
end

local function replace(node, buf, fn)
  if node.buf then
    return node.buf == buf and fn(node) or node
  end
  node[1], node[2] = replace(node[1], buf, fn), replace(node[2], buf, fn)
  return node
end

local function prune(node, buf)
  if node.buf then
    return node.buf ~= buf and node or nil
  end
  local a, b = prune(node[1], buf), prune(node[2], buf)
  if a and b then
    node[1], node[2] = a, b
    return node
  end
  return a or b
end

local function first_leaf(node)
  while not node.buf do
    node = node[1]
  end
  return node.buf
end

local function shown()
  for _, win in pairs(wins) do
    if vim.api.nvim_win_is_valid(win) then
      return true
    end
  end
  return false
end

local function highlight_borders()
  local cur = vim.api.nvim_get_current_win()
  for _, win in pairs(wins) do
    if vim.api.nvim_win_is_valid(win) then
      vim.wo[win].winhighlight = "NormalFloat:Normal,FloatBorder:" .. (win == cur and "FloatBorder" or "WinSeparator")
    end
  end
end

local function focus(buf)
  local win = wins[buf]
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_set_current_win(win)
    vim.cmd.startinsert()
  end
end

---Open or reposition a float for every pane
local function show()
  rects = layout(root, area(), {})
  for buf, r in pairs(rects) do
    local cfg = {
      relative = "editor",
      row = r.row,
      col = r.col,
      width = math.max(r.width - 2, 1),
      height = math.max(r.height - 2, 1),
      border = "rounded",
      style = "minimal",
      zindex = 50,
    }
    if wins[buf] and vim.api.nvim_win_is_valid(wins[buf]) then
      vim.api.nvim_win_set_config(wins[buf], cfg)
    else
      wins[buf] = vim.api.nvim_open_win(buf, false, cfg)
    end
  end
  highlight_borders()
end

local function hide()
  for buf, win in pairs(wins) do
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    wins[buf] = nil
  end
end

local function close_pane(buf)
  if not root then
    return
  end
  root = prune(root, buf)
  if wins[buf] and vim.api.nvim_win_is_valid(wins[buf]) then
    vim.api.nvim_win_close(wins[buf], true)
  end
  wins[buf] = nil
  if vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_delete(buf, { force = true })
  end
  if not root then
    rects, last = {}, nil
  else
    if last == buf then
      last = first_leaf(root)
    end
    show()
    focus(last)
  end
end

local function move(key)
  local cur = rects[vim.api.nvim_get_current_buf()]
  if not cur then
    return
  end
  local best, best_dist
  for buf, r in pairs(rects) do
    -- a neighbour lies beyond our edge in that direction and overlaps us on the other axis
    local beyond = (key == "h" and r.col + r.width <= cur.col)
      or (key == "l" and r.col >= cur.col + cur.width)
      or (key == "k" and r.row + r.height <= cur.row)
      or (key == "j" and r.row >= cur.row + cur.height)
    local overlaps = (key == "h" or key == "l")
        and r.row < cur.row + cur.height and cur.row < r.row + r.height
      or r.col < cur.col + cur.width and cur.col < r.col + r.width
    if beyond and overlaps then
      local dist = math.abs(r.col - cur.col) + math.abs(r.row - cur.row)
      if not best_dist or dist < best_dist then
        best, best_dist = buf, dist
      end
    end
  end
  if best then
    focus(best)
  end
end

local split

---A new pane's terminal buffer, with the pane keys mapped on it
local function new_buf()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].filetype = "floatterm"
  local map = function(lhs, fn, desc) vim.keymap.set("n", lhs, fn, { buffer = buf, desc = desc }) end
  map("<leader>wv", function() split("v") end, "Split terminal pane vertically")
  map("<leader>wh", function() split("h") end, "Split terminal pane horizontally")
  map("<leader>wc", function() close_pane(buf) end, "Close terminal pane")
  for _, key in ipairs({ "h", "j", "k", "l" }) do
    map("<C-" .. key .. ">", function() move(key) end, "Move to terminal pane " .. key)
  end
  -- Ctrl+C reaches the shell in terminal mode already; outside it, send the same
  -- interrupt to the pane's process and go back to typing in the shell
  map("<C-c>", function()
    vim.fn.chansend(vim.bo[buf].channel, "\3")
    vim.cmd.startinsert()
  end, "Interrupt the running process")
  -- One key out of terminal mode. Terminals send Ctrl+Space as <C-Space> or as NUL (<C-@>)
  for _, lhs in ipairs({ "<C-Space>", "<C-@>" }) do
    vim.keymap.set("t", lhs, [[<C-\><C-n>]], { buffer = buf, desc = "Leave terminal mode" })
  end
  return buf
end

---Start the shell once the pane's window exists, so the terminal gets the pane's size
local function start(buf)
  vim.api.nvim_win_call(wins[buf], function()
    vim.fn.jobstart(vim.o.shell, {
      term = true,
      on_exit = vim.schedule_wrap(function() close_pane(buf) end),
    })
  end)
end

function split(dir)
  local cur = vim.api.nvim_get_current_buf()
  local r = rects[cur]
  if not r then
    return
  end
  local half_w, half_h = math.floor(r.width / 2) - 2, math.floor(r.height / 2) - 2
  if (dir == "v" and half_w < MIN_WIDTH) or (dir == "h" and half_h < MIN_HEIGHT) then
    return vim.notify("Terminal pane is too small to split", vim.log.levels.WARN)
  end
  local buf = new_buf()
  root = replace(root, cur, function(leaf) return { dir = dir, leaf, { buf = buf } } end)
  show()
  start(buf)
  focus(buf)
end

function M.toggle()
  if shown() then
    return hide()
  end
  if not root then
    local buf = new_buf()
    root = { buf = buf }
    show()
    start(buf)
    last = buf
  else
    show()
  end
  focus(last)
end

function M.setup()
  vim.keymap.set({ "n", "t" }, [[<C-\>]], M.toggle, { desc = "Toggle floating terminal" })

  local group = vim.api.nvim_create_augroup("floatterm", { clear = true })
  vim.api.nvim_create_autocmd("WinEnter", {
    group = group,
    callback = function()
      local buf = vim.api.nvim_get_current_buf()
      if rects[buf] then
        last = buf
      end
      if shown() then
        highlight_borders()
      end
    end,
  })
  vim.api.nvim_create_autocmd("VimResized", {
    group = group,
    callback = function()
      if root and shown() then
        show()
      end
    end,
  })
end

return M

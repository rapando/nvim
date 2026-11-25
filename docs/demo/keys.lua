-- Demo-only overlay for the recording: shows the keys being pressed (bottom right) and a
-- caption for the step (bottom left). Loaded with `nvim -c "luafile keys.lua"`; not part of the config.
local ns = vim.api.nvim_create_namespace("demo_keys")
vim.api.nvim_set_hl(0, "DemoKey", { bg = "#c4a7e7", fg = "#232136", bold = true })
vim.api.nvim_set_hl(0, "DemoCaption", { bg = "#393552", fg = "#e0def4", bold = true })

local names = { ["<Space>"] = "Space", ["<CR>"] = "Enter", ["<Tab>"] = "Tab", ["<Esc>"] = "Esc", ["<BS>"] = "⌫" }
local seq, last = {}, 0
local keys_win, keys_buf, cap_win, cap_buf
local clear_timer, cap_timer

local function float(buf, anchor, col, row)
  return vim.api.nvim_open_win(buf, false, {
    relative = "editor", anchor = anchor, row = row, col = col, width = 1, height = 1,
    style = "minimal", focusable = false, zindex = 300, noautocmd = true,
  })
end

local function show(win_name, text, spans)
  local buf = win_name == "keys" and keys_buf or cap_buf
  local win = win_name == "keys" and keys_win or cap_win
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { text })
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for _, s in ipairs(spans or { { 0, #text, win_name == "keys" and "DemoKey" or "DemoCaption" } }) do
    vim.api.nvim_buf_set_extmark(buf, ns, 0, s[1], { end_col = math.min(s[2], #text), hl_group = s[3], strict = false })
  end
  vim.api.nvim_win_set_config(win, { width = math.max(1, vim.fn.strdisplaywidth(text)), hide = text == "" })
end

local function captions(tokens, ft)
  local joined = table.concat(tokens, " ")
  local function ends(s) return joined:sub(-#s) == s end
  if ends("Space k k") then return "Code explorer: project map · code · callers, callees, tests" end
  if ends("Space k g") then return "Import graph: ↻ marks an import cycle" end
  if ft == "explorer-graph" and ends("d") then return "d: also show what the imports import" end
  if ft == "explorer-graph" and ends("f") then return "f: re-center on the module under the cursor" end
  if ft == "explorer-graph" and ends("q") then return "q: back to the code" end
  if ends("Space t f") then return "Run this file's tests" end
  if ends("Space d b") then return "Breakpoint set" end
  if ends("Space k d") then return "Debug the last failing test" end
  if ends("Space d c") then return "Continue: call trail and values on the paused line" end
  local name = vim.api.nvim_buf_get_name(0)
  if ft == "explorer" and ends("Enter") then
    return name:find("map", 1, true) and "Enter: open the file, or fold the folder" or "Enter: jump to the entry"
  end
  if ends("Space d u") then return "Hide the debugger UI to make room" end
  if ft == "explorer" and ends("/ t e s t s") then return "Find the tests in the map" end
  if ends("Tab") then return "Tab: move between map, code and context panel" end
end

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    keys_buf, cap_buf = vim.api.nvim_create_buf(false, true), vim.api.nvim_create_buf(false, true)
    local row = vim.o.lines - 2
    keys_win = float(keys_buf, "SE", vim.o.columns - 1, row)
    cap_win = float(cap_buf, "SW", 1, row)
    show("keys", "")
    show("cap", "")
  end,
})

vim.on_key(function(_, typed)
  if not typed or typed == "" or not keys_win then
    return
  end
  local key = vim.fn.keytrans(typed)
  if key:find("Mouse") or key:find("^<Cmd") or key:find("^<Plug") then
    return
  end
  local now = vim.uv.hrtime() / 1e6
  if now - last > 1800 then
    seq = {}
  end
  last = now
  seq[#seq + 1] = names[key] or key
  if #seq > 6 then
    table.remove(seq, 1)
  end
  vim.schedule(function()
    local text, spans = "", {}
    for i, k in ipairs(seq) do
      local cap = " " .. k .. " "
      if i > 1 then
        text = text .. " "
      end
      spans[#spans + 1] = { #text, #text + #cap, "DemoKey" }
      text = text .. cap
    end
    show("keys", text, spans)
    local caption = captions(seq, vim.bo.filetype)
    if caption then
      show("cap", " " .. caption .. " ")
      if cap_timer then cap_timer:stop() end
      cap_timer = vim.defer_fn(function() show("cap", "") end, 7000)
    end
    if clear_timer then clear_timer:stop() end
    clear_timer = vim.defer_fn(function() show("keys", "") end, 1800)
  end)
end)

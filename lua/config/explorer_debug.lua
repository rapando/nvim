-- Debug view for code explorer mode.
--   <leader>kd  debug the last failing test (neotest + nvim-dap)
-- Remembers which tests failed, runs the last failure under the debugger with a breakpoint on the
-- line that failed, and when the debugger stops shows:
--   * a call trail of your own code only (library frames folded, `z` shows them)
--   * the values of the variables used on the paused line, inline
local M = {}

local ns = vim.api.nvim_create_namespace("code_explorer_debug")
M.failures = {} -- position id -> { id, path, name, line, message }
M.order = {} -- failure ids, oldest first

local panel -- { buf, win, entries, frames, show_library }
local attached = false

-- Failures from neotest --------------------------------------------------------------------------

-- Registered in neotest's setup as a consumer: sees every result as tests finish
function M.consumer(client)
  client.listeners.results = function(_, results)
    for id, result in pairs(results) do
      if id:find("::", 1, true) then
        if result.status == "failed" then
          local err = result.errors and result.errors[1] or {}
          M.failures[id] = {
            id = id,
            path = id:match("^(.-)::"),
            name = id:match("::([^:]+)$") or id,
            line = err.line and (err.line + 1) or nil,
            message = err.message or result.short,
          }
          M.order = vim.tbl_filter(function(x) return x ~= id end, M.order)
          M.order[#M.order + 1] = id
        elseif result.status == "passed" and M.failures[id] then
          M.failures[id] = nil
          M.order = vim.tbl_filter(function(x) return x ~= id end, M.order)
        end
      end
    end
  end
  return {}
end

-- Trail ---------------------------------------------------------------------------------------

local function project_root()
  local out = vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true }):wait()
  local root = vim.trim(out.stdout or "")
  return (out.code == 0 and root ~= "") and root or vim.uv.cwd()
end

local function is_library(path, root)
  if not path or not vim.startswith(path, root .. "/") then
    return true
  end
  return path:find("/%.?venv/") ~= nil or path:find("site%-packages") ~= nil or path:find("/node_modules/") ~= nil
end

local function ensure_panel()
  if panel and vim.api.nvim_win_is_valid(panel.win) then
    return panel
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype, vim.bo[buf].bufhidden, vim.bo[buf].filetype = "nofile", "wipe", "explorer"
  local prev = vim.api.nvim_get_current_win()
  local win = vim.api.nvim_open_win(buf, false, { split = "right", win = -1, width = 44 })
  for k, v in pairs({ number = false, relativenumber = false, signcolumn = "no", wrap = false, cursorline = true, winfixwidth = true }) do
    vim.wo[win][k] = v
  end
  vim.w[win].explorer = true
  panel = { buf = buf, win = win, show_library = panel and panel.show_library or false }
  local function map(lhs, fn)
    vim.keymap.set("n", lhs, fn, { buffer = buf, nowait = true })
  end
  map("q", M.close)
  map("z", function()
    panel.show_library = not panel.show_library
    M.render()
  end)
  map("<CR>", function()
    local entry = panel.entries and panel.entries[vim.api.nvim_win_get_cursor(0)[1]]
    if not entry then
      return
    end
    local session = require("dap").session()
    if session and entry.frame then
      pcall(session._frame_set, session, entry.frame)
    end
    -- go to the code window, not another panel
    local target
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if not vim.w[w].explorer and vim.api.nvim_win_get_config(w).relative == "" and vim.bo[vim.api.nvim_win_get_buf(w)].buftype == "" then
        target = w
        break
      end
    end
    if target and entry.path then
      vim.api.nvim_set_current_win(target)
      vim.cmd.edit(vim.fn.fnameescape(entry.path))
      vim.api.nvim_win_set_cursor(0, { entry.line, 0 })
      vim.cmd("normal! zz")
    end
  end)
  vim.api.nvim_set_current_win(prev)
  return panel
end

function M.close()
  if panel and vim.api.nvim_win_is_valid(panel.win) and #vim.api.nvim_tabpage_list_wins(0) > 1 then
    vim.api.nvim_win_close(panel.win, true)
  end
  panel = nil
end

local function rel(root, path)
  return vim.startswith(path, root .. "/") and path:sub(#root + 2) or vim.fn.fnamemodify(path, ":t")
end

function M.render()
  if not panel or not vim.api.nvim_buf_is_valid(panel.buf) or not panel.frames then
    return
  end
  local root = panel.root
  local lines, hls, entries = { " Debug trail" }, { { 0, "Title" } }, {}
  local function add(text, hl, entry)
    lines[#lines + 1] = text
    if hl then
      hls[#hls + 1] = { #lines - 1, hl }
    end
    entries[#lines] = entry
  end
  if panel.failure then
    add(" ✗ " .. panel.failure.name, "DiagnosticError")
    local first = (panel.failure.message or ""):match("[^\n]+")
    if first then
      add("   " .. first:sub(1, 38), "Comment")
    end
    add("")
  end

  -- outermost call first, the paused frame last
  local frames = {}
  for i = #panel.frames, 1, -1 do
    frames[#frames + 1] = panel.frames[i]
  end
  local depth, hidden = 0, 0
  for i, frame in ipairs(frames) do
    local path = frame.source and frame.source.path
    local library = is_library(path, root)
    local paused = i == #frames
    if library and not panel.show_library and not paused then
      hidden = hidden + 1
    else
      local where = path and ("%s:%d"):format(rel(root, path), frame.line) or "?"
      local indent = depth == 0 and " " or (" " .. string.rep(" ", depth - 1) .. "└ ")
      local text = ("%s%s  %s"):format(indent, where, frame.name)
      if paused then
        text = text .. "   ◀"
      end
      add(text, paused and "Visual" or (library and "Comment" or nil), path and { path = path, line = frame.line, frame = frame } or nil)
      depth = depth + 1
    end
  end
  if hidden > 0 then
    add("")
    add((" %d library frame%s hidden  (z to show)"):format(hidden, hidden == 1 and "" or "s"), "Comment")
  end
  add("")
  add(" ⏎ jump   z library frames   q close", "Comment")

  vim.bo[panel.buf].modifiable = true
  vim.api.nvim_buf_set_lines(panel.buf, 0, -1, false, lines)
  vim.bo[panel.buf].modifiable = false
  vim.api.nvim_buf_clear_namespace(panel.buf, ns, 0, -1)
  for _, h in ipairs(hls) do
    vim.api.nvim_buf_set_extmark(panel.buf, ns, h[1], 0, { end_row = h[1] + 1, hl_group = h[2], hl_eol = true, strict = false })
  end
  panel.entries = entries
  if vim.api.nvim_win_is_valid(panel.win) then
    pcall(vim.api.nvim_win_set_cursor, panel.win, { #lines - 2, 0 })
  end
end

-- Inline values -------------------------------------------------------------------------------

local function clear_inline()
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) then
      vim.api.nvim_buf_clear_namespace(b, ns, 0, -1)
    end
  end
end

local function show_inline(session, frame)
  local path = frame.source and frame.source.path
  if not path then
    return
  end
  session:request("scopes", { frameId = frame.id }, function(err, resp)
    local scope = not err and resp and resp.scopes and resp.scopes[1]
    if not scope then
      return
    end
    session:request("variables", { variablesReference = scope.variablesReference }, function(err2, vars)
      if err2 or not vars then
        return
      end
      vim.schedule(function()
        local buf = vim.fn.bufnr(path)
        if buf < 0 or not vim.api.nvim_buf_is_loaded(buf) then
          return
        end
        local text = vim.api.nvim_buf_get_lines(buf, frame.line - 1, frame.line, false)[1] or ""
        local values = {}
        for _, v in ipairs(vars.variables or {}) do
          if v.type ~= "function" and v.type ~= "module" and not v.name:find("^[%s%(]") and not v.name:find("^__") then
            values[v.name] = v.value
          end
        end
        local shown, seen = {}, {}
        for word in text:gmatch("[%a_][%w_]*") do
          if values[word] and not seen[word] then
            seen[word] = true
            local value = values[word]:gsub("\n", " ")
            shown[#shown + 1] = ("%s = %s"):format(word, #value > 30 and (value:sub(1, 29) .. "…") or value)
          end
        end
        if #shown > 0 then
          vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
          vim.api.nvim_buf_set_extmark(buf, ns, frame.line - 1, 0, {
            virt_text = { { "  ◂ " .. table.concat(shown, "   "), "DiagnosticVirtualTextInfo" } },
            virt_text_pos = "eol",
          })
        end
      end)
    end)
  end)
end

-- Debugger events -----------------------------------------------------------------------------

function M.attach()
  if attached then
    return
  end
  attached = true
  local dap = require("dap")
  dap.listeners.after.event_stopped["code_explorer"] = function(session, body)
    session:request("stackTrace", { threadId = body.threadId, levels = 60 }, function(err, resp)
      if err or not resp then
        return
      end
      vim.schedule(function()
        local frames = resp.stackFrames or {}
        local root = project_root()
        local p = ensure_panel()
        p.frames, p.root = frames, root
        local last = M.order[#M.order]
        p.failure = M.running_failure or (last and M.failures[last]) or nil
        M.render()
        -- values for the first frame in the project
        for _, frame in ipairs(frames) do
          if not is_library(frame.source and frame.source.path, root) then
            show_inline(session, frame)
            break
          end
        end
      end)
    end)
  end
  local function finished()
    vim.schedule(function()
      clear_inline()
      M.running_failure = nil
      M.close()
    end)
  end
  dap.listeners.after.event_continued["code_explorer"] = function()
    vim.schedule(clear_inline)
  end
  dap.listeners.before.event_terminated["code_explorer"] = finished
  dap.listeners.before.event_exited["code_explorer"] = finished
end

-- Entry point ---------------------------------------------------------------------------------

function M.debug_last_failure()
  local id = M.order[#M.order]
  local failure = id and M.failures[id]
  if not failure then
    vim.notify("No failing test recorded yet. Run the tests first (<leader>tt or <leader>tf).", vim.log.levels.INFO)
    return
  end
  M.attach()
  M.running_failure = failure
  -- stop on the line that failed
  if failure.line and failure.path and vim.uv.fs_stat(failure.path) then
    local buf = vim.fn.bufadd(failure.path)
    vim.fn.bufload(buf)
    local has = false
    for _, bp in ipairs(require("dap.breakpoints").get(buf)[buf] or {}) do
      has = has or bp.line == failure.line
    end
    if not has then
      require("dap.breakpoints").set({}, buf, failure.line)
    end
  end
  require("neotest").run.run({ failure.id, strategy = "dap" })
end

-- A session started any other way (<leader>dc) gets the trail too
function M.enable()
  M.attach()
  vim.notify("Debug trail on: it appears when the debugger next stops")
end

return M

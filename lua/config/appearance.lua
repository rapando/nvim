-- Appearance: pick a colorscheme (applied live, saved across sessions) and the terminal font.
-- Neovim in a terminal can't draw its own font, so font changes go to the terminal itself:
--   Ghostty: written to its config, applied through AppleScript `perform action` (>= 1.3).
--   WezTerm: written to ~/.config/wezterm/nvim-appearance.lua, which your wezterm.lua loads
--            (see wezterm_snippet below); WezTerm hot-reloads it.
--   Terminal.app: set through AppleScript on the front window and the default profile.
local M = {}

M.themes = {
  { name = "rose-pine-moon", label = "Rosé Pine Moon" },
  { name = "rose-pine-main", label = "Rosé Pine" },
  { name = "rose-pine-dawn", label = "Rosé Pine Dawn", light = true },
  { name = "tokyonight-night", label = "Tokyo Night" },
  { name = "tokyonight-storm", label = "Tokyo Night Storm" },
  { name = "tokyonight-day", label = "Tokyo Night Day", light = true },
  { name = "catppuccin-mocha", label = "Catppuccin Mocha" },
  { name = "catppuccin-macchiato", label = "Catppuccin Macchiato" },
  { name = "catppuccin-latte", label = "Catppuccin Latte", light = true },
  { name = "kanagawa-wave", label = "Kanagawa Wave" },
  { name = "kanagawa-dragon", label = "Kanagawa Dragon" },
  { name = "kanagawa-lotus", label = "Kanagawa Lotus", light = true },
}

local opts = {
  default_theme = "rose-pine-moon",
  state_file = vim.fn.stdpath("data") .. "/appearance.json",
  ghostty_config = nil, -- auto-detected
  apply_to_terminal = true, -- false: write the config but don't tell Ghostty to reload
  wezterm_file = nil, -- auto: <config dir>/wezterm/nvim-appearance.lua
}

local BLOCK_START = "# >>> nvim appearance (managed by ~/.config/nvim) >>>"
local BLOCK_END = "# <<< nvim appearance <<<"

-- State ---------------------------------------------------------------------------------------

local function read_state()
  local f = io.open(opts.state_file)
  if not f then
    return {}
  end
  local ok, data = pcall(vim.json.decode, f:read("*a"))
  f:close()
  return ok and type(data) == "table" and data or {}
end

local function write_state(patch)
  local data = vim.tbl_extend("force", read_state(), patch)
  local f = io.open(opts.state_file, "w")
  if f then
    f:write(vim.json.encode(data))
    f:close()
  end
end

local function theme_label(name)
  for _, t in ipairs(M.themes) do
    if t.name == name then
      return t.label
    end
  end
  return name
end

-- Themes --------------------------------------------------------------------------------------

function M.apply_theme(name)
  local ok = pcall(vim.cmd.colorscheme, name)
  if ok then
    M.current = name
  else
    vim.notify("Theme not found: " .. name, vim.log.levels.WARN)
  end
  return ok
end

function M.pick_theme(on_done)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_set = require("telescope.actions.set")
  local action_state = require("telescope.actions.state")

  local before = M.current
  local current = 1
  for i, t in ipairs(M.themes) do
    if t.name == before then
      current = i
    end
  end

  pickers
    .new(require("telescope.themes").get_dropdown({ previewer = false, layout_config = { width = 44 } }), {
      prompt_title = "Theme  (live preview · <CR> keep · <Esc> revert)",
      default_selection_index = current,
      finder = finders.new_table({
        results = M.themes,
        entry_maker = function(t)
          local mark = t.name == before and "● " or "  "
          return { value = t, ordinal = t.label, display = mark .. t.label .. (t.light and "  (light)" or "") }
        end,
      }),
      sorter = conf.generic_sorter({}),
      -- typing a filter moves the selection without a shift_selection, so preview here too
      on_complete = {
        function()
          local entry = action_state.get_selected_entry()
          if entry and entry.value.name ~= M.current then
            M.apply_theme(entry.value.name)
          end
        end,
      },
      attach_mappings = function(bufnr)
        local keep = false
        local function preview()
          local entry = action_state.get_selected_entry()
          if entry then
            M.apply_theme(entry.value.name)
          end
        end
        action_set.shift_selection:enhance({ post = preview })
        actions.select_default:replace(function()
          local entry = action_state.get_selected_entry()
          keep = true
          actions.close(bufnr)
          if entry and M.apply_theme(entry.value.name) then
            write_state({ theme = entry.value.name })
          end
          if on_done then
            on_done()
          end
        end)
        actions.close:enhance({
          post = function()
            if not keep and before then
              M.apply_theme(before)
            end
          end,
        })
        return true
      end,
    })
    :find()
end

-- Terminal font (Ghostty) ---------------------------------------------------------------------

local function in_ghostty()
  -- TERM_PROGRAM is "tmux" inside tmux, but Ghostty's resources dir is still inherited
  return vim.env.TERM_PROGRAM == "ghostty" or vim.env.GHOSTTY_RESOURCES_DIR ~= nil
end

local function ghostty_bin()
  local bin = vim.fn.exepath("ghostty")
  if bin == "" and vim.uv.fs_stat("/Applications/Ghostty.app/Contents/MacOS/ghostty") then
    bin = "/Applications/Ghostty.app/Contents/MacOS/ghostty"
  end
  return bin ~= "" and bin or nil
end

local function ghostty_config_path()
  if opts.ghostty_config then
    return opts.ghostty_config
  end
  local xdg = vim.env.XDG_CONFIG_HOME or (vim.env.HOME .. "/.config")
  local mac = vim.env.HOME .. "/Library/Application Support/com.mitchellh.ghostty"
  for _, p in ipairs({ xdg .. "/ghostty/config.ghostty", xdg .. "/ghostty/config", mac .. "/config.ghostty", mac .. "/config" }) do
    if vim.uv.fs_stat(p) then
      return p
    end
  end
  return mac .. "/config.ghostty"
end

-- Current terminal font as Ghostty resolves it (managed block included)
local function ghostty_current()
  local bin = ghostty_bin()
  local res = { family = nil, size = nil }
  if not bin then
    return res
  end
  local out = vim.system({ bin, "+show-config" }, { text = true }):wait()
  for line in (out.stdout or ""):gmatch("[^\n]+") do
    local k, v = line:match("^(font%-[%w%-]+) = (.*)$")
    if k == "font-family" and v ~= "" and not res.family then
      res.family = v
    elseif k == "font-size" then
      res.size = tonumber(v)
    end
  end
  return res
end

-- Replace (or append) the managed block at the end of Ghostty's config, so it wins over the
-- user's own lines without touching them. `font-family = ""` clears the fallback list first.
local function write_ghostty(settings)
  local path = ghostty_config_path()
  local lines = {}
  local f = io.open(path)
  if f then
    local inside = false
    for line in f:lines() do
      if line == BLOCK_START then
        inside = true
      elseif line == BLOCK_END then
        inside = false
      elseif not inside then
        lines[#lines + 1] = line
      end
    end
    f:close()
  end
  while #lines > 0 and lines[#lines] == "" do
    lines[#lines] = nil
  end
  local block = { "", BLOCK_START }
  if settings.family then
    vim.list_extend(block, { 'font-family = ""', ('font-family = "%s"'):format(settings.family) })
  end
  if settings.size then
    block[#block + 1] = ("font-size = %d"):format(settings.size)
  end
  block[#block + 1] = BLOCK_END
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  vim.fn.writefile(vim.list_extend(lines, block), path)
end

local function ghostty_action(action)
  if not opts.apply_to_terminal or vim.fn.executable("osascript") == 0 then
    return
  end
  local script = ('tell application "Ghostty" to perform action "%s" on focused terminal of selected tab of front window'):format(action)
  vim.system({ "osascript", "-e", script }, { text = true }, function(out)
    if out.code ~= 0 then
      vim.schedule(function()
        vim.notify("Ghostty didn't accept the change: " .. vim.trim(out.stderr or ""), vim.log.levels.WARN)
      end)
    end
  end)
end

-- WezTerm ------------------------------------------------------------------------------------

local function in_wezterm()
  return vim.env.TERM_PROGRAM == "WezTerm" or vim.env.WEZTERM_PANE ~= nil or vim.env.WEZTERM_EXECUTABLE ~= nil
end

local function wezterm_file()
  if opts.wezterm_file then
    return opts.wezterm_file
  end
  local xdg = vim.env.XDG_CONFIG_HOME or (vim.env.HOME .. "/.config")
  return xdg .. "/wezterm/nvim-appearance.lua"
end

local wezterm_snippet = [[
-- in your wezterm.lua, after `local config = wezterm.config_builder()`:
local nvim_appearance = (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/wezterm/nvim-appearance.lua"
wezterm.add_to_config_reload_watch_list(nvim_appearance)
local ok, a = pcall(dofile, nvim_appearance)
if ok then
  if a.family then config.font = wezterm.font(a.family) end
  if a.size then config.font_size = a.size end
end]]

local function wezterm_hooked()
  local xdg = vim.env.XDG_CONFIG_HOME or (vim.env.HOME .. "/.config")
  for _, p in ipairs({ vim.env.WEZTERM_CONFIG_FILE, vim.env.HOME .. "/.wezterm.lua", xdg .. "/wezterm/wezterm.lua" }) do
    if p and vim.uv.fs_stat(p) then
      local f = io.open(p)
      local text = f and f:read("*a") or ""
      if f then
        f:close()
      end
      return text:find("nvim-appearance", 1, true) ~= nil, p
    end
  end
  return false, nil
end

local function write_wezterm(settings)
  local path = wezterm_file()
  local parts = {}
  if settings.family then
    parts[#parts + 1] = ("  family = %q,"):format(settings.family)
  end
  if settings.size then
    parts[#parts + 1] = ("  size = %d,"):format(settings.size)
  end
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  vim.fn.writefile({ "-- managed by ~/.config/nvim (appearance.lua)", "return {", unpack(parts), "}" }, path)
  if not wezterm_hooked() then
    vim.notify(
      "WezTerm doesn't load " .. path .. " yet. Add this to your wezterm.lua:\n\n" .. wezterm_snippet,
      vim.log.levels.WARN
    )
  end
end

-- Terminal.app -------------------------------------------------------------------------------

local function in_apple_terminal()
  return vim.env.TERM_PROGRAM == "Apple_Terminal" or vim.env.__CFBundleIdentifier == "com.apple.Terminal"
end

local function osa(script)
  if vim.fn.executable("osascript") == 0 then
    return nil
  end
  local out = vim.system({ "osascript", "-e", script }, { text = true }):wait()
  if out.code ~= 0 then
    vim.notify("Terminal.app didn't accept the change: " .. vim.trim(out.stderr or ""), vim.log.levels.WARN)
    return nil
  end
  return vim.trim(out.stdout or "")
end

-- Terminal.app wants a PostScript name ("JetBrainsMonoNF-Regular"); resolve it from the family
local function postscript_name(family)
  local out = vim.system({ "fc-match", "-f", "%{postscriptname}", family }, { text = true }):wait()
  local name = vim.trim(out.stdout or "")
  return name ~= "" and name or family
end

local function apple_terminal_current()
  local res = { family = nil, size = nil }
  local out = osa(
    'tell application "Terminal" to return (font size of current settings of selected tab of front window) as text'
  )
  res.size = tonumber(out)
  return res
end

local function apple_terminal_apply(t)
  if not opts.apply_to_terminal then
    return
  end
  local cmds = {}
  for _, target in ipairs({ "current settings of selected tab of front window", "default settings" }) do
    if t.family then
      cmds[#cmds + 1] = ('set font name of %s to "%s"'):format(target, postscript_name(t.family))
    end
    if t.size then
      cmds[#cmds + 1] = ("set font size of %s to %d"):format(target, t.size)
    end
  end
  if #cmds > 0 then
    osa('tell application "Terminal"\n' .. table.concat(cmds, "\n") .. "\nend tell")
  end
end

-- Terminals we can switch fonts in
local function backend()
  if in_ghostty() and ghostty_bin() then
    return "ghostty"
  elseif in_wezterm() then
    return "wezterm"
  elseif in_apple_terminal() then
    return "terminal"
  end
end

local function terminal_name()
  return ({ wezterm = "WezTerm", terminal = "Terminal.app" })[backend()] or "Ghostty"
end

local function current_font()
  if backend() == "ghostty" then
    return ghostty_current()
  end
  if backend() == "terminal" then
    return apple_terminal_current()
  end
  return { family = nil, size = nil } -- WezTerm: only our managed values are known
end

local function managed()
  return read_state().terminal or {}
end

local function set_terminal(patch)
  local t = vim.tbl_extend("force", managed(), patch)
  write_state({ terminal = t })
  if backend() == "wezterm" then
    write_wezterm(t)
    return -- WezTerm hot-reloads the watched file
  end
  if backend() == "terminal" then
    apple_terminal_apply(patch)
    return
  end
  write_ghostty(t)
  if patch.size then
    ghostty_action("set_font_size:" .. patch.size)
  end
  if patch.family then
    ghostty_action("reload_config")
  end
end

function M.list_fonts()
  local lines = {}
  if backend() ~= "ghostty" then
    -- WezTerm / Terminal.app: fontconfig's family list ("A,B" aliases: keep the first name)
    if vim.fn.executable("fc-list") == 0 then
      return {}
    end
    local out = vim.system({ "fc-list", ":", "family" }, { text = true }):wait()
    for line in (out.stdout or ""):gmatch("[^\n]+") do
      lines[#lines + 1] = vim.trim(line:match("^([^,]+)"))
    end
  else
    local out = vim.system({ ghostty_bin(), "+list-fonts" }, { text = true }):wait()
    for line in (out.stdout or ""):gmatch("[^\n]+") do
      if not line:match("^%s") then
        lines[#lines + 1] = line
      end
    end
  end
  local fonts, seen = {}, {}
  for _, line in ipairs(lines) do
    if line ~= "" and not seen[line] then
      seen[line] = true
      fonts[#fonts + 1] = { family = line, nerd = line:find("Nerd Font") ~= nil }
    end
  end
  table.sort(fonts, function(a, b)
    if a.nerd ~= b.nerd then
      return a.nerd
    end
    return a.family < b.family
  end)
  return fonts
end

function M.pick_font(on_done)
  if not backend() then
    vim.notify("The font is set by your terminal; switching it from Neovim needs Ghostty, WezTerm or Terminal.app", vim.log.levels.WARN)
    return
  end
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local current = managed().family or current_font().family
  local fonts = M.list_fonts()
  -- the config may name a family loosely ("Iosevka Term" for "IosevkaTerm Nerd Font Mono")
  local function squash(name)
    return (name or ""):lower():gsub("[%s\"]", "")
  end
  local index
  for i, font in ipairs(fonts) do
    if not index and squash(current) ~= "" and vim.startswith(squash(font.family), squash(current)) then
      index, current = i, font.family
    end
  end

  pickers
    .new(require("telescope.themes").get_dropdown({ previewer = false, layout_config = { width = 44 } }), {
      prompt_title = ("Terminal font  (%s · <CR> apply)"):format(terminal_name()),
      default_selection_index = index or 1,
      finder = finders.new_table({
        results = fonts,
        entry_maker = function(font)
          local mark = font.family == current and "● " or "  "
          return { value = font, ordinal = font.family, display = mark .. font.family .. (font.nerd and "  \u{f0e7}" or "") }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(bufnr)
        actions.select_default:replace(function()
          local entry = action_state.get_selected_entry()
          actions.close(bufnr)
          if entry then
            set_terminal({ family = entry.value.family })
            if not entry.value.nerd then
              vim.notify("Not a Nerd Font: file and git icons will fall back to the terminal's built-in symbols")
            end
          end
          if on_done then
            on_done()
          end
        end)
        return true
      end,
    })
    :find()
end

function M.change_font_size(delta)
  local size = managed().size or current_font().size or (backend() == "wezterm" and 12 or 13)
  size = math.max(8, math.min(32, size + delta))
  set_terminal({ size = size })
  return size
end

-- Modal ---------------------------------------------------------------------------------------

function M.open()
  local width = 52
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].filetype = "appearance"
  local font = backend() and current_font() or {}
  local size = managed().size or font.size

  local function render()
    local family = managed().family or font.family or "terminal default"
    local font_row = backend() and family or "set by your terminal"
    local lines = {
      "",
      ("  Theme   %-30s  t"):format(theme_label(M.current or "")),
      ("  Font    %-30s  f"):format(font_row:sub(1, 30)),
      ("  Size    %-30s  - +"):format(backend() and tostring(size or "?") or "—"),
      "",
      "  t theme   f font   -/+ size   q close",
    }
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    local ns = vim.api.nvim_create_namespace("appearance_modal")
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    for row = 1, 3 do
      vim.api.nvim_buf_set_extmark(buf, ns, row, 2, { end_col = 8, hl_group = "Comment" })
      vim.api.nvim_buf_set_extmark(buf, ns, row, 10, { end_col = 40, hl_group = "Title" })
      vim.api.nvim_buf_set_extmark(buf, ns, row, 42, { end_col = #lines[row + 1], hl_group = "Special" })
    end
    vim.api.nvim_buf_set_extmark(buf, ns, 5, 0, { end_col = #lines[6], hl_group = "Comment" })
  end

  render()
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = 6,
    row = math.floor((vim.o.lines - 8) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = "  Appearance ",
    title_pos = "center",
  })
  vim.wo[win].cursorline = false

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
  local function map(lhs, fn)
    vim.keymap.set("n", lhs, fn, { buffer = buf, nowait = true })
  end
  map("q", close)
  map("<Esc>", close)
  map("t", function()
    close()
    M.pick_theme(M.open)
  end)
  map("f", function()
    close()
    M.pick_font(M.open)
  end)
  for lhs, delta in pairs({ ["-"] = -1, ["+"] = 1, ["="] = 1 }) do
    map(lhs, function()
      if backend() then
        size = M.change_font_size(delta)
        render()
      end
    end)
  end
end

function M.setup(user_opts)
  opts = vim.tbl_extend("force", opts, user_opts or {})
  -- `vim.g.colors_name` drops the variant (kanagawa-wave reports "kanagawa"), so track the
  -- name the scheme was loaded by, including a manual :colorscheme
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("appearance_current", { clear = true }),
    callback = function(args)
      M.current = args.match
    end,
  })
  M.apply_theme(read_state().theme or opts.default_theme)
end

return M

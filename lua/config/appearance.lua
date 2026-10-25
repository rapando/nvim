-- Appearance: pick a colorscheme (applied live, saved across sessions) and the terminal font.
-- Neovim in a terminal can't draw its own font, so font changes are written to Ghostty's
-- config and applied through Ghostty's AppleScript `perform action` (Ghostty >= 1.3).
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

local function managed()
  return read_state().terminal or {}
end

local function set_terminal(patch)
  local t = vim.tbl_extend("force", managed(), patch)
  write_state({ terminal = t })
  write_ghostty(t)
  if patch.size then
    ghostty_action("set_font_size:" .. patch.size)
  end
  if patch.family then
    ghostty_action("reload_config")
  end
end

function M.list_fonts()
  local bin = ghostty_bin()
  if not bin then
    return {}
  end
  local out = vim.system({ bin, "+list-fonts" }, { text = true }):wait()
  local fonts, seen = {}, {}
  for line in (out.stdout or ""):gmatch("[^\n]+") do
    if not line:match("^%s") and not seen[line] then
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
  if not in_ghostty() or not ghostty_bin() then
    vim.notify("The font is set by your terminal; switching it from Neovim needs Ghostty", vim.log.levels.WARN)
    return
  end
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local current = ghostty_current().family
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
      prompt_title = "Terminal font  (Ghostty · <CR> apply)",
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
              vim.notify("Not a Nerd Font: file and git icons will fall back to Ghostty's built-in symbols")
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
  local size = managed().size or ghostty_current().size or 13
  size = math.max(8, math.min(32, size + delta))
  set_terminal({ size = size })
  return size
end

-- Modal ---------------------------------------------------------------------------------------

function M.open()
  local width = 52
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].filetype = "appearance"
  local font = in_ghostty() and ghostty_current() or {}
  local size = managed().size or font.size

  local function render()
    local family = managed().family or font.family or "terminal default"
    local font_row = in_ghostty() and family or "set by your terminal"
    local lines = {
      "",
      ("  Theme   %-30s  t"):format(theme_label(M.current or "")),
      ("  Font    %-30s  f"):format(font_row:sub(1, 30)),
      ("  Size    %-30s  - +"):format(in_ghostty() and tostring(size or "?") or "—"),
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
      if in_ghostty() then
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

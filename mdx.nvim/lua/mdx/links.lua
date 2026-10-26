-- Broken relative links and #anchors, as diagnostics (buffer) or a quickfix list (project)
local util = require("mdx.util")
local M = {}

M.ns = vim.api.nvim_create_namespace("mdx.links")

local anchor_cache = {} ---@type table<string, { mtime: integer, slugs: table<string, true> }>

local function slugs_of(headings)
  local s = {}
  for _, h in ipairs(headings) do s[h.slug] = true end
  return s
end

local function file_slugs(path)
  local stat = vim.uv.fs_stat(path)
  if not stat then return nil end
  local c = anchor_cache[path]
  if c and c.mtime == stat.mtime.sec then return c.slugs end
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then return nil end
  local slugs = slugs_of(util.scan(lines).headings)
  anchor_cache[path] = { mtime = stat.mtime.sec, slugs = slugs }
  return slugs
end

local function decode(s)
  return (s:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end))
end

---@return string? problem
local function check(target, file, own_slugs)
  target = target:gsub("^<", ""):gsub(">$", "")
  if target == "" or target:match("^%a[%w+.-]*:") then return nil end -- http:, mailto:, …
  local path, anchor = target:match("^([^#]*)#?(.*)$")
  path = decode(path)
  if path == "" then
    if anchor ~= "" and not own_slugs[anchor:lower()] then return "No heading #" .. anchor end
    return nil
  end
  local base = vim.fs.dirname(file)
  if path:sub(1, 1) == "/" then base = vim.fs.root(file, ".git") or base end
  local full = vim.fs.normalize(vim.fs.joinpath(base, path))
  if not vim.uv.fs_stat(full) then return "Missing file " .. path end
  if anchor ~= "" and full:match("%.md$") then
    local slugs = file_slugs(full)
    if slugs and not slugs[anchor:lower()] then return "No heading #" .. anchor .. " in " .. vim.fs.basename(path) end
  end
  return nil
end

---@return { row: integer, col: integer, msg: string }[]
local function problems(lines, file)
  local scan = util.scan(lines)
  local own = slugs_of(scan.headings)
  local out = {}
  for _, l in ipairs(scan.links) do
    local msg = check(l.target, file, own)
    if msg then out[#out + 1] = { row = l.row, col = l.col, msg = msg } end
  end
  return out
end

function M.check_buffer(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  local file = vim.api.nvim_buf_get_name(buf)
  if file == "" then return vim.diagnostic.reset(M.ns, buf) end
  local diags = {}
  for _, p in ipairs(problems(vim.api.nvim_buf_get_lines(buf, 0, -1, false), file)) do
    diags[#diags + 1] = { lnum = p.row, col = p.col, message = p.msg, severity = vim.diagnostic.severity.WARN, source = "mdx" }
  end
  vim.diagnostic.set(M.ns, buf, diags)
end

---Check every markdown file under the cwd and list problems in the quickfix list
function M.check_project()
  local root = vim.fn.getcwd()
  local files = util.md_files(root)
  local items = {}
  for _, file in ipairs(files) do
    local buf = vim.fn.bufnr(file)
    local lines = (buf ~= -1 and vim.api.nvim_buf_is_loaded(buf)) and vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      or vim.fn.readfile(file)
    for _, p in ipairs(problems(lines, file)) do
      items[#items + 1] = { filename = file, lnum = p.row + 1, col = p.col + 1, text = p.msg, type = "W" }
    end
  end
  vim.fn.setqflist({}, " ", { title = "mdx: broken links", items = items })
  if #items == 0 then
    vim.notify(string.format("mdx: no broken links in %d markdown files", #files))
  elseif pcall(require, "trouble") then
    vim.cmd("Trouble qflist open")
  else
    vim.cmd("copen")
  end
  return items
end

return M

local M = {}

local warned = {}

---Warn once per key so a failing feature doesn't spam on every render
function M.warn_once(key, msg)
  if warned[key] then return end
  warned[key] = true
  vim.schedule(function() vim.notify("mdx: " .. msg, vim.log.levels.WARN) end)
end

---@return fun(...)
function M.debounce(ms, fn)
  local timer = assert(vim.uv.new_timer())
  return function(...)
    local args = { ... }
    timer:stop()
    timer:start(ms, 0, vim.schedule_wrap(function() fn(unpack(args)) end))
  end
end

function M.text(node, buf)
  return vim.treesitter.get_node_text(node, buf)
end

---Last line a node covers (a block ending at column 0 really ends on the line before)
function M.last_row(node)
  local er, ec = node:end_()
  return ec == 0 and er - 1 or er
end

---Format a number without trailing ".0"
function M.num(n)
  if n == math.floor(n) then return tostring(math.floor(n)) end
  return string.format("%.1f", n)
end

local fence_query
---Every fenced code block in a markdown tree
---@return { node: TSNode, lang: string?, code: string, first: integer, last: integer }[]
function M.fences(buf, root)
  fence_query = fence_query or vim.treesitter.query.parse("markdown", "(fenced_code_block) @block")
  local out = {}
  for _, node in fence_query:iter_captures(root, buf) do
    local lang, code = nil, ""
    for child in node:iter_children() do
      if child:type() == "info_string" then
        local l = child:named_child(0)
        lang = l and M.text(l, buf) or nil
      elseif child:type() == "code_fence_content" then
        code = M.text(child, buf)
      end
    end
    out[#out + 1] = { node = node, lang = lang, code = code, first = node:start(), last = M.last_row(node) }
  end
  return out
end

---GitHub-style heading anchor
function M.slug(text)
  local s = text:lower():gsub("`", ""):gsub("[^%w%s%-_\128-\255]", ""):gsub("%s", "-")
  return s
end

---Line-based scan of a markdown file: headings, task counts per heading and links.
---Used where there is no buffer/treesitter tree (project-wide outline and link check).
function M.scan(lines)
  local headings, links, seen = {}, {}, {}
  local stack, in_fence = {}, nil
  for i, line in ipairs(lines) do
    local fence = line:match("^%s*(```+)") or line:match("^%s*(~~~+)")
    if fence then
      if not in_fence then in_fence = fence elseif fence:sub(1, 1) == in_fence:sub(1, 1) then in_fence = nil end
    elseif not in_fence then
      local hashes, title = line:match("^(#+)%s+(.-)%s*#*%s*$")
      if hashes and #hashes <= 6 then
        local slug = M.slug(title)
        if seen[slug] then
          seen[slug] = seen[slug] + 1
          slug = slug .. "-" .. seen[slug]
        else
          seen[slug] = 0
        end
        local h = { row = i - 1, level = #hashes, text = title, slug = slug, done = 0, total = 0 }
        headings[#headings + 1] = h
        while #stack > 0 and stack[#stack].level >= h.level do stack[#stack] = nil end
        stack[#stack + 1] = h
      else
        local box = line:match("^%s*[-*+]%s+%[([ xX])%]%s")
        if box then
          for _, h in ipairs(stack) do
            h.total = h.total + 1
            if box ~= " " then h.done = h.done + 1 end
          end
        end
        -- blank out inline code so links inside it are ignored, keeping columns
        local scrubbed = line:gsub("`[^`]*`", function(s) return string.rep(" ", #s) end)
        for col, target in scrubbed:gmatch("()%]%(%s*(<?[^)%s]+>?)") do
          links[#links + 1] = { row = i - 1, col = col, target = target }
        end
      end
    end
  end
  return { headings = headings, links = links }
end

---Markdown files under root, skipping .git and node_modules
function M.md_files(root)
  if vim.fn.executable("fd") == 1 then
    local res = vim.system({ "fd", "--type", "f", "--extension", "md", "--hidden",
      "--exclude", ".git", "--exclude", "node_modules" }, { cwd = root, text = true }):wait()
    if res.code == 0 then
      local files = {}
      for f in vim.gsplit(vim.trim(res.stdout), "\n") do
        if f ~= "" then files[#files + 1] = vim.fs.joinpath(root, f) end
      end
      return files
    end
  end
  return vim.fs.find(function(name, path)
    return name:match("%.md$") and not path:match("/%.git") and not path:match("/node_modules")
  end, { path = root, type = "file", limit = math.huge })
end

return M

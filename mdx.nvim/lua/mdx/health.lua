local M = {}

function M.check()
  local h = vim.health
  h.start("mdx")

  for _, lang in ipairs({ "markdown", "markdown_inline" }) do
    if pcall(vim.treesitter.language.inspect, lang) then h.ok(lang .. " parser installed")
    else h.error(lang .. " parser missing", "Run :TSInstall " .. lang) end
  end

  local ok, state = pcall(require, "render-markdown.state")
  local handler = ok and state.custom_handlers and state.custom_handlers.markdown
  if handler and handler.extends then
    h.ok("Draws through render-markdown (custom handler registered)")
  elseif package.loaded["render-markdown"] then
    h.warn("render-markdown is loaded but mdx isn't its markdown handler; mdx draws on its own",
      "Add custom_handlers = { markdown = require('mdx').handler() } to render-markdown's opts")
  else
    h.info("render-markdown not loaded; mdx draws on its own")
  end

  h.start("mdx: code runners (<leader>mx)")
  local venv = vim.env.VIRTUAL_ENV
  if venv then h.ok("python: " .. venv .. "/bin/python (from $VIRTUAL_ENV)")
  elseif vim.fn.executable("python3") == 1 then h.ok("python: python3")
  else h.warn("python3 not found") end
  for _, exe in ipairs({ "go", "goimports", "bash" }) do
    if vim.fn.executable(exe) == 1 then h.ok(exe) else h.info(exe .. " not found") end
  end

  h.start("mdx: mermaid")
  local mode = require("mdx.config").options.mermaid.mode
  if vim.fn.executable("mmdc") == 1 and mode == "auto" then
    h.info("mmdc found: in Ghostty/kitty snacks.nvim draws diagrams as images and mdx skips them")
  else
    h.ok("Flowcharts are drawn as text (mode = " .. tostring(mode) .. ")")
  end
end

return M

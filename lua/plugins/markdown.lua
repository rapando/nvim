return {
  -- mdx: our markdown extras (task progress, table bars, runnable code blocks,
  -- link checks, text mermaid, outline picker). Lives in this repo under mdx.nvim/
  {
    dir = vim.fn.stdpath("config") .. "/mdx.nvim",
    name = "mdx",
    ft = { "markdown" },
    cmd = "Mdx",
    keys = {
      { "<leader>ml", "<cmd>Mdx links<CR>", desc = "Check markdown links (project)" },
      { "<leader>mo", "<cmd>Mdx outline<CR>", desc = "Markdown outline (project)" },
    },
    opts = {},
  },

  -- Markdown inline rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    -- mdx plugs into its custom handler API; stay on 8.x so an update can't change that API
    version = "^8",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons", "mdx" },
    ft = { "markdown" },
    keys = {
      { "<leader>mr", "<cmd>RenderMarkdown toggle<CR>", desc = "Toggle markdown render" },
    },
    opts = {
      render_modes = { "n", "c", "t" },
      -- Show raw markdown only on the cursor line
      anti_conceal = { enabled = true },
      latex = { enabled = false },
      heading = {
        sign = false,
        position = "inline",
        icons = { "󰼏  ", "󰎨  ", "󰼑  ", "󰎲  ", "󰼓  ", "󰎴  " },
        -- H1/H2 span the window and get a frame; H3+ hug their text
        width = { "full", "full", "block" },
        border = { true, true, false },
        border_virtual = true,
        above = "▁",
        below = "▔",
        left_pad = { 1, 1, 1, 1, 1, 1 },
        right_pad = 2,
        min_width = { 0, 0, 30, 24, 20, 20 },
      },
      paragraph = { left_margin = 0 },
      code = {
        sign = false,
        style = "full",
        width = "block",
        min_width = 60,
        left_pad = 2,
        right_pad = 2,
        border = "thick",
        language_name = true,
        inline_pad = 1,
      },
      dash = { icon = "─", width = "full" },
      bullet = { icons = { "●", "○", "◆", "◇" } },
      checkbox = {
        unchecked = { icon = "󰄱 " },
        checked = { icon = "󰄵 ", scope_highlight = "@markup.strikethrough" },
      },
      quote = { icon = "▌" },
      pipe_table = { preset = "round", cell = "padded" },
      link = { enabled = true },
      sign = { enabled = false },
      -- mdx draws its extras as part of render-markdown's pass (extends, so builtins still run)
      custom_handlers = {
        markdown = {
          extends = true,
          parse = function(ctx) return require("mdx").handler().parse(ctx) end,
        },
      },
    },
  },

  -- Inline images in markdown via the Kitty graphics protocol (Ghostty, kitty).
  -- Only the image module is enabled; non-PNG formats need ImageMagick (`magick`),
  -- mermaid fences need `mmdc`, math needs `tectonic` or `pdflatex`.
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false, -- must be loaded before the first markdown buffer opens
    opts = {
      image = {
        enabled = true,
        doc = { inline = true, max_width = 80, max_height = 30 },
      },
    },
  },

  -- Markdown browser preview (real typography / header sizes)
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = function()
      require("lazy").load({ plugins = { "markdown-preview.nvim" } })
      vim.fn["mkdp#util#install"]()
    end,
    init = function()
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_theme = "dark"
    end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", ft = "markdown", desc = "Markdown browser preview" },
    },
    -- its commands are buffer-local, created on FileType
    config = function()
      vim.cmd("doautocmd FileType")
    end,
  },
}

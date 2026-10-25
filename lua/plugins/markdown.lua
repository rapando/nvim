return {
  -- Markdown inline rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
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

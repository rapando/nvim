return {
  -- Default theme
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    config = function()
      require("rose-pine").setup({
        variant = "moon",
        -- Markdown heading hierarchy: stronger background + bold for higher levels
        highlight_groups = {
          RenderMarkdownH1Bg = { fg = "love", bg = "love", blend = 35, bold = true },
          RenderMarkdownH2Bg = { fg = "gold", bg = "gold", blend = 25, bold = true },
          RenderMarkdownH3Bg = { fg = "rose", bg = "rose", blend = 15, bold = true },
          RenderMarkdownH4Bg = { fg = "pine", bg = "pine", blend = 10, bold = true },
          RenderMarkdownH5Bg = { fg = "foam", bg = "foam", blend = 8 },
          RenderMarkdownH6Bg = { fg = "iris", bg = "iris", blend = 8 },
          RenderMarkdownH1 = { fg = "love", bold = true },
          RenderMarkdownH2 = { fg = "gold", bold = true },
          RenderMarkdownH3 = { fg = "rose", bold = true },
          RenderMarkdownH4 = { fg = "pine", bold = true },
          RenderMarkdownH5 = { fg = "foam" },
          RenderMarkdownH6 = { fg = "iris" },
          RenderMarkdownCode = { bg = "surface" },
          RenderMarkdownCodeBorder = { bg = "overlay" },
        },
      })
      vim.cmd([[colorscheme rose-pine]])
    end,
  },
}

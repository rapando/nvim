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
      -- Applies the theme saved by the appearance picker (<leader>ua), else Rosé Pine Moon
      require("config.appearance").setup()
    end,
  },

  -- More themes for the appearance picker; lazy.nvim loads each one on :colorscheme
  { "folke/tokyonight.nvim", lazy = true },
  { "catppuccin/nvim", name = "catppuccin", lazy = true },
  { "rebelot/kanagawa.nvim", lazy = true },
}

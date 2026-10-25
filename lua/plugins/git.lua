return {
  -- Lazygit integration
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },

  -- Git signs & inline blame
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local gs = require("gitsigns")
      gs.setup({
        signs = {
          add          = { text = "▎" },
          change       = { text = "▎" },
          delete       = { text = "" },
          topdelete    = { text = "" },
          changedelete = { text = "▎" },
        },
      })
      vim.keymap.set("n", "]h", function() gs.nav_hunk("next") end, { desc = "Next hunk" })
      vim.keymap.set("n", "[h", function() gs.nav_hunk("prev") end, { desc = "Prev hunk" })
      vim.keymap.set("n", "<leader>gs", gs.stage_hunk, { desc = "Stage hunk" })
      vim.keymap.set("n", "<leader>gr", gs.reset_hunk, { desc = "Reset hunk" })
      vim.keymap.set("n", "<leader>gp", gs.preview_hunk, { desc = "Preview hunk" })
      vim.keymap.set("n", "<leader>gb", gs.toggle_current_line_blame, { desc = "Toggle line blame" })
    end,
  },
}

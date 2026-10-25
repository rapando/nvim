-- Buffer navigation
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Prev buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Close buffer" })

-- K: peek folded lines first, fall back to LSP hover
vim.keymap.set("n", "K", function()
  local ok, ufo = pcall(require, "ufo")
  if ok and ufo.peekFoldedLinesUnderCursor() then
    return
  end
  vim.lsp.buf.hover()
end, { desc = "Hover / peek fold" })

-- Split navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom split" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top split" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })

vim.keymap.set("n", "<leader>wh", "<cmd>split<CR>", { desc = "Split horizontally" })
vim.keymap.set("n", "<leader>wv", "<cmd>vsplit<CR>", { desc = "Split vertically" })
vim.keymap.set("n", "<leader>wc", "<C-w>c", { desc = "Close split" })

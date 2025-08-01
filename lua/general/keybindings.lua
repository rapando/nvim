-- All keybindings are here.

-- force redraw with leader+r
vim.api.nvim_set_keymap('n', '<leader>r', ':redraw!<CR>', { noremap = true, silent = true })

-- manual formatting
vim.keymap.set('n', 'gq', 'gq', { noremap = true, silent = true })

-- TABS Settings
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Tabs
map("n", "<leader>tt", ":tabnew<CR>", opts)
map("n", "<leader>tn", ":tabnext<CR>", opts)
map("n", "<leader>tp", ":tabprevious<CR>", opts)
map("n", "<leader>tx", ":tabclose<CR>", opts)

-- Tab finder using Telescope
map("n", "tf", function()
    require("telescope.builtin").tabs()
end, { desc = "Find Tab" })

map("n", "<leader>tr", function()
    local name = vim.fn.input("Rename tab: ")
    if name ~= "" then
        vim.t.tab_name = name
    end
end, { desc = "Rename Tab" })

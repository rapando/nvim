vim.api.nvim_set_keymap('n', '<leader>gg', ':LazyGit<CR>', { noremap = true, silent = true })
local neogit = require("neogit")
neogit.setup{}

vim.keymap.set('n', '<leader>gc', function()
    require("neogit").open({ kind = "floating" })
end, { desc = "Open Neogit in floating mode" })

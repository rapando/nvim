-- Tree
-- disable the default tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- nvim-tree settings
require("nvim-tree").setup({
    view = {
        width = 25,
        side = "left",
    },
    filters = {
        dotfiles = false, -- show all dotfiles by default
    },
    git = {
		enable = false,
        ignore = false, -- Show gitignored files
    },
    renderer = {
        -- root_folder_label = false,
        icons = {
            show = {
                file = true,
                folder = true,
                folder_arrow = true,
            },
        },
    },
})

-- Patch for "No such group: --Detected--" bug in nvim tree
local explorer_ok, explorer = pcall(require, "nvim-tree.explorer")
if explorer_ok then
    local original_destroy = explorer.destroy
    explorer.destroy = function(self, ...)
        local ok, _ = pcall(function()
            if self._augroup then
                vim.api.nvim_del_augroup_by_id(self._augroup)
            end
        end)
        return original_destroy(self, ...)
    end
end

-- <leader-n> opens/closes nvim-tree
vim.api.nvim_set_keymap("n", "<leader>n", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

-- Mapping to open file in a vertical split to the right
vim.api.nvim_set_keymap('n', '<leader>v', ':vsplit <A-R>=expand("%:p:h")<CR>/<A-R>=expand("%:t")<CR><CR>',
    { noremap = true, silent = true })


-- Mapping to open file in a vertical split to the left
vim.api.nvim_set_keymap('n', '<leader>V', ':leftabove vsplit<CR>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<leader>o', "<cmd>lua require('telescope.builtin').find_files()<CR>", { noremap = true, silent = true })


-- BUFFER MANAGEMENT
--[[require("bufferline").setup({
    options = {
        show_buffer_close_icons = true,
        show_buffer_icons = true,
        separator_style = "thin",
        always_show_bufferline = true,
        max_name_length = 18,
        right_mouse_command = "bdelete! %d", -- Right-click to close buffer 
    }
})

-- Move to next buffer 
vim.api.nvim_set_keymap('n', '>', ':bnext<CR>', { noremap = true, silent = true })

-- Move to previous buffer
vim.api.nvim_set_keymap('n', '<', ':bprev<CR>', { noremap = true, silent = true })
]]

-- Livegrep feature for searching for files.
vim.api.nvim_set_keymap('n', '<leader>f', ':Telescope live_grep<CR>', { noremap = true, silent = true })

-- search with spectre
vim.keymap.set("n", "<leader>S", '<cmd>lua require("spectre").toggle()<CR>', {
	desc = "Toggle Spectre"
})

vim.keymap.set("n", "<leader>sw", '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
	desc = "Search current word"
})

vim.keymap.set("v", "<leader>sw", '<esc><cmd>lua require("spectre").open_visual()<CR>', {
	desc = "Search current word"
})

vim.keymap.set("n", "<leader>sp", '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
	desc = "Search on current file"
})

-- ignore these directories in live grep search 
require("telescope").setup{
	defaults = {
		file_ignore_patterns = {
			"node_modules",
			".git",
			"build",
			"tmp",
			"target",
			"__pycache__",
			"dist",
		}
	}
}

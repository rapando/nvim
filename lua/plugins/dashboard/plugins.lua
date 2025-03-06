return {
    {
        "goolord/alpha-nvim",
        dependencies = { 
            "nvim-tree/nvim-web-devicons",
            "ahmedkhalf/project.nvim",
            "nvim-telescope/telescope.nvim",
        },
        config = function()
            require("project_nvim").setup({
                manual_mode = false, -- auto detect projects,
                detection_methods = { "pattern" },
                patterns = { ".git", "Makefile", "package.json", "Cargo.toml", "go.mod" },
                on_project_selected = function(project)
                    vim.cmd("cd " ..project.path)
                    require("nvim-tree.api").tree.open()
                end,
            })

            require("telescope").load_extension("projects")

            local alpha = require("alpha")
            local dashboard = require("alpha.themes.dashboard")

            dashboard.section.header.val = {
                "##    ## ##    ## ######## ########  ########  ",
                "##   ##  ###   ## ##       ##     ## ##     ## ",
                "##  ##   ####  ## ##       ##     ## ##     ## ",
                "#####    ## ## ## ######   ########  ##     ## ",
                "##  ##   ##  #### ##       ##   ##   ##     ## ",
                "##   ##  ##   ### ##       ##    ##  ##     ## ",
                "##    ## ##    ## ######## ##     ## ########  ",
            }

            dashboard.section.buttons.val = {
                dashboard.button("p", "📂 Recent Projects", ":Telescope projects <CR>"),
                dashboard.button("f", "🔍 Find File", ":Telescope find_files <CR>"),
                dashboard.button("n", "📝 New File", ":ene <BAR> startinsert <CR>"),
                dashboard.button("q", "❌ Quit", ":qa<CR>"),
            }

            alpha.setup(dashboard.opts)

        end
    }
}

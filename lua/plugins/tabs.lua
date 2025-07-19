return {
    {
        "nanozuki/tabby.nvim",
        config = function()
            local theme = {
                fill = 'TabLineFill',
                head = 'TabLine',
                current_tab = 'TabLineSel',
                tab = 'TabLine',
                win = 'TabLine',
                tail = 'TabLine',
            }

            require("tabby.tabline").set(function(line)
                return {
                    {
                        { '  ', hl = theme.head },
                        line.sep('', theme.head, theme.fill),
                    },
                    line.tabs().foreach(function(tab)
                        local name = vim.t[tab.tabnr].tab_name or tab.name()
                        return {
                            line.sep('', theme.fill, tab.is_current() and theme.current_tab or theme.tab),
                            name,
                            line.sep('', tab.is_current() and theme.current_tab or theme.tab, theme.fill),
                            hl = tab.is_current() and theme.current_tab or theme.tab,
                            margin = ' ',
                        }
                    end),
                    hl = theme.fill,
                }
            end)
        end
    }
}

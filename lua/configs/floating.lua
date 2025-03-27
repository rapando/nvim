-- Floating.
require("noice").setup({
    cmdline = {
        enabled = true,
        view = "cmdline_popup", -- Floating view for the command-line
    },
    popupmenu = {
        enabled = true,
        backend = "nui",
    },
    messages = {
        enabled = true,
        view = "mini", -- Optional: floating mini messages
    },
    lsp = {
        progress = { enabled = true },
        hover = { enabled = true },
        signature = { enabled = true },
    },
    notify = {
        enabled = true,
        view = "notify",
    },
    presets = {
        bottom_search = true,   -- Bottom search
        command_palette = true, -- Command palette view
    },
})

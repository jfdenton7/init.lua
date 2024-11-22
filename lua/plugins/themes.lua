return {
    -- vim.cmd("highlight CustomCmpPicker guibg=#b4ebbc guifg=#212031 gui=bold")
    {
        "marko-cerovac/material.nvim",
        lazy = false,
        priority = 1000,
        enabled = true,
        config = function()
            vim.g.material_style = "deep ocean"
            local colors = require("material.colors")

            require("material").setup({
                custom_highlights = {
                    Pmenu = { bg = colors.editor.bg },
                },
                plugins = {
                    "trouble",
                    "telescope",
                    "nvim-cmp",
                    "mini",
                    "flash",
                    "dap",
                    "neogit",
                },
            })

            vim.cmd.colorscheme("material")
        end,
    },
    {
        "tjdevries/colorbuddy.nvim",
        enabled = true,
        priority = 1000,
        config = function()
            -- vim.cmd.colorscheme("gruvbuddy")
            -- require("themes.ziggy")
            -- require("themes.synthwave")
        end,
    },
}

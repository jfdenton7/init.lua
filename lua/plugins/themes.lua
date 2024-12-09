return {
    -- vim.cmd("highlight CustomCmpPicker guibg=#b4ebbc guifg=#212031 gui=bold")
    {
        "rktjmp/lush.nvim",
        -- if you wish to use your own colorscheme:
    },
    {
        dir = os.getenv("HOME") .. "/.config/nvim/lua/themes/focus",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd("colorscheme focus")
        end,
    },
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
                    -- Folded = { bg = colors.editor.bg, fg = colors.editor.bg },
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

            -- vim.cmd.colorscheme("material")
        end,
    },
}

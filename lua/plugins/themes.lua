return {
    -- vim.cmd("highlight CustomCmpPicker guibg=#b4ebbc guifg=#212031 gui=bold")
    {
        "catppuccin/nvim",
        name = "catppuccin",
        enabled = true,
        priority = 1000,
        lazy = false,
        config = function()
            require("catppuccin").setup({
                custom_highlights = function(colors)
                    return {
                        MiniTablineTabpagesection = { fg = colors.green, style = { "bold" } },
                        HighlightYank = { bg = colors.mauve },
                        AIActionsHeader = { fg = colors.lavender, style = { "bold" } }, -- mauve
                        AIActionsAction = { fg = colors.lavender },
                        AIActionsInActiveContext = { link = "Comment" },
                        AIActionsActiveContext = { fg = colors.peach, style = { "bold" } },
                        Folded = { fg = colors.peach, bg = "" },
                    }
                end,
            })
            vim.cmd.colorscheme("catppuccin")
        end,
    },
    {
        "rktjmp/lush.nvim",
        -- if you wish to use your own colorscheme:
    },
    {
        dir = os.getenv("HOME") .. "/.config/nvim/lua/themes/focus",
        enabled = false,
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
        enabled = false,
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

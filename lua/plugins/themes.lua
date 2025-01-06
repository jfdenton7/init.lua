return {
    -- vim.cmd("highlight CustomCmpPicker guibg=#b4ebbc guifg=#212031 gui=bold")
    {
        "rose-pine/neovim",
        name = "rose-pine",
        enabled = true,
        priority = 1000,
        config = function()
            require("rose-pine").setup({
                variant = "main", -- auto, main, moon, or dawn
                dark_variant = "main", -- main, moon, or dawn

                highlight_groups = {
                    StatusLine = { fg = "love", bg = "love", blend = 10 },
                    StatusLineNC = { fg = "subtle", bg = "surface" },
                    -- Comment = { fg = "foam" },
                    -- VertSplit = { fg = "muted", bg = "muted" },
                    -- MiniTablineTabpagesection = { fg = colors.green, style = { "bold" } },
                    HighlightYank = { bg = "rose" },
                    AIActionsHeader = { fg = "pine", bold = true }, -- mauve
                    AIActionsAction = { fg = "pine" },
                    AIActionsInActiveContext = { link = "Comment" },
                    AIActionsActiveContext = { fg = "love", bold = true },
                    Folded = { fg = "rose", bg = "" },
                },
            })

            vim.cmd("colorscheme rose-pine")
            -- vim.cmd("colorscheme rose-pine-main")
            -- vim.cmd("colorscheme rose-pine-moon")
            -- vim.cmd("colorscheme rose-pine-dawn")
            vim.cmd("colorscheme rose-pine")
        end,
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        enabled = false,
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

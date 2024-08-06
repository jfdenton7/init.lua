return {
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            -- vim.cmd.colorscheme("tokyonight-night")
        end,
    },
    {
        "EdenEast/nightfox.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            -- Default options
            require("nightfox").setup({
                palettes = {
                    duskfox = {
                        bg3 = "#191724", -- from rose-pine iterm theme
                    },
                    terafox = {
                        sel0 = "#3e4a5b", -- Popup bg, visual selection bg
                        sel1 = "#4f6074", -- Popup sel bg, search bg
                    },
                },
                options = {
                    -- Compiled file's destination location
                    transparent = false, -- Disable setting background
                    dim_inactive = false, -- Non focused panes set to alternative background
                    styles = { -- Style to be applied to different syntax groups
                        comments = "italic", -- Value is any valid attr-list value `:help attr-list`
                        conditionals = "NONE",
                        constants = "NONE",
                        functions = "NONE",
                        keywords = "italic",
                        numbers = "italic",
                        operators = "italic",
                        strings = "italic",
                        types = "NONE",
                        variables = "NONE",
                    },
                },
            })

            vim.cmd.colorscheme("terafox")
            -- vim.cmd.colorscheme("duskfox")
        end,
    }, -- lazy
    {
        "rose-pine/neovim",
        priority = 1000,
        name = "rose-pine",
        config = function()
            -- vim.cmd.colorscheme("rose-pine-main")
        end,
    },
}

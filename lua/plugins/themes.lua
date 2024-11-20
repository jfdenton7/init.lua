return {
    -- vim.cmd("highlight CustomCmpPicker guibg=#b4ebbc guifg=#212031 gui=bold")
    {
        "rose-pine/neovim",
        name = "rose-pine",
        enabled = false,
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("rose-pine-main")
        end,
    },
    {
        "marko-cerovac/material.nvim",
        lazy = false,
        priority = 1000,
        enabled = true,
        config = function()
            require("material").setup({
                plugins = {
                    "neogit",
                },
            })

            vim.g.material_style = "deep ocean"
            vim.cmd.colorscheme("material")
        end,
    },
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        enabled = false,
        config = function()
            require("tokyonight").setup({
                style = "night",
                plugins = {
                    mini_cursorword = false,
                },
                on_colors = function(colors)
                    colors.bg = "#0b0b12"
                    colors.bg_sidebar = "#0b0b12"
                    colors.bg_highlight = "#181a26"
                end,
                on_highlights = function(hl, c)
                    hl.MiniCursorWord = {
                        fg = nil,
                        bg = nil,
                        underline = true,
                    }
                    hl.MiniCursorWordCurrent = {
                        fg = nil,
                        bg = nil,
                        underline = true,
                    }
                    hl.WinBar = {
                        bg = c.bg,
                    }
                    hl.PmenuSel = {
                        bg = "#aaf3b5",
                        fg = "#212031",
                    }
                    hl.TroubleNormal = {
                        bg = c.bg,
                    }
                    hl.TroubleNormalNC = {
                        bg = c.bg,
                    }
                end,
            })
            vim.cmd.colorscheme("tokyonight")
        end,
    },
    {
        "tjdevries/colorbuddy.nvim",
        enabled = false,
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("gruvbuddy")
            -- require("themes.ziggy")
            -- require("themes.synthwave")
        end,
    },
}

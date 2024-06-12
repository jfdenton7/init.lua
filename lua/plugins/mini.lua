return {
    {
        'echasnovski/mini.nvim',
        version = false,
        config = function()
            require("mini.indentscope").setup({
                symbol = "│",
                options = { try_as_border = true },
            })
            -- disable indentscope for specific files...
            vim.api.nvim_create_autocmd("FileType", {
                pattern = {
                    "help",
                    "alpha",
                    "dashboard",
                    "neo-tree",
                    "Trouble",
                    "lazy",
                    "mason",
                    "notify",
                    "toggleterm",
                    "lazyterm",
                },
                callback = function()
                    vim.b.miniindentscope_disable = true
                end,
            })

            require("mini.files").setup()
            require("mini.ai").setup()
            require("mini.pairs").setup()
            require('mini.bracketed').setup({
                buffer     = { suffix = 'b', options = {} },
                comment    = { suffix = '', options = {} },
                conflict   = { suffix = 'x', options = {} },
                diagnostic = { suffix = 'd', options = {} },
                file       = { suffix = 'f', options = {} },
                indent     = { suffix = 'i', options = {} },
                jump       = { suffix = 'j', options = {} },
                location   = { suffix = 'l', options = {} },
                oldfile    = { suffix = 'o', options = {} },
                quickfix   = { suffix = 'q', options = {} },
                treesitter = { suffix = 't', options = {} },
                undo       = { suffix = '', options = {} },
                window     = { suffix = 'w', options = {} },
                yank       = { suffix = 'y', options = {} },
            })

            local hipatterns = require('mini.hipatterns')
            hipatterns.setup({
                highlighters = {
                    -- this is just folke's todo plugin but with no search
                    -- -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
                    -- fixme     = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
                    -- hack      = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsHack' },
                    -- todo      = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
                    -- note      = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },

                    -- Highlight hex color strings (`#rrggbb`) using that color
                    hex_color = hipatterns.gen_highlighter.hex_color(),
                },
            })

            vim.keymap.set("n", "<leader>N", function()
                require("mini.files").open(vim.api.nvim_buf_get_name(0))
            end, { desc = "MiniFiles: open relative" })
        end
    }
}

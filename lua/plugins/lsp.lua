return {
    -- {
    --     "nvim-java/nvim-java",
    --     config = function()
    --         require("java").setup()
    --     end,
    -- },
    -- LSP Configuration & Plugins
    {
        "stevearc/aerial.nvim",
        opts = {},
        -- Optional dependencies
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("aerial").setup({
                -- optionally use on_attach to set keymaps when aerial has attached to a buffer
                on_attach = function(bufnr)
                    -- Jump forwards/backwards with '{' and '}'
                    vim.keymap.set("n", "[s", "<cmd>AerialPrev<CR>", { buffer = bufnr })
                    vim.keymap.set("n", "]s", "<cmd>AerialNext<CR>", { buffer = bufnr })
                end,
                layout = {
                    -- max_width = {40, 0.2} means "the lesser of 40 columns or 20% of total"
                    min_width = { 0.2 },
                },
            })
            -- You probably also want to set a keymap to toggle aerial
            vim.keymap.set("n", "<leader>fo", "<cmd>AerialToggle!<CR>")
        end,
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            -- "nvim-java",
            -- ensure nvim-cmp plugins are loaded before setting up the config
            "nvim-cmp",
            -- Automatically install LSPs to stdpath for neovim
            { "williamboman/mason.nvim", config = true },
            "williamboman/mason-lspconfig.nvim",

            -- Useful status updates for LSP
            -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
            { "j-hui/fidget.nvim", tag = "legacy", opts = {} },

            -- Additional lua configuration, makes nvim stuff amazing!
            -- 'folke/neodev.nvim',
            -- { "Bilal2453/luvit-meta",    lazy = true }, -- optional `vim.uv` typings
            {
                "folke/lazydev.nvim",
                ft = "lua", -- only load on lua files
                opts = {
                    library = {
                        -- See the configuration section for more details
                        -- Load luvit types when the `vim.uv` word is found
                        { path = "luvit-meta/library", words = { "vim%.uv" } },
                    },
                },
            },
        },
        config = function()
            require("core.lsp").setup()
        end,
    },
    -- Autocompletion
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            -- Snippet Engine & its associated nvim-cmp source
            -- 'L3MON4D3/LuaSnip',
            {
                "L3MON4D3/LuaSnip",
                -- follow latest release.
                version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
                -- install jsregexp (optional!).
                build = "make install_jsregexp",
            },
            "saadparwaiz1/cmp_luasnip",

            -- Adds LSP completion capabilities
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-buffer",

            -- Adds a number of user-friendly snippets
            "rafamadriz/friendly-snippets",

            -- symbols in completion menu
            "onsails/lspkind.nvim",
        },
    },
}

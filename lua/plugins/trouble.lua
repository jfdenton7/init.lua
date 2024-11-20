return {
    {
        "folke/trouble.nvim",
        event = "VeryLazy",
        config = function()
            require("trouble").setup({
                preview = {
                    scratch = false,
                },
                keys = {
                    -- ["<cr>"] = "jump_close",
                    ["<esc>"] = "close",
                },
                modes = {
                    lsp_definitions = {
                        focus = true,
                        win = {
                            type = "float",
                            relative = "editor",
                            border = "rounded",
                            position = { 0, 1 },
                            size = { width = 0.5, height = 0.4 },
                            zindex = 200,
                        },
                    },
                    lsp_implementations = {
                        focus = true,
                        win = {
                            type = "float",
                            relative = "editor",
                            border = "rounded",
                            position = { 0, 1 },
                            size = { width = 0.5, height = 0.4 },
                            zindex = 200,
                        },
                    },
                    lsp_references = {
                        focus = true,
                        win = {
                            type = "float",
                            relative = "editor",
                            border = "rounded",
                            position = { 0, 1 },
                            size = { width = 0.5, height = 0.4 },
                            zindex = 200,
                            -- type = "split",
                            -- size = 0.3,
                            -- position = "bottom",
                        },
                    },
                    lsp_outgoing_calls = {
                        focus = true,
                        win = {
                            type = "float",
                            relative = "editor",
                            border = "rounded",
                            position = { 0, 1 },
                            size = { width = 0.5, height = 0.4 },
                            zindex = 200,
                        },
                    },
                    lsp_incoming_calls = {
                        focus = true,
                        win = {
                            type = "float",
                            relative = "editor",
                            border = "rounded",
                            position = { 0, 1 },
                            size = { width = 0.5, height = 0.4 },
                            zindex = 200,
                        },
                    },
                    diagnostics = {},
                    symbols = {
                        focus = true,
                        win = {
                            -- type = "float",
                            -- relative = "editor",
                            -- border = "rounded",
                            -- position = { 0, 1 },
                            -- size = { width = 0.5, height = 0.4 },
                            -- zindex = 200,

                            type = "split",
                            size = 0.2,
                            relative = "editor",
                            -- border = "rounded",
                            -- position = { 0.5, 0.5 },
                            position = "left",
                            -- size = { width = 0.25, height = 1 },
                            -- zindex = 200,
                        },
                    },
                    todo = {
                        focus = true,
                        win = {
                            type = "float",
                            relative = "editor",
                            border = "rounded",
                            position = { 0, 1 },
                            size = { width = 0.5, height = 0.4 },
                            zindex = 200,
                        },
                    },
                    quickfix = {
                        focus = true,
                        win = {
                            type = "float",
                            relative = "editor",
                            border = "rounded",
                            position = { 0, 1 },
                            size = { width = 0.5, height = 0.4 },
                            zindex = 200,
                        },
                    },
                },
            })
            local trouble = require("trouble")

            vim.keymap.set("n", "<leader>ft", function()
                trouble.open("todo")
            end, { desc = "trouble: open todo comments" })

            vim.keymap.set("n", "<leader>fq", function()
                trouble.open("quickfix")
            end, { desc = "trouble: show quickfix" })

            -- vim.keymap.set("n", "gd", function()
            --     trouble.open("lsp_definitions")
            -- end, { desc = "trouble: show lsp_definitions" })

            -- vim.keymap.set("n", "go", function()
            --     trouble.open("lsp_outgoing_calls")
            -- end, { desc = "trouble: show lsp_outgoing_calls" })
            --
            -- vim.keymap.set("n", "gi", function()
            --     trouble.open("lsp_incoming_calls")
            -- end, { desc = "trouble: show lsp_incoming_calls" })
            --
            -- vim.keymap.set("n", "gr", function()
            --     trouble.open("lsp_references")
            -- end, { desc = "trouble: show lsp_references" })
            --
            -- vim.keymap.set("n", "gI", function()
            --     trouble.open("lsp_implementations")
            -- end, { desc = "trouble: show lsp_implementations" })
            --
            vim.keymap.set("n", "<leader>fo", function()
                trouble.open("symbols")
            end, { desc = "trouble: show symbols" })

            vim.keymap.set("n", "<leader>fE", function()
                trouble.open("diagnostics")
            end, { desc = "trouble: show diagnostics" })

            -- vim.keymap.set("n", "]]", function()
            --     trouble.next("diagnostics")
            --     trouble.jump("diagnostics")
            -- end)
        end,
    },
}

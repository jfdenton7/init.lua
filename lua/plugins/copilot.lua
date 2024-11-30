return {
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        branch = "canary",
        dependencies = {
            -- { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
            { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
            {
                "github/copilot.vim",
                event = "InsertEnter",
                opts = {},
                config = function()
                    vim.g.copilot_on = false
                    vim.cmd("Copilot disable")

                    local toggle_copilot = function()
                        if vim.g.copilot_on then
                            vim.g.copilot_on = false
                            vim.cmd("Copilot disable")
                        else
                            vim.g.copilot_on = true
                            vim.cmd("Copilot enable")
                        end
                    end

                    vim.keymap.set("n", "<leader>ct", toggle_copilot, { desc = "Copilot: toggle" })

                    -- vim.keymap.set("n", "<leader>cp", "<cmd>Copilot panel<cr>", { desc = "Copilot: open panel" })
                    vim.keymap.set("i", "<C-J>", 'copilot#Accept("\\<CR>")', {
                        expr = true,
                        replace_keycodes = false,
                        desc = "Copilot: accept suggestion",
                    })
                    vim.keymap.set("i", "<C-e>", "<Plug>(copilot-dismiss)", { desc = "Copilot dismiss suggestion" })
                end,
            },
        },
        opts = {
            debug = false, -- Enable debugging
            -- See Configuration section for rest
            show_help = true,
            window = {
                layout = "float",
            },
            mappings = {
                accept_diff = {
                    normal = "<C-CR>",
                    insert = "<C-CR>",
                },
                reset = {
                    normal = "<C-r>",
                    insert = "<C-r>",
                },
            },
        },
        config = function(_, opts)
            local chat = require("CopilotChat")
            chat.setup(opts)

            vim.keymap.set("n", "<leader>com", function()
                chat.open({
                    window = { layout = "float" },
                    auto_follow_cursor = true,
                })
            end, { desc = "copilot open menu" })

            vim.keymap.set({ "x" }, "<leader>coo", function()
                vim.cmd("CopilotChatOptimize")
            end, { desc = "copilot optimize" })

            vim.keymap.set({ "x" }, "<leader>coe", function()
                vim.cmd("CopilotChatExplain")
            end, { desc = "copilot explain" })

            vim.keymap.set({ "x" }, "<leader>cor", function()
                vim.cmd("CopilotChatReview")
            end, { desc = "copilot review" })

            vim.keymap.set({ "x" }, "<leader>cod", function()
                vim.cmd("CopilotChatDocs")
            end, { desc = "copilot docs" })

            vim.keymap.set({ "x" }, "<leader>cof", function()
                vim.cmd("CopilotChatFix")
            end, { desc = "copilot fix" })

            vim.keymap.set({ "x" }, "<leader>cot", function()
                vim.cmd("CopilotChatTests")
            end, { desc = "copilot tests" })
        end,
        -- See Commands section for default commands if you want to lazy load on them
    },
}

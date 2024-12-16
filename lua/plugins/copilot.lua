return {
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        branch = "main",
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
                width = 0.8,
                height = 0.5,
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
            local mini_notify = require("mini.notify")
            chat.setup(opts)

            vim.keymap.set({ "n", "v" }, "<leader>com", function()
                chat.open({
                    window = { layout = "float" },
                    auto_follow_cursor = true,
                })
            end, { desc = "copilot open menu" })

            local answer = nil
            vim.keymap.set({ "n", "v" }, "<leader>coq", function()
                -- grab selection if mode is in visual
                -- otherwise
                -- default to vim.ui.input
                vim.ui.input({ prompt = " " }, function(input)
                    if input == nil or #input == 0 then
                        return
                    end

                    local pre_prompt =
                        "You must always respond in code. If you want to include an explanation, you MUST use comments. "
                    local id = mini_notify.add("  Thinking...", "INFO", "Special")
                    chat.ask(pre_prompt .. input, {
                        headless = true,
                        callback = function(response, _)
                            answer = response
                            mini_notify.remove(id)
                            id = mini_notify.add("  Response Ready", "INFO", "Special")
                            vim.defer_fn(function()
                                mini_notify.remove(id)
                            end, 1500)
                        end,
                    })
                    -- remove notification after 5 seconds
                    vim.defer_fn(function()
                        mini_notify.remove(id)
                    end, 5000)
                end)
            end)

            vim.keymap.set("n", "<leader>cop", function()
                vim.print(answer)
                --- get the file type
                if answer == nil then
                    local id = mini_notify.add("  no question asked", "ERROR", "DiagnosticError")
                    vim.defer_fn(function()
                        mini_notify.remove(id)
                    end, 1500)
                    return
                end
                local header = vim.split(answer, "\n")[1]
                local file_type = string.sub(header, 4)
                if file_type ~= nil and string.find(file_type, "`") == nil then
                    local lines = vim.split(answer, "\n")
                    local content = ""
                    local line_sep = ""
                    for i, line in ipairs(lines) do
                        if i ~= 1 and i ~= #lines then
                            content = content .. line_sep .. line
                            line_sep = "\n"
                        end
                    end

                    require("core.ui.preview").open_preview(content, { bo = { filetype = file_type } })
                else
                    local id = mini_notify.add("  could not parse file type", "ERROR", "DiagnosticError")
                    vim.defer_fn(function()
                        mini_notify.remove(id)
                    end, 1500)
                end
            end)

            -- vim.keymap.set({ "x" }, "<leader>coo", function()
            --     vim.cmd("CopilotChatOptimize")
            -- end, { desc = "copilot optimize" })
            --
            -- vim.keymap.set({ "x" }, "<leader>coe", function()
            --     vim.cmd("CopilotChatExplain")
            -- end, { desc = "copilot explain" })
            --
            -- vim.keymap.set({ "x" }, "<leader>cor", function()
            --     vim.cmd("CopilotChatReview")
            -- end, { desc = "copilot review" })
            --
            -- vim.keymap.set({ "x" }, "<leader>cod", function()
            --     vim.cmd("CopilotChatDocs")
            -- end, { desc = "copilot docs" })
            --
            -- vim.keymap.set({ "x" }, "<leader>cof", function()
            --     vim.cmd("CopilotChatFix")
            -- end, { desc = "copilot fix" })
            --
            -- vim.keymap.set({ "x" }, "<leader>cot", function()
            --     vim.cmd("CopilotChatTests")
            -- end, { desc = "copilot tests" })
        end,
        -- See Commands section for default commands if you want to lazy load on them
    },
}

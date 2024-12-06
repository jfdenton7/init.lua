return {
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        event = "BufEnter",
        config = function()
            require("toggleterm").setup({
                open_mapping = "<C-S-t>",
                size = 10,
            })

            local Terminal = require("toggleterm.terminal").Terminal
            local trim_spaces = true

            local repl = Terminal:new({
                cmd = "python3",
                dir = "git_dir",
                direction = "vertical",
                -- on_open = function(_)
                --     local keys = vim.api.nvim_replace_termcodes("<c-/><c-n><c-w>H", true, false, true)
                --     vim.api.nvim_feedkeys(keys, "n", false)
                -- end
            })
            vim.keymap.set("n", "<leader>pr", function()
                repl:toggle(30)
            end, { desc = "open python repl" })

            local task = Terminal:new({
                cmd = "task",
                dir = "git_dir",
                direction = "vertical",
                -- float_opts = {
                --     border = "curved",
                --     width = 100,
                --     height = 22,
                -- },
                -- function to run on opening the terminal
                on_open = function(term)
                    vim.cmd("startinsert!")
                    vim.cmd("wincmd R")
                    vim.api.nvim_win_set_width(term.window, 75)
                    vim.api.nvim_buf_set_keymap(
                        term.bufnr,
                        "n",
                        "q",
                        "<cmd>close<CR>",
                        { noremap = true, silent = true }
                    )
                end,
                -- function to run on closing the terminal
                on_close = function(term)
                    vim.cmd("startinsert!")
                end,
            })

            vim.keymap.set("n", "<leader>tl", function()
                task:toggle(15)
            end, { desc = "Term: open task cli" })

            local marks = Terminal:new({
                cmd = "mark",
                dir = "git_dir",
                direction = "float",
                float_opts = {
                    border = "curved",
                    width = 70,
                    height = 24,
                },
                -- function to run on opening the terminal
                on_open = function(term)
                    vim.cmd("startinsert!")
                    -- vim.api.nvim_buf_set_keymap(
                    --     term.bufnr,
                    --     "n",
                    --     "q",
                    --     "<cmd>close<CR>",
                    --     { noremap = true, silent = true }
                    -- )
                end,
                -- function to run on closing the terminal
                on_close = function(term)
                    vim.cmd("startinsert!")
                end,
            })

            vim.keymap.set("n", "<leader>?", function()
                marks:toggle(15)
            end, { desc = "Term: open marks cli" })

            local lazygit = Terminal:new({
                cmd = "lazygit",
                dir = "git_dir",
                direction = "float",
                float_opts = {
                    border = "none",
                },
                -- function to run on opening the terminal
                on_open = function(term)
                    vim.cmd("startinsert!")
                    vim.keymap.set("n", "q", function()
                        vim.cmd("close")
                    end, { buffer = term.bufnr, desc = "toggle term closed" })
                end,
                -- function to run on closing the terminal
                on_close = function(term)
                    vim.cmd("startinsert!")
                end,
            })

            local lazygit_toggle = function()
                lazygit:toggle()
            end

            local lazyhistory_toggle = function()
                local history = Terminal:new({
                    cmd = string.format("lazygit log --filter %s", vim.fn.expand("%:.")),
                    dir = "git_dir",
                    direction = "float",
                    float_opts = {
                        border = "none",
                    },
                    -- function to run on opening the terminal
                    on_open = function(term)
                        vim.cmd("startinsert!")
                        vim.keymap.set("i", "q", function()
                            vim.cmd("close")
                        end, { buffer = term.bufnr })
                    end,
                    -- function to run on closing the terminal
                    on_close = function(term)
                        vim.cmd("startinsert!")
                    end,
                })

                history:toggle()
            end

            local yazi_toggle = function()
                local yazi = Terminal:new({
                    cmd = string.format("yazi %s", vim.fn.expand("%:h")),
                    -- dir = "git_dir",
                    direction = "float",
                    float_opts = {
                        border = "single",
                    },
                    -- function to run on opening the terminal
                    on_open = function(term)
                        vim.cmd("startinsert!")
                        vim.keymap.set("n", "q", function()
                            vim.cmd("close")
                        end, { buffer = term.bufnr, desc = "toggle term closed" })
                    end,
                    -- function to run on closing the terminal
                    on_close = function(term)
                        vim.cmd("startinsert!")
                    end,
                })

                yazi:toggle()
            end

            local empty = function()
                Terminal:new({}):toggle(20, "vertical")
            end

            vim.keymap.set("n", "<leader>to", empty, { desc = "Term: open float" })
            vim.keymap.set("n", "<leader>Y", yazi_toggle, { desc = "ToggleTerm: yazi file explorer" })
            vim.keymap.set("n", "<leader>gh", lazyhistory_toggle, { desc = "ToggleTerm: lazygit history for file" })
            vim.keymap.set("n", "<leader>gg", lazygit_toggle, { desc = "ToggleTerm: lazygit toggle" })
            vim.keymap.set("v", "<leader>ts", function()
                require("toggleterm").send_lines_to_terminal("single_line", trim_spaces, { args = vim.v.count })
            end, { desc = "Term: send line to term" })
        end,
    },
}

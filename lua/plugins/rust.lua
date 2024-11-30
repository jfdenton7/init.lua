return {
    {
        "mrcjkb/rustaceanvim",
        version = "^5", -- Recommended
        lazy = false, -- This plugin is already lazy
        config = function()
            vim.g.rustaceanvim = {
                tools = {
                    float_win_config = {
                        border = "rounded",
                    },
                },
                server = {
                    -- client, bufnr
                    on_attach = function(_, bufnr)
                        local buf_opts = { buffer = bufnr, silent = true }

                        vim.diagnostic.config({
                            virtual_text = false,
                        })

                        local function toggle_inlay_hints()
                            vim.lsp.inlay_hint.enable(
                                not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }),
                                { bufnr = bufnr }
                            )
                        end

                        vim.keymap.set("n", "<leader>ei", toggle_inlay_hints)

                        vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, buf_opts)
                        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, buf_opts)
                        -- vim.keymap.set("n", "<leader>ra", vim.lsp.buf.code_action, buf_opts)

                        vim.keymap.set("n", "<leader>ra", function()
                            vim.cmd.RustLsp("codeAction")
                        end, { silent = true, desc = "Rust: code actions" })

                        vim.keymap.set("n", "<leader>r", function()
                            vim.cmd.RustLsp("run")
                        end, { silent = true, desc = "Rust: run" })

                        vim.keymap.set("n", "<leader>n", function()
                            vim.cmd.RustLsp("debug")
                        end, { silent = true, desc = "Rust: start debugger" })

                        -- vim.keymap.set("n", "<leader>e", function()
                        --     vim.cmd.RustLsp({ "renderDiagnostic", "current" })
                        -- end, { desc = "Rust: open diagnostic" })

                        vim.keymap.set("n", "<leader>!", function()
                            vim.cmd.RustLsp("explainError")
                        end, { desc = "Rust: explain error" })
                    end,
                },
            }
        end,
    },
}

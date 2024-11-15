return {
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.7",
        -- or                              , branch = '0.1.x',
        event = "VeryLazy",
        dependencies = {
            "AckslD/nvim-neoclip.lua",
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        config = function()
            require("telescope").setup({
                defaults = {
                    -- layout_strategy = "vertical",
                    layout_config = {
                        horizontal = { preview_cutoff = 80, preview_width = 0.55 },
                        vertical = { mirror = true, preview_cutoff = 25 },
                        prompt_position = "top",
                        width = 0.87,
                        height = 0.80,
                    },
                    layout_strategy = "flex",
                    prompt_prefix = ">  ",
                    sorting_strategy = "descending",
                    file_ignore_patterns = {
                        "node_modules",
                        "target",
                    },
                },
                pickers = {
                    buffers = {
                        mappings = {
                            i = {
                                ["<c-d>"] = require("telescope.actions").delete_buffer,
                            },
                        },
                    },
                },
                extensions = {
                    fzf = {
                        fuzzy = true, -- false will only do exact matching
                        override_generic_sorter = true, -- override the generic sorter
                        override_file_sorter = true, -- override the file sorter
                        case_mode = "smart_case", -- or "ignore_case" or "respect_case"
                        -- the default case_mode is "smart_case"
                    },
                },
            })
            require("neoclip").setup()

            local themes = require("telescope.themes")

            local no_preview = themes.get_dropdown({
                winblend = 0,
                layout_config = {
                    width = 120,
                },
                prompt = " ",
                results_height = 15,
                previewer = false,
            })
            -- extensions
            require("telescope").load_extension("fzf")
            require("telescope").load_extension("neoclip")
            -- require("telescope").load_extension("refactoring")

            local builtins = require("telescope.builtin")
            local _ = require("core.extensions.telescope").actions()

            vim.keymap.set("n", "<leader>ff", function()
                builtins.find_files()
            end, {})

            vim.keymap.set("n", "<leader>fg", function()
                builtins.live_grep()
            end, {})

            vim.keymap.set("n", "<leader>fb", function()
                builtins.buffers(no_preview)
            end, {})

            vim.keymap.set("n", "<leader>f'", function()
                builtins.marks()
            end, {})

            vim.keymap.set("n", "<leader>fi", function()
                builtins.current_buffer_fuzzy_find(no_preview)
            end, {})

            vim.keymap.set("n", "<localleader>ss", function()
                builtins.spell_suggest(themes.get_cursor())
            end, {})

            vim.keymap.set("n", "<leader>fe", function()
                builtins.diagnostics(themes.get_ivy())
            end)

            vim.keymap.set("n", "<leader>fh", function()
                builtins.help_tags()
            end, {})

            vim.keymap.set("n", "<leader>hk", function()
                builtins.keymaps(themes.get_ivy())
            end, { desc = "Telescope: find keys" })

            vim.keymap.set("n", "<leader>cc", function()
                builtins.colorscheme(no_preview)
            end, { desc = "telescope: find colorschemes" })

            vim.keymap.set("n", "<leader>fy", function()
                require("telescope").extensions.neoclip.default()
            end, { desc = "telescope: find yanked text" })

            vim.keymap.set("n", "<leader>fm", function()
                builtins.marks(themes.get_ivy())
            end, { desc = "telescope: find marks" })

            vim.keymap.set("n", "<leader>fs", function()
                builtins.lsp_document_symbols(themes.get_ivy())
            end)

            vim.keymap.set("n", "gI", function()
                builtins.lsp_implementations(
                    vim.tbl_extend(
                        "force",
                        themes.get_cursor({ layout_config = { width = 0.8 }, path_display = { "truncate" } }),
                        { show_line = false }
                    )
                )
            end, { desc = "telescope: go to lsp_implementations" })

            vim.keymap.set("n", "gi", function()
                builtins.lsp_incoming_calls(
                    vim.tbl_extend(
                        "force",
                        themes.get_cursor({ layout_config = { width = 0.8 }, path_display = { "truncate" } }),
                        { show_line = false }
                    )
                )
            end, { desc = "telescope: go to lsp_incoming_calls" })

            vim.keymap.set("n", "go", function()
                builtins.lsp_outgoing_calls(
                    vim.tbl_extend(
                        "force",
                        themes.get_cursor({ layout_config = { width = 0.8 }, path_display = { "truncate" } }),
                        { show_line = false }
                    )
                )
            end, { desc = "telescope: go to lsp_outgoing_calls" })

            vim.keymap.set("n", "gd", function()
                builtins.lsp_definitions(
                    vim.tbl_extend(
                        "force",
                        themes.get_cursor({ layout_config = { width = 0.8 }, path_display = { "truncate" } }),
                        { show_line = false }
                    )
                )
            end, { desc = "telescope: go to lsp_definitions" })

            vim.keymap.set("n", "gr", function()
                builtins.lsp_references(
                    vim.tbl_extend(
                        "force",
                        themes.get_cursor({ layout_config = { width = 0.8 }, path_display = { "truncate" } }),
                        { show_line = false }
                    )
                )
            end, { desc = "telescope: go to lsp_references" })
        end,
    },
}

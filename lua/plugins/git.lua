return {
    {
        "NeogitOrg/neogit",
        enabled = false,
        dependencies = {
            "nvim-lua/plenary.nvim", -- required
            "sindrets/diffview.nvim", -- optional - Diff integration

            -- Only one of these is needed.
            "nvim-telescope/telescope.nvim", -- optional
        },
        config = function()
            require("neogit").setup({})

            vim.keymap.set("n", "<leader>gg", function()
                vim.cmd("Neogit")
            end, { desc = "Neogit: open" })
        end,
    },

    {
        "sindrets/diffview.nvim",
        event = "VeryLazy",
        enabled = false,
        keys = {
            {
                "<leader>dd",
                function()
                    vim.cmd("DiffviewOpen")
                end,
                desc = "diffview: toggle",
            },
            {
                "<leader>di",
                mode = { "n" },
                function()
                    local commit_hash = vim.fn.expand("<cword>")
                    if commit_hash ~= "" then
                        vim.cmd(string.format("DiffviewOpen %s~1..%s", commit_hash, commit_hash))
                    end
                end,
                desc = "diffview inspect commit",
            },
        },
        config = function()
            vim.g._diffview_open = false

            local augroup = vim.api.nvim_create_augroup("CustomDiffviewKeymaps", { clear = true })
            vim.api.nvim_create_autocmd("FileType", {
                group = augroup,
                pattern = "DiffviewFiles",
                callback = function()
                    vim.keymap.set("n", "<leader>q", function()
                        local ft = vim.bo.filetype
                        if ft == "DiffviewFiles" then
                            vim.cmd("tabc")
                        end
                    end, { desc = "close diffview", buffer = true })
                end,
            })

            require("diffview").setup()
        end,
    },
    {
        "akinsho/git-conflict.nvim",
        version = "*",
        event = "VeryLazy",
        opts = {
            default_mappings = {
                ours = "<leader>go",
                theirs = "<leader>gt",
                none = "<leader>gn",
                both = "<leader>gb",
                prev = "[x",
                next = "]x",
            },
            disable_diagnostics = true,
        },
        config = true,
    },
    {
        "pwntester/octo.nvim",
        enabled = false,
        event = "VeryLazy",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("octo").setup()
        end,
    },
}

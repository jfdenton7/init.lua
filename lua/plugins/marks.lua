return {
    {
        "cbochs/grapple.nvim",
        dependencies = {
            { "nvim-tree/nvim-web-devicons", lazy = true },
        },
        opts = {
            scope = "git", -- also try out "git_branch"
            icons = true, -- setting to "true" requires "nvim-web-devicons"
            status = false,
            win_opts = {
                width = 120,
                height = 12,
            },
        },
        keys = {
            { "<leader>fa", "<cmd>Grapple toggle<cr>", desc = "Tag a file" },
            { "<c-f>", "<cmd>Grapple toggle_tags<cr>", desc = "Toggle tags menu" },

            { "<c-a>", "<cmd>Grapple select index=1<cr>", desc = "Select first tag" },
            { "<c-r>", "<cmd>Grapple select index=2<cr>", desc = "Select second tag" },
            { "<c-s>", "<cmd>Grapple select index=3<cr>", desc = "Select third tag" },
            { "<c-t>", "<cmd>Grapple select index=4<cr>", desc = "Select fourth tag" },

            { "<c-s-n>", "<cmd>Grapple cycle_tags next<cr>", desc = "Go to next tag" },
            { "<c-s-p>", "<cmd>Grapple cycle_tags prev<cr>", desc = "Go to previous tag" },
        },
    },
    {
        "ThePrimeagen/harpoon",
        enabled = false,
        event = "VeryLazy",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local harpoon = require("harpoon")

            -- REQUIRED
            harpoon:setup()
            -- REQUIRED

            vim.keymap.set("n", "<leader>fa", function()
                harpoon:list():add()
            end, { desc = "Harpoon: file add" })

            vim.keymap.set("n", "<c-r>", function()
                harpoon:list():select(1)
            end, { desc = "Harpoon: navigate to 1st" })

            vim.keymap.set("n", "<c-s>", function()
                harpoon:list():select(2)
            end, { desc = "Harpoon: navigate to 2nd" })

            vim.keymap.set("n", "<c-t>", function()
                harpoon:list():select(3)
            end, { desc = "Harpoon: navigate to 3rd" })

            vim.keymap.set("n", "<c-g>", function()
                harpoon:list():select(4)
            end, { desc = "Harpoon: navigate to 4th" })

            -- Toggle previous & next buffers stored within Harpoon list
            -- vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
            -- vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)

            vim.keymap.set("n", "<c-f>", function()
                harpoon.ui:toggle_quick_menu(harpoon:list())
            end, { desc = "Harpoon: toggle list" })
        end,
    },
}

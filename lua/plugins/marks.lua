return {
    {
        "ThePrimeagen/harpoon",
        enabled = true,
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

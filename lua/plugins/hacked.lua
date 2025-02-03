return {
    {
        "josiahdenton/hacked.nvim",
        -- dir = "/Users/jfdenton/work/hacked.nvim",
        config = function()
            require("hacked.diagnostics").setup()
            require("hacked.blame").setup()
            require("hacked.executor").setup()
            require("hacked.portal").setup()

            vim.keymap.set({ "n", "x" }, "<leader>ba", function()
                require("hacked.portal").save()
            end)

            vim.keymap.set("n", "<leader>bo", function()
                require("hacked.portal").open()
            end)

            vim.keymap.set("n", "<leader>bz", function()
                require("hacked.portal").clear()
            end)

            vim.keymap.set("n", "<leader>fe", function()
                require("hacked.multibuffer").diagnostics()
            end)

            vim.keymap.set("n", "gb", function()
                require("hacked.blame").line()
            end, { desc = "" })

            vim.keymap.set("v", "gb", function()
                require("hacked.blame").selection()
            end, { desc = "" })

            vim.keymap.set("v", "<leader>gb", function()
                require("hacked.blame").browse()
            end, { desc = "" })
        end,
    },
}

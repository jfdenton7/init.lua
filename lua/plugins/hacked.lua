return {
    {
        "josiahdenton/hacked.nvim",
        -- dir = "/Users/jfdenton/work/hacked.nvim",
        config = function()
            require("hacked.diagnostics").setup()
            require("hacked.blame").setup()
            require("hacked.executor").setup()

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

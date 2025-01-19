return {
    {
        -- "josiahdenton/inline-session-notes.nvim",
        dir = "/Users/jfdenton/work/inline-session-notes.nvim",
        config = function()
            local inline = require("inline-session-notes")
            inline.setup({
                border = false,
            })

            vim.keymap.set("n", "<leader>ta", function()
                inline.add()
            end)

            vim.keymap.set("n", "<leader>te", function()
                inline.edit()
            end)

            vim.keymap.set("n", "<leader>td", function()
                inline.delete()
            end)

            vim.keymap.set("n", "<leader>tq", function()
                inline.quickfix()
            end)
        end,
    },
}

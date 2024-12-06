return {
    {
        "dhruvasagar/vim-table-mode",
        enabled = true,
        ft = "md", -- only load on markdown
        config = function()
            vim.g.table_mode_corner = "|"
        end,
    },
}

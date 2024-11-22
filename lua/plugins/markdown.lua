return {
    {
        "dhruvasagar/vim-table-mode",
        ft = "md", -- only load on markdown
        config = function()
            vim.g.table_mode_corner = "|"
        end,
    },
}

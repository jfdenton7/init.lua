return {
    {
        "shortcuts/no-neck-pain.nvim",
        version = "*",
        config = function()
            require("no-neck-pain").setup({
                width = 140
                -- buffers = {
                --     scratchPad = {
                --         -- set to `false` to
                --         -- disable auto-saving
                --         enabled = true,
                --         -- set to `nil` to default
                --         -- to current working directory
                --         location = nil, --  "~/notes/",
                --     },
                --     bo = {
                --         filetype = "md",
                --     },
                --     right = {
                --         enabled = false,
                --     },
                -- },
            })

            vim.keymap.set("n", "<leader>zz", function()
                vim.cmd("NoNeckPain")
            end, { desc = "ZenMode: toggle" })
        end,
    },
    -- {
    --     "folke/zen-mode.nvim",
    --     config = function()
    --         require("zen-mode").setup({
    --             window = {
    --                 backdrop = 1, -- 0.95, -- shade the backdrop of the Zen window. Set to 1 to keep the same as Normal
    --                 -- height and width can be:
    --                 -- * an absolute number of cells when > 1
    --                 -- * a percentage of the width / height of the editor when <= 1
    --                 -- * a function that returns the width or the height
    --                 width = 100, -- width of the Zen window
    --                 height = 1, -- height of the Zen window
    --                 -- by default, no options are changed for the Zen window
    --                 -- uncomment any of the options below, or add other vim.wo options you want to apply
    --                 options = {
    --                     -- signcolumn = "no", -- disable signcolumn
    --                     number = false, -- disable number column
    --                     relativenumber = false, -- disable relative numbers
    --                     cursorline = false, -- disable cursorline
    --                     -- cursorcolumn = false, -- disable cursor column
    --                     -- foldcolumn = "0", -- disable fold column
    --                     -- list = false, -- disable whitespace characters
    --                 },
    --             },
    --             plugins = {
    --                 -- disable some global vim options (vim.o...)
    --                 -- comment the lines to not apply the options
    --                 options = {
    --                     enabled = true,
    --                     ruler = false, -- disables the ruler text in the cmd line area
    --                     showcmd = false, -- disables the command in the last line of the screen
    --                     -- you may turn on/off statusline in zen mode by setting 'laststatus'
    --                     -- statusline will be shown only if 'laststatus' == 3
    --                     laststatus = 0, -- turn off the statusline in zen mode
    --                 },
    --                 twilight = { enabled = true }, -- enable to start Twilight when zen mode opens
    --                 gitsigns = { enabled = false }, -- disables git signs
    --                 -- this will change the font size on wezterm when in zen mode
    --                 -- See alse also the Plugins/Wezterm section in this projects README
    --                 wezterm = {
    --                     enabled = false,
    --                     -- can be either an absolute font size or the number of incremental steps
    --                     font = "+4", -- (10% increase per step)
    --                 },
    --             },
    --             -- callback where you can add custom code when the Zen window opens
    --             on_open = function(win) end,
    --             -- callback where you can add custom code when the Zen window closes
    --             on_close = function() -- if zen-mode is open, try closing everything after closing zen float
    --                 -- vim.api.nvim_feedkeys("ZQ", "n", false) -- can't do this (some things break this...)
    --             end,
    --         })
    --
    --         -- zen keymaps
    --         vim.keymap.set("n", "<leader>zz", function()
    --             vim.cmd("ZenMode")
    --         end, { desc = "ZenMode: toggle" })
    --     end,
    -- },
}

local M = {}

local store = require("core.extensions.tabby.store")
local ui = require("core.extensions.tabby.ui")
local prints = require("core.extensions.tabby.prints")

local draw_loop = function()
    local timer = vim.uv.new_timer()
    timer:start(
        0,
        30000,
        vim.schedule_wrap(function()
            vim.cmd("redrawstatus")
        end)
    )
end

M.render = function()
    store.tick()
    return ui.render(store.state())
end

M.setup = function()
    prints.setup()
    vim.api.nvim_create_autocmd({ "VimEnter", "BufWinEnter" }, {
        group = vim.api.nvim_create_augroup("user/winbar", { clear = true }),
        desc = "Attach winbar",
        callback = function(args)
            if
                not vim.api.nvim_win_get_config(0).zindex -- Not a floating window
                and vim.bo[args.buf].buftype == "" -- Normal buffer
                and not vim.wo[0].diff -- Not in diff mode
            then
                -- vim.api.nvim__redraw
                vim.o.showtabline = 0
                vim.wo.winbar = "%{%v:lua.require'core.extensions.tabby'.render()%}"
            end
        end,
    })
    draw_loop()
end

return M

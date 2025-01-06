local M = {}

local store = require("core.extensions.tabby.store")

--- @return table<table<string>>
local content = function()
    local active_tabpage = vim.api.nvim_tabpage_get_number(0)
    local total_tabpages = #vim.api.nvim_list_tabpages()
    if total_tabpages == 1 then
        return {}
    end
    return {
        { "(", "Comment" },
        { string.format("%d/%d", active_tabpage, total_tabpages), "@variable.builtin" },
        { ")", "Comment" },
    } -- TODO replace with something better...
end

M.setup = function()
    store.register_tabby({
        name = "pager",
        split = true,
        default = content,
        focused = content,
    })
end

return M

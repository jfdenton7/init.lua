local M = {}

M.user_ranges = {}

local find = require("core.extensions.folds.find")

M.add_user_range = function()
    local selection = find.visual_selection()
    table.insert(M.user_ranges, selection[1])
    vim.notify("added selection", vim.log.levels.INFO, {})
end

M.remove_user_range = function()
    local cursor_pos = vim.fn.getpos(".")
    local cursor_line = cursor_pos[2]
    for i, range in ipairs(M.user_ranges) do
        if cursor_line >= range[1] and cursor_line <= range[2] then
            table.remove(M.user_ranges, i)
            vim.notify("removed selection", vim.log.levels.INFO, {})
            return
        end
    end

    vim.notify("not an active selection", vim.log.levels.WARN, {})
end

return M

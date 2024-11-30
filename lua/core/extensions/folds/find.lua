local M = {}

--- @return table<table<integer>>
M.visual_selection = function()
    local visual_pos = vim.fn.getpos("v")
    local visual_line = visual_pos[2]
    local cursor_pos = vim.fn.getpos(".")
    local cursor_line = cursor_pos[2]

    if visual_line < cursor_line then
        return { { math.max(1, visual_line - 1), cursor_line + 1 } }
    else
        return { { math.max(1, cursor_line - 1), visual_line + 1 } }
    end
end

local local_marks = {}
for i = 97, 122 do
    table.insert(local_marks, string.char(i))
end

--- finds all buffer local marks in the current buffer
--- @return table<integer>
M.find_marks = function()
    local positions = {}
    for _, mark in ipairs(local_marks) do
        local pos = vim.api.nvim_buf_get_mark(0, mark)
        if pos[1] > 0 then
            table.insert(positions, pos[1])
        end
    end

    return positions
end

--- finds all buffer local diagnostics
M.find_diagnostics = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local diagnostics = vim.diagnostic.get(bufnr)

    if #diagnostics == 0 then
        return {}
    end

    local positions = vim.tbl_map(function(diagnostic)
        return diagnostic.lnum + 1
    end, diagnostics)

    return positions
end

M.find_nearby_marks = function()
    -- line , col
    local cursor = vim.api.nvim_win_get_cursor(0)
    -- get all marks and sort by position
    local marks = {}
    for _, mark in ipairs(local_marks) do
        local pos = vim.api.nvim_buf_get_mark(0, mark)
        if pos[1] > 0 then
            table.insert(marks, {
                mark = mark,
                line = pos[1],
                pos = pos,
            })
        end
    end

    if #marks == 0 then
        return {}
    end

    table.sort(marks, function(a, b)
        return a.line < b.line
    end)

    -- find which is closest to my cursor
    local closest = 1
    local distance = math.abs(cursor[1] - marks[1].line)
    for i, mark in ipairs(marks) do
        if distance > math.abs(cursor[1] - mark.line) then
            closest = i
            distance = math.abs(cursor[1] - mark.line)
        end
    end

    return { marks, closest }
end

return M

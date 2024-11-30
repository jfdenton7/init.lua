local M = {}

local mrtables = require("core.extensions.folds.table")

--- @param words table<string>
--- @return table<integer>
M.buffer_text = function(words)
    local positions = {}
    for _, word in ipairs(words) do
        vim.cmd(string.format("vimgrep /%s/ %%", word))
        local entries = vim.fn.getqflist()
        local lines = vim.tbl_map(function(entry)
            return entry.lnum
        end, entries)
        positions = mrtables.merge(positions, lines)
    end
    return positions
end

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

return M

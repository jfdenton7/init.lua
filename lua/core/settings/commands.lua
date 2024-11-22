local M = {}

local FOLD_WINDOW = 3 -- show 3 lines above and below diagnostic

local local_marks = {}
for i = 97, 122 do
    table.insert(local_marks, string.char(i))
end

--- finds all buffer local marks in the current buffer
local find_marks = function()
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
local find_diagnostics = function()
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

--- @param positions table<integer>
--- @return table<table<integer>>
local find_folds = function(positions)
    if #positions == 0 then
        return {}
    end

    local bufnr = vim.api.nvim_get_current_buf()
    table.sort(positions, function(a, b)
        return a < b
    end)

    local prev_pos = positions[1]
    local folds = { { 1, math.max(prev_pos - FOLD_WINDOW, 1) } }
    positions = { unpack(positions, 2) }
    for _, pos in pairs(positions) do
        if (prev_pos + FOLD_WINDOW) < (pos - FOLD_WINDOW) then -- no intersection, needs new fold
            table.insert(folds, { prev_pos + FOLD_WINDOW, pos - FOLD_WINDOW })
        end
        prev_pos = pos
    end

    -- special case for last position
    local last_line = vim.api.nvim_buf_line_count(bufnr)
    if (prev_pos + FOLD_WINDOW) < last_line then
        table.insert(folds, { (prev_pos + FOLD_WINDOW), last_line })
    end

    return folds
end

local find_nearby_marks = function()
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

local focus_marks = function()
    if vim.g.custom_focus_mode ~= nil and vim.g.custom_focus_mode then
        vim.cmd("normal zE")
        vim.g.custom_focus_mode = false

        vim.keymap.del("n", "<tab>")
        vim.keymap.del("n", "<s-tab>")
        return
    end

    vim.keymap.set("n", "<tab>", function()
        local t = find_nearby_marks()
        local marks = t[1]
        local closest = t[2] -- 1, 2
        local next = marks[(closest % #marks) + 1]
        vim.api.nvim_win_set_cursor(0, next.pos)
    end, { desc = "go to next mark" })

    vim.keymap.set("n", "<s-tab>", function()
        local t = find_nearby_marks()
        local marks = t[1]
        local closest = t[2]
        local prev = marks[closest > 1 and closest - 1 or #marks]
        vim.api.nvim_win_set_cursor(0, prev.pos)
    end, { desc = "go to previous mark" })

    vim.wo.foldminlines = 0
    vim.wo.fillchars = (vim.o.fillchars ~= "" and vim.o.fillchars .. "," or "") .. "fold: "
    vim.wo.foldtext = 'v:lua.require("core.settings.commands").custom_folds_style()'
    vim.wo.foldmethod = "manual"
    vim.cmd("normal zE")

    local marks = find_marks()
    if #marks == 0 then
        vim.notify("no marks found, nowhere to focus", vim.log.levels.WARN, {})
        return
    end

    local folds = find_folds(marks)
    for _, fold in ipairs(folds) do
        vim.cmd(string.format("%d,%dfold", fold[1], fold[2]))
    end

    vim.notify("focused marks", vim.log.levels.INFO, {})
    vim.g.custom_focus_mode = true
end

-- NOTE: if any intersection occurs between diagnostics, we leave them be
local focus_diagnostics = function() -- should not be an autocmd, should be a user cmd
    if vim.g.custom_focus_mode ~= nil and vim.g.custom_focus_mode then
        vim.cmd("normal zE")
        vim.g.custom_focus_mode = false

        vim.keymap.del("n", "<tab>")
        vim.keymap.del("n", "<s-tab>")
        return
    end

    vim.keymap.set("n", "<tab>", function()
        vim.diagnostic.goto_next({ float = false })
    end, { desc = "go to next diagnostic" })

    vim.keymap.set("n", "<s-tab>", function()
        vim.diagnostic.goto_prev({ float = false })
    end, { desc = "go to previous diagnostic" })

    vim.wo.foldminlines = 0
    vim.wo.fillchars = (vim.o.fillchars ~= "" and vim.o.fillchars .. "," or "") .. "fold: "
    vim.wo.foldtext = 'v:lua.require("core.settings.commands").custom_folds_style()'
    vim.wo.foldmethod = "manual"
    vim.cmd("normal zE")

    local diagnostics = find_diagnostics()
    if #diagnostics == 0 then
        vim.notify("no diagnostics found, nowhere to focus", vim.log.levels.WARN, {})
        return
    end

    local folds = find_folds(diagnostics)
    for _, fold in ipairs(folds) do
        vim.cmd(string.format("%d,%dfold", fold[1], fold[2]))
    end

    vim.notify("focused diagnostics", vim.log.levels.INFO, {})
    vim.g.custom_focus_mode = true
end

M.custom_folds_style = function()
    return string.rep("─────────────────", 30)
end

M.setup = function()
    vim.api.nvim_create_user_command("FocusDiagnostics", focus_diagnostics, {})

    vim.keymap.set("n", "<leader>E", function()
        focus_diagnostics()
    end, { desc = "focus diagnostics" })

    vim.api.nvim_create_user_command("FocusMarks", focus_marks, {})

    vim.keymap.set("n", "<leader>M", function()
        focus_marks()
    end, { desc = "focus marks" })
end

return M

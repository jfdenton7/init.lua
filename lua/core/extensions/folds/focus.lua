local M = {}

local editor = require("core.extensions.folds.editor")
local user = require("core.extensions.folds.user")
local find = require("core.extensions.folds.find")
local generate = require("core.extensions.folds.generate")

M.user_ranges = function()
    if vim.g.custom_focus_mode ~= nil and vim.g.custom_focus_mode then
        vim.cmd("normal zE")
        vim.g.custom_focus_mode = false
        editor.set_fold_options("user")

        -- TODO
        -- vim.keymap.del("n", "<tab>")
        -- vim.keymap.del("n", "<s-tab>")
        return
    end

    if #user.user_ranges == 0 then
        vim.notify("no set user ranges for this buffer", vim.log.levels.WARN, {})
        return
    end

    editor.set_fold_options("manual")
    vim.cmd("normal zE")

    local folds = generate.folds_for_ranges(user.user_ranges)
    for _, fold in ipairs(folds) do
        vim.cmd(string.format("%d,%dfold", fold[1], fold[2]))
    end

    vim.notify("focused user ranges", vim.log.levels.INFO, {})
    vim.g.custom_focus_mode = true
end

M.marks = function()
    if vim.g.custom_focus_mode ~= nil and vim.g.custom_focus_mode then
        vim.cmd("normal zE")
        vim.g.custom_focus_mode = false
        editor.set_fold_options("user")

        vim.keymap.del("n", "<tab>")
        vim.keymap.del("n", "<s-tab>")
        return
    end

    vim.keymap.set("n", "<tab>", function()
        local t = find.find_nearby_marks()
        local marks = t[1]
        local closest = t[2] -- 1, 2
        local next = marks[(closest % #marks) + 1]
        vim.api.nvim_win_set_cursor(0, next.pos)
    end, { desc = "go to next mark" })

    vim.keymap.set("n", "<s-tab>", function()
        local t = find.find_nearby_marks()
        local marks = t[1]
        local closest = t[2]
        local prev = marks[closest > 1 and closest - 1 or #marks]
        vim.api.nvim_win_set_cursor(0, prev.pos)
    end, { desc = "go to previous mark" })

    local marks = find.find_marks()
    if #marks == 0 then
        vim.notify("no marks found, nowhere to focus", vim.log.levels.WARN, {})
        return
    end

    editor.set_fold_options("manual")
    vim.cmd("normal zE")

    local folds = generate.folds_for_positions(marks)
    for _, fold in ipairs(folds) do
        vim.cmd(string.format("%d,%dfold", fold[1], fold[2]))
    end

    vim.notify("focused marks", vim.log.levels.INFO, {})
    vim.g.custom_focus_mode = true
end

-- NOTE: if any intersection occurs between diagnostics, we leave them be
M.diagnostics = function()
    if vim.g.custom_focus_mode ~= nil and vim.g.custom_focus_mode then
        vim.cmd("normal zE")
        vim.g.custom_focus_mode = false
        editor.set_fold_options("user")

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

    local diagnostics = find.find_diagnostics()
    if #diagnostics == 0 then
        vim.notify("no diagnostics found, nowhere to focus", vim.log.levels.WARN, {})
        return
    end

    editor.set_fold_options("manual")
    vim.cmd("normal zE")

    local folds = generate.folds_for_positions(diagnostics)
    for _, fold in ipairs(folds) do
        vim.cmd(string.format("%d,%dfold", fold[1], fold[2]))
    end

    vim.notify("focused diagnostics", vim.log.levels.INFO, {})
    vim.g.custom_focus_mode = true
end

M.visual_selection = function()
    if vim.g.custom_focus_mode ~= nil and vim.g.custom_focus_mode then
        vim.cmd("normal zE")
        vim.g.custom_focus_mode = false
        editor.set_fold_options("user")
        return
    end

    local vs = find.visual_selection()
    if #vs == 0 then
        vim.notify("unable to get visual selection", vim.log.levels.WARN, {})
        return
    end

    editor.set_fold_options("manual")
    vim.cmd("normal zE")

    local folds = generate.folds_for_ranges(vs)
    for _, fold in ipairs(folds) do
        vim.cmd(string.format("%d,%dfold", fold[1], fold[2]))
    end

    vim.notify("focused visual selection", vim.log.levels.INFO, {})
    vim.g.custom_focus_mode = true
end

return M

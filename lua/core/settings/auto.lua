local M = {}

--- Used for settings highlight groups
--- @param severity vim.diagnostic.Severity
--- @return string
local severity_to_string = function(severity)
    local options = {
        [vim.diagnostic.severity.ERROR] = "Error",
        [vim.diagnostic.severity.WARN] = "Warn",
        [vim.diagnostic.severity.INFO] = "Info",
        [vim.diagnostic.severity.HINT] = "Hint",
    }
    return options[severity]
end

--- Determines priority of diagnostics when limiting virtual text to 3 items
--- @param severity vim.diagnostic.Severity
--- @return integer
local severity_to_priority = function(severity)
    local options = {
        [vim.diagnostic.severity.ERROR] = 1000,
        [vim.diagnostic.severity.WARN] = 100,
        [vim.diagnostic.severity.INFO] = 10,
        [vim.diagnostic.severity.HINT] = 1,
    }
    return options[severity]
end

local MAX_DIAGNOSTICS = 3
local MAX_DIAGNOSTIC_MSG_LENGTH = 80
local SPACES = 4

--- @return table<integer, vim.Diagnostic>
local collect_surrounding_diagnostics = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local line = vim.api.nvim_win_get_cursor(0)[1] - 1 -- lines start at 0 (top)
    local diagnostics = vim.diagnostic.get(bufnr)

    if #diagnostics == 0 then
        return {}
    end

    --- @param a vim.Diagnostic
    --- @param b vim.Diagnostic
    --- @return boolean
    local sort_by_cursor_distance_and_severity = function(a, b)
        return (math.abs(a.lnum - line) - severity_to_priority(a.severity))
            < (math.abs(b.lnum - line) - severity_to_priority(b.severity))
    end

    table.sort(diagnostics, sort_by_cursor_distance_and_severity)

    return { unpack(diagnostics, 1, MAX_DIAGNOSTICS) }
end

local signs = require("core.ui.symbols").lsp_signs()

--- @param diagnostic vim.Diagnostic
--- @param spaces integer number of spaces to prefix
--- @return table
local format_diagnostic = function(diagnostic, spaces)
    local symbols = {
        [vim.diagnostic.severity.ERROR] = signs.Error,
        [vim.diagnostic.severity.WARN] = signs.Warn,
        [vim.diagnostic.severity.HINT] = signs.Hint,
        [vim.diagnostic.severity.INFO] = signs.Info,
    }

    local diagnostic_split = vim.split(diagnostic.message, "\n")
    --- @type string[]
    local lines_limited = {}
    for _, message in ipairs(diagnostic_split) do
        if #message > MAX_DIAGNOSTIC_MSG_LENGTH then
            local remaining = message
            while #remaining > MAX_DIAGNOSTIC_MSG_LENGTH do
                local pos = string.find(remaining, " ", MAX_DIAGNOSTIC_MSG_LENGTH)
                if pos ~= nil then
                    local limited = string.sub(remaining, 0, pos)
                    table.insert(lines_limited, limited)
                else
                    -- no more whitespace could be found
                    break
                end
                remaining = string.sub(remaining, pos)
            end
            if #remaining > 0 then
                table.insert(lines_limited, remaining)
            end
        else
            table.insert(lines_limited, message)
        end
    end

    local lines = {}
    for i, message in ipairs(lines_limited) do
        local symbol
        if i == 1 then
            symbol = symbols[diagnostic.severity]
        else
            symbol = "│"
        end
        local msg = string.format("%s%s %s", string.rep(" ", spaces), symbol, message)
        table.insert(lines, { { msg, "Diagnostic" .. severity_to_string(diagnostic.severity) } })
    end

    return lines
end

local show_virtual_text_diagnostics = function()
    if not vim.g._user_virtual_text_ns then
        vim.g._user_virtual_text_ns = vim.api.nvim_create_namespace("user_virtual_text")
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1 -- lines start at 0 (top)
    vim.api.nvim_buf_clear_namespace(bufnr, vim.g._user_virtual_text_ns, 0, -1)

    -- fetch diagnostics
    local diagnostics = vim.diagnostic.get(bufnr, { lnum = cursor_line, severity = vim.diagnostic.severity.ERROR })
    if #diagnostics == 0 then
        return
    end
    local virt_lines = {}
    for _, diagnostic in ipairs(diagnostics) do
        local lines = format_diagnostic(diagnostic, SPACES)
        for _, line in ipairs(lines) do
            table.insert(virt_lines, line)
        end
    end
    local diagnostic = diagnostics[1]
    vim.api.nvim_buf_set_extmark(bufnr, vim.g._user_virtual_text_ns, diagnostic.lnum, 0, {
        virt_lines = virt_lines,
        virt_text_pos = "eol",
    })
end

M.setup = function()
    -- TOOD: should revisit this and try something else... maybe a floating window of some kind?
    -- vim.api.nvim_create_autocmd({ "DiagnosticChanged", "CursorMoved" }, {
    --     pattern = {
    --         "*.c",
    --         "*.h",
    --         "*.ts",
    --         "*.js",
    --         "*.tsx",
    --         "*.jsx",
    --         "*.rs",
    --         "*.go",
    --         "*.py",
    --         "*.css",
    --         "*.scss",
    --         "*.vue",
    --         "*.html",
    --         "*.json",
    --         "*.java",
    --         "*.lua",
    --     },
    --     callback = show_virtual_text_diagnostics,
    -- })

    vim.api.nvim_create_autocmd("RecordingEnter", {
        pattern = "*",
        callback = function()
            vim.cmd("redrawstatus")
        end,
    })

    vim.api.nvim_create_autocmd("RecordingLeave", {
        pattern = "*",
        callback = function()
            vim.cmd("redrawstatus")
        end,
    })

    vim.api.nvim_create_autocmd({ "ModeChanged" }, {
        pattern = "*",
        callback = function()
            vim.cmd("redrawstatus")
        end,
        desc = "statusline",
    })

    vim.api.nvim_create_autocmd({ "TextYankPost" }, {
        pattern = { "*" },
        callback = function()
            vim.highlight.on_yank({ higroup = "HighlightYank" })
        end,
        desc = "Highlight yanked text",
    })

    -- vim.api.nvim_create_autocmd({ "VimEnter", "InsertLeave" }, {
    --     pattern = "*",
    --     callback = function()
    --         vim.opt.number = true
    --         vim.opt.relativenumber = true
    --     end,
    -- })
    --
    -- vim.api.nvim_create_autocmd({ "InsertEnter" }, {
    --     pattern = "*",
    --     callback = function()
    --         vim.opt.number = true
    --         vim.opt.relativenumber = false
    --     end,
    -- })
    --
    -- didn't work very well :(
    -- local min_cursor_group = vim.api.nvim_create_augroup("MinimalCursorLine", { clear = true })
    -- vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
    --     group = min_cursor_group,
    --     pattern = "*",
    --     callback = function()
    --         vim.opt_local.cursorline = true
    --     end,
    -- })
    --
    -- vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
    --     group = min_cursor_group,
    --     pattern = "*",
    --     callback = function()
    --         vim.opt_local.cursorline = false
    --     end,
    -- })
end

return M

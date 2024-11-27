-- local set = vim.opt_local

--
-- -- Set local settings for terminal buffers
-- vim.api.nvim_create_autocmd("TermOpen", {
--     group = vim.api.nvim_create_augroup("custom-term-open", {}),
--     callback = function()
--         set.number = false
--         set.relativenumber = false
--         set.scrolloff = 0
--     end,
-- })
--
--
-- -- Open a terminal at the bottom of the screen with a fixed height.
-- vim.keymap.set("n", "<leader>t", function()
--     vim.cmd.new()
--     vim.cmd.wincmd "J"
--     vim.api.nvim_win_set_height(0, 12)
--     vim.wo.winfixheight = true
--     vim.cmd.term()
-- end)
--

-- You will likely want to reduce updatetime which affects CursorHold
-- note: this setting is global and should be set only once
-- vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
--   group = vim.api.nvim_create_augroup("float_diagnostic", { clear = true }),
--   callback = function ()
--     vim.diagnostic.open_float(nil, {focus=false})
--   end
-- })

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
local SPACES = 4

--- @return table<number, vim.Diagnostic>
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
--- @return string
local format_diagnostic = function(diagnostic, spaces)
    local symbols = {
        [vim.diagnostic.severity.ERROR] = signs.Error,
        [vim.diagnostic.severity.WARN] = signs.Warn,
        [vim.diagnostic.severity.HINT] = signs.Hint,
        [vim.diagnostic.severity.INFO] = signs.Info,
    }

    local message = vim.split(diagnostic.message, "\n")[1]
    return string.format("%s%s %s", string.rep(" ", spaces), symbols[diagnostic.severity], message)
end

local show_virtual_text_diagnostics = function()
    if not vim.g._user_virtual_text_ns then
        vim.g._user_virtual_text_ns = vim.api.nvim_create_namespace("user_virtual_text")
    end

    local bufnr = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_clear_namespace(bufnr, vim.g._user_virtual_text_ns, 0, -1)

    -- fetch diagnostics
    local diagnostics = collect_surrounding_diagnostics()

    for _, diagnostic in ipairs(diagnostics) do
        vim.api.nvim_buf_set_extmark(bufnr, vim.g._user_virtual_text_ns, diagnostic.lnum, 0, {
            virt_text = {
                { format_diagnostic(diagnostic, SPACES), "Diagnostic" .. severity_to_string(diagnostic.severity) },
            },
            virt_text_pos = "eol",
        })
    end
end

M.setup = function()
    vim.api.nvim_create_autocmd({ "DiagnosticChanged" }, {
        pattern = {
            "*.c",
            "*.h",
            "*.ts",
            "*.js",
            "*.tsx",
            "*.jsx",
            "*.rs",
            "*.go",
            "*.py",
            "*.css",
            "*.scss",
            "*.vue",
            "*.html",
            "*.json",
            "*.java",
            "*.lua",
        },
        callback = show_virtual_text_diagnostics,
    })

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
            vim.highlight.on_yank()
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

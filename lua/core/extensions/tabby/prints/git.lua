local M = {}

local store = require("core.extensions.tabby.store")

local branch = function()
    local branch = vim.fn.system("git branch --show-current 2> /dev/null | tr -d '\n'")
    if branch ~= "" then
        return " " .. branch
    else
        return "(unknown)"
    end
end

--- @alias tabby.ChangeType "file"|"ins"|"del"

--- @type table<tabby.ChangeType, string>
local symbols = {
    file = "",
    ins = "",
    del = "",
}

--- @return tabby.ChangeType|nil,string|nil
local change_symbol = function(change)
    if string.find(change, "file") then
        return symbols.file, "Comment"
    elseif string.find(change, "ins") then
        return symbols.ins, "DiagnosticOk"
    elseif string.find(change, "del") then
        return symbols.del, "DiagnosticError"
    end
end

--- @return table<table<string>>
local stat = function()
    local stats = vim.system({ "git", "diff", "--stat" }):wait()
    if stats.stdout then
        local lines = vim.split(stats.stdout, "\n", { trimempty = true })
        local changes = lines[#lines]
        local changes_by_type = vim.split(changes, ",", { trimempty = true })
        local content = {}
        for _, change in ipairs(changes_by_type) do
            local amount = string.match(change, "%d+")
            local symbol, hg = change_symbol(change)
            table.insert(content, { " ", "Comment" })
            table.insert(content, { amount, "Comment" })
            table.insert(content, { " ", "Comment" })
            table.insert(content, { symbol, hg })
            table.insert(content, { " ", "Comment" })
        end
        return content
    end
    return {}
end

M.setup = function()
    store.register_tabby({
        name = "git",
        split = false,
        focused = function()
            return { { branch, "DiagnosticOk" }, unpack(stat()) }
        end,
        default = function()
            return { { branch, "DiagnosticOk" }, unpack(stat()) }
        end,
    })
end

return M

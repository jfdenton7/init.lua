local M = {}

local store = require("core.extensions.tabby.store")
--- we only update every 30 seconds or when
--- we have successfully written to the buffer
local CACHE_UPDATE_TIME = 30000
local cache = {
    branch = nil,
    stat = nil,
}
local valid = {
    branch = false,
    stat = false,
}

local branch = function()
    if cache.branch and valid.branch then
        return cache.branch
    end

    vim.system({ "git", "branch", "--show-current" }, { text = true }, function(out)
        if out.stdout and out.stdout ~= "" then
            cache.branch = " " .. string.gsub(out.stdout, "%s+", "")
        else
            cache.branch = "(unknown)"
        end
        valid.branch = true
    end)
    return cache.branch or ""
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
    if cache.stat and valid.stat then
        return cache.stat
    end

    vim.system({ "git", "diff", "--stat" }, { text = true }, function(out)
        if out.stdout then
            local lines = vim.split(out.stdout, "\n", { trimempty = true })
            local changes = lines[#lines]
            if changes and #changes > 0 then
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
                cache.stat = content
            end
        else
            cache.stat = {}
        end
        valid.stat = true
    end)
    return cache.stat or {}
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

    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        group = vim.api.nvim_create_augroup("user/winbar/git", { clear = true }),
        desc = "Attach statusline",
        callback = vim.schedule_wrap(function()
            valid.stat = false
            valid.branch = false
        end),
    })

    local timer = vim.uv.new_timer()
    timer:start(
        CACHE_UPDATE_TIME,
        CACHE_UPDATE_TIME,
        vim.schedule_wrap(function()
            valid.stat = false
            valid.branch = false
        end)
    )
end

return M

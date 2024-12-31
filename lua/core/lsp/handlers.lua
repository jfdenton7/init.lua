local M = {}

--- @param arr table
local filter = function(arr, fn)
    if type(arr) ~= "table" then
        return arr
    end

    local filtered = {}
    for k, v in pairs(arr) do
        if fn(v, k, arr) then
            table.insert(filtered, v)
        end
    end

    return filtered
end

local function filterReactDTS(value)
    return string.match(value.uri, "react/index.d.ts") == nil
end

M.ts_ls = {
    handlers = {
        ["textDocument/definition"] = function(err, result, method, ...)
            if vim.islist(result) and #result > 1 then
                local filtered = filter(result, filterReactDTS)
                return vim.lsp.handlers["textDocument/definition"](err, filtered, method, ...)
            end

            return vim.lsp.handlers["textDocument/definition"](err, result, method, ...)
        end,
    },
}

return M

local M = {}

local files = require("core.extensions.files")
local store = require("core.extensions.ai.store")

--- @param state State
--- @return State
M.setup = function(state)
    store.register_action({
        name = "",
        msg = "",
        mode = "n",
        key = ",p",
        ui = "doc_patterns",
        hidden = false,
        apply = M.open,
    })
    store.register_context({
        name = "",
        key = ",,p",
        ui = "menu",
        active = false,
        getter = M.context,
    })
    return state
end

--- @param state State
M.open = function(state)
    return state
end

--- @param state State
--- @return string
M.context = function(state)
    local content = files.read(state.patterns.file_path)
    if content ~= nil then
        local prompt = "refer to the following coding patterns as examples you should follow\n"
        return prompt .. "<patterns>" .. content .. "\n</patterns>"
    end
    return ""
end

return M

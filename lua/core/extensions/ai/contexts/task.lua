local M = {}

local files = require("core.extensions.files")
local store = require("core.extensions.ai.store")

--- @param state State
--- @return State
M.setup = function(state)
    store.register_action({
        name = "task",
        msg = "",
        mode = "n",
        key = ",t",
        ui = "doc_task",
        hidden = false,
        apply = M.open,
    })
    store.register_context({
        name = "task",
        key = ",,t",
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
    local content = files.read(state.task.file_path)
    if content ~= nil then
        local prompt = "refer to the following for context on the current task\n"
        return prompt .. "<task>" .. content .. "\n</task>"
    end
    return ""
end

return M

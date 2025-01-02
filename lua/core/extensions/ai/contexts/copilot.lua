local M = {}

local store = require("core.extensions.ai.store")

--- @param state State
--- @return State
M.setup = function(state)
    store.register_context({
        name = "",
        key = ",,g",
        active = false,
        ui = "menu",
        getter = function(_)
            return "\n\n#git:staged\n\n"
        end,
    })
    store.register_context({
        name = "",
        key = ",,B",
        active = false,
        ui = "menu",
        getter = function(_)
            return "\n\n#buffer\n\n"
        end,
    })
    store.register_context({
        name = "",
        key = ",,f",
        active = false,
        ui = "menu",
        getter = function(_)
            return "\n\n#files\n\n"
        end,
    })
    return state
end

return M

local M = {}

--- @param state State
M.setup = function(state)
    require("core.extensions.ai.contexts.blocks").setup(state)
    require("core.extensions.ai.contexts.selection").setup(state)
    require("core.extensions.ai.contexts.copilot").setup(state)
    -- require("core.extensions.ai.contexts.debugger").setup(state)
    require("core.extensions.ai.contexts.urls").setup(state)
    require("core.extensions.ai.contexts.patterns").setup(state)
    require("core.extensions.ai.contexts.task").setup(state)
end

return M

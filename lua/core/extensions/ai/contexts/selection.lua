local M = {}

local buffer = require("core.editor.buffer")
local store = require("core.extensions.ai.store")

--- @param state State
--- @return State
M.setup = function(state)
    store.register_context({
        name = "selection",
        key = ",,s",
        ui = "menu",
        active = false,
        getter = M.context,
    })
    return state
end

--- @param _ State
--- @return string
M.context = function(_)
    local sel_start, sel_end = buffer.active_selection()
    vim.api.nvim_command('normal! "+y')

    local lines = vim.fn.getline(sel_start, sel_end)
    if #lines == 0 then
        return ""
    end
    if type(lines) == "string" then
        return "refer to the following selected code.\n" .. "```%s\n" .. lines .. "\n```"
    end

    return "refer to the following selected code.\n"
        .. string.format("```%s\n", vim.api.nvim_get_option_value("filetype", { buf = 0 }))
        .. table.concat(lines, "\n")
        .. "\n```"
end

return M

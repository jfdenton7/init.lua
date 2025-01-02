local M = {}

local store = require("core.extensions.ai.store")
local mini_notify = require("mini.notify")

--- @param state State
--- @return State
M.setup = function(state)
    store.register_action({
        name = "󰀳",
        msg = "",
        mode = "n",
        key = ",u",
        hidden = false,
        apply = M.replace,
        ui = "menu",
    })
    store.register_action({
        name = "󰜏",
        msg = "",
        mode = "n",
        key = ",U",
        hidden = false,
        apply = M.open,
        ui = "menu",
    })
    store.register_context({
        name = "󰖟",
        key = ",,u",
        active = false,
        getter = M.context,
        ui = "menu",
    })

    return state
end

--- @param state State
--- @return string
M.context = function(state)
    if #state.url == 0 then
        return ""
    end

    return "\n\n#url " .. state.url .. "\n\n"
end

--- @param state State
--- @return State
M.open = function(state)
    if #state.url > 0 then
        local id = mini_notify.add("opening " .. state.url)
        vim.defer_fn(function()
            mini_notify.remove(id)
        end, 1500)
        local escaped_url = vim.fn.shellescape(state.url, true)
        -- remove the added quotes
        local url = string.sub(escaped_url, 2, #escaped_url - 1)
        vim.system({ "open", url }):wait()
    end
    return state
end

--- @param state State
--- @return State
M.replace = function(state)
    if #state.url > 0 then
        local id = mini_notify.add("replacing " .. state.url)
        vim.defer_fn(function()
            mini_notify.remove(id)
        end, 3500)
    end
    vim.ui.input({ prompt = "url" }, function(input)
        if input == nil or #input == 0 then
            return
        end

        state.url = input
    end)
    return state
end

return M

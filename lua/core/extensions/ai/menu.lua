local M = {}

local store = require("core.extensions.ai.store")

--- @param state State
--- @return State
M.setup = function(state)
    store.register_action({
        name = "quit",
        msg = "",
        mode = "n",
        key = ",q",
        hidden = false,
        ui = "menu",
        apply = M.quit,
    })
    return state
end

--- close out the menu, removing all keymaps
--- @param state State
--- @return State
M.quit = function(state)
    for _, keymap in ipairs(state.actions) do
        vim.keymap.del(keymap.mode, keymap.key)
    end

    for _, keymap in ipairs(state.contexts) do
        vim.keymap.del("n", keymap.key)
    end

    vim.api.nvim_buf_delete(state.menu.bufnr, { force = true })
    return store.default_state()
end

return M

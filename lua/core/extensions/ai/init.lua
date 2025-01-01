local M = {}

local ui = require("core.extensions.ai.ui")
local assistant = require("core.extensions.ai.assistant")
local contexts = require("core.extensions.ai.contexts")
local menu = require("core.extensions.ai.menu")
local store = require("core.extensions.ai.store")

M.setup = function()
    vim.keymap.set("n", "<leader>ai", function()
        local state = store.state()
        if vim.api.nvim_buf_is_valid(state.menu.bufnr) then
            return -- noop when trying to double open
        end

        assistant.setup(state)
        contexts.setup(state)
        menu.setup(state)
        store.setup()
        ui.open_menu(state)
    end, { desc = "open AI action panel" })
end

return M

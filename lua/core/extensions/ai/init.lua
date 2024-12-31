local M = {}

local ui = require("core.extensions.ai.ui")
local actions = require("core.extensions.ai.actions")
local context_builder = require("core.extensions.ai.context")
local app = require("core.extensions.ai.app")

M.setup = function()
    local _app = app.new()
    vim.keymap.set("n", "<leader>ai", function()
        if vim.api.nvim_buf_is_valid(_app.menu_bufnr) then
            vim.api.nvim_buf_delete(_app.menu_bufnr, { force = true })
        end
        local contexts = context_builder.contexts()
        ui.open_menu(_app, actions.keymap, contexts)

        -- quitting will delete the keymap everytime
        for _, keymap in ipairs(actions.keymap) do
            vim.keymap.set(keymap.mode, keymap.key, function()
                keymap.action(_app)
                if keymap.name ~= "quit" then
                    ui.draw_menu(_app, actions.keymap, contexts)
                end
            end, { desc = "ai: " .. keymap.name })
        end

        for _, context in ipairs(contexts) do
            vim.keymap.set("n", context.key, function()
                context_builder.toggle(context.name)
                ui.draw_menu(_app, actions.keymap, contexts)
            end, { desc = "ai: " .. "toggle " .. context.name })
        end
    end, { desc = "open AI action panel" })
end

return M

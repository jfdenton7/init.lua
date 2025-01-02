local M = {}

local buffer = require("core.editor.buffer")
local store = require("core.extensions.ai.store")
local chat = require("CopilotChat")
local float = require("core.ui.float")
-- local source = require("CopilotChat.")
local ui = require("core.extensions.ai.ui")

local CMD_PREFIX = "<command>"
local CMD_POSTFIX = "</command>"

--- @param state State
--- @return State
M.setup = function(state)
    store.register_action({
        name = "generate",
        msg = "",
        mode = { "n", "v" },
        key = ",g",
        ui = "menu",
        hidden = false,
        apply = M.generate,
    })
    store.register_action({
        name = "review",
        msg = "reviewing buffer",
        mode = "n",
        key = ",r",
        ui = "menu",
        hidden = false,
        apply = M.review,
    })
    store.register_action({
        name = "plan",
        msg = "",
        mode = "n",
        key = ",P",
        ui = "menu",
        hidden = false,
        apply = M.plan,
    })
    store.register_action({
        name = "ask",
        msg = "",
        mode = "n",
        key = ",a",
        ui = "menu",
        hidden = false,
        apply = M.ask,
    })

    return state
end

--- @param state State
local contexts = function(state)
    local prompt = "<context>"
    for _, context in ipairs(state.contexts) do
        local content = context.getter(state)
        if content ~= nil and #content > 0 and context.active then
            prompt = prompt .. "\n" .. content
        end
    end
    prompt = prompt .. "\n</context>"
    return prompt
end

--- diagnose errors / race conditions in the current buffer
--- @param state State
--- @return State
M.ask = function(state)
    vim.ui.input({ prompt = "  Ask" }, function(input)
        if input == nil or #input == 0 then
            return
        end
        local pre = "answer the following question, keep it short and to the point"
        chat.ask(pre .. input .. "\n" .. contexts(state), {
            headless = true,
            callback = function(response, _)
                float.open(response, {
                    enter = false,
                    rel = "lhs",
                    height = 10,
                    width = 0.8,
                    bo = { filetype = "markdown" },
                    wo = { wrap = true },
                    close_on_q = true,
                })
            end,
        })
    end)
    return state
end

--- diagnose errors / race conditions in the current buffer
--- @param state State
--- @return State
M.review = function(state)
    chat.ask("/Review", {
        headless = true,
    })
    return state
end

--- plan the next step
--- @param state State
--- @return State
M.plan = function(state)
    vim.cmd("tabnew")
    chat.ask(
        "describe the next steps to complete the task, keep the answer short and in bullets: "
            .. contexts(state)({ window = { layout = "replace" }, highlight_selection = false })
    )
    return state
end

--- @param state State
--- @return State
M.generate = function(state)
    local status = vim.api.nvim_get_mode()
    local should_replace = status.mode == "v" or status.mode == "V" or status.mode == "^V"
    local sel_start, sel_end = buffer.active_selection()

    local prompt_header =
        "<rules>You must always respond in code. If you want to include an explanation, you MUST use comments.</rules>"
    prompt_header = prompt_header .. contexts(state) .. "\n\n" .. "/COPILOT_GENERATE" -- TODO: unsure if I need this...

    local _start, _end
    if should_replace then
        _start, _end = sel_start, sel_end
    else
        local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
        _start, _end = row, row
    end
    vim.ui.input({ prompt = "  Generate" }, function(input)
        if input == nil or #input == 0 then
            return
        end
        local ns_id = ui.load_start(_start, _end, should_replace)
        local prompt_cmd = CMD_PREFIX .. input .. CMD_POSTFIX
        chat.ask(prompt_header .. prompt_cmd, {
            headless = true,
            callback = function(response, _)
                local lines = vim.split(response, "\n")
                lines = vim.list_slice(lines, 2, #lines - 1)
                ui.load_end(ns_id)
                if should_replace then
                    vim.api.nvim_buf_set_lines(0, _start - 1, _end, false, lines)
                else
                    vim.api.nvim_buf_set_lines(0, _start, _start, false, lines)
                end
            end,
        })
    end)

    return state
end

return M

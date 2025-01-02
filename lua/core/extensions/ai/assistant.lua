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
        name = "",
        msg = "",
        mode = { "n", "v" },
        key = ",g",
        ui = "menu",
        hidden = false,
        apply = M.generate,
    })
    store.register_action({
        name = "",
        msg = "reviewing buffer",
        mode = "n",
        key = ",r",
        ui = "menu",
        hidden = false,
        apply = M.review,
    })
    store.register_action({
        name = "󰧑",
        msg = "",
        mode = "n",
        key = ",P",
        ui = "menu",
        hidden = false,
        apply = M.plan,
    })
    store.register_action({
        name = "",
        msg = "",
        mode = { "n", "x" },
        key = ",a",
        ui = "menu",
        hidden = false,
        apply = M.ask,
    })
    store.register_action({
        name = "󱈅",
        msg = "getting explanation",
        mode = { "x" },
        key = ",e",
        ui = "menu",
        hidden = false,
        apply = M.explain,
    })
    store.register_context({
        name = " ",
        key = ",,A",
        active = false,
        getter = M.qr_history_context,
        ui = "menu",
    })
    store.register_context({
        name = " 󱈅",
        key = ",,E",
        active = false,
        getter = M.er_history_context,
        ui = "menu",
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

--- @type string represents the last response from M.explain
local er_history = ""

--- @param state State
--- @return State
M.explain = function(state)
    local sel_start, sel_end = buffer.active_selection()
    local lines = vim.api.nvim_buf_get_lines(0, sel_start - 1, sel_end, false)
    local selected_text = table.concat(lines, "\n")

    local prompt = [[
<rules>
- provide an explanation for the following code.
- use example input as you go through the code
- discuss how the code modifies the input
</rules>
<code>]] .. selected_text .. "</code>"

    chat.ask(prompt, {
        headless = true,
        callback = function(response, _)
            er_history = response
            float.open(response, {
                enter = false,
                rel = "lhs",
                row = 1000,
                height = 0.25,
                width = 0.8,
                bo = { filetype = "markdown" },
                wo = { wrap = true },
                close_on_q = true,
            })
        end,
    })
    return state
end

--- @param _ State
--- @return string
M.er_history_context = function(_)
    if #er_history == 0 then
        return ""
    end
    return "<chat-history>" .. er_history .. "</chat-history>"
end

--- @type string represents the last response from M.ask
local qr_history = ""

--- respond to a question based off of the available context
--- @param state State
--- @return State
M.ask = function(state)
    vim.ui.input({ prompt = "  Ask" }, function(input)
        if input == nil or #input == 0 then
            return
        end
        local pre = [[
<rules>
- answer the following question
- keep it short, to the point, and use markdown standards.
- if there is a previous question, then this question builds on that one
</rules>
        ]]
        chat.ask(pre .. "<question>" .. input .. "</question>\n" .. contexts(state), {
            headless = true,
            callback = function(response, _)
                qr_history = "<previous-question>"
                    .. input
                    .. "</previous-question><previous-answer>"
                    .. response
                    .. "</previous-answer>"
                float.open(response, {
                    enter = false,
                    rel = "lhs",
                    row = 1000, -- ensure it pops up on the bottom
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

--- @param _ State
--- @return string
M.qr_history_context = function(_)
    if #qr_history == 0 then
        return ""
    end
    return "<chat-history>" .. qr_history .. "</chat-history>"
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
    chat.ask([[
<rules>
- describe the next steps to complete the task
- keep the answer short and in bullets
- focus on code changes and how best to structure the solution
- talk about possible design alternatives
</rules>
        ]] .. contexts(state)({ window = { layout = "replace" }, highlight_selection = false }))
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

local M = {}

local context_builder = require("core.extensions.ai.context")
local ui = require("core.extensions.ai.ui")
local chat = require("CopilotChat")
local mini_notify = require("mini.notify")
local buffer = require("core.editor.buffer")

local CMD_PREFIX = "<command>"
local CMD_POSTFIX = "</command>"

local contexts = function()
    local prompt = "<context>"
    local contexts = context_builder.contexts()
    for _, context in ipairs(contexts) do
        local content = context.getter()
        if content ~= nil and #content > 0 and context.active then
            prompt = prompt .. "\n" .. content
        end
    end
    prompt = prompt .. "\n</context>"
    return prompt
end

--- generate unit tests, example usage / construction, or ...
--- @param ctx App
M.generate = function(ctx)
    local status = vim.api.nvim_get_mode()
    local should_replace = status.mode == "v" or status.mode == "V" or status.mode == "^V"
    local sel_start, sel_end = buffer.active_selection()

    local prompt_header =
        "<rules>You must always respond in code. If you want to include an explanation, you MUST use comments.</rules>"
    prompt_header = prompt_header .. contexts() .. "/COPILOT_GENERATE" -- TODO: unsure if I need this...

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
end

--- @param ctx App
M.chunk = function(ctx)
    local start_line, end_line = buffer.active_selection()

    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    local path = vim.split(vim.fn.expand("%"), ".", { plain = true, trimempty = true })
    local extension = path[#path]

    context_builder.save_chunk(vim.fn.join(lines, "\n"), extension)
    vim.api.nvim_command('normal! "+y')
end

--- set the task context
--- @param ctx App
M.task = function(ctx)
    context_builder.update_task()
end

M.plan = function()
    local task = context_builder.task()
    chat.ask(
        "describe the next step we need to do for the following task, keeping the answer short and to the point: "
            .. task
            .. " #git",
        { window = { layout = "replace" }, highlight_selection = false }
    )
end

--- set the task context
--- @param ctx App
M.patterns = function(ctx)
    context_builder.update_patterns()
end

--- @class CopilotDiagnostic
--- @field lnum number
--- @field level string
--- @field message string

--- diagnose errors / race conditions in the current buffer
--- @param ctx App
M.review = function(ctx) -- we can just use the CopilotChatReview command...
    local id = mini_notify.add("  reviewing...", "INFO", "Comment")
    vim.defer_fn(function()
        mini_notify.remove(id)
    end, 1500)
    chat.ask("/Review", {
        headless = true,
        callback = function()
            local id = mini_notify.add("  added review comments", "INFO", "DiagnosticOk")
            vim.defer_fn(function()
                mini_notify.remove(id)
            end, 1500)
        end,
    })
end

--- learn new topic
--- @param ctx App
M.learn = function(ctx)
    vim.cmd("tabnew")
    chat.ask("", {
        window = { layout = "replace" },
    })
end

--- quizzes built from the topics above
--- @param ctx App
M.quiz = function(ctx) end

--- @param ctx App
M.clear_chunks = function(ctx)
    context_builder.clear_chunks()
end

--- close out the menu, removing all keymaps
--- @param ctx App
M.quit = function(ctx)
    for _, keymap in ipairs(M.keymap) do
        vim.keymap.del(keymap.mode, keymap.key)
    end

    for _, keymap in ipairs(context_builder.contexts()) do
        vim.keymap.del("n", keymap.key)
    end

    vim.api.nvim_buf_delete(ctx.menu_bufnr, { force = true })
    ctx.menu_bufnr = -1
end

--- @class AIAction
--- @field name string
--- @field mode "n"|"v"|"x"|table
--- @field key string
--- @field action fun(context: App)

--- @type table<AIAction>
M.keymap = {
    {
        name = "generate",
        key = ",g",
        action = M.generate,
        mode = { "n", "v" },
    },
    {
        name = "patterns",
        key = ",p",
        action = M.patterns,
        mode = "n",
    },
    {
        name = "task",
        key = ",t",
        action = M.task,
        mode = "n",
    },
    {
        name = "add chunk",
        key = ",c",
        action = M.chunk,
        mode = "v",
    },
    {
        name = "clear chunks",
        key = ",z",
        action = M.clear_chunks,
        mode = "n",
    },
    {
        name = "review",
        key = ",r",
        action = M.review,
        mode = { "n", "v" },
    },
    {
        name = "plan",
        key = ",P",
        action = M.plan,
        mode = { "n" },
    },
    {
        name = "quiz",
        key = ",Z",
        action = M.quiz,
        mode = "n",
    },
    {
        name = "quit",
        key = ",q",
        action = M.quit,
        mode = "n",
    },
}

return M

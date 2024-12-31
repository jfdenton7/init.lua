--- handles feeding content to copilot to make better suggestions
local M = {}

local PREFIX = ".nvim_"
local TASK_FILE_NAME = "task_context.md"
local CHUNKS_FILE_NAME = "chunks.json"
local PATTERNS_FILE_NAME = "patterns_context.md"

local float = require("core.ui.float")
local git = require("core.extensions.git")
local files = require("core.extensions.files")
local mini_notify = require("mini.notify")

local MAX_CHUNKS = 10 -- if we go beyond this, we should bump it out

--- @param content string
--- @param extension string type of code chunk to add
M.save_chunk = function(content, extension)
    local path = git.root() .. "/" .. PREFIX .. CHUNKS_FILE_NAME
    local raw = files.read(path)
    local chunks
    if raw ~= nil then
        chunks = vim.fn.json_decode(raw)
    else
        chunks = {}
    end

    if #chunks == MAX_CHUNKS then
        -- rmv the oldest entry
        chunks = vim.list_slice(chunks, 2)
        -- TODO: notify we dropped an entry
    end
    table.insert(chunks, { content = content, extension = extension })
    raw = vim.fn.json_encode(chunks)
    local err = files.write(path, raw)
    if err ~= nil then
        --- TODO: notify
    end
end

local format_chunk = function(chunk)
    return string.format(
        [[```%s
%s
```
    ]],
        chunk.extension,
        chunk.content
    )
end

--- @return string
M.chunks_meta = function()
    local path = git.root() .. "/" .. PREFIX .. CHUNKS_FILE_NAME
    local content = files.read(path)
    if content == nil then
        return ""
    end

    local chunks = vim.fn.json_decode(content)
    if type(chunks) ~= "table" then
        return ""
    end
    return "(" .. #chunks .. "/" .. MAX_CHUNKS .. ")"
end

--- @return string
M.chunks = function()
    local path = git.root() .. "/" .. PREFIX .. CHUNKS_FILE_NAME
    local content = files.read(path)
    if content == nil then
        return ""
    end

    local prompt = "<snippets>utilize these snippets or documentation from the code base for additional clarity"
    local chunks = vim.fn.json_decode(content)
    if type(chunks) ~= "table" or #chunks == 0 then
        return ""
    end

    for _, chunk in ipairs(chunks) do
        prompt = prompt .. "\n" .. format_chunk(chunk)
    end

    return prompt .. "</snippets>"
end

--- @return string
M.staged = function()
    return string.format("<git-staged-diff>%s</git-staged-diff>", git.diffs(true))
end

--- opens a floating buffer, user will set task context here (markdown file)
M.update_task = function()
    float.open(
        nil,
        { rel = "center", width = 0.8, height = 0.3, title = "  Task Context", close_on_q = true, enter = true }
    )
    local path = git.root() .. "/" .. PREFIX .. TASK_FILE_NAME
    vim.cmd("edit" .. path)
end

--- @return string task description, in markdown format
M.task = function()
    local path = git.root() .. "/" .. PREFIX .. TASK_FILE_NAME
    local content = files.read(path)
    if content == nil then
        return ""
    end

    local prompt = "refer to the following for context on the current task\n"
    return prompt .. "<task>" .. content .. "\n</task>"
end

--- opens a floating buffer, user will set task context here (markdown file)
M.update_patterns = function()
    float.open(
        nil,
        { rel = "center", width = 0.8, height = 0.3, title = "  Coding Patterns", close_on_q = true, enter = true }
    )
    local path = git.root() .. "/" .. PREFIX .. PATTERNS_FILE_NAME
    vim.cmd("edit" .. path)
end

M.patterns = function()
    local path = git.root() .. "/" .. PREFIX .. PATTERNS_FILE_NAME
    local content = files.read(path)
    if content == nil then
        return ""
    end

    local prompt = "refer to the following coding patterns as examples you should follow\n"
    return prompt .. "<patterns>" .. content .. "\n</patterns>"
end

--- gets all lines in the active selection
M.selection = function()
    local visual_pos = vim.fn.getpos("v")
    local visual_line = visual_pos[2]
    local cursor_pos = vim.fn.getpos(".")
    local cursor_line = cursor_pos[2]
    local start_line = math.min(visual_line, cursor_line)
    local end_line = math.max(visual_line, cursor_line)
    vim.api.nvim_command('normal! "+y')

    local lines = vim.fn.getline(start_line, end_line)
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

--- @return string
M.scope = function() end

M.clear_chunks = function()
    vim.cmd(string.format("!rm %s", PREFIX .. CHUNKS_FILE_NAME))
    local id = mini_notify.add("cleared chunks context", "INFO", "Comment")
    vim.defer_fn(function()
        mini_notify.remove(id)
    end, 2500)
end

local none = function()
    return ""
end

--- @class Context
--- @field name string
--- @field key string
--- @field active boolean
--- @field getter fun(): string
--- @field meta fun(): string

--- @type table<Context>
local contexts = {
    {
        name = "chunks", -- saved a list of "chunks", which is just code selected and saved into an active list..., save up to N chunks, (saved to file)
        key = ",,c",
        active = false,
        getter = M.chunks,
        meta = M.chunks_meta,
    },
    {
        name = "selection",
        key = ",,s",
        active = false,
        getter = M.selection,
        meta = none,
    },
    {
        name = "staged", -- use git cli
        key = ",,g",
        active = false,
        getter = M.staged,
        meta = none,
    },
    {
        name = "task", -- (saved to markdown file)
        key = ",,t",
        active = false,
        getter = M.task,
        meta = none,
    },
    {
        name = "patterns", -- (saved to markdown file)
        key = ",,p",
        active = false,
        getter = M.patterns,
        meta = none,
    },
    {
        name = "debugger", -- (not saved)
        key = ",,d",
        active = false,
        getter = M.scope,
        meta = none,
    },
}

--- @param name string
M.toggle = function(name)
    -- TODO: setup custom toggle menu for chunks (granularity)
    -- then tab could add virtual lines for the chunk to display content
    -- use enter key to toggle each chunk (custom keymap for buffer)
    -- "q" to quit out
    for _, v in ipairs(contexts) do
        if v.name == name then
            v.active = not v.active
        end
    end
end

M.contexts = function()
    return contexts
end

return M

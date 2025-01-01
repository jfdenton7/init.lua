local M = {}

local mini_notify = require("mini.notify")
local files = require("core.extensions.files")
local git = require("core.extensions.git")
local ui = require("core.extensions.ai.ui")

--- @class State
--- @field menu AIMenu
--- @field blocks Blocks
--- @field patterns Document
--- @field task Document
--- @field actions table<AIAction>
--- @field contexts table<Context>

--- @class AIMenu
--- @field open boolean
--- @field bufnr integer

--- @class Blocks
--- @field pos integer
--- @field list table<Block>
--- @field open boolean
--- @field bufnr integer

--- @class Document
--- @field bufnr integer
--- @field file_path string

--- @class AIAction
--- @field name string
--- @field msg string
--- @field mode "n"|"v"|"x"|table
--- @field key string
--- @field hidden boolean
--- @field apply fun(state: State): State
--- @field ui "menu"|"blocks_open"|"blocks_redraw"|"doc_task"|"doc_patterns"

--- @class Context
--- @field name string
--- @field key string
--- @field active boolean
--- @field getter fun(state: State): string
--- @field meta ?fun(state: State): table<string,string>
--- @field ui "menu"|"blocks_open"|"blocks_redraw"|"doc_task"|"doc_patterns"

local PREFIX = ".nvim_"
local TASK_FILE_NAME = "task_context.md"
local PATTERNS_FILE_NAME = "patterns_context.md"
local PERSIST_FILE_NAME = "ai.json"

--- @return State
M.default_state = function()
    return {
        menu = {
            open = false,
            bufnr = -1,
        },
        blocks = {
            pos = 1,
            list = {},
            open = false,
            bufnr = -1,
        },
        patterns = {
            file_path = PREFIX .. PATTERNS_FILE_NAME,
            bufnr = -1,
        },
        task = {
            file_path = PREFIX .. TASK_FILE_NAME,
            bufnr = -1,
        },
        actions = {},
        contexts = {},
    }
end

--- @type State
local state = M.default_state()

--- @class RegisterOpts
--- @field bufnr integer|nil

--- @type RegisterOpts
local register_defaults = {
    bufnr = nil,
}

--- @return State
M.state = function()
    return state
end

--- @param context Context
--- @param opts ?RegisterOpts
--- @return integer index of the registered context
M.register_context = function(context, opts)
    table.insert(state.contexts, context)
    opts = opts or register_defaults
    vim.keymap.set("n", context.key, function()
        for _, registered in ipairs(state.contexts) do
            if registered.name == context.name then
                registered.active = not registered.active
                ui.draw(state, context.ui)
                vim.defer_fn(M.persist, 0)
            end
        end
    end, { desc = "ai: toggle " .. context.name, buffer = opts.bufnr })
    return #state.contexts
end

--- @param action AIAction
--- @param opts ?RegisterOpts
--- @return integer index of the registered action
M.register_action = function(action, opts)
    table.insert(state.actions, action)
    opts = opts or register_defaults
    vim.keymap.set(action.mode, action.key, function()
        if #action.msg > 0 then
            local id = mini_notify.add(action.msg, "INFO", "Comment")
            vim.defer_fn(function()
                mini_notify.remove(id)
            end, 1500)
        end
        state = action.apply(state)
        if state.menu.open then
            ui.draw(state, action.ui)
        end
        if action.name ~= "quit" then
            vim.defer_fn(M.persist, 0)
        end
    end, { desc = "ai: " .. action.name, buffer = opts.bufnr })
    return #state.actions
end

--- @param name string
M.deregister_action = function(name)
    local id = 0
    for i, action in ipairs(state.actions) do
        if action.name == name then
            id = i
            break
        end
    end
    table.remove(state.actions, id)
end

--- @class PersistedState
--- @field blocks table<Block>
--- @field block_pos integer
--- @field contexts table<string, boolean>

--- called whenever a state change occurs, with a 500ms delay
--- to ensure we don't slow down UX and updates to the UI.
M.persist = function()
    local contexts = {}
    for _, context in ipairs(state.contexts) do
        contexts[context.name] = context.active
    end

    --- @type PersistedState
    local persisted = {
        blocks = state.blocks.list,
        block_pos = state.blocks.pos,
        contexts = contexts,
    }

    local raw = vim.fn.json_encode(persisted)
    local err = files.write(git.root() .. "/" .. PREFIX .. PERSIST_FILE_NAME, raw)
    if err ~= nil then
        local id = mini_notify.add("failed to persist ai state", "ERROR", "DiagnosticError")
        vim.defer_fn(function()
            mini_notify.remove(id)
        end, 1500)
    end
end

--- setup should be called after registering everything
--- so when we load the persisted state we correctly
--- assign active contexts
M.setup = function()
    local content = files.read(git.root() .. "/" .. PREFIX .. PERSIST_FILE_NAME)
    if content ~= nil then
        --- @type PersistedState
        local persisted = vim.fn.json_decode(content)
        state.blocks.list = persisted.blocks
        state.blocks.pos = persisted.block_pos
        for _, context in ipairs(state.contexts) do
            if persisted.contexts[context.name] ~= nil then
                context.active = persisted.contexts[context.name]
            end
        end
    end
end

return M

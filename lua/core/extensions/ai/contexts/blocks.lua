local M = {}

local buffer = require("core.editor.buffer")
local store = require("core.extensions.ai.store")
local mini_notify = require("mini.notify")

--- @class Block
--- @field content string
--- @field extension string
--- @field path string
--- @field active boolean

--- @param state State
--- @return table<string,string>
local meta = function(state)
    local active = #vim.tbl_filter(function(value)
        return value.active
    end, state.blocks.list)

    return { active .. "," .. #state.blocks.list, "Comment" }
end

--- @param state State
--- @return State
M.setup = function(state)
    store.register_action({
        name = "󰩭",
        msg = "added selection",
        mode = "v",
        key = ",s",
        hidden = false,
        apply = M.add,
        ui = "menu",
    })
    store.register_action({
        name = "",
        msg = "",
        mode = "n",
        key = ",l",
        hidden = false,
        apply = M.list,
        ui = "blocks_open",
    })
    store.register_action({
        name = "󱟃",
        msg = "cleared selections",
        mode = "n",
        key = ",z",
        hidden = false,
        apply = M.clear,
        ui = "menu",
    })
    store.register_context({
        name = "",
        key = ",,b",
        active = false,
        getter = M.context,
        meta = meta,
        ui = "menu",
    })

    return state
end

--- @param state State
--- @return State
M.list = function(state)
    state.blocks.bufnr = vim.api.nvim_create_buf(true, false)
    store.register_action({
        name = "toggle block",
        msg = "",
        mode = "n",
        key = "<enter>",
        hidden = true,
        ui = "blocks_redraw",
        apply = function(_state)
            for i, block in ipairs(_state.blocks.list) do
                if i == _state.blocks.pos then
                    block.active = not block.active
                end
            end
            return _state
        end,
    }, { bufnr = state.blocks.bufnr })
    store.register_action({
        name = "next block",
        msg = "",
        mode = "n",
        key = "<tab>",
        hidden = true,
        ui = "blocks_redraw",
        apply = function(_state)
            _state.blocks.pos = (_state.blocks.pos % #_state.blocks.list) + 1
            return _state
        end,
    }, { bufnr = state.blocks.bufnr })
    store.register_action({
        name = "previous block",
        msg = "",
        mode = "n",
        key = "<s-tab>",
        hidden = true,
        ui = "blocks_redraw",
        apply = function(_state)
            _state.blocks.pos = _state.blocks.pos - 1
            if _state.blocks.pos < 1 then
                _state.blocks.pos = #_state.blocks.list
            end
            return _state
        end,
    }, { bufnr = state.blocks.bufnr })
    vim.api.nvim_buf_attach(state.blocks.bufnr, false, {
        on_detach = function()
            state.blocks.open = false
            store.deregister_action("previous block")
            store.deregister_action("next block")
            store.deregister_action("toggle block")
        end,
    })
    return state
end

local MAX_BLOCKS = 10

--- @param state State
--- @return State
M.add = function(state)
    local start_line, end_line = buffer.active_selection()
    local relative_file_path = vim.fn.expand("%:.")
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    local segments = vim.split(relative_file_path, ".", { plain = true, trimempty = true })
    local extension = segments[#segments]

    if #state.blocks.list == MAX_BLOCKS then
        -- rmv the oldest entry
        state.blocks.list = vim.list_slice(state.blocks.list, 2)
        local id = mini_notify.add("max chunks, dropping oldest", "WARN", "DiagnosticWarn")
        vim.defer_fn(function()
            mini_notify.remove(id)
        end, 1500)
    end

    table.insert(
        state.blocks.list,
        { content = vim.fn.join(lines, "\n"), extension = extension, path = relative_file_path, active = true }
    )
    vim.api.nvim_command('normal! "+y')

    return state
end

--- @param state State
M.clear = function(state)
    state.blocks.list = {}
    return state
end

--- @param block Block
local format_chunk = function(block)
    return string.format(
        [[```%s
%s
```
    ]],
        block.extension,
        block.content
    )
end

--- @param state State
--- @return string
M.context = function(state)
    local prompt = "<snippets>utilize these snippets or documentation from the code base for additional clarity"
    for _, block in ipairs(state.blocks.list) do
        if block.active then
            prompt = prompt .. "\n" .. format_chunk(block)
        end
    end

    return prompt .. "</snippets>"
end

return M

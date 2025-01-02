local M = {}

--- @class PickerEntry
--- @field value any
--- @field display string

local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")
local finders = require("telescope.finders")
local themes = require("telescope.themes")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local git = require("core.extensions.git")

local focused = themes.get_dropdown({
    winblend = 0,
    layout_config = {
        width = 80,
    },
    prompt = " ",
    results_height = 15,
})

local no_preview = themes.get_dropdown({
    winblend = 0,
    layout_config = {
        width = 80,
    },
    prompt = " ",
    results_height = 15,
    previewer = false,
})

--- open a picker that's either takes default preview content with options or only a list of options
---
--- M.open_picker(
---     "Pick Fruit",
---     nil,
---     { { value = "apple", display = "Apple" }, { value = "orange", display = "Orange" } },
---     function(entry)
---         vim.print(entry)
---     end
--- )
--- @param title string
--- @param preview_content ?string
--- @param entries table<PickerEntry|string>
--- @param on_select fun(entry: any)
M.open_picker = function(title, preview_content, entries, on_select)
    local theme
    if preview_content ~= nil and #preview_content > 0 then
        theme = focused
    else
        theme = no_preview
    end
    pickers
        .new(theme, {
            prompt_title = title,
            finder = finders.new_table({
                results = entries,
                --- @param item PickerEntry|string
                entry_maker = function(item)
                    if type(item) == "table" then
                        return {
                            value = item.value,
                            ordinal = "ddd",
                            display = item.display,
                        }
                    end
                    return {
                        value = item,
                        ordinal = "ddd",
                        display = item,
                    }
                end,
            }),
            previewer = previewers.new_buffer_previewer({
                define_preview = function(self, _, _)
                    if preview_content ~= nil and #preview_content > 0 then
                        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.split(preview_content, "\n"))
                    end
                end,
            }),
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(function()
                    local selection = action_state.get_selected_entry()
                    actions.close(prompt_bufnr)
                    on_select(selection.value)
                end)
                return true
            end,
        })
        :find()
end

local float = require("core.ui.float")

--- @param state State
M.draw_menu = function(state)
    if vim.g._user_ai_virtual_text_ns == nil then
        vim.g._user_ai_virtual_text_ns = vim.api.nvim_create_namespace("user_ai_virtual_text")
    end

    vim.api.nvim_buf_clear_namespace(state.menu.bufnr, vim.g._user_ai_virtual_text_ns, 0, -1)

    local lines = {}
    for _, action in ipairs(state.actions) do
        if not action.hidden then
            local line = { { action.key .. " - ", "Comment" }, { action.name, "AIActionsAction" } }
            table.insert(lines, line)
        end
    end
    table.insert(lines, {})
    table.insert(lines, { { "Contexts", "AIActionsHeader" } })

    for _, context in ipairs(state.contexts) do
        local meta = { "", "Comment" }
        if context.meta ~= nil then
            meta = context.meta(state)
        end
        local status_hg = "AIActionsInActiveContext"
        if context.active then
            status_hg = "AIActionsActiveContext"
        end
        table.insert(lines, {
            { context.key .. " - ", status_hg },
            { context.name .. "  ", status_hg },
            meta,
        })
    end

    vim.api.nvim_buf_set_extmark(state.menu.bufnr, vim.g._user_ai_virtual_text_ns, 0, 0, {
        virt_text = { { "AI Actions", "AIActionsHeader" } },
        virt_lines = lines,
        virt_text_pos = "eol",
    })
end

--- should open a window on the RHS with the AI options (actions + )
--- @param state State
M.open_menu = function(state)
    state.menu.bufnr = float.open(nil, {
        rel = "rhs",
        row = 3,
        width = 15,
        height = 28,
        enter = false,
        wo = { number = false, relativenumber = false },
    })
    M.draw_menu(state)
    state.menu.open = true
end

--- @param state State
--- @param ui string
M.draw = function(state, ui)
    M.draw_menu(state)
    if ui == "blocks_open" then
        M.draw_blocks_menu(state)
    elseif ui == "blocks_redraw" then
        M.draw_blocks_content(state)
    elseif ui == "doc_task" or ui == "doc_patterns" then
        M.draw_doc(state, ui)
    end
end

--- @param state State
--- @param ui string
M.draw_doc = function(state, ui)
    local title = ui == "doc_patterns" and "  Coding Patterns" or "  Task"
    local rel_path = ui == "doc_patterns" and state.patterns.file_path or state.task.file_path
    float.open(nil, {
        rel = "center",
        width = 0.8,
        height = 0.3,
        title = title,
        close_on_q = true,
        enter = true,
    })
    local path = git.root() .. "/" .. rel_path
    vim.cmd("edit" .. path)
end

--- @param state State
M.draw_blocks_content = function(state)
    local block = state.blocks.list[state.blocks.pos]
    local lines = vim.split(block.content, "\n")
    local preview = { "", string.format("```%s", block.extension) }
    for _, line in ipairs(lines) do
        table.insert(preview, line)
    end
    table.insert(preview, "```")
    vim.api.nvim_buf_set_lines(state.blocks.bufnr, 0, -1, false, preview)
    local hg = block.active and "DiagnosticOk" or "Comment"
    local symbol = block.active and "  " or "  "
    local ns = vim.api.nvim_create_namespace("user_ai_blocks_list")
    vim.api.nvim_buf_clear_namespace(state.blocks.bufnr, ns, 0, -1)
    vim.api.nvim_buf_set_extmark(state.blocks.bufnr, ns, 0, 0, {
        virt_text = {
            {
                string.rep(" ", 4) .. symbol .. block.path .. " " .. string.format(
                    "(%d/%d)",
                    state.blocks.pos,
                    #state.blocks.list
                ),
                hg,
            },
        },
        virt_text_pos = "overlay",
    })
end

--- @param state State
M.draw_blocks_menu = function(state)
    if #state.blocks.list == 0 or state.blocks.open then
        return
    end

    float.open(nil, {
        bufnr = state.blocks.bufnr,
        rel = "center",
        width = 0.8,
        height = 0.5,
        enter = true,
        bo = { filetype = "markdown" },
        wo = { number = false, relativenumber = false, conceallevel = 1 },
    })
    state.blocks.open = true

    M.draw_blocks_content(state)
end

local next_loader_id = 1

--- @param _start integer
--- @param _end integer
--- @param apply_ghost boolean
--- @return integer id
M.load_start = function(_start, _end, apply_ghost)
    local loader_id = next_loader_id
    next_loader_id = next_loader_id + 1
    local ns_id = vim.api.nvim_create_namespace("user_loader_vt_" .. loader_id)
    if not apply_ghost then
        vim.api.nvim_buf_set_extmark(0, ns_id, _start - 1, 0, {
            virt_text = { { string.rep(" ", 4), "Comment" }, { "  Thinking...", "DiagnosticOk" } },
            virt_text_pos = "eol",
        })
        return ns_id
    end

    local lines = vim.api.nvim_buf_get_lines(0, _start - 1, _end, false)
    for i, line in ipairs(lines) do
        vim.api.nvim_buf_set_extmark(0, ns_id, _start - 1 + i - 1, 0, {
            virt_text = (
                i == 1
                and { { line, "Comment" }, { string.rep(" ", 4), "Comment" }, { "  Thinking...", "DiagnosticOk" } }
            ) or { { line, "Comment" } },
            virt_text_pos = "overlay",
        })
    end
    return ns_id
end

--- @param ns_id integer namespace ID to clear for this loader
M.load_end = function(ns_id)
    vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
end

return M

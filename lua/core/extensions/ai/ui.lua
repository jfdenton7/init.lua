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

--- @param app App
--- @param keymap table<AIAction>
--- @param contexts table<Context>
M.draw_menu = function(app, keymap, contexts)
    if vim.g._user_ai_virtual_text_ns == nil then
        vim.g._user_ai_virtual_text_ns = vim.api.nvim_create_namespace("user_ai_virtual_text")
    end

    vim.api.nvim_buf_clear_namespace(app.menu_bufnr, vim.g._user_ai_virtual_text_ns, 0, -1)

    local lines = {}
    for _, action in ipairs(keymap) do
        local line = { { action.key .. " - ", "Comment" }, { action.name, "Special" } }
        table.insert(lines, line)
    end
    table.insert(lines, {})
    table.insert(lines, { { "Contexts", "Comment" } })

    for _, context in ipairs(contexts) do
        local line
        if context.active then
            line = {
                { context.key .. " - ", "Comment" },
                { context.name, "Special" },
                { " " .. context.meta(), "Comment" },
            }
        else
            line = {
                { context.key .. " - ", "Comment" },
                { context.name, "Comment" },
                { " " .. context.meta(), "Comment" },
            }
        end
        table.insert(lines, line)
    end

    vim.api.nvim_buf_set_extmark(app.menu_bufnr, vim.g._user_ai_virtual_text_ns, 0, 0, {
        virt_text = { { "AI Actions", "Comment" } },
        virt_lines = lines,
        virt_text_pos = "eol",
    })
end

--- should open a window on the RHS with the AI options (actions + )
--- @param app App
--- @param keymap table<AIAction>
--- @param contexts table<Context>
M.open_menu = function(app, keymap, contexts)
    app.menu_bufnr = float.open(nil, {
        rel = "rhs",
        row = 2,
        width = 21,
        height = 0.80,
        enter = false,
        wo = { number = false, relativenumber = false },
    })
    M.draw_menu(app, keymap, contexts)
end

local next_loader_id = 1

--- @param _start number
--- @param _end number
--- @param apply_ghost boolean
--- @return number id
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

--- @param ns_id number namespace ID to clear for this loader
M.load_end = function(ns_id)
    vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
end

return M

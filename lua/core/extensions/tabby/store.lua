local M = {}

--- @class tabby.State
--- @field content table<tabby.Content>
--- @field focused string printer currently in focus
--- @field tabbies table<tabby.Name, tabby.Cat> table of available printers

--- @alias tabby.Name "default"|"player"|"git"|"filepath"|"stats"|"pager"|"system"

--- @class tabby.Content
--- @field display table<table<string>>
--- @field split_next boolean

--- @class tabby.Cat
--- @field name tabby.Name
--- @field split boolean
--- @field focused fun(): table<table<string>>
--- @field default fun(): table<table<string>>

--- @return tabby.State
local default_state = function()
    return {
        content = {},
        focused = "default",
        tabbies = {},
    }
end

--- @type tabby.State
local state = default_state()

--- @return tabby.State
M.state = function()
    return state
end

---   adds a tabby.Printer to the list of printers
--- @param cat tabby.Cat
M.register_tabby = function(cat)
    table.insert(state.tabbies, cat)
end

--- @param name tabby.Name
M.focus_on = function(name)
    state.focused = name
end

--- @param t1 table
--- @param t2 table
--- @return table t3 which is made from merging t1 and t2 (not in-place)
local merge = function(t1, t2)
    local t3 = { unpack(t1) }
    for _, entry in ipairs(t2) do
        t3[#t3 + 1] = entry
    end
    return t3
end

--- update state
--- will run before ui.render
M.tick = function()
    if state.focused == "default" then
        local content = {}
        for _, cat in ipairs(state.tabbies) do
            table.insert(content, { display = cat.default(), split_next = cat.split })
        end
        state.content = content
    else
        local cat = state.tabbies[state.focused]
        state.content = { { display = cat.focused(), split_next = cat.split } }
    end
end

return M

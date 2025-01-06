local M = {}

--- @param state tabby.State
--- @return string
M.render = function(state)
    local winbar = ""
    for _, content in ipairs(state.content) do
        local segment = table.concat(
            vim.iter(content.display)
                :map(function(pair)
                    local display = type(pair[1]) == "function" and pair[1]() or pair[1]
                    return string.format("%%#%s#%s", pair[2], display)
                end)
                :totable(),
            ""
        )
        if content.split_next then
            winbar = winbar .. segment .. "%="
        else
            winbar = winbar .. segment .. " "
        end
    end

    return winbar
end

return M

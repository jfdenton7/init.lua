local M = {}

local store = require("core.extensions.tabby.store")

local CACHE_UPDATE_TIME = 90000
local cache = {
    battery_level = nil,
}
local valid = {
    battery_level = false,
}

--- @class tabby.BatteryStatus
--- @field condition integer
--- @field symbol string

local battery_levels = {
    { condition = 95, symbol = "󰁹" },
    { condition = 90, symbol = "󰂂" },
    { condition = 80, symbol = "󰂁" },
    { condition = 70, symbol = "󰂀" },
    { condition = 60, symbol = "󰁿" },
    { condition = 50, symbol = "󰁾" },
    { condition = 40, symbol = "󰁽" },
    { condition = 30, symbol = "󰁼" },
    { condition = 20, symbol = "󰁻" },
    { condition = 10, symbol = "󰁺" },
    { condition = 0, symbol = "󰂎" },
}

--- @return string
local battery = function()
    if cache.battery_level and valid.battery_level then
        return cache.battery_level
    end

    vim.system({ "pmset", "-g", "batt" }, { text = true }, function(cmd)
        local pattern = "%d%d?%d?%%" -- %d%d%d? matches 2 or 3 digits, %% matches the '%' character

        local segments = vim.split(cmd.stdout, " ", { trimempty = true })
        local percentage = ""
        for _, segment in ipairs(segments) do
            local start_pos, end_pos = string.find(segment, pattern)
            if start_pos and end_pos then
                percentage = string.sub(segment, start_pos, end_pos)
                percentage = string.sub(percentage, 1, #percentage - 1)
            end
        end
        if #percentage == 0 then
            cache.battery_level = "󰂑"
            valid.battery_level = true
            return
        end

        local remaining = tonumber(percentage)
        for _, level in ipairs(battery_levels) do
            if remaining >= level.condition then
                cache.battery_level = level.symbol
                valid.battery_level = true
                return
            end
        end
    end)

    return cache.battery_level or ""
end

local hours_minutes = function()
    local current_time = os.date("%H:%M")
    return tostring(current_time)
end

M.setup = function()
    store.register_tabby({
        name = "system",
        split = false,
        focused = function()
            return { { hours_minutes, "DiagnosticOk" }, { " ", "Comment" }, { battery, "DiagnosticOk" } }
        end,
        default = function()
            return { { hours_minutes, "DiagnosticOk" }, { " ", "Comment" }, { battery, "DiagnosticOk" } }
        end,
    })

    local timer = vim.uv.new_timer()
    timer:start(
        CACHE_UPDATE_TIME,
        CACHE_UPDATE_TIME,
        vim.schedule_wrap(function()
            valid.battery_level = false
        end)
    )
end

return M

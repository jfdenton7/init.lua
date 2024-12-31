--- @class App -- TODO: probably just rename "app" or something like that...
--- @field code_bufnr number
--- @field menu_bufnr number

local M = {}

--- @return App
M.new = function()
    return { code_bufnr = -1, menu_bufnr = -1 }
end

return M

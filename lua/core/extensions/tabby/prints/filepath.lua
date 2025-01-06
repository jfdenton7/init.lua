local M = {}

local store = require("core.extensions.tabby.store")

--- @return string
local file_path = function()
    local rel_path = vim.fn.expand("%:.")
    if #rel_path == 0 then
        return "scratch"
    end
    return rel_path
end

M.setup = function()
    store.register_tabby({
        name = "filepath",
        split = false,
        focused = function()
            return { { file_path, "Comment" } } -- content, hg-group
        end,
        default = function()
            return { { file_path, "Comment" } } -- content, hg-group
        end,
    })
end

return M

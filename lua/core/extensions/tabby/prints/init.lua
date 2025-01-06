local M = {}

M.setup = function()
    require("core.extensions.tabby.prints.git").setup()
    require("core.extensions.tabby.prints.filepath").setup()
    require("core.extensions.tabby.prints.pager").setup()
    require("core.extensions.tabby.prints.system").setup()
    -- require("core.extensions.tabby.prints.player").setup()
    -- require("core.extensions.tabby.prints.stats")
end

return M

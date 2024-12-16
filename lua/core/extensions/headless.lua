local M = {}

--- @param s string
M.copilot = function(s)
    local chat = require("CopilotChat")
    chat.ask(s, {
        headless = true,
        callback = function(response, _)
            vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(response, "\n"))
            vim.cmd("wq")
        end,
    })
end

return M

local M = {}

local buffer = require("core.editor.buffer")

M.selection_with_last_yank = function()
    local start_line, end_line = buffer.active_selection()
    local last_yank = vim.fn.getreg('"')
    local selected_lines = vim.fn.getline(start_line, end_line)
    local ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
    if type(selected_lines) == "string" then
        selected_lines = { selected_lines }
    end

    vim.cmd("tabnew")
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(bufnr)
    vim.cmd("vsplit")

    vim.api.nvim_buf_set_name(bufnr, "yank:" .. bufnr)
    vim.keymap.set("n", "q", function()
        vim.cmd("tabclose")
    end, { buffer = bufnr })
    vim.api.nvim_set_option_value("filetype", ft, { buf = bufnr })
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(last_yank, "\n"))
    vim.cmd("wincmd l")
    bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_set_option_value("filetype", ft, { buf = bufnr })
    vim.api.nvim_buf_set_lines(0, 0, -1, false, selected_lines)
    vim.api.nvim_buf_set_name(bufnr, "selection:" .. bufnr)
    vim.keymap.set("n", "q", function()
        vim.cmd("tabclose")
    end, { buffer = bufnr })
    vim.cmd("diffthis")
    vim.cmd("wincmd h")
    vim.cmd("diffthis")
end

return M

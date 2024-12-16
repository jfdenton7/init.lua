local M = {}

local style = require("core.ui.style")

--- @class PreviewOpts
--- @field rel ?"cursor" | "center"
--- @field cursor ?{row : integer, col: integer}
--- @field height ?integer uses % of screen size
--- @field width ?integer uses % of screen size
--- @field bo ?table<string, any>

--- @type PreviewOpts
local default_opts = {
    rel = "cursor",
    bo = {
        filetype = "markdown",
    },
    height = 0.30,
    width = 0.60,
}

local ABOVE_OFFSET = 2

--- @param content string
--- @param opts ?PreviewOpts
M.open_preview = function(content, opts)
    opts = opts or default_opts
    opts.height = opts.height or default_opts.height
    opts.width = opts.width or default_opts.width
    opts.rel = opts.rel or default_opts.rel
    opts.bo = opts.bo or default_opts.bo

    local win = vim.api.nvim_get_current_win()
    local bufnr = vim.api.nvim_create_buf(true, true)
    local win_width = vim.api.nvim_win_get_width(win)
    local win_height = vim.api.nvim_win_get_height(win)

    local width = math.floor(win_width * opts.width)
    local height = math.floor(win_height * opts.height)
    local row, col

    if opts.rel == "center" then
        row = (win_height - height) * 0.5 -- row is height
        col = (win_width - width) * 0.5 -- col is width
    elseif opts.rel == "cursor" then
        local pos = vim.fn.getpos(".")
        local win_size = vim.fn.winsaveview()
        row = math.max(pos[2] - win_size.topline - height - ABOVE_OFFSET, 1)
        col = pos[3]
        vim.print(row, col)
    end

    local float_win = vim.api.nvim_open_win(bufnr, true, {
        title = "Copilot",
        border = style.rounded_border(),
        relative = "win",
        win = win,
        row = row,
        col = col,
        height = height,
        width = width,
    })

    vim.api.nvim_set_current_win(float_win)

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(content, "\n"))
    for buf_opt, setting in pairs(opts.bo) do
        vim.api.nvim_set_option_value(buf_opt, setting, { buf = bufnr })
    end

    vim.keymap.set("n", "q", function()
        vim.api.nvim_buf_delete(bufnr, { force = true })
    end, { buffer = bufnr })
end

-- example usage
-- M.toggle_preview(
--     [[
-- local bufnr = vim.api.nvim_get_current_buf()
-- vim.api.nvim_buf_set_option(bufnr, 'filetype', 'lua')
-- ]],
--     { bo = { filetype = "lua", modifiable = false } }
-- )

return M

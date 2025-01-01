local M = {}

local style = require("core.ui.style")

--- @class FloatOpts
--- @field rel ?"cursor" | "center" | "rhs" | "lhs"
--- @field title ?string what to put as float title
--- @field enter ?boolean whether to enter float, defaults to true
--- @field bufnr ?integer buffer number
--- @field cursor ?{row : integer, col: integer}
--- @field height ?integer uses % of screen size
--- @field width ?integer uses % of screen size
--- @field row ?integer
--- @field col ?integer
--- @field bo ?table<string, any>
--- @field wo ?table<string, any>
--- @field close_on_q ?boolean

--- @type FloatOpts
local default_opts = {
    rel = "cursor",
    title = "",
    enter = true,
    bo = {
        filetype = "markdown",
    },
    wo = {},
    height = 0.30,
    width = 0.60,
    close_on_q = true,
}

local ABOVE_OFFSET = 2

--- @param content ?string
--- @param opts ?FloatOpts
M.open = function(content, opts)
    opts = opts or default_opts
    opts.height = opts.height or default_opts.height
    opts.width = opts.width or default_opts.width
    opts.rel = opts.rel or default_opts.rel
    opts.title = opts.title or default_opts.title
    if opts.enter == nil then
        opts.enter = default_opts.enter
    end
    if opts.close_on_q == nil then
        opts.close_on_q = default_opts.close_on_q
    end
    opts.bo = opts.bo or default_opts.bo
    opts.wo = opts.wo or default_opts.wo
    local bufnr = opts.bufnr or vim.api.nvim_create_buf(true, true)
    local win = vim.api.nvim_get_current_win()
    local win_width = vim.api.nvim_win_get_width(win)
    local win_height = vim.api.nvim_win_get_height(win)

    if opts.width <= 1 then
        opts.width = math.floor(win_width * opts.width)
    end
    if opts.height <= 1 then
        opts.height = math.floor(win_height * opts.height)
    end
    local row, col

    if opts.rel == "center" then
        row = (win_height - opts.height) * 0.5 -- row is height
        col = (win_width - opts.width) * 0.5 -- col is width
    elseif opts.rel == "cursor" then
        local pos = vim.fn.getpos(".")
        local win_size = vim.fn.winsaveview()
        row = math.max(pos[2] - win_size.topline - opts.height - ABOVE_OFFSET, 1)
        col = pos[3]
    elseif opts.rel == "rhs" then
        row = 0
        col = vim.api.nvim_win_get_width(0) -- 0 refers to the current window
    elseif opts.rel == "lhs" then
        row = 0
        col = 0
    end

    if opts.row ~= nil then
        row = opts.row
    end
    if opts.col ~= nil then
        row = opts.col
    end

    local float_win = vim.api.nvim_open_win(bufnr, opts.enter, {
        title = opts.title,
        border = style.rounded_border(),
        relative = "win",
        win = win,
        row = row,
        col = col,
        height = opts.height,
        width = opts.width,
    })

    if content ~= nil and #content > 0 then
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(content, "\n"))
    end

    for buf_opt, setting in pairs(opts.bo) do
        vim.api.nvim_set_option_value(buf_opt, setting, { buf = bufnr })
    end

    for wo_opt, setting in pairs(opts.wo) do
        vim.api.nvim_set_option_value(wo_opt, setting, { win = float_win })
    end

    if opts.close_on_q then
        vim.keymap.set("n", "q", function()
            vim.api.nvim_buf_delete(bufnr, { force = true })
        end, { buffer = bufnr })
    end

    return bufnr
end

-- local bufnr = M.open_float("test test", { rel = "rhs", width = 0.25, height = 1, enter = false })
-- vim.keymap.set("n", ",q", function()
--     if vim.api.nvim_buf_is_valid(bufnr) then
--         vim.api.nvim_buf_delete(bufnr, { force = true })
--     end
-- end)

-- example usage
-- M.toggle_preview(
--     [[
-- local bufnr = vim.api.nvim_get_current_buf()
-- vim.api.nvim_buf_set_option(bufnr, 'filetype', 'lua')
-- ]],
--     { bo = { filetype = "lua", modifiable = false } }
-- )

return M

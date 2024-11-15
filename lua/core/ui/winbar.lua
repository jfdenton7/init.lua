local M = {}

local symbols = require("core.ui.symbols").winbar()

-- credit to https://github.com/MariaSolOs/dotfiles/blob/mac/.config/nvim/lua/winbar.lua

local function tab_position()
    local active_tabpage = vim.api.nvim_tabpage_get_number(0)
    local total_tabpages = #vim.api.nvim_list_tabpages()
    return string.format("(%d/%d)", active_tabpage, total_tabpages)
end

---@return string
M.render = function()
    if vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()) == "" then
        return table.concat({
            " ",
            "%=",
            string.format("%%#WinBarSep#%s", tab_position()),
        })
    end

    local path = vim.fs.normalize(vim.fn.expand("%:p"))
    local prefix, prefix_path = "", ""
    local separator = string.format("%%#WinBarSep#%s", symbols.Separator)

    if vim.api.nvim_win_get_width(0) < math.floor(vim.o.columns / 3) then
        vim.fn.pathshorten(path)
    else
        local special_dirs = {
            HOME = vim.env.HOME,
            NOTES = vim.g.notes_dir,
            WORK = vim.g.work_dir,
            TOOLS = vim.g.tools_dir,
            LEARN = vim.g.learning_dir,
        }
        for dir_name, dir_path in pairs(special_dirs) do
            if vim.startswith(path, vim.fs.normalize(dir_path)) and #dir_path > #prefix_path then
                prefix, prefix_path = dir_name, dir_path
            end
        end

        if prefix ~= "" then
            path = path:gsub("^" .. prefix_path, "")
            prefix = string.format("%%#WinBarRoot#%s %s%s", symbols.Folder, prefix, separator)
        end
    end

    path = path:gsub("^/", "")

    return table.concat({
        " ",
        -- prefix,
        -- table.concat(
        --     vim.iter(vim.split(path, "/"))
        --         :map(function(segment)
        --             return string.format("%%#WinBar#%s", segment)
        --         end)
        --         :totable(),
        --     separator
        -- ),
        "%=",
        string.format("%%#WinBarSep#%s", tab_position()),
    })
end

M.setup = function()
    -- NOTE: disabled for now, using mini
    -- vim.o.showtabline = 0
    -- vim.api.nvim_create_autocmd({ "VimEnter", "BufWinEnter" }, {
    --     group = vim.api.nvim_create_augroup("user/winbar", { clear = true }),
    --     desc = "Attach winbar",
    --     callback = function(args)
    --         if
    --             not vim.api.nvim_win_get_config(0).zindex -- Not a floating window
    --             and vim.bo[args.buf].buftype == "" -- Normal buffer
    --             -- and vim.api.nvim_buf_get_name(args.buf) ~= "" -- Has a file name
    --             and not vim.wo[0].diff -- Not in diff mode
    --         then
    --             vim.wo.winbar = "%{%v:lua.require'core.ui.winbar'.render()%}"
    --         end
    --     end,
    -- })
end

return M

local M = {}

--- @class FoldOptions
--- @field foldminlines integer
--- @field fillchars string
--- @field foldtext string
--- @field foldmethod string
local FoldOptions = {}

--- @type FoldOptions | nil
local user_fold_options = nil
local manual_mode_fold_options = {
    foldminlines = 0,
    fillchars = (vim.o.fillchars ~= "" and vim.o.fillchars .. "," or "") .. "fold: ",
    foldtext = 'v:lua.require("core.extensions.folds.ui").custom_folds_style()',
    foldmethod = "manual",
}

local save_user_fold_options = function()
    user_fold_options = {
        foldminlines = vim.wo.foldminlines,
        fillchars = vim.wo.fillchars,
        foldtext = vim.wo.foldtext,
        foldmethod = vim.wo.foldmethod,
    }
end

--- @alias FoldMode "user" | "manual"

--- @param mode FoldMode
M.set_fold_options = function(mode)
    local fo
    if mode == "user" and user_fold_options ~= nil then
        fo = user_fold_options
    elseif mode == "manual" then
        fo = manual_mode_fold_options
        save_user_fold_options()
    else
        return
    end

    vim.wo.foldminlines = fo.foldminlines
    vim.wo.fillchars = fo.fillchars
    vim.wo.foldtext = fo.foldtext
    vim.wo.foldmethod = fo.foldmethod
end

return M

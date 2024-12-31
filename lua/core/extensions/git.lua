local M = {}

M.setup = function()
    vim.keymap.set("n", "<leader>goc", function()
        local commit_hash = vim.fn.expand("<cword>")
        vim.fn.system(string.format("gh browse %s", commit_hash))
    end, { desc = "git browse commit hash" })

    vim.keymap.set("n", "<leader>gof", function()
        local file_name = vim.fn.expand("%:.")
        vim.fn.system(string.format("gh browse %s", file_name))
    end, { desc = "git browse file" })
end

M.branch_name = function()
    local branch = vim.fn.system("git branch --show-current 2> /dev/null | tr -d '\n'")
    if branch ~= "" then
        return branch
    else
        return ""
    end
end

--- @return string path to git root
M.root = function()
    local job = vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true }):wait()
    return vim.trim(job.stdout)
end

--- @param staged ?boolean
--- @return string
M.diffs = function(staged)
    local job
    if staged then
        job = vim.system({ "git", "diff", "--cached" }, { text = true }):wait()
    else
        job = vim.system({ "git", "diff" }, { text = true }):wait()
    end
    return job.stdout
end

return M

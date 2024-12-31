local M = {}

--- reads file and returns content, error
---
--- @param file_path string
--- @return string|nil,string|nil
--- @usage
--- local content, err = M.read_file("~/Documents/test.txt")
--- if content ~= nil then
---     vim.print(content)
--- else
---     vim.print(err)
--- end
---
M.read = function(file_path)
    file_path = vim.fn.expand(file_path)
    local file = io.open(file_path, "r")
    if not file then
        return nil, "error: could not open file: " .. file_path
    end

    local content = file:read("*all")
    file:close()
    return content, nil
end

--- @param path string
--- @param content string what we write to the file
--- @return string|nil error description of what went wrong
M.write = function(path, content)
    local file = io.open(path, "w")
    if file then
        file:write(content)
        file:close()
    else
        return "error: could not open file " .. path
    end
end

return M

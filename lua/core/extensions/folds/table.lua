local M = {}

--- @param t1 table
--- @param t2 table
--- @return table t3 which is made from merging t1 and t2 (not in-place)
M.merge = function(t1, t2)
    local t3 = { unpack(t1) }
    for _, entry in ipairs(t2) do
        t3[#t3 + 1] = entry
    end
    return t3
end

return M

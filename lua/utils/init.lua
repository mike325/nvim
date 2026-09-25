local M = {}

require 'globals'

setmetatable(M, {
    __index = function(self, k)
        local mt = getmetatable(self)
        if mt[k] then
            return mt[k]
        end

        local ok, x = pcall(require, 'utils.' .. k)
        if not ok then
            error('Missing utils module ' .. k .. ' Error: ' .. x)
            x = nil
        end

        return x
    end,
})

return M

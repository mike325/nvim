-- luacheck: globals unpack vim
-- local api = vim.api
local strmeta = getmetatable( "" )

-- Magic methods

strmeta.__add = function( a, b )
    return a .. b
end

strmeta.__mul = function( a, b )
    if type(b) == 'number' then
        local rsp = ''
        for i=1,b do
            rsp = rsp .. a
        end
        return rsp
    end
    return nil
end

strmeta.__mod = function( a, b )
    if type( b ) == "table" then
        return string.format( a, unpack( b ) )
    end
    return string.format( a, b )
end

strmeta.__index = function( a, b )
    if type(b) == 'number' then
        return b > #a and nil or string.sub( a, b, b )
    end
    return string[b]
end

-- custom functions
-- FIXME
-- function string:split(separator)
--     local fields = {}
--     local pattern = string.format("([^%s]+)", separator)
--     self:gsub(pattern, function(c) fields[#fields+1] = c end)
--     return fields
-- end
--
-- function string:capitalize()
--     for name,val in pairs(self) do
--         print(name, val)
--     end
--     return string:gsub(self, "^%l", string.upper)
-- end
--
-- function string:join(iter)
--     return type(iter) == 'table' and table.concat(iter, self) or error('Join operate only with tables')
-- end

return strmeta

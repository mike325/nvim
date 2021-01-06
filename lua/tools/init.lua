_G['tools']  = setmetatable({}, {
    __index = function(self, k)
        local ok
        local mt = getmetatable(self)

        local x = mt[k]
        if x ~= nil then
            return x
        end

        ok, x = pcall(require, 'tools.'..k)

        if not ok then
            error('Missing tools module '..k..' Error: '..x)
            x = nil
        else
            mt[k] = x
        end

        return x
    end
})

return _G['tools']

_G['tools']  = setmetatable({}, {
    __index = function(self, k)
        local mt = getmetatable(self)

        local x = mt[k]
        if x ~= nil then
            return x
        end

        local ok, x = pcall(require, 'tools.'..k)

        if not ok then
            x = nil
            error('Missing tools module '..k)
        else
            mt[k] = x
        end

        return x
    end
})

return _G['tools']

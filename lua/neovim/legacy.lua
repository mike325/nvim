local api = vim.api

local M = {}

M.fn = setmetatable({}, {
    __index = function(self, k)
        local mt = getmetatable(self)
        local x = mt[k]
        if x ~= nil then
            return x
        end
        local f = function(...)
            return api.nvim_call_function(k, { ... })
        end
        mt[k] = f
        return f
    end,
})

M.g = setmetatable({}, {
    __index = function(_, k)
        local ok, value = pcall(api.nvim_get_var, k)
        return ok and value or nil
    end,
    __newindex = function(_, k, v)
        if v == nil then
            return api.nvim_del_var(k)
        else
            return api.nvim_set_var(k, v)
        end
    end,
})

M.b = setmetatable({}, {
    __index = function(_, k)
        local ok, value = pcall(api.nvim_buf_get_var, 0, k)
        return ok and value or nil
    end,
    __newindex = function(_, k, v)
        if v == nil then
            return api.nvim_buf_del_var(0, k)
        else
            return api.nvim_buf_set_var(0, k, v)
        end
    end,
})

M.w = setmetatable({}, {
    __index = function(_, k)
        local ok, value = pcall(api.nvim_win_get_var, 0, k)
        return ok and value or nil
    end,
    __newindex = function(_, k, v)
        if v == nil then
            return api.nvim_win_del_var(0, k)
        else
            return api.nvim_win_set_var(0, k, v)
        end
    end,
})

M.t = setmetatable({}, {
    __index = function(_, k)
        local ok, value = pcall(api.nvim_tabpage_get_var, 0, k)
        return ok and value or nil
    end,
    __newindex = function(_, k, v)
        if v == nil then
            return api.nvim_tabpage_del_var(0, k)
        else
            return api.nvim_tabpage_set_var(0, k, v)
        end
    end,
})

M.v = setmetatable({}, {
    __index = function(_, k)
        local ok, value = pcall(api.nvim_get_vvar, k)
        return ok and value or nil
    end,
    __newindex = function(_, k, v)
        return api.nvim_set_vvar(k, v)
    end,
})

M.o = setmetatable({}, {
    __index = function(_, k)
        return api.nvim_get_option(k)
    end,
    __newindex = function(_, k, v)
        return api.nvim_set_option(k, v)
    end,
})

M.bo = setmetatable({}, {
    __index = function(_, k)
        return api.nvim_buf_get_option(0, k)
    end,
    __newindex = function(_, k, v)
        return api.nvim_buf_set_option(0, k, v)
    end,
})

M.wo = setmetatable({}, {
    __index = function(_, k)
        return api.nvim_win_get_option(0, k)
    end,
    __newindex = function(_, k, v)
        return api.nvim_win_set_option(0, k, v)
    end,
})

M.opt = setmetatable({}, {
    __index = function(_, k)
        local ok, g = pcall(api.nvim_get_option, k)
        local l = M.bo[k] or M.wo[k]
        return ok and l or g
    end,
    __newindex = function(_, k, v)
        if M.o[k] then
            M.o[k] = v
        end
        if M.bo[k] ~= nil then
            M.bo[k] = v
        elseif M.wo[k] ~= nil then
            M.wo[k] = v
        end
        return M.o[k] ~= nil and M.o[k] or (M.bo[k] ~= nil and M.bo[k] or M.wo[k])
    end,
})

M.opt_local = setmetatable({}, {
    __index = function(_, k)
        return M.bo[k] or M.wo[k]
    end,
    __newindex = function(_, k, v)
        if M.bo[k] ~= nil then
            M.bo[k] = v
        elseif M.wo[k] ~= nil then
            M.wo[k] = v
        end
        return M.bo[k] ~= nil and M.bo[k] or M.wo[k]
    end,
})

M.opt_global = setmetatable({}, {
    __index = function(_, k)
        return M.o[k]
    end,
    __newindex = function(_, k, v)
        M.o[k] = v
        return M.o[k]
    end,
})

return M

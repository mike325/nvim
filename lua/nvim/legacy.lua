local api = vim.api

local M = {}

-- if api.nvim_call_function('has', {'nvim-0.5'}) == 0  then
M.fn = setmetatable({}, {
    __index = function(self, k)
        local mt = getmetatable(self)
        local x = mt[k]
        if x ~= nil then
            return x
        end
        local f = function(...) return api.nvim_call_function(k, {...}) end
        mt[k] = f
        return f
    end
})

M.g = setmetatable({}, {
    __index = function(_, k)
        local ok, value = pcall(api.nvim_get_var, k)
        return ok and value or nil
    end;
    __newindex = function(_, k, v)
        if v == nil then
            return api.nvim_del_var(k)
        else
            return api.nvim_set_var(k, v)
        end
    end;
})

M.b = setmetatable({}, {
    __index = function(_, k)
        local ok, value = pcall(api.nvim_buf_get_var, 0, k)
        return ok and value or nil
    end;
    __newindex = function(_, k, v)
        if v == nil then
            return api.nvim_buf_del_var(0, k)
        else
            return api.nvim_buf_set_var(0, k, v)
        end
    end
})

M.w = setmetatable({}, {
    __index = function(_, k)
        local ok, value = pcall(api.nvim_win_get_var, 0, k)
        return ok and value or nil
    end;
    __newindex = function(_, k, v)
        if v == nil then
            return api.nvim_win_del_var(0, k)
        else
            return api.nvim_win_set_var(0, k, v)
        end
    end
})

M.t = setmetatable({}, {
    __index = function(_, k)
        local ok, value = pcall(api.nvim_tabpage_get_var, 0, k)
        return ok and value or nil
    end;
    __newindex = function(_, k, v)
        if v == nil then
            return api.nvim_tabpage_del_var(0, k)
        else
            return api.nvim_tabpage_set_var(0, k, v)
        end
    end
})

M.v = setmetatable({}, {
    __index = function(_, k)
        local ok, value = pcall(api.nvim_get_vvar, k)
        return ok and value or nil
    end;
    __newindex = function(_, k, v)
        return api.nvim_set_vvar(k, v)
    end
})

M.o = setmetatable({}, {
    __index = function(_, k)
        return api.nvim_get_option(k)
    end;
    __newindex = function(_, k, v)
        return api.nvim_set_option(k, v)
    end
})

M.bo = setmetatable({}, {
    __index = function(_, k)
        return api.nvim_buf_get_option(0, k)
    end;
    __newindex = function(_, k, v)
        return api.nvim_buf_set_option(0, k, v)
    end
})

M.wo = setmetatable({}, {
    __index = function(_, k)
        return api.nvim_win_get_option(0, k)
    end;
    __newindex = function(_, k, v)
        return api.nvim_win_set_option(0, k, v)
    end
})

-- end

return M

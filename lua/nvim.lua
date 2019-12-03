-- luacheck: globals unpack vim
local nvim = {}
local api = vim.api

-- Took from https://github.com/norcalli/nvim_utils
-- GPL3 apply to the nvim object
nvim = setmetatable({
    l = api.loop;
    has_version = function(version) api.nvim_call_function('has', {'nvim-'..version}) end;
    fn = setmetatable({}, {
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
    });
    buf = setmetatable({}, {
        __index = function(self, k)
        local mt = getmetatable(self)
        local x = mt[k]
        if x ~= nil then
            return x
        end
                local f = api['nvim_buf_'..k]
        mt[k] = f
        return f
        end
    });
    ex = setmetatable({}, {
        __index = function(self, k)
        local mt = getmetatable(self)
        local x = mt[k]
        if x ~= nil then
            return x
        end
        local command = k:gsub("_$", "!")
        local f = function(...)
            return api.nvim_command(table.concat(vim.tbl_flatten {command, ...}, " "))
        end
        mt[k] = f
        return f
        end
    });
    g = setmetatable({}, {
        __index = function(_, k)
            local ok, value pcall(api.nvim_get_var, k)
            return ok and value or nil
        end;
        __newindex = function(_, k, v)
            if v == nil then
                return api.nvim_del_var(k)
            else
                return api.nvim_set_var(k, v)
            end
        end;
    });
    v = setmetatable({}, {
        __index = function(_, k)
            local ok, value pcall(api.nvim_get_vvar, k)
            return ok and value or nil
        end;
        __newindex = function(_, k, v)
            return api.nvim_set_vvar(k, v)
        end
    });
    b = setmetatable({}, {
        __index = function(_, k)
            local ok, value pcall(api.nvim_buf_get_var, 0, k)
            return ok and value or nil
        end;
        __newindex = function(_, k, v)
            if v == nil then
                return api.nvim_buf_del_var(0, k)
            else
                return api.nvim_buf_set_var(0, k, v)
            end
        end
    });
    o = setmetatable({}, {
        __index = function(_, k)
            return api.nvim_get_option(k)
        end;
        __newindex = function(_, k, v)
            return api.nvim_set_option(k, v)
        end
    });
    bo = setmetatable({}, {
        __index = function(_, k)
            return api.nvim_buf_get_option(0, k)
        end;
        __newindex = function(_, k, v)
            return api.nvim_buf_set_option(0, k, v)
        end
    });
    env = setmetatable({}, {
        __index = function(_, k)
            local ok, value pcall(api.nvim_call_function, 'getenv', {k})
            return ok and value or nil
        end;
        __newindex = function(_, k, v)
            return api.nvim_call_function('setenv', {k, v})
        end
    });
}, {
  __index = function(self, k)
    local mt = getmetatable(self)
    local x = mt[k]
    if x ~= nil then
      return x
    end
    local f = api['nvim_'..k]
    mt[k] = f
    return f
  end
})

nvim.option = nvim.o

return nvim

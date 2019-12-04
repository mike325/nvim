-- luacheck: globals unpack vim
local nvim = {}
local api = vim.api

local function nvim_get_mapping(m, lhs, ...)
    local mappings
    local mapping

    local opts = ...

    local modes = {
        normal = 'n',
        insert = 'i',
        visual = 'v',
        select  = 's',
        command = 'c',
        terminal = 't',
    }

    local mode = modes[m] ~= nil and modes[m] or m

    if opts['buffer'] ~= nil and opts['buffer'] == true then
        mappings = vim.api.nvim_buf_get_keymap(mode)
    else
        mappings = vim.api.nvim_get_keymap(mode)
    end

    for _,map in pairs(mappings) do
        if map['lhs'] == lhs then
            mapping = map['rhs']
            break
        end
    end

    return mapping

end

local function nvim_set_mapping(m, lhs, rhs, ...)
    local opts = ...

    local modes = {
        normal = 'n',
        insert = 'i',
        visual = 'v',
        select  = 's',
        command = 'c',
        terminal = 't',
    }

    local mode = modes[m] ~= nil and modes[m] or m

    if opts['buffer'] ~= nil and opts['buffer'] == true then
        opts['buffer'] = nil

        if rhs ~= nil then
            vim.api.nvim_buf_set_keymap(0, mode, lhs, rhs, opts)
        else
            vim.api.nvim_buf_del_keymap(0, mode, lhs)
        end
    else
        if rhs ~= nil then
            vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
        else
            vim.api.nvim_del_keymap(mode, lhs)
        end
    end

end

-- Took from https://github.com/norcalli/nvim_utils
-- GPL3 apply to the nvim object
nvim = setmetatable({
    l = api.loop;
    nvim_get_mapping = nvim_get_mapping;
    nvim_set_mapping = nvim_set_mapping;
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

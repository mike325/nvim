-- luacheck: globals unpack vim
-- local i = vim.inspect
local api = vim.api

-- Took from https://github.com/norcalli/nvim_utils
-- GPL3 apply to the nvim object
local nvim = {
    plugins = setmetatable({}, {
        __index = function(self, k)
            local mt = getmetatable(self)
            local x = mt[k]
            if x ~= nil then
                return x
            end
            local ok, plugs = pcall(api.nvim_get_var, 'plugs')
            if ok then
                local plugin = plugs[k]
                mt[k] = plugin
                return plugin
            end
            return nil
        end
    });
    has = setmetatable({
            cmd = function(cmd)
                return api.nvim_call_function('exists', {':'..cmd}) == 1
            end;
            command = function(command)
                return api.nvim_call_function('exists', {'##'..command}) == 1
            end;
            augroup = function(augroup)
                return api.nvim_call_function('exists', {'#'..augroup}) == 1
            end;
            option = function(option)
                return api.nvim_call_function('exists', {'+'..option}) == 1
            end;
            func = function(func)
                return api.nvim_call_function('exists', {'*'..func}) == 1
            end;
        },{
            __call = function(_, feature)
                return api.nvim_call_function('has', {feature}) == 1
            end;
        }
    );
    exists = setmetatable({
            cmd = function(cmd)
                return api.nvim_call_function('exists', {':'..cmd}) == 1
            end;
            command = function(command)
                return api.nvim_call_function('exists', {'##'..command}) == 1
            end;
            augroup = function(augroup)
                return api.nvim_call_function('exists', {'#'..augroup}) == 1
            end;
            option = function(option)
                return api.nvim_call_function('exists', {'+'..option}) == 1
            end;
            func = function(func)
                return api.nvim_call_function('exists', {'*'..func}) == 1
            end;
        },{
            __call = function(_, feature)
                return api.nvim_call_function('exists', {feature}) == 1
            end;
        }
    );
    env = setmetatable({}, {
        __index = function(_, k)
            local ok, value = pcall(api.nvim_call_function, 'getenv', {k})
            if not ok then
                value = api.nvim_call_function('expand', {'$'..k})
                value = value == k and nil or value
            end
            return value or nil
        end;
        __newindex = function(_, k, v)
            local ok, _ = pcall(api.nvim_call_function, 'setenv', {k, v})
            if not ok then
                v = type(v) == 'string' and '"'..v..'"' or v
                local _ = api.nvim_eval('let $'..k..' = '..v)
            end
        end
    });
    -- TODO: Replace this with vim.cmd
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
    win = setmetatable({}, {
        __index = function(self, k)
            local mt = getmetatable(self)
            local x = mt[k]
            if x ~= nil then
                return x
            end
            local f = api['nvim_win_'..k]
            mt[k] = f
            return f
        end
    });
    tab = setmetatable({}, {
        __index = function(self, k)
            local mt = getmetatable(self)
            local x = mt[k]
            if x ~= nil then
                return x
            end
            local f = api['nvim_tabpage_'..k]
            mt[k] = f
            return f
        end
    });
}

setmetatable(nvim, {
    __index = function(self, k)
        local ok

        local mt = getmetatable(self)
        local x = mt[k]
        if x ~= nil then
            return x
        end

        ok, x = pcall(require, 'nvim.'..k)

        if not ok then
            x = api['nvim_'..k]
            if x ~= nil then
                mt[k] = x
            else
                -- Used to access vim's g, b, o, bo, wo, fn, etc interfaces
                x = vim[k]
                mt[k] = x
            end
        end

        return x
    end
})

if api.nvim_call_function('has', {'nvim-0.5'}) == 0  then
    local legacy = require'nvim.legacy'
    for obj,val in pairs(legacy) do
        nvim[obj] = val
    end
end

return nvim

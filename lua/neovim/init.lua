local api = vim.api

require 'globals'

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
            if plugs[k] then
                mt[k] = plugs[k]
                return plugs[k]
            end

            if not ok and packer_plugins then
                plugs = packer_plugins
                if plugs[k] and plugs[k].loaded then
                    return plugs[k]
                end
            end

            return nil
        end,
    }),
    has = setmetatable({
        cmd = function(cmd)
            return api.nvim_call_function('exists', { ':' .. cmd }) == 2
        end,
        command = function(command)
            return api.nvim_call_function('exists', { '##' .. command }) == 2
        end,
        augroup = function(augroup)
            return api.nvim_call_function('exists', { '#' .. augroup }) == 1
        end,
        option = function(option)
            return api.nvim_call_function('exists', { '+' .. option }) == 1
        end,
        func = function(func)
            return api.nvim_call_function('exists', { '*' .. func }) == 1
        end,
    }, {
        __call = function(_, feature)
            if type(feature) == type {} then
                vim.validate {
                    version = { feature, vim.tbl_islist, 'a nvim version string to list' },
                }
                local nvim_version = {
                    vim.version().major,
                    vim.version().minor,
                    vim.version().patch,
                }
                return require('storage').check_version(nvim_version, feature)
            end
            return api.nvim_call_function('has', { feature }) == 1
        end,
    }),
    exists = setmetatable({
        cmd = function(cmd)
            return api.nvim_call_function('exists', { ':' .. cmd }) == 2
        end,
        command = function(command)
            return api.nvim_call_function('exists', { '##' .. command }) == 2
        end,
        augroup = function(augroup)
            return api.nvim_call_function('exists', { '#' .. augroup }) == 1
        end,
        option = function(option)
            return api.nvim_call_function('exists', { '+' .. option }) == 1
        end,
        func = function(func)
            return api.nvim_call_function('exists', { '*' .. func }) == 1
        end,
    }, {
        __call = function(_, feature)
            return api.nvim_call_function('exists', { feature }) == 1
        end,
    }),
    env = setmetatable({}, {
        __index = function(_, k)
            local ok, value = pcall(api.nvim_call_function, 'getenv', { k })
            if not ok then
                value = api.nvim_call_function('expand', { '$' .. k })
                value = value == k and nil or value
            end
            return value or nil
        end,
        __newindex = function(_, k, v)
            local ok, _ = pcall(api.nvim_call_function, 'setenv', { k, v })
            if not ok then
                v = type(v) == 'string' and '"' .. v .. '"' or v
                local _ = api.nvim_eval('let $' .. k .. ' = ' .. v)
            end
        end,
    }),
    ex = setmetatable({}, {
        __index = function(self, k)
            local mt = getmetatable(self)
            local x = mt[k]
            if x ~= nil then
                return x
            end
            local command = k:gsub('_$', '!')
            local f = function(...)
                return api.nvim_command(table.concat(vim.tbl_flatten { command, ... }, ' '))
            end
            mt[k] = f
            return f
        end,
    }),
    buf = setmetatable({}, {
        __index = function(self, k)
            local mt = getmetatable(self)
            local x = mt[k]
            if x ~= nil then
                return x
            end
            local f = api['nvim_buf_' .. k]
            mt[k] = f
            return f
        end,
    }),
    win = setmetatable({}, {
        __index = function(self, k)
            local mt = getmetatable(self)
            local x = mt[k]
            if x ~= nil then
                return x
            end
            local f = api['nvim_win_' .. k]
            mt[k] = f
            return f
        end,
    }),
    tab = setmetatable({}, {
        __index = function(self, k)
            local mt = getmetatable(self)
            local x = mt[k]
            if x ~= nil then
                return x
            end
            local f = api['nvim_tabpage_' .. k]
            mt[k] = f
            return f
        end,
    }),
    reg = setmetatable({}, {
        __index = function(_, k)
            local ok, value = pcall(api.nvim_call_function, 'getreg', { k })
            return ok and value or nil
        end,
        __newindex = function(_, k, v)
            if v == nil then
                error "Can't clear registers"
            end
            pcall(api.nvim_call_function, 'setreg', { k, v })
        end,
    }),
    keymap = require('neovim.mappings').keymap,
    executable = function(exe)
        vim.validate { exe = { exe, 'string' } }
        return vim.fn.executable(exe) == 1
    end,
}

setmetatable(nvim, {
    __index = function(self, k)
        local mt = getmetatable(self)
        if mt[k] then
            return mt[k]
        end

        local ok, x = pcall(RELOAD, 'neovim.' .. k)

        if not ok then
            x = api['nvim_' .. k]
            if not x then
                x = vim[k]
            end
        end

        return x
    end,
})

if api.nvim_call_function('has', { 'nvim-0.5' }) == 0 then
    local legacy = require 'neovim.legacy'
    for obj, val in pairs(legacy) do
        nvim[obj] = val
    end
end

return nvim

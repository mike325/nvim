local api = vim.api

require 'globals'

local function get_autocmd(opts)
    vim.validate {
        opts = { opts, 'table', true },
    }
    opts = opts or {}

    local ok, autocmds = pcall(api.nvim_get_autocmds, opts)
    if not ok then
        autocmds = {}
    end
    return autocmds
end

local function get_augroup(name_id)
    vim.validate {
        name_id = {
            name_id,
            function(n)
                return type(n) == type '' or type(n) == type(0)
            end,
            'Augroup name string or id number',
        },
    }
    return get_autocmd { group = name_id }
end

local function get_augroup_id(name)
    local groups = get_augroup(name)
    if #groups > 0 then
        return groups[1].group
    end
    return -1
end

-- local function get_augroup_name(id)
--     local groups = get_augroup(id)
--     if #groups > 0 then
--         return
--     end
-- end

local function add_augroup(name, clear)
    vim.validate {
        name = { name, 'string' },
        clear = { clear, 'boolean', true },
    }

    local groups = get_augroup(name)
    if #groups == 0 or clear then
        return api.nvim_create_augroup(name, { clear = clear == true })
    end
    return groups[1].group
end

local function clear_augroup(name)
    vim.validate {
        name = { name, 'string' },
    }
    api.nvim_create_augroup(name, { clear = true })
end

local function del_augroup(name_id)
    vim.validate {
        name_id = {
            name_id,
            function(n)
                return type(n) == type '' or type(n) == type(0)
            end,
            'Augroup name string or id number',
        },
    }

    local api_call = type(name_id) == type '' and api.nvim_del_augroup_by_name or api.nvim_del_augroup_by_id
    pcall(api_call, name_id)
    -- local ok, _ = pcall(api_call, name_id)
    -- NOTE: May disable notifications and do a silent fail
    -- if not ok then
    --     vim.notify(('Augroup %s does not exists'):format(name_id), 'WARN', { title = 'Augroup delete' })
    -- end
end

local function add_autocmd(event, opts)
    vim.validate {
        opts = { opts, 'table', true },
        event = {
            event,
            function(e)
                return type(e) == type '' or vim.tbl_islist(e)
            end,
            'an array of events or a event string',
        },
    }

    local clear = opts.clear
    opts.clear = nil

    if opts.group then
        add_augroup(opts.group)
    end

    if clear and opts.group then
        clear_augroup(opts.group)
    end

    return api.nvim_create_autocmd(event, opts)
end

local function add_command(name, cmd, opts)
    vim.validate {
        name = { name, 'string' },
        cmd = {
            cmd,
            function(c)
                return type(c) == type '' or vim.is_callable(c)
            end,
            'a string or a lua function',
        },
        opts = { opts, 'table', true },
    }
    opts = opts or {}
    if opts.buffer then
        local buffer = type(opts.buffer) == type(0) and opts.buffer or 0
        opts.buffer = nil
        api.nvim_buf_create_user_command(buffer, name, cmd, opts)
    else
        api.nvim_create_user_command(name, cmd, opts)
    end
end

local function del_command(name, buffer)
    vim.validate {
        name = { name, 'string' },
        buffer = {
            buffer,
            function(b)
                return type(b) == type(true) or type(b) == type(0)
            end,
            'a boolean or a number',
        },
    }
    if buffer then
        buffer = type(buffer) == type(0) and buffer or 0
        api.nvim_buf_del_user_command(buffer, name)
    else
        api.nvim_del_user_command(name)
    end
end

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
        command = function(command)
            return api.nvim_call_function('exists', { ':' .. command }) == 2
        end,
        event = function(event)
            return api.nvim_call_function('exists', { '##' .. event }) == 2
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
    command = {
        set = add_command,
        del = del_command,
    },
    augroup = setmetatable({
        add = add_augroup,
        del = del_augroup,
        get = get_augroup,
        get_id = get_augroup_id,
        clear = clear_augroup,
    }, {
        __index = function(self, k)
            local mt = getmetatable(self)
            local x = mt[k]
            if x ~= nil then
                return x
            end
            local cmds = get_augroup(k)
            return #cmds > 0 and cmds or nil
        end,
        __newindex = function(_, k, v)
            if type(k) == type '' and k ~= '' then
                if v == nil then
                    del_augroup(k)
                elseif type(v) == type {} then
                    local autocmds
                    if vim.tbl_islist(v) then
                        autocmds = vim.deepcopy(v)
                    else
                        autocmds = { v }
                    end
                    local clear = true
                    for _, aucmd in ipairs(autocmds) do
                        local opts = aucmd
                        local event = opts.event
                        opts.event = nil
                        if event then
                            add_augroup(k, clear)
                            clear = false
                            opts.group = k
                            add_autocmd(event, opts)
                        else
                            error(debug.traceback 'Missing autocmd event!')
                        end
                    end
                end
            end
        end,
    }),
    autocmd = setmetatable({
        add = add_autocmd,
        get = get_autocmd,
        del = function(id)
            vim.validate {
                id = { id, 'number' },
            }
            pcall(vim.api.nvim_del_autocmd, id)
        end,
    }, {
        __index = function(self, k)
            local mt = getmetatable(self)
            local x = mt[k]
            if x ~= nil then
                return x
            end
            local cmds = get_autocmd { event = k }
            return #cmds > 0 and cmds or nil
        end,
        __newindex = function(_, k, v)
            if type(k) == type '' and k ~= '' and type(v) == type {} then
                local autocmds
                if vim.tbl_islist(v) then
                    autocmds = vim.deepcopy(v)
                else
                    autocmds = { v }
                end
                local clear = true
                for _, aucmd in ipairs(autocmds) do
                    local opts = aucmd
                    local event = opts.event
                    opts.event = nil
                    if event then
                        add_augroup(k, clear)
                        clear = false
                        opts.group = k
                        add_autocmd(event, opts)
                    else
                        error(debug.traceback 'Missing autocmd event!')
                    end
                end
            end
        end,
    }),
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

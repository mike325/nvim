-- luacheck: globals unpack vim
-- local inspect = vim.inspect
local api = vim.api

local nvim_get_mapping = function(m, lhs, ...)
    local mappings
    local mapping

    local opts = ... ~= nil and ... or {}

    local modes = {
        normal   = "n",
        visual   = "v",
        operator = "o",
        insert   = "i",
        command  = "c",
        select   = "s",
        langmap  = "l",
        terminal = "t",
    }

    local mode = modes[m] ~= nil and modes[m] or m

    if opts ~= nil and opts['buffer'] ~= nil and opts['buffer'] == true then
        mappings = api.nvim_buf_get_keymap(mode)
    else
        mappings = api.nvim_get_keymap(mode)
    end

    for _,map in pairs(mappings) do
        if map['lhs'] == lhs then
            mapping = map['rhs']
            break
        end
    end

    return mapping

end

local nvim_set_mapping = function(m, lhs, rhs, ...)
    local opts = ... ~= nil and ... or {}

    local modes = {
        normal   = "n",
        visual   = "v",
        operator = "o",
        insert   = "i",
        command  = "c",
        select   = "s",
        langmap  = "l",
        terminal = "t",
    }

    local mode = modes[m] ~= nil and modes[m] or m

    if opts ~= nil and opts['buffer'] ~= nil then
        local buf = type(opts['buffer']) == 'boolean' and 0 or opts['buffer']
        opts['buffer'] = nil
        opts = opts == nil and {} or opts

        if rhs ~= nil then
            api.nvim_buf_set_keymap(buf, mode, lhs, rhs, opts)
        else
            api.nvim_buf_del_keymap(buf, mode, lhs)
        end
    else
        opts = opts == nil and {} or opts
        if rhs ~= nil then
            api.nvim_set_keymap(mode, lhs, rhs, opts)
        else
            api.nvim_del_keymap(mode, lhs)
        end
    end
end

local nvim_create_autogrp = function(autogrp)
    api.nvim_command('augroup '..autogrp..' | autocmd! | autogrp end')
end

local nvim_set_autocmd = function(event, pattern, cmd, ...)
    local opts = ... ~= nil and ... or {}
    local once = nil
    local group = nil
    local create = nil
    local nested = nil
    local autocmd = {'autocmd'}

    if opts ~= nil then
        group = opts['group'] ~= nil and opts['group'] or nil
        create = opts['create'] ~= nil and opts['create'] or nil
        once = opts['once'] ~= nil and '++once' or nil
        nested = opts['nested'] ~= nil and '++nested' or nil
    end

    if group ~= nil then
        table.insert(autocmd, group)
    end

    if event ~= nil then
        if type(event) == 'table' then
            event = table.concat(event, ',')
        end

        table.insert(autocmd, event)
    end

    if pattern ~= nil then
        if type(pattern) == 'table' then
            pattern = table.concat(pattern, ',')
        end

        table.insert(autocmd, pattern)
    end

    if once ~= nil then
        table.insert(autocmd, once)
    end

    if nested ~= nil then
        table.insert(autocmd, nested)
    end

    if cmd == nil then
        autocmd[1] = 'autocmd!'
    else
        table.insert(autocmd, cmd)
    end

    if create ~= nil then
        nvim_create_autogrp(group)
    end

    autocmd = table.concat(autocmd, ' ')

    api.nvim_command(autocmd)
end

local nvim_set_abbr = function(m, lhs, rhs, ...)
    local opts = ... ~= nil and ... or {}
    local command = {}
    local extras = {}

    local modes = {
        insert   = "i",
        command  = "c",
    }

    if type(opts) ~= 'table' and opts ~= nil then
        opts = {opts}
    end

    if opts ~= nil then
        if opts['buffer'] ~= nil  then
            table.insert(extras, '<buffer>')
        end

        if opts['expr'] ~= nil and rhs ~= nil then
            table.insert(extras, '<expr>')
        end
    end

    local mode = modes[m] ~= nil and modes[m] or m

    for _, v in pairs(extras) do
        table.insert(command, v)
    end

    if mode == 'i' then
        if rhs == nil then
            table.insert(command, 1, 'iunabbrev')
            table.insert(command, lhs)
        else
            table.insert(command, 1, 'iabbrev')
            table.insert(command, lhs)
            table.insert(command, rhs)
        end
    elseif mode == 'c' then
        if rhs == nil then
            table.insert(command, 1, 'cunabbrev')
            table.insert(command, lhs)
        else
            table.insert(command, 1, 'cabbrev')
            table.insert(command, lhs)
            table.insert(command, rhs)
        end
    end

    if opts['silent'] ~= nil then
        table.insert(command, 1, 'silent!')
    end

    command = table.concat(command, ' ')

    api.nvim_command(command)
end

local nvim_set_command = function(lhs, rhs, ...)
    local opts = ... ~= nil and ... or {}

    local command = {
        'command',
    }

    if rhs == nil then
        command[1] = 'delcommand'
        command[#command + 1] = lhs
    else

        if opts['force'] ~= nil and opts['force'] == true then
            command[1] = 'command!'
            opts['force'] = nil
        end

        local attr
        for name,val in pairs(opts) do
            if val ~= false then
                attr = '-'..name
                if type(val) ~= 'boolean' then
                    attr = attr..'='..val
                end
                command[#command + 1] = attr
            end
        end
        command[#command + 1] = lhs
        command[#command + 1] = rhs
    end

    command = table.concat(command, ' ')
    api.nvim_command(command)

end

-- TODO
-- local nvim_get_abbr = function(m, lhs)
--     local command = {}
--
--     local modes = {
--         insert   = "i",
--         command  = "c",
--     }
--
--     local mode = modes[m] ~= nil and modes[m] or m
-- end

-- Took from https://github.com/norcalli/nvim_utils
-- GPL3 apply to the nvim object
local nvim = {
    l = api.loop;
    nvim_set_abbr    = nvim_set_abbr;
    nvim_get_mapping = nvim_get_mapping;
    nvim_set_mapping = nvim_set_mapping;
    nvim_set_autocmd = nvim_set_autocmd;
    nvim_set_command = nvim_set_command;
    echoerr = function(msg)
        if type(msg) == 'string' and #msg > 0 then
            vim.api.nvim_err_writeln(msg)
        end
    end;
    list_clean = function(lst)
        local tmp = lst

        for idx,val in pairs(lst) do
            val = vim.trim(val)
            if #val == 0 or val == [[\n]] then
                table.remove(tmp, idx)
            end
        end

        return tmp
    end;
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
            autocmd = function(autocmd)
                return api.nvim_call_function('exists', {'##'..autocmd}) == 1
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
            __call = function(self, feature)
                return api.nvim_call_function('has', {feature}) == 1
            end;
        }
    );
    exists = setmetatable({
            cmd = function(cmd)
                return api.nvim_call_function('exists', {':'..cmd}) == 1
            end;
            autocmd = function(autocmd)
                return api.nvim_call_function('exists', {'##'..autocmd}) == 1
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
            __call = function(self, feature)
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

-- Neovim 0.5 now includes this shortcuts by default and in case of fn it's actually
-- more powerfull since Neovim's native fn object can auto-convert lua functions
-- allowing to use jobstart and family with lua callbacks
if api.nvim_call_function('has', {'nvim-0.5'}) == 0  then
    nvim['fn'] = setmetatable({}, {
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
    nvim['g'] = setmetatable({}, {
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
    nvim['b'] = setmetatable({}, {
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
    nvim['w'] = setmetatable({}, {
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
    nvim['t'] = setmetatable({}, {
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
    nvim['v'] = setmetatable({}, {
        __index = function(_, k)
            local ok, value = pcall(api.nvim_get_vvar, k)
            return ok and value or nil
        end;
        __newindex = function(_, k, v)
            return api.nvim_set_vvar(k, v)
        end
    })
    nvim['o'] = setmetatable({}, {
        __index = function(_, k)
            return api.nvim_get_option(k)
        end;
        __newindex = function(_, k, v)
            return api.nvim_set_option(k, v)
        end
    })
    nvim['bo'] = setmetatable({}, {
        __index = function(_, k)
            return api.nvim_buf_get_option(0, k)
        end;
        __newindex = function(_, k, v)
            return api.nvim_buf_set_option(0, k, v)
        end
    })
    nvim['wo'] = setmetatable({}, {
        __index = function(_, k)
            return api.nvim_win_get_option(0, k)
        end;
        __newindex = function(_, k, v)
            return api.nvim_win_set_option(0, k, v)
        end
    })
end

setmetatable(nvim, {
    __index = function(self, k)
        local mt = getmetatable(self)
        local x = mt[k]
        if x ~= nil then
            return x
        end

        local f = api['nvim_'..k]
        if f ~= nil then
            mt[k] = f
        else
            f = vim[k]
        end
        return f
    end
})

return nvim

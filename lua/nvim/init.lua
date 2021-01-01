-- luacheck: globals unpack vim
-- local i = vim.inspect
local api = vim.api
local has_attrs = require'tools.tables'.has_attrs

local function transform_mapping(lhs)
    if lhs:sub(1, 3) == '<c-' or lhs:sub(1, 3) == '<a-' or lhs:sub(1, 3) == '<s-' then
        lhs = string.upper(lhs:sub(1, 3)) .. lhs:sub(4, #lhs)
    elseif nvim.eval(([[ '%s' =~? '<\(cr\|del\|esc\|bs\|tab\)>' ]]):format(lhs)) then
        lhs = lhs:upper()
    end

    return lhs
end

local function nvim_set_abbr(abbr)

    if not has_attrs(abbr, {'mode', 'lhs'}) then
        nvim.echoerr('Missing arguments, set_abbr need a mode and a lhs attribbutes')
        return false
    end

    local command = {}
    local extras = {}

    local modes = {
        insert   = "i",
        command  = "c",
    }

    local lhs = abbr.lhs
    local rhs = abbr.rhs
    local args = type(abbr.args) == 'table' and abbr.args or {abbr.args}
    local mode = modes[abbr.mode] ~= nil and modes[abbr.mode] or abbr.mode

    if args.buffer ~= nil  then
        table.insert(extras, '<buffer>')
    end

    if args.expr ~= nil and rhs ~= nil then
        table.insert(extras, '<expr>')
    end

    for _, v in pairs(extras) do
        table.insert(command, v)
    end

    if mode == 'i' or mode == 'insert' then
        if rhs == nil then
            table.insert(command, 1, 'iunabbrev')
            table.insert(command, lhs)
        else
            table.insert(command, 1, 'iabbrev')
            table.insert(command, lhs)
            table.insert(command, rhs)
        end
    elseif mode == 'c' or mode == 'command' then
        if rhs == nil then
            table.insert(command, 1, 'cunabbrev')
            table.insert(command, lhs)
        else
            table.insert(command, 1, 'cabbrev')
            table.insert(command, lhs)
            table.insert(command, rhs)
        end
    else
        nvim.echoerr('Unsupported mode', mode)
        return false
    end

    if args.silent ~= nil then
        table.insert(command, 1, 'silent!')
    end

    api.nvim_command(table.concat(command, ' '))
end

local function nvim_get_mapping(mapping)

    if not has_attrs(mapping, {'mode', 'lhs'}) then
        nvim.echoerr('Missing arguments, get_mapping need a mode and a lhs attribbutes')
        return false
    end

    local result
    local mappings

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

    local lhs = transform_mapping(mapping.lhs)
    local args = type(mapping.args) == 'table' and mapping.args or {mapping.args}
    local mode = modes[mapping.mode] ~= nil and modes[mapping.mode] or mapping.mode

    if args.buffer ~= nil and args.buffer == true then
        mappings = api.nvim_buf_get_keymap(mode)
    else
        mappings = api.nvim_get_keymap(mode)
    end

    for _,map in pairs(mappings) do
        if map['lhs'] == lhs then
            result = map['rhs']
            break
        end
    end

    return result
end


local function nvim_set_mapping(mapping)

    if not has_attrs(mapping, {'mode', 'lhs'}) then
        nvim.echoerr('Missing arguments, set_mapping need a mode and a lhs attribbutes')
        return false
    end

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

    local args = type(mapping.args) == 'table' and mapping.args or {mapping.args}
    local mode = modes[mapping.mode] ~= nil and modes[mapping.mode] or mapping.mode
    local lhs = mapping.lhs
    local rhs = mapping.rhs

    if args.buffer ~= nil then
        local buf = type(args.buffer) == 'boolean' and 0 or args.buffer
        args.buffer = nil

        if rhs ~= nil then
            api.nvim_buf_set_keymap(buf, mode, lhs, rhs, args)
        else
            api.nvim_buf_del_keymap(buf, mode, lhs)
        end
    else
        args = args == nil and {} or args
        if rhs ~= nil then
            api.nvim_set_keymap(mode, lhs, rhs, args)
        else
            api.nvim_del_keymap(mode, lhs)
        end
    end
end


local function nvim_create_autogrp(autogrp)
    api.nvim_command('augroup '..autogrp..' | autocmd! | autogrp end')
end

local function nvim_get_autocmd(autocmd)

    if not has_attrs(autocmd, {'event'}) and not has_attrs(autocmd, {'group'}) then
        nvim.echoerr('Missing arguments, get_autocmd need event or group attribbute')
        return false
    end

    local autocmd_str = {'autocmd'}

    autocmd_str[#autocmd_str + 1] = autocmd.group ~= nil and autocmd.group or nil
    autocmd_str[#autocmd_str + 1] = autocmd.event ~= nil and autocmd.event or nil

    local ok, _ = pcall(vim.api.nvim_exec, table.concat(autocmd_str, ' '), true)

    if not ok then
        return nil
    end

    return true
    -- TODO: Work in parse autocmd output
end

local function nvim_has_autocmd(autocmd)
    return nvim_get_autocmd(autocmd) ~= nil
end

local function nvim_set_autocmd(autocmd)

    if not has_attrs(autocmd, {'event'}) then
        nvim.echoerr('Missing arguments, set_autocmd need event attribbute')
        return false
    end

    local autocmd_str = {'autocmd'}

    local once    = autocmd.once    ~= nil and '++once'        or nil
    local nested  = autocmd.nested  ~= nil and '++nested'      or nil
    local cmd     = autocmd.cmd     ~= nil and autocmd.cmd     or nil
    local event   = autocmd.event   ~= nil and autocmd.event   or nil
    local group   = autocmd.group   ~= nil and autocmd.group   or nil
    local clean   = autocmd.clean   ~= nil and autocmd.clean   or nil
    local pattern = autocmd.pattern ~= nil and autocmd.pattern or nil

    if group ~= nil then
        autocmd_str[#autocmd_str + 1] = group
    end

    if event ~= nil then
        if type(event) == 'table' then
            event = table.concat(event, ',')
        end

        autocmd_str[#autocmd_str + 1] = event
    end

    if pattern ~= nil then
        if type(pattern) == 'table' then
            pattern = table.concat(pattern, ',')
        end

        autocmd_str[#autocmd_str + 1] = pattern
    end

    if once ~= nil then
        autocmd_str[#autocmd_str + 1] = once
    end

    if nested ~= nil then
        autocmd_str[#autocmd_str + 1] = nested
    end

    if cmd == nil then
        autocmd_str[1] = 'autocmd!'
    else
        autocmd_str[#autocmd_str + 1] = cmd
    end

    if clean ~= nil and group ~= nil then
        nvim_create_autogrp(group)
    elseif group ~= nil and not nvim_has_autocmd { group = group } then
        nvim_create_autogrp(group)
    end

    api.nvim_command(table.concat(autocmd_str, ' '))
end

local function nvim_set_command(command)
    if not has_attrs(command, {'lhs'}) then
        nvim.echoerr('Missing arguments, set_command need a mode and a lhs attribbutes')
        return false
    end

    local lhs  = command.lhs
    local rhs  = command.rhs
    local args = type(command.args) == 'table' and command.args or {command.args}

    local command_str = {'command'}

    if rhs == nil then
        command_str = {'delcommand'}
        command_str[#command_str + 1] = lhs
    else

        if args.force then
            command_str = {'command!'}
            args.force = nil
        end

        local attr
        for name,val in pairs(args) do
            if val ~= false then
                attr = '-'..name
                if type(val) ~= 'boolean' then
                    attr = attr..'='..val
                end
                command_str[#command_str + 1] = attr
            end
        end
        command_str[#command_str + 1] = lhs
        command_str[#command_str + 1] = rhs
    end

    api.nvim_command(table.concat(command_str, ' '))
end

-- Took from https://github.com/norcalli/nvim_utils
-- GPL3 apply to the nvim object
_G['nvim'] = {
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

-- Neovim 0.5 now includes this shortcuts by default and in case of fn it's actually
-- more powerfull since Neovim's native fn object can auto-convert lua functions
-- allowing to use jobstart and family with lua callbacks
if api.nvim_call_function('has', {'nvim-0.5'}) == 0  then
    _G['nvim']['fn'] = setmetatable({}, {
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
    _G['nvim']['g'] = setmetatable({}, {
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
    _G['nvim']['b'] = setmetatable({}, {
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
    _G['nvim']['w'] = setmetatable({}, {
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
    _G['nvim']['t'] = setmetatable({}, {
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
    _G['nvim']['v'] = setmetatable({}, {
        __index = function(_, k)
            local ok, value = pcall(api.nvim_get_vvar, k)
            return ok and value or nil
        end;
        __newindex = function(_, k, v)
            return api.nvim_set_vvar(k, v)
        end
    })
    _G['nvim']['o'] = setmetatable({}, {
        __index = function(_, k)
            return api.nvim_get_option(k)
        end;
        __newindex = function(_, k, v)
            return api.nvim_set_option(k, v)
        end
    })
    _G['nvim']['bo'] = setmetatable({}, {
        __index = function(_, k)
            return api.nvim_buf_get_option(0, k)
        end;
        __newindex = function(_, k, v)
            return api.nvim_buf_set_option(0, k, v)
        end
    })
    _G['nvim']['wo'] = setmetatable({}, {
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

local func_to_lua = {
    'executable',
    'isdirectory',
    'filereadable',
    'bufloaded',
}

for _,func_name in pairs(func_to_lua) do
    local original = nvim.fn[func_name]
    if original ~= nil and nvim[func_name] == nil then
        _G['nvim'][func_name] = function(...)
            return original(...) == 1
        end
    end
end

return nvim

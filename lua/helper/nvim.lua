-- luacheck: globals unpack vim
local api = vim.api

local nvim = {}

nvim.plugs = nil
local ok, rsp = pcall(api.nvim_get_var, 'plugs')

if ok then
    nvim.plugs = rsp
end


local function nvimFuncWrapper (name, ...)
    return api.nvim_call_function(name, {...})
end

local function getcwd()
    return api.nvim_call_function('getcwd', {})
end

nvim.getcwd = getcwd

nvim.has        = function(feature) return nvimFuncWrapper('has', feature) end
nvim.executable = function(program) return nvimFuncWrapper('executable', program) end
nvim.exepath    = function(program) return nvimFuncWrapper('exepath', program) end
nvim.system     = function(cmd) return nvimFuncWrapper('system', cmd) end
nvim.systemlist = function(cmd) return nvimFuncWrapper('systemlist', cmd) end
nvim.split      = function(str, pattern, keepempty) return nvimFuncWrapper('split', str, pattern, keepempty) end
nvim.join       = function(str, separator) return nvimFuncWrapper('join', str, separator) end

nvim.realpath = function(path)
    path = path == '.' and getcwd() or path
    return nvimFuncWrapper('fnamemodify', path, ':p')
end

nvim.finddir = function(name, path, count)
    path = path == '.' and getcwd() or path
    return nvimFuncWrapper('finddir', name, path, count)
end

nvim.findfile= function(name, path, count)
    path = path == '.' and getcwd() or path
    return nvimFuncWrapper('findfile', name, path, count)
end

nvim.json = {}

nvim.json.decode = function(json) return nvimFuncWrapper('json_decode', json) end
nvim.json.encode = function(json) return nvimFuncWrapper('json_encode', json) end
-- nvim.json.read   = function(json) return nvimFuncWrapper('json_encode', json) end
-- nvim.json.write  = function(json) return nvimFuncWrapper('json_encode', json) end

nvim.nvim_option = function(option)
    if type(option) == "string" then
        return api.nvim_get_option(option)
    else
        if not has_key(option, 'name') then
            return nil
        end
        local option_name = option['name']
        local fn_type = has_key(option, 'value') and 'set' or 'get'
        local scope = has_key(option, 'scope') and option['scope'] or 'global'

        local functions = {
            global = {
                get = api.nvim_get_option,
                set = api.nvim_set_option,
            },
            win = {
                get = api.nvim_win_get_option,
                set = api.nvim_win_set_option,
                handle = has_key(option, 'handle') and option['handle'] or api.nvim_get_current_win()
            },
            buf = {
                get = api.nvim_buf_get_option,
                set = api.nvim_buf_set_option,
                handle = has_key(option, 'handle') and option['handle'] or api.nvim_get_current_buf()
            },
        }

        if fn_type == 'get' then
            if scope == 'global' then
                return functions[scope][fn_type](option_name)
            end
            return functions[scope][fn_type](functions[scope]['handle'], option_name)
        else
            if scope == 'global' then
                return functions[scope][fn_type](option_name, option['value'])
            end
            return functions[scope][fn_type](functions[scope]['handle'], option_name, option['value'])
        end
    end
    return nil
end

-- nvim.map = function(lhs, rhs, mode, buffer, noremap, expr, silent)
--
--     local valid_modes = {
--         normal = 'n',
--         n = 'n',
--         visual = 'v',
--         v = 'v',
--         insert = 'i',
--         i = 'i',
--         command = 'c',
--         c = 'c',
--     }
--
--     if type(mode) ~= "string" and not has_key(valid_modes, mode) then
--         return nil
--     end
--
--     mode    = valid_modes[mode]
--     buffer  = buffer == true and '<buffer>' or ''
--     silent  = silent == true and '<silent>' or ''
--     expr    = expr == true and '<expr>' or ''
--     noremap = noremap == true and 'noremap' or 'map'
-- end
return nvim

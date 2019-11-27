-- luacheck: globals unpack vim
local nvim = {}

local function nvimFuncWrapper (name, ...)
    return vim.api.nvim_call_function(name, {...})
end

nvim.getcwd     = function() return nvimFuncWrapper('getcwd') end
nvim.has        = function(feature) return nvimFuncWrapper('has', feature) end
nvim.executable = function(program) return nvimFuncWrapper('executable', program) end
nvim.exepath    = function(program) return nvimFuncWrapper('exepath', program) end
nvim.system     = function(cmd) return nvimFuncWrapper('system', cmd) end
nvim.systemlist = function(cmd) return nvimFuncWrapper('systemlist', cmd) end
nvim.stdpath    = function(path) return nvimFuncWrapper('stdpath', path) end
nvim.split      = function(str, pattern, keepempty) return nvimFuncWrapper('split', str, pattern, keepempty) end
nvim.join       = function(str, separator) return nvimFuncWrapper('join', str, separator) end

nvim.isdirectory  = function(dir) return nvimFuncWrapper('isdirectory', dir) end
nvim.filereadable = function(file) return nvimFuncWrapper('filereadable', file) end
nvim.filewritable = function(file) return nvimFuncWrapper('filewritable', file) end
nvim.mkdir        = function(dir, ...) return nvimFuncWrapper('mkdir', dir, ...) end

nvim.realpath = function(path)
    path = path == '.' and getcwd() or path
    return nvimFuncWrapper('fnamemodify', path, ':p')
end

nvim.globpath = function(path, expr)
    path = path == '.' and getcwd() or path
    local nosuf = false
    local list = true
    return nvimFuncWrapper('globpath', path, expr, nosuf, list)
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

nvim.has_version = function(version)
    return vim.api.nvim_call_function('has', {'nvim-'..version})
end

nvim.get_env = function(env)
    local value = vim.loop.os_getenv(env)
    return value ~= nil and value or nil
end

nvim.set_env = function(env, value) vim.loop.os_setenv(env, value) end

return nvim

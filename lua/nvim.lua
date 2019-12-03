-- luacheck: globals unpack vim
local nvim = {}

local function nvimFuncWrapper (name, ...)
    return vim.api.nvim_call_function(name, {...})
end

function nvim.has(feature) return nvimFuncWrapper('has', feature) end
function nvim.join(str, separator) return nvimFuncWrapper('join', str, separator) end
function nvim.split(str, pattern, keepempty) return nvimFuncWrapper('split', str, pattern, keepempty) end
function nvim.system(cmd) return nvimFuncWrapper('system', cmd) end
function nvim.exists(setting) return nvimFuncWrapper('exists', setting) end
function nvim.getcwd() return nvimFuncWrapper('getcwd') end
function nvim.stdpath(path) return nvimFuncWrapper('stdpath', path) end
function nvim.exepath(program) return nvimFuncWrapper('exepath', program) end
function nvim.executable(program) return nvimFuncWrapper('executable', program) end
function nvim.systemlist(cmd) return nvimFuncWrapper('systemlist', cmd) end

function nvim.mkdir(dir, ...) return nvimFuncWrapper('mkdir', dir, ...) end
function nvim.isdirectory(dir) return nvimFuncWrapper('isdirectory', dir) end
function nvim.filereadable(file) return nvimFuncWrapper('filereadable', file) end
function nvim.filewritable(file) return nvimFuncWrapper('filewritable', file) end

function nvim.has_version(version) return vim.api.nvim_call_function('has', {'nvim-'..version}) end

function nvim.realpath(path)
    path = path == '.' and getcwd() or path
    return nvimFuncWrapper('fnamemodify', path, ':p')
end

function nvim.globpath(path, expr)
    path = path == '.' and getcwd() or path
    local nosuf = false
    local list = true
    return nvimFuncWrapper('globpath', path, expr, nosuf, list)
end

function nvim.finddir(name, path, ...)
    path = path == '.' and getcwd() or path
    local count = {...}
    if #count > 0 then
        return nvimFuncWrapper('finddir', name, path, count)
    end
    return nvimFuncWrapper('finddir', name, path)
end

function nvim.findfile(name, path, ...)
    path = path == '.' and getcwd() or path
    local count = {...}
    if #count > 0 then
        return nvimFuncWrapper('findfile', name, path, count)
    end
    return nvimFuncWrapper('findfile', name, path)
end

nvim.json = {}

function nvim.json.decode(json) return nvimFuncWrapper('json_decode', json) end
function nvim.json.encode(json) return nvimFuncWrapper('json_encode', json) end

-- nvim.json.read   = function(json) return nvimFuncWrapper('json_encode', json) end
-- nvim.json.write  = function(json) return nvimFuncWrapper('json_encode', json) end

function nvim.set_env(env, value) vim.loop.os_setenv(env, value) end
function nvim.get_env(env)
    local value = vim.loop.os_getenv(env)
    return value ~= nil and value or nil
end

return nvim

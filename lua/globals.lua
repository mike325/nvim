_G['RELOAD'] = function(modname)
    if vim then
        if vim.is_thread() then
            package.loaded[modname] = nil
        elseif vim.v.vim_did_enter == 1 then
            package.loaded[modname] = nil
            if vim.loader and vim.loader.enabled then
                vim.loader.reset(modname)
            end
        end
    else
        package.loaded[modname] = nil
    end
    return require(modname)
end

_G['P'] = function(...)
    local tbls = require 'utils.tables'
    local vars = tbls.tbl_map(tbls.inspect, { ... })
    print(unpack(vars))
    return { ... }
end

_G['PRINT'] = _G['P']

_G['PASTE'] = function(data)
    if not vim then
        error(debug.traceback 'This platform is unsupported')
    end

    local tmp = data
    if not vim.isarray(tmp) then
        if type(tmp) == type '' then
            tmp = vim.split(tmp, '\n')
        else
            tmp = vim.split(vim.inspect(tmp), '\n')
        end
    else
        tmp = vim.deepcopy(tmp)
    end
    vim.paste(
        vim.tbl_map(function(v)
            return type(v) == type '' and v or vim.inspect(v)
        end, tmp),
        -1
    )
end

_G['PERF'] = function(msg, ...)
    local args = { ... }
    assert(type(args[1]) == 'function', debug.traceback 'The first argument must be a function')
    assert(not msg or type(msg) == 'string', debug.traceback 'msg must be a string')
    msg = msg or 'Func reference elpse time:'
    local func = args[1]
    table.remove(args, 1)
    -- local start = os.time()
    local start = os.clock()
    local data = func(unpack(args))
    print(msg, ('%.2f s'):format(os.clock() - start))
    -- print(msg, ('%.2f s'):format(os.difftime(os.time(), start)))
    return data
end

--- @class vim.Ringbuf
--- @field clear  fun()
--- @field push fun(item: any)
--- @field pop  fun(): any?
--- @field peek fun(): any?

---@class Async
---@field output vim.Ringbuf
---@field jobs table<string, vim.SystemObj>

---@type Async?
if not ASYNC and not vim.is_thread() then
    _G['ASYNC'] = {
        output = require('stack'):new(15),
        jobs = {},
    }
end

if not STORAGE then
    _G['STORAGE'] = {
        modern_git = -1,
        scratches = {},
        compile_flags = {},
        compile_commands_dbs = {},
        jobs = {},
        async = {},
        autocmds = {},
        filelists = {},
        hosts = {},
        remotes = {},
        servers = {},
        loggers = {},
        watchers = {},
        databases = {},
    }
end

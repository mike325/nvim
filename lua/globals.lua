_G['RELOAD'] = function(pkg)
    package.loaded[pkg] = nil
    return require(pkg)
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
    if not vim.tbl_islist(data) then
        if type(data) == type '' then
            data = vim.split(data, '\n')
        else
            data = vim.split(vim.inspect(data), '\n')
        end
    end
    vim.paste(data, -1)
end

_G['PERF'] = function(msg, ...)
    local args = { ... }
    assert(type(args[1]) == 'function', debug.traceback 'The first argumet must be a function')
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

if not STORAGE then
    _G['STORAGE'] = {
        modern_git = -1,
        scratchs = {},
        compile_flags = {},
        databases = {},
        jobs = {},
        autocmds = {},
        filelists = {},
        hosts = {},
        remotes = {},
        servers = {},
    }
end

require 'completions'

_G['P'] = function(...)
    local vars = vim.tbl_map(vim.inspect, { ... })
    print(unpack(vars))
    return { ... }
end

_G['PRINT'] = _G['P']

_G['RELOAD'] = function(pkg)
    package.loaded[pkg] = nil
    return require(pkg)
end

_G['PASTE'] = function(data)
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
    vim.validate { func = { args[1], 'function' }, message = { msg, 'string', true } }
    local func = args[1]
    table.remove(args, 1)
    -- local start = os.time()
    local start = os.clock()
    local data = func(unpack(args))
    msg = msg or 'Func reference elpse time:'
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

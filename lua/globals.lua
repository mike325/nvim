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
    if type(data) == type '' then
        data = vim.split(data, '\n')
    end
    if type(data) ~= type {} then
        data = vim.inspect(vim.split(data, '\n'))
    end
    vim.paste(data, -1)
end

_G['PERF'] = function(msg, ...)
    local args = { ... }
    assert(#args > 0 and vim.is_callable(args[1]), 'Invalid func ref')
    assert(not msg or type(msg) == type '', 'Invalid message: ' .. vim.inspect(msg))
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
        has_cjson = -1,
        jobs = {},
        autocmds = {},
        filelists = {},
        hosts = {},
        remotes = {},
        mappings = {
            g = {},
            b = {},
        },
        commands = {
            g = {},
            b = {},
        },
    }
end

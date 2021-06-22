_G['P'] = function(val, str)
    print(vim.inspect(val))
    return str and vim.inspect(val) or val
end

_G['RELOAD'] = function(pkg)
    package.loaded[pkg] = nil
    return require(pkg)
end

_G['PASTE'] = function(data)
    if type(data) == type('') then
        data = vim.split(data, '\n')
    end
    if type(data) ~= type({}) then
        data = vim.inspect(vim.split(data, '\n'))
    end
    vim.paste(data, -1)
end

if not STORAGE then
    _G['STORAGE'] = {
        git_version = '',
        modern_git = -1,
        scratchs = {},
        compile_flags = {},
        databases = {},
        has_cjson = -1,
        jobs = {},
        autocmds = {},
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

_G['P'] = function(val, str)
    print(vim.inspect(val))
    return str and vim.inspect(val) or val
end

_G['REALOAD'] = function(pkg)
    package.loaded[pkg] = nil
    return require(pkg)
end

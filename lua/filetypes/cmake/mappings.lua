local nvim = require 'nvim'
local completions = RELOAD 'completions'

nvim.command.set('CMake', function(opts)
    RELOAD('filetypes.cmake.utils').execute(opts.fargs)
end, { nargs = '+', desc = 'Wrapper around cmake binary' })

nvim.command.set('CMakeBuild', function(opts)
    local cmake = {
        build_type = 'RelWithDebInfo',
        args = {},
    }

    local build_types = {}
    for k, v in ipairs(vim.deepcopy(require 'filetypes.cpp.build_types')) do
        build_types[k:lower()] = v
    end

    for _, arg in ipairs(opts.fargs) do
        if build_types[arg:lower()] then
            cmake.build_type = arg
        else
            table.insert(cmake.args, arg)
        end
    end

    RELOAD('filetypes.cmake.utils').build(cmake)
end, {
    nargs = '?',
    complete = completions.build_type,
    desc = 'Build current project with CMake',
})

nvim.command.set('CMakeConfig', function(opts)
    local cmake = {
        build_type = 'RelWithDebInfo',
        args = {},
    }

    local build_types = {}
    for k, v in ipairs(vim.deepcopy(require 'filetypes.cpp.build_types')) do
        build_types[k:lower()] = v
    end

    for _, arg in ipairs(opts.fargs) do
        if build_types[arg:lower()] then
            cmake.build_type = arg
        else
            table.insert(cmake.args, arg)
        end
    end

    RELOAD('filetypes.cmake.utils').config(cmake)
end, {
    nargs = '?',
    complete = completions.build_type,
    desc = 'Configure current project to build using CMake',
})

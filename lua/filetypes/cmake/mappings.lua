local nvim = require 'nvim'
local comp_utils = RELOAD 'completions.utils'

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
    complete = comp_utils.get_completion(vim.tbl_keys(require 'filetypes.cpp.build_types')),
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
    complete = comp_utils.get_completion(vim.tbl_keys(require 'filetypes.cpp.build_types')),
    desc = 'Configure current project to build using CMake',
})

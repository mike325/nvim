local nvim = require 'nvim'

local executable = require('utils.files').executable
-- local readfile = require('utils.files').readfile
-- local is_file = require('utils.files').is_file
-- local realpath = require('utils.files').realpath
-- local getcwd = require('utils.files').getcwd
local completions = RELOAD 'completions'

-- local compile_flags = STORAGE.compile_flags
-- local databases = STORAGE.databases

nvim.command.set('Compile', function(opts)
    local flags = {}
    local build_type

    local build_types = {}
    for k, v in ipairs(vim.deepcopy(require 'filetypes.cpp.build_types')) do
        build_types[k:lower()] = v
    end

    for _, arg in ipairs(opts.fargs) do
        if build_types[arg:lower()] then
            build_type = arg
        else
            table.insert(flags, arg)
        end
    end

    local cpp_utils = RELOAD 'filetypes.cpp.utils'
    cpp_utils.compile {
        flags = flags,
        build_type = build_type,
    }
end, {
    nargs = '*',
    force = true,
    buffer = true,
    complete = completions.build_type,
    desc = 'Compile C/C++ project calling directly the compiler'
})

nvim.command.set('Build', function(opts)
    local flags = {}
    local build_type

    local build_types = {}
    for k, v in ipairs(vim.deepcopy(require 'filetypes.cpp.build_types')) do
        build_types[k:lower()] = v
    end

    for _, arg in ipairs(opts.fargs) do
        if build_types[arg:lower()] then
            build_type = arg
        else
            table.insert(flags, arg)
        end
    end

    local cpp_utils = RELOAD 'filetypes.cpp.utils'
    cpp_utils.build {
        flags = flags,
        build_type = build_type,
    }
end, {
    nargs = '*',
    force = true,
    buffer = true,
    complete = completions.build_type,
    desc = 'Build C/C++ project using the projects build system'
})

nvim.command.set('Execute', function(opts)
    local cpp_utils = RELOAD 'filetypes.cpp.utils'
    cpp_utils.execute(nil, opts.fargs)
end, { nargs = '*', force = true, buffer = true, complete = 'file', desc = 'Execute a binary from a build collateral' })

nvim.command.set('BuildExecute', function(opts)
    local flags = {}
    local build_type

    local build_types = {}
    for k, v in ipairs(vim.deepcopy(require 'filetypes.cpp.build_types')) do
        build_types[k:lower()] = v
    end

    for _, arg in ipairs(opts.fargs) do
        if build_types[arg:lower()] then
            build_type = arg
        else
            table.insert(flags, arg)
        end
    end

    local cpp_utils = RELOAD 'filetypes.cpp.utils'
    cpp_utils.build {
        flags = flags,
        build_type = build_type,
        cb = cpp_utils.execute,
    }
end, {
    nargs = '*',
    force = true,
    buffer = true,
    complete = completions.build_type,
    desc = 'Build and Execute C/C++ project'
})

-- TODO: Fallback to TermDebug
if nvim.plugins['nvim-dap'] then
    nvim.command.set('BuildDebugFile', function(opts)
        local dap = vim.F.npcall(require, 'dap')
        if not dap then
            error(debug.traceback("Missing DAP!"))
        end

        local args = opts.fargs
        local flags = {}

        local cpp_utils = RELOAD 'filetypes.cpp.utils'

        vim.list_extend(flags, args)
        cpp_utils.build {
            compiler = cpp_utils.get_compiler(),
            build_type = 'debug',
            flags = flags,
            cb = function() dap.continue() end,
            single = true,
        }
    end, {
        nargs = '*',
        force = true,
        buffer = true,
    })

    nvim.command.set('BuildDebug', function(opts)
        local dap = vim.F.npcall(require, 'dap')
        if not dap then
            error(debug.traceback("Missing DAP!"))
        end

        -- local args = opts.fargs
        -- local flags = {}
        -- vim.list_extend(flags, args)
        local cpp_utils = RELOAD 'filetypes.cpp.utils'

        cpp_utils.build {
            compiler = cpp_utils.get_compiler(),
            build_type = 'debug',
            flags = opts.fargs,
            cb = function() dap.continue() end,
        }
    end, {
        nargs = '*',
        force = true,
        buffer = true,
    })
end

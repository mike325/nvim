local M = {}
local nvim = require 'nvim'
local completions = RELOAD 'completions'

function M.setup()
    local mkdir = require('utils.files').mkdir
    local is_dir = require('utils.files').is_dir
    local is_file = require('utils.files').is_file
    local link = require('utils.files').link

    nvim.command.set('CMake', function(opts)
        local args = opts.fargs
        local Job = RELOAD 'jobs'
        local cmake = Job:new {
            cmd = 'cmake',
            args = args,
            qf = {
                on_fail = {
                    open = true,
                    jump = false,
                },
                context = 'CMake',
                title = 'CMake',
            },
        }
        cmake:start()
        cmake:progress()
    end, { nargs = '+', buffer = true })

    nvim.command.set('CMakeConfig', function(opts)
        -- Release, Debug, RelWithDebInfo, etc.

        local build_type = opts.args ~= '' and opts.args or 'RelWithDebInfo'
        local build_dir = 'build'

        if not is_dir(build_dir) then
            mkdir(build_dir)
        end

        local args = {
            '.',
            '-DCMAKE_BUILD_TYPE=' .. build_type,
            '-B' .. build_dir,
        }

        local c_compiler
        local cpp_compiler

        if vim.env.CC then
            c_compiler = { '-DCMAKE_C_COMPILER=' .. vim.env.CC }
        elseif vim.g.c_compiler then
            c_compiler = { '-DCMAKE_C_COMPILER=' .. vim.g.c_compiler }
        end

        if vim.env.CXX then
            cpp_compiler = '-DCMAKE_CXX_COMPILER=' .. vim.env.CXX
        elseif vim.g.c_compiler then
            cpp_compiler = '-DCMAKE_CXX_COMPILER=' .. vim.g.cpp_compiler
        end

        if c_compiler then
            table.insert(args, c_compiler)
        end

        if cpp_compiler then
            table.insert(args, cpp_compiler)
        end

        local cmake = RELOAD('jobs'):new {
            cmd = 'cmake',
            args = args,
            qf = {
                on_fail = {
                    open = true,
                    jump = false,
                },
                context = 'CMake',
                title = 'CMake',
            },
        }
        cmake:start()
        cmake:progress()
    end, {
        nargs = '?',
        buffer = true,
        complete = completions.cmake_build,
    })

    nvim.command.set('CMakeBuild', function(opts)
        -- Release, Debug, RelWithDebInfo, etc.
        local build_type = opts.args ~= '' and opts.args or 'RelWithDebInfo'
        local build_dir = 'build'

        if not is_dir(build_dir) then
            mkdir(build_dir)
        end

        local args = {
            '--build',
            build_dir,
            '--config',
            build_type,
        }

        local cmake = RELOAD('jobs'):new {
            cmd = 'cmake',
            args = args,
            qf = {
                on_fail = {
                    open = true,
                    jump = false,
                },
                context = 'CMake',
                title = 'CMake',
            },
            callbacks_on_success = function(_)
                vim.notify('Build completed!', 'INFO', { title = 'CMake' })
                if is_file 'build/compile_commands.json' then
                    link('build/compile_commands.json', '.', false, true)
                end
                RELOAD('utils.qf').clear()
            end,
            callbacks_on_failure = function(_, rc)
                vim.notify('CMake Build Failed! :c with exit code: ' .. rc, 'ERROR', { title = 'CMake' })
            end,
        }

        cmake:start()
        cmake:progress()
    end, {
        nargs = '?',
        buffer = true,
        complete = completions.cmake_build,
    })
end

return M

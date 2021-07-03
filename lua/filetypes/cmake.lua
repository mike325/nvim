local set_command = require'neovim.commands'.set_command
local mkdir = require'utils'.files.mkdir
local is_dir = require'utils'.files.is_dir
local jobs = require'jobs'

local M = {}

function M.setup()
    set_command{
        lhs = 'CMake',
        rhs = function(args)
            args = args or ''
            local cmd = {'cmake'}
            vim.list_extend(cmd, vim.split(args, ' '))
            jobs.send_job{
                cmd = cmd,
                qf = {
                    on_fail = {
                        open = true,
                        jump = false,
                    },
                    open = false,
                    jump = false,
                    context = 'CMake',
                    title = 'CMake',
                },
            }
        end,
        args = {nargs = '+', force = true, buffer = true}
    }

    set_command{
        lhs = 'CMakeConfig',
        rhs = function(build_type)
            -- Release, Debug, RelWithDebInfo, etc.
            build_type = (build_type and build_type ~= '') and build_type or 'RelWithDebInfo'
            local build_dir = 'build'
            if not is_dir(build_dir) then
                mkdir(build_dir)
            end
            local cmd = {
                'cmake',
                '.',
                '-DCMAKE_BUILD_TYPE='..build_type,
                '-B'..build_dir,
            }

            local c_compiler
            local cpp_compiler

            if vim.env.CC then
                c_compiler = {'-DCMAKE_C_COMPILER='..vim.env.CC}
            elseif vim.g.c_compiler then
                c_compiler = {'-DCMAKE_C_COMPILER='..vim.g.c_compiler}
            end

            if vim.env.CXX then
                c_compiler = '-DCMAKE_CXX_COMPILER='..vim.env.CXX
            elseif vim.g.c_compiler then
                c_compiler = '-DCMAKE_CXX_COMPILER='..vim.g.cpp_compiler
            end

            if c_compiler then
                table.insert(cmd, c_compiler)
            end

            if cpp_compiler then
                table.insert(cmd, cpp_compiler)
            end

            jobs.send_job{
                cmd = cmd,
                qf = {
                    on_fail = {
                        open = true,
                        jump = false,
                    },
                    open = false,
                    jump = false,
                    context = 'CMake',
                    title = 'CMake',
                },
            }
        end,
        args = {nargs = '?', force = true, buffer = true}
    }

    set_command{
        lhs = 'CMakeBuild',
        rhs = function(build_type)
            -- Release, Debug, RelWithDebInfo, etc.
            build_type = (build_type and build_type ~= '') and build_type or 'RelWithDebInfo'
            local build_dir = 'build'
            if not is_dir(build_dir) then
                mkdir(build_dir)

            end
            local cmd = {
                'cmake',
                '--build',
                build_dir,
                '--config',
                build_type,
            }

            jobs.send_job{
                cmd = cmd,
                qf = {
                    on_fail = {
                        open = true,
                        jump = false,
                    },
                    open = false,
                    jump = false,
                    context = 'CMake',
                    title = 'CMake',
                },
            }
        end,
        args = {nargs = '?', force = true, buffer = true}
    }
end

return M

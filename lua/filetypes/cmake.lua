local M = {}

function M.setup()

    local mkdir      = require'utils'.files.mkdir
    local is_dir     = require'utils'.files.is_dir
    local is_file    = require'utils'.files.is_file
    local link       = require'utils'.files.link

    local set_command = require'neovim.commands'.set_command

    local echomsg = require'utils'.messages.echomsg
    local echoerr = require'utils'.messages.echoerr

    set_command{
        lhs = 'CMake',
        rhs = function(...)
            local args = {...}
            local Job = RELOAD'jobs'
            local cmake = Job:new{
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
        end,
        args = {nargs = '+', force = true, buffer = true}
    }

    set_command{
        lhs = 'CMakeConfig',
        rhs = function(build_type)
            -- Release, Debug, RelWithDebInfo, etc.

            build_type = (build_type and build_type ~= '') and build_type or 'RelWithDebInfo'
            local build_dir = 'build'
            local Job = RELOAD'jobs'

            if not is_dir(build_dir) then
                mkdir(build_dir)
            end

            local args = {
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
                cpp_compiler = '-DCMAKE_CXX_COMPILER='..vim.env.CXX
            elseif vim.g.c_compiler then
                cpp_compiler = '-DCMAKE_CXX_COMPILER='..vim.g.cpp_compiler
            end

            if c_compiler then
                table.insert(args, c_compiler)
            end

            if cpp_compiler then
                table.insert(args, cpp_compiler)
            end

            local cmake = Job:new{
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
        end,
        args = {nargs = '?', force = true, buffer = true, complete = 'customlist,neovim#cmake_build'}
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

            local args = {
                '--build',
                build_dir,
                '--config',
                build_type,
            }

            local Job = RELOAD'jobs'
            local cmake = Job:new{
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

            cmake:callback_on_success(function(_)
                echomsg('Build completed!', 'CMake')
                if is_file('build/compile_commands.json') then
                    link(
                        'build/compile_commands.json',
                        '.',
                        false,
                        true
                    )
                end
                vim.fn.setqflist({}, 'r')
            end)

            cmake:callback_on_failure(function(_, rc)
                echoerr('CMake Build Failed! :c with exit code: '..rc, 'CMake')
            end)

            cmake:start()
            cmake:progress()
        end,
        args = {nargs = '?', force = true, buffer = true, complete = 'customlist,neovim#cmake_build'}
    }

end

return M

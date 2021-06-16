local nvim = require'nvim'

-- local clear_lst = require'utils'.tables.clear_lst
-- local split = require'utils'.strings.split

local getcwd         = require'utils.files'.getcwd
local realpath       = require'utils.files'.realpath
local executable     = require'utils.files'.executable
local readfile       = require'utils.files'.readfile
local is_file        = require'utils.files'.is_file
local basedir        = require'utils.files'.basedir
local normalize_path = require'utils.files'.normalize_path

-- vim.bo.foldmethod = 'syntax'
vim.bo.expandtab = true
-- vim.bo.shiftround = true
vim.bo.tabstop = 4
vim.bo.shiftwidth = 0
vim.bo.softtabstop = -1
vim.bo.commentstring = '// %s'
vim.bo.define = [[^\(#\s*define\|[a-z]*\s*const\(expr\)\?\s*[a-z]*\)]]

if executable('clang-format') then
    vim.bo.formatprg = 'clang-format --style=file --fallback-style=WebKit'
end

local M = {}

local compile_flags = {}

local compilers = {
    c = {
        'clang',
        'gcc',
    },
    cpp = {
        'clang++',
        'g++',
    }
}

local default_flags = {
    ['clang++'] = {
        '-S',
        '-std=c++17',
        '-Wall',
        '-Wextra',
        '-Weverything',
        '-Wno-c++98-compat',
        '-Wpedantic',
        '-Wno-missing-prototypes',
    },
    ['g++'] = {
        '-S',
        '-std=c++17',
        '-Wall',
        '-Wextra',
        '-Wpedantic',
    },
    clang = {
        '-S',
        '-Wall',
        '-Wextra',
        '-Weverything',
        '-Wno-missing-prototypes',
        '-Wpedantic',
    },
    gcc = {
        '-S',
        '-Wall',
        '-Wextra',
        '-Wpedantic',
    },
}

local function get_compiler()
    local ft = vim.bo.filetype
    local compiler
    for _,exe in pairs(compilers[ft]) do
        if executable(exe) then
            compiler = exe
            break
        end
    end
    return compiler
end

local function set_opts(filename, has_tidy, compiler, bufnum)
    if filename and compile_flags[filename] then
        if #compile_flags[filename].includes > 0 then
            vim.api.nvim_buf_set_option(
                bufnum,
                'path',
                '.,,'..table.concat(compile_flags[filename].includes, ',')
            )
        end

        if #compile_flags[filename].flags > 0 and not has_tidy then
            local config_flags = table.concat(compile_flags[filename].flags, ' ')
            vim.api.nvim_buf_set_option(
                bufnum,
                'makeprg',
                ('%s %s -o %s %%'):format(compiler, config_flags, vim.fn.tempname())
            )
        end
    elseif not has_tidy then
        local config_flags = table.concat(default_flags[compiler], ' ')
        vim.api.nvim_buf_set_option(
            bufnum,
            'makeprg',
            ('%s %s -o %s %%'):format(compiler, config_flags, vim.fn.tempname())
        )
    end
end

function M.setup()
    local compiler = get_compiler()
    local bufnum = nvim.get_current_buf()
    local bufname = nvim.buf.get_name(0)
    local cwd = is_file(bufname) and basedir(bufname) or getcwd()
    if compiler then
        local flags_file = vim.fn.findfile('compile_flags.txt', cwd..';')
        local db_file = vim.fn.findfile('compile_commands.json', cwd..';')
        local has_tidy = false
        if executable('clang-tidy') and (flags_file ~= '' or db_file ~= '') then
            has_tidy = true
            vim.bo.makeprg = 'clang-tidy %'
            vim.bo.errorformat = '%E%f:%l:%c: fatal error: %m,%E%f:%l:%c: error: %m,%W%f:%l:%c: warning: %m'
        end
        if flags_file ~= '' then
            local filename = realpath(normalize_path(flags_file))
            if not compile_flags[filename] then
                readfile(filename, function(data)
                    if data and #data > 0 then
                        compile_flags[filename] = {
                            flags = {},
                            includes = {},
                        }
                        for _,line in pairs(data) do
                            if line:sub(1, 1) == '-' or line:sub(1, 1) == '/' then
                                table.insert(compile_flags[filename].flags, line)
                            end
                            if line:sub(1, 2) == '-I' or line:sub(1, 2) == '/I' then
                                local path = line:sub(3, #line):gsub('^%s+', '')
                                table.insert(compile_flags[filename].includes, path)
                            end
                        end
                        vim.schedule_wrap(function()
                            set_opts(filename, has_tidy, compiler, bufnum)
                        end)()
                    end
                end)
            else
                set_opts(filename, has_tidy, compiler, bufnum)
            end
        elseif not has_tidy then
            -- NOTE: We need to call this multiple times since readfile is async
            set_opts(nil, has_tidy, compiler, bufnum)
        end
    end
end

M.setup()

return M

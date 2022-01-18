local load_module = require('utils.helpers').load_module
local null_ls = load_module 'null-ls'
local sys = require 'sys'

local executable = require('utils.files').executable
local is_file = require('utils.files').is_file

if not null_ls then
    return {}
end

local languages = { 'cpp', 'lua', 'python', 'vim', 'sh' }
local servers = {}

-- TODO: Respect config files Ex. compile_commands.json, stylua.toml, pyproject.toml, etc
for _, lang in ipairs(languages) do
    local ok, module = pcall(require, 'filetypes.' .. lang)
    if ok then
        if module.formatprg then
            if not servers[lang] then
                servers[lang] = {}
            end
            servers[lang].formatprg = vim.deepcopy(module.formatprg)
        end
        if module.makeprg then
            if not servers[lang] then
                servers[lang] = {}
            end
            servers[lang].makeprg = vim.deepcopy(module.makeprg)
        end
    end
end

servers.c = servers.cpp
servers.bash = servers.sh

local M = {}

if servers.lua then
    M.lua = {}
    if executable 'stylua' then
        table.insert(
            M.lua,
            null_ls.builtins.formatting.stylua.with {
                args = function(params)
                    local args = {}

                    local realpath = require('utils.files').realpath

                    local project = vim.fn.findfile('stylua.toml', '.;')
                    project = project ~= '' and realpath(project) or nil

                    if not project then
                        args = vim.deepcopy(servers.lua.formatprg.stylua)
                        for idx, arg in ipairs(args) do
                            if arg == 'WIDTH' then
                                args[idx] = require('utils.buffers').get_indent()
                                break
                            end
                        end
                    else
                        vim.list_extend(args, { '-s', '-' })
                    end

                    return args
                end,
            }
        )
    end

    if executable 'luacheck' then
        table.insert(
            M.lua,
            null_ls.builtins.diagnostics.luacheck.with {
                extra_args = function(params)
                    return vim.deepcopy(servers.lua.makeprg.luacheck)
                end,
            }
        )
    else
        local exe = {
            sys.home .. '/.luarocks/bin/luacheck',
            sys.home .. '/cache/nvim/packer_hererocks/' .. sys.luajit .. '/bin/luacheck',
        }
        for i = 1, #exe do
            if is_file(exe[i]) then
                table.insert(
                    M.lua,
                    null_ls.builtins.diagnostics.luacheck.with {
                        command = exe[1],
                        extra_args = function(params)
                            return vim.deepcopy(servers.lua.makeprg.luacheck)
                        end,
                    }
                )
            end
        end
    end
end

if servers.sh then
    M.sh = {}
    if executable 'shfmt' then
        table.insert(
            M.sh,
            null_ls.builtins.formatting.shfmt.with {
                extra_args = function(params)
                    local args = vim.deepcopy(servers.sh.formatprg.shfmt)
                    for idx, arg in ipairs(args) do
                        if arg == 'WIDTH' then
                            args[idx] = require('utils.buffers').get_indent()
                            break
                        end
                    end
                    return args
                end,
            }
        )
    end
    if executable 'shellcheck' then
        table.insert(
            M.sh,
            null_ls.builtins.diagnostics.shellcheck.with {
                extra_args = function(params)
                    local args = vim.deepcopy(servers.sh.makeprg.shellcheck)
                    -- NOTE: Remove gcc format
                    table.remove(args, 1)
                    table.remove(args, 1)
                    return args
                end,
            }
        )
    end
end

return M

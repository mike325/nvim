local executable = require('utils.files').executable
local sys = require 'sys'
local is_file = require('utils.files').is_file

local M = {
    makeprg = {
        luacheck = {
            '--max-cyclomatic-complexity',
            '20',
            '--std',
            'luajit',
            '--formatter',
            'plain',
            '--codes',
            '--ranges',
        },
    },
    formatprg = {
        stylua = {
            '--indent-type',
            'Spaces',
            '--indent-width',
            'WIDTH',
            '--quote-style',
            'AutoPreferSingle',
            '--column-width',
            '120',
            '--call-parentheses',
            'None',
        },
    },
}

function M.get_formatter()
    local cmd
    if executable 'stylua' then
        cmd = { 'stylua' }
        local config = vim.fn.findfile('.stylua.toml', '.;')
        if config == '' then
            config = vim.fn.findfile('stylua.toml', '.;')
            if config == '' then
                vim.list_extend(cmd, M.formatprg[cmd[1]])
                cmd = require('utils.buffers').replace_indent(cmd)
            end
        end
    end
    return cmd
end

function M.get_linter()
    local cmd
    if executable 'luacheck' then
        cmd = { 'luacheck' }
        vim.list_extend(cmd, M.makeprg[cmd[1]])
    else
        local exe = {
            sys.home .. '/.luarocks/bin/luacheck',
            sys.home .. '/cache/nvim/packer_hererocks/' .. sys.luajit .. '/bin/luacheck',
        }
        for i = 1, #exe do
            if is_file(exe[i]) then
                cmd = { exe[i] }
                vim.list_extend(cmd, M.makeprg[cmd[1]])
                break
            end
        end
    end
    return cmd
end

function M.format()
    if executable 'stylua' then
        local buffer = vim.api.nvim_get_current_buf()
        local external_formatprg = require('utils.functions').external_formatprg
        local realpath = require('utils.files').realpath

        local project = vim.fn.findfile('stylua.toml', '.;')
        project = project ~= '' and realpath(project) or nil

        local cmd = { 'stylua' }
        if not project then
            vim.list_extend(cmd, M.formatprg.stylua)
        else
            table.insert(cmd, '-s')
        end

        external_formatprg {
            cmd = require('utils.buffers').replace_indent(cmd),
            buffer = buffer,
            -- efm = '%trror: cannot format %f: Cannot parse %l:c: %m,%trror: cannot format %f: %m',
        }
    else
        return 1
    end

    return 0
end

return M

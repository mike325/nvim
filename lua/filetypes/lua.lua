local sys = require 'sys'
-- local nvim = require 'nvim'

local executable = require('utils.files').executable
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
            '$WIDTH',
            '--quote-style',
            'AutoPreferSingle',
            '--column-width',
            '120',
            '--call-parentheses',
            'None',
        },
    },
}

-- TODO: Extract config file lookup function to centralize the logic
function M.get_formatter(_)
    local cmd
    if executable 'stylua' then
        cmd = { 'stylua' }
        local config_file = RELOAD('utils.buffers').find_config { configs = { '.stylua.toml', 'stylua.toml' } }
        if config_file then
            vim.list_extend(cmd, { '-f', config_file })
        else
            vim.list_extend(cmd, M.formatprg[cmd[1]])
            cmd = require('utils.buffers').replace_indent(cmd)
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
            vim.fn.stdpath('cache'):gsub('\\', '/') .. '/packer_hererocks/' .. sys.luajit .. '/bin/luacheck',
        }
        for i = 1, #exe do
            if is_file(exe[i]) then
                cmd = { exe[i] }
                vim.list_extend(cmd, M.makeprg[vim.fs.basename(cmd[1])])
                break
            end
        end
    end
    return cmd
end

return M

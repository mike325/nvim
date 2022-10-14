local sys = require 'sys'
local nvim = require 'neovim'

local executable = require('utils.files').executable

local is_file = require('utils.files').is_file
local getcwd = require('utils.files').getcwd

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
function M.get_formatter(stdin)
    local cmd
    if executable 'stylua' then
        cmd = { 'stylua' }
        local configs = { '.stylua.toml', 'stylua.toml' }

        -- TODO: lookup upwards in file's directory
        local dirs = { getcwd() }

        local buffer = nvim.buf.get_name(0)
        if buffer ~= '' and not buffer:match '^%w+:/' then
            table.insert(dirs, 1, vim.fs.dirname(buffer))
        end

        local found = false
        for _, cwd in ipairs(dirs) do
            local config_path = vim.fs.find(configs, { upward = true, type = 'file', path = cwd })
            if #config_path > 0 then
                vim.list_extend(cmd, { '-f', require('utils.files').realpath(config_path[1]) })
                found = true
                break
            end
        end
        if not found then
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

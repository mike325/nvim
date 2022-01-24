local executable = require('utils.files').executable

local M = {
    makeprg = {
        shellcheck = {
            '-f',
            'gcc',
            '-x',
            '-e',
            '1117',
        },
    },
    formatprg = {
        shfmt = {
            '-i',
            'WIDTH',
            '-s',
            '-ci',
            '-kp',
            '-w',
        },
    },
}

function M.get_formatter()
    local cmd
    if executable 'shfmt' then
        cmd = { 'shfmt' }
        vim.list_extend(cmd, M.formatprg[cmd[1]])
        cmd = require('utils.buffers').replace_indent(cmd)
    end
    return cmd
end

function M.get_linter()
    local cmd
    if executable 'shellcheck' then
        cmd = { 'shellcheck' }
        vim.list_extend(cmd, M.makeprg[cmd[1]])
    end
    return cmd
end

function M.format()
    local buffer = vim.api.nvim_get_current_buf()
    local external_formatprg = require('utils.functions').external_formatprg

    if executable 'shfmt' then
        local cmd = { 'shfmt' }
        vim.list_extend(cmd, M.formatprg.shfmt)

        external_formatprg {
            cmd = require('utils.buffers').replace_indent(cmd),
            buffer = buffer,
        }
    else
        return 1
    end

    return 0
end

return M

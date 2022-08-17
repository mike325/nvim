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
            '$WIDTH',
            '-s',
            '-ci',
            '-kp',
        },
    },
}

function M.get_formatter(stdin)
    local cmd
    if executable 'shfmt' then
        cmd = { 'shfmt' }
        vim.list_extend(cmd, M.formatprg[cmd[1]])
        cmd = require('utils.buffers').replace_indent(cmd)
        if not stdin then
            table.insert(cmd, '-w')
        end
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

return M

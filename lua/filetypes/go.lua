local executable = require('utils.files').executable

local M = {
    makeprg = {},
    formatprg = {
        gofmt = {
            '-s',
        },
    },
}

function M.get_formatter(stdin)
    local cmd
    if executable 'gofmt' then
        cmd = { 'gofmt' }
        vim.list_extend(cmd, M.formatprg[cmd[1]])
        if not stdin then
            table.insert(cmd, '-w')
        end
    end
    return cmd
end

function M.get_linter()
    return false
end

return M

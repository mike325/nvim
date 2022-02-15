local executable = require('utils.files').executable

local M = {
    makeprg = {},
    formatprg = {
        gofmt = {
            '-s',
            '-w',
        },
    },
}

function M.get_formatter()
    local cmd
    if executable 'gofmt' then
        cmd = { 'gofmt' }
        vim.list_extend(cmd, M.formatprg[cmd[1]])
    end
    return cmd
end

function M.get_linter()
    return false
end

return M

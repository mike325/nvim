local executable = require('utils.files').executable

local M = {
    makeprg = {},
    formatprg = {
        rustfmt = {},
    },
}

function M.get_formatter(stdin)
    local cmd
    if executable 'rustfmt' then
        cmd = { 'rustfmt' }
        vim.list_extend(cmd, M.formatprg[cmd[1]])
    end
    return cmd
end

function M.get_linter()
    return false
end

return M

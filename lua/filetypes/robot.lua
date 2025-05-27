local executable = require('utils.files').executable

local M = {
    makeprg = {},
    formatprg = {
        robotidy = {
            '--overwrite',
            '--no-color',
            '--indent',
            '$WIDTH',
        },
    },
}

function M.get_formatter(_)
    local cmd
    if executable 'robotidy' then
        cmd = { 'robotidy' }
        vim.list_extend(cmd, M.formatprg[cmd[1]])
    end
    return cmd
end

function M.get_linter()
    return false
end

return M

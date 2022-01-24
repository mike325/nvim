local executable = require('utils.files').executable

local M = {
    makeprg = {
        vint = {
            '--enable-neovim',
            '-t',
            '-w',
        },
    },
}

function M.get_linter()
    local cmd
    if executable 'vint' then
        cmd = { 'vint' }
        vim.list_extend(cmd, M.makeprg[cmd[1]])
    end
    return cmd
end

function M.get_formatter()
    return false
end

return M

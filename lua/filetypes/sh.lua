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
            'WITHD',
            '-s',
            '-ci',
            '-kp',
            '-w',
        },
    },
}

function M.format()
    local buffer = vim.api.nvim_get_current_buf()
    local external_formatprg = require('utils.functions').external_formatprg

    if executable 'shfmt' then
        local cmd = { 'shfmt' }
        vim.list_extend(cmd, M.formatprg.shfmt)

        for idx, arg in ipairs(cmd) do
            if arg == 'WIDTH' then
                cmd[idx] = require('utils.buffers').get_indent()
                break
            end
        end

        external_formatprg {
            cmd = cmd,
            buffer = buffer,
        }
    else
        -- Fallback to internal formater
        return 1
    end

    return 0
end

return M

local executable = require('utils').files.executable

local M = {}

function M.format()
    local buffer = vim.api.nvim_get_current_buf()
    local external_formatprg = require('utils').functions.external_formatprg

    if executable 'shfmt' then
        external_formatprg {
            cmd = {
                'shfmt',
                '-i',
                '4',
                '-s',
                '-ci',
                '-kp',
                '-w',
            },
            buffer = buffer,
        }
    else
        -- Fallback to internal formater
        return 1
    end

    return 0
end

return M

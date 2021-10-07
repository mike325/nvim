local M = {}

function M.format()
    local buffer = vim.api.nvim_get_current_buf()
    local external_formatprg = require('utils.functions').external_formatprg

    local project = vim.fn.findfile('stylua.toml', '.;')

    if require('utils.files').executable 'stylua' then
        local cmd = { 'stylua' }
        if project == '' then
            vim.list_extend(cmd, {
                '--indent-type',
                'Spaces',
                '--indent-width',
                '4',
                '--quote-style',
                'AutoPreferSingle',
                '--column-width',
                '110',
            })
        end
        external_formatprg {
            cmd = cmd,
            buffer = buffer,
            -- efm = '%trror: cannot format %f: Cannot parse %l:c: %m,%trror: cannot format %f: %m',
        }
    end
end

return M

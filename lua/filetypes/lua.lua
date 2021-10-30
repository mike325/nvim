local M = {}

function M.format()
    if require('utils.files').executable 'stylua' then
        local buffer = vim.api.nvim_get_current_buf()
        local external_formatprg = require('utils.functions').external_formatprg
        local realpath = require('utils.files').realpath

        local project = vim.fn.findfile('stylua.toml', '.;')
        project = project ~= '' and realpath(project) or nil

        local cmd = { 'stylua' }
        if not project then
            vim.list_extend(cmd, {
                '--indent-type',
                'Spaces',
                '--indent-width',
                '4',
                '--quote-style',
                'AutoPreferSingle',
                '--column-width',
                '120',
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

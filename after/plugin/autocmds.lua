local nvim = require 'nvim'

if not nvim.plugins['nvim-bqf'] then
    vim.api.nvim_create_autocmd({ 'FileType' }, {
        desc = 'Setup Qf mappings to navigate old/new lists',
        group = vim.api.nvim_create_augroup('QuickfixMappings', { clear = true }),
        pattern = 'qf',
        callback = function(_)
            local is_loclist = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].loclist == 1
            local cmd_prefix = is_loclist and 'l' or 'c'
            vim.keymap.set(
                'n',
                '<',
                ('<cmd>%solder<CR>'):format(cmd_prefix),
                { noremap = true, silent = true, nowait = true, buffer = true }
            )
            vim.keymap.set(
                'n',
                '>',
                ('<cmd>%snewer<CR>'):format(cmd_prefix),
                { noremap = true, silent = true, nowait = true, buffer = true }
            )
        end,
    })
end

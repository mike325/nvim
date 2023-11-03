local nvim = require 'nvim'

if not vim.keymap then
    vim.keymap = nvim.keymap
end

local has_mini = nvim.plugins['mini.nvim'] ~= nil

if not has_mini then
    vim.keymap.set('n', ']e', [[:<C-U>lua require"mappings".move_line(true)<CR>]], { noremap = true, silent = true })
    vim.keymap.set('n', '[e', [[:<C-U>lua require"mappings".move_line(false)<CR>]], { noremap = true, silent = true })
end

if not nvim.plugins['vim-commentary'] and not nvim.plugins['Comment.nvim'] and not nvim.plugins['mini.nvim'] then
    vim.keymap.set(
        'n',
        'gc',
        '<cmd>set opfunc=neovim#comment<CR>g@',
        { noremap = true, silent = true, desc = 'Custom comment surrunding {motion}' }
    )

    vim.keymap.set(
        'v',
        'gc',
        ':<C-U>call neovim#comment(visualmode(), v:true)<CR>',
        { noremap = true, silent = true, desc = 'Custom comment surrunding visual selection' }
    )

    vim.keymap.set('n', 'gcc', function()
        local cursor = vim.api.nvim_win_get_cursor(0)
        require('utils.functions').toggle_comments(cursor[1] - 1, cursor[1])
        vim.api.nvim_win_set_cursor(0, cursor)
    end, { noremap = true, silent = true, desc = 'Custom comment surrunding current line' })
end

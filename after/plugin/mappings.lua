local nvim = require 'neovim'

if not vim.keymap then
    vim.keymap = nvim.keymap
end

if not nvim.plugins['vim-commentary'] and not nvim.plugins['Comment.nvim'] then
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

if not nvim.plugins['nvim-cmp'] then
    vim.keymap.set(
        'i',
        '<TAB>',
        [[<C-R>=neovim#tab()<CR>]],
        { noremap = true, silent = true, desc = 'Custom TAB completion' }
    )
    vim.keymap.set(
        'i',
        '<S-TAB>',
        [[<C-R>=neovim#shifttab()<CR>]],
        { noremap = true, silent = true, desc = 'Custom Shift TAB completion' }
    )
    vim.keymap.set(
        'i',
        '<CR>',
        [[<C-R>=neovim#enter()<CR>]],
        { noremap = true, silent = true, desc = 'Custom CR action' }
    )
end

if nvim.plugins['vim-fugitive'] then
    vim.keymap.set('n', '=e', '<cmd>Gedit<CR>', { noremap = true, silent = true, desc = 'Fugitive Gedit shortcut' })
end

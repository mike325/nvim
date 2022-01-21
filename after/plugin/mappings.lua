if not vim.keymap then
    vim.keymap = require('nvim').keymap
end

-- local noremap = { noremap = true }
local noremap_silent = { noremap = true, silent = true }

if
    not packer_plugins
    or (packer_plugins and not packer_plugins['vim-commentary'] and not packer_plugins['Comment.nvim'])
then
    vim.keymap.set('n', 'gc', '<cmd>set opfunc=neovim#comment<CR>g@', noremap_silent)

    vim.keymap.set('v', 'gc', ':<C-U>call neovim#comment(visualmode(), v:true)<CR>', noremap_silent)

    vim.keymap.set('n', 'gcc', function()
        local cursor = vim.api.nvim_win_get_cursor(0)
        require('utils.functions').toggle_comments(cursor[1] - 1, cursor[1])
        vim.api.nvim_win_set_cursor(0, cursor)
    end, noremap_silent)
end

if not packer_plugins or (packer_plugins and not packer_plugins['nvim-cmp']) then
    -- TODO: Migrate to lua functions
    vim.keymap.set('i', '<TAB>', [[<C-R>=neovim#tab()<CR>]], noremap_silent)

    -- TODO: Migrate to lua functions
    vim.keymap.set('i', '<S-TAB>', [[<C-R>=neovim#shifttab()<CR>]], noremap_silent)

    -- TODO: Migrate to lua functions
    vim.keymap.set('i', '<CR>', [[<C-R>=neovim#enter()<CR>]], noremap_silent)
end

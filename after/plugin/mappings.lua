local nvim = require 'nvim'

if not vim.keymap then
    vim.keymap = nvim.keymap
end

-- TODO: Lazy check for mini
local has_mini = nvim.plugins['mini.nvim'] ~= nil or (vim.g.minimal and vim.F.npcall(require, 'mini.comment') ~= nil)
local has_cmp = nvim.plugins['nvim-cmp']

if not has_mini then
    vim.keymap.set('n', ']e', [[:<C-U>lua require"mappings.keymaps".move_line(true)<CR>]], { noremap = true, silent = true })
    vim.keymap.set('n', '[e', [[:<C-U>lua require"mappings.keymaps".move_line(false)<CR>]], { noremap = true, silent = true })
end

-- NOTE: Neovim 0.10 now have builtin comment support, this is no longer needed
local missing_comment = not nvim.plugins['vim-commentary'] and not nvim.plugins['Comment.nvim'] and not has_mini
if not nvim.has { 0, 10 } and missing_comment then
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

if not has_cmp then
    local maps = require 'completions.mappings'

    vim.keymap.set({ 'i', 's' }, '<Tab>', function()
        maps.next_item()
    end, { noremap = true })

    vim.keymap.set({ 'i', 's' }, '<S-Tab>', function()
        maps.prev_item()
    end, { noremap = true })

    vim.keymap.set({ 'i', 's' }, '<CR>', function()
        maps.enter_item()
    end, { noremap = true })

    vim.keymap.set({ 'i', 's' }, '<c-y>', function()
        maps.enter_item()
    end, { noremap = true })

    vim.keymap.set({ 'i', 's' }, '<c-e>', function()
        maps.close()
    end, { noremap = true })
end

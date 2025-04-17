local nvim = require 'nvim'

if not vim.keymap then
    vim.keymap = nvim.keymap
end

-- TODO: Lazy check for mini
local has_mini = nvim.plugins['mini.nvim'] ~= nil or (vim.g.minimal and vim.F.npcall(require, 'mini.comment') ~= nil)

if not has_mini then
    vim.keymap.set(
        'n',
        ']e',
        [[:<C-U>lua require"mappings.keymaps".move_line(true)<CR>]],
        { noremap = true, silent = true }
    )
    vim.keymap.set(
        'n',
        '[e',
        [[:<C-U>lua require"mappings.keymaps".move_line(false)<CR>]],
        { noremap = true, silent = true }
    )
end

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

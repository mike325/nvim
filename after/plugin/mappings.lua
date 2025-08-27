local nvim = require 'nvim'

if not vim.keymap then
    vim.keymap = nvim.keymap
end

if not nvim.has { 0, 11 } then
    local mapping_pairs = {
        arglist = '',
        tag = 't',
        buflist = 'b',
        quickfix = 'c',
        loclist = 'l',
    }

    local maps = {
        first = '[',
        last = ']',
        previous = '[',
        next = ']',
    }

    for postfix_map, prefix_cmd in pairs(mapping_pairs) do
        local prefix = postfix_map:sub(1, 1)
        for map_type, key in pairs(maps) do
            local iterator = not (map_type == 'last' or map_type == 'first')
            local action_key = iterator and prefix or prefix:upper()
            local count = iterator and 'exe "".(v:count ? v:count : "")."' or ''
            vim.keymap.set(
                'n',
                string.format('%s%s', key, action_key),
                string.format(':<C-U>%s%s%s%s<CR>zvzz', count, prefix_cmd, map_type, iterator and '"' or ''),
                {
                    noremap = true,
                    silent = true,
                    desc = string.format('Go to the %s element of the %s', map_type, postfix_map),
                }
            )
        end

        if prefix == 'q' or prefix == 'l' then
            vim.keymap.set(
                'n',
                '[' .. string.format('<C-%s>', prefix),
                ':<C-U>exe "".(v:count ? v:count : "")."' .. prefix_cmd .. 'pfile"<CR>zvzz',
                { noremap = true, silent = true, desc = 'Go to the prev file of the ' .. postfix_map }
            )
            vim.keymap.set(
                'n',
                ']' .. string.format('<C-%s>', prefix),
                ':<C-U>exe "".(v:count ? v:count : "")."' .. prefix_cmd .. 'nfile"<CR>zvzz',
                { noremap = true, silent = true, desc = 'Go to the next file of the ' .. postfix_map }
            )
        elseif prefix == 't' then
            vim.keymap.set(
                'n',
                '[' .. string.format('<C-%s>', prefix),
                ':<C-U>exe "".(v:count ? v:count : "")."p' .. prefix_cmd .. 'previous"<CR>zvzz',
                { noremap = true, silent = true, desc = 'Go to the prev file of the ' .. postfix_map }
            )
            vim.keymap.set(
                'n',
                ']' .. string.format('<C-%s>', prefix),
                ':<C-U>exe "".(v:count ? v:count : "")."p' .. prefix_cmd .. 'next"<CR>zvzz',
                { noremap = true, silent = true, desc = 'Go to the next file of the ' .. postfix_map }
            )
        end
    end
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

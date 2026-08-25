-- TODO: should this be buffer local ?

local ts_textobjects = require 'utils.treesitter.textobjects'

local select = require 'nvim-treesitter-textobjects.select'
for keymap, ts_capture in pairs(ts_textobjects.select) do
    vim.keymap.set({ 'x', 'o' }, keymap, function()
        select.select_textobject(ts_capture, 'textobjects')
    end)
end

local swap = require 'nvim-treesitter-textobjects.swap'
for ts_motion, mappings in pairs(ts_textobjects.swap) do
    for keymap, ts_capture in pairs(mappings) do
        local action = string.format('swap_%s', ts_motion == 'swap_next' and 'next' or 'previous')
        vim.keymap.set('n', keymap, function()
            swap[action](ts_capture)
        end)
    end
end

local move = require 'nvim-treesitter-textobjects.move'
for ts_motion, mappings in pairs(ts_textobjects.move) do
    for ts_jump, ts_objects in pairs(mappings) do
        local action = string.format('goto_%s_%s', ts_motion, ts_jump == 'range_start' and 'start' or 'end')
        for keymap, ts_capture in pairs(ts_objects) do
            vim.keymap.set({ 'n', 'x', 'o' }, keymap, function()
                move[action](ts_capture, 'textobjects')
            end)
        end
    end
end

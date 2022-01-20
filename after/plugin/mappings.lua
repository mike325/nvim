local set_mapping = require('neovim.mappings').set_mapping

-- local plugins = require('neovim').plugins

-- local noremap = { noremap = true }
local noremap_silent = { noremap = true, silent = true }

if not packer_plugins or (packer_plugins and not packer_plugins['vim-commentary']) then
    set_mapping {
        mode = 'n',
        lhs = 'gc',
        rhs = '<cmd>set opfunc=neovim#comment<CR>g@',
        args = noremap_silent,
    }

    set_mapping {
        mode = 'v',
        lhs = 'gc',
        rhs = ':<C-U>call neovim#comment(visualmode(), v:true)<CR>',
        args = noremap_silent,
    }

    set_mapping {
        mode = 'n',
        lhs = 'gcc',
        rhs = function()
            local cursor = vim.api.nvim_win_get_cursor(0)
            require('utils.functions').toggle_comments(cursor[1] - 1, cursor[1])
            vim.api.nvim_win_set_cursor(0, cursor)
        end,
        args = noremap_silent,
    }
end

if not packer_plugins or (packer_plugins and not packer_plugins['nvim-cmp']) then
    -- TODO: Migrate to lua functions
    set_mapping {
        mode = 'i',
        lhs = '<TAB>',
        rhs = [[<C-R>=neovim#tab()<CR>]],
        args = noremap_silent,
    }

    -- TODO: Migrate to lua functions
    set_mapping {
        mode = 'i',
        lhs = '<S-TAB>',
        rhs = [[<C-R>=neovim#shifttab()<CR>]],
        args = noremap_silent,
    }

    -- TODO: Migrate to lua functions
    set_mapping {
        mode = 'i',
        lhs = '<CR>',
        rhs = [[<C-R>=neovim#enter()<CR>]],
        args = noremap_silent,
    }
end

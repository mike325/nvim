if vim.fn.executable 'git' == 0 then
    return {}
end

return {
    {
        'tpope/vim-fugitive',
        cmd = { 'G' },
        event = { 'CursorHold', 'CursorHoldI' },
        config = function()
            vim.keymap.set(
                'n',
                '=e',
                '<cmd>Gedit<CR>',
                { noremap = true, silent = true, desc = 'Fugitive Gedit shortcut' }
            )
        end,
    },
    {
        'junegunn/gv.vim',
        cmd = 'GV',
        dependencies = {
            { 'tpope/vim-fugitive' },
        },
    },
    {
        'sindrets/diffview.nvim',
        cond = require('storage').has_version('git', { '2', '31', '0' }),
        config = function()
            require 'configs.diffview'
            vim.keymap.set(
                'n',
                '<leader>D',
                '<cmd>DiffviewOpen<CR>',
                { noremap = true, silent = true, desc = 'Open DiffView' }
            )
        end,
        cmd = { 'DiffviewOpen', 'DiffviewFileHistory', 'DiffviewLog' },
        dependencies = {
            { 'nvim-lua/plenary.nvim' },
        },
    },

    {
        'lewis6991/gitsigns.nvim',
        event = { 'CursorHold', 'CursorHoldI' },
        dependencies = {
            { 'nvim-lua/plenary.nvim' },
        },
        opts = {
            on_attach = function(bufnr)
                local opts = {
                    -- noremap = true,
                    buffer = bufnr,
                }
                local keymaps = {
                    [']c'] = {
                        mode = 'n',
                        mapping = function()
                            if vim.opt_local.diff:get() then
                                vim.cmd.normal { bang = true, args = { ']c' } }
                            else
                                require('gitsigns.actions').next_hunk()
                            end
                        end,
                    },
                    ['[c'] = {
                        mode = 'n',
                        mapping = function()
                            if vim.opt_local.diff:get() then
                                vim.cmd.normal { bang = true, args = { '[c' } }
                            else
                                require('gitsigns.actions').prev_hunk()
                            end
                        end,
                    },
                    ['=s'] = { mode = { 'n', 'v' }, mapping = '<cmd>lua require"gitsigns".stage_hunk()<CR>' },
                    ['=S'] = { mode = 'n', mapping = '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>' },
                    ['=u'] = { mode = { 'n', 'v' }, mapping = '<cmd>lua require"gitsigns".reset_hunk()<CR>' },
                    ['=U'] = { mode = 'n', mapping = '<cmd>lua require"gitsigns".reset_buffer()<CR>' },
                    ['=f'] = { mode = 'n', mapping = '<cmd>lua require"gitsigns".preview_hunk()<CR>' },
                    ['=M'] = {
                        mode = 'n',
                        mapping = '<cmd>lua require"gitsigns".blame_line{full=false, ignore_whitespace=true}<CR>',
                    },

                    -- Text objects
                    ['ih'] = {
                        mode = { 'o', 'x' },
                        mapping = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
                    },
                    ['ah'] = {
                        mode = { 'o', 'x' },
                        mapping = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
                    },
                }

                for lhs, rhs in pairs(keymaps) do
                    vim.keymap.set(rhs.mode, lhs, rhs.mapping, opts)
                end
            end,
            -- current_line_blame = true,
            -- current_line_blame_opts = {
            --     virt_text = true,
            --     virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
            --     delay = 1000,
            --     ignore_whitespace = false,
            -- },
            -- current_line_blame_formatter_opts = {
            --     relative_time = false,
            -- },
        },
    },
    {
        'rhysd/git-messenger.vim',
        lazy = true,
        keys = '=m',
        cmd = 'GitMessenger',
        init = function()
            vim.g.git_messenger_no_default_mappings = 1
        end,
        config = function()
            vim.api.nvim_set_keymap('n', '=m', '<Plug>(git-messenger)', { silent = true, nowait = true })
        end,
    },
}

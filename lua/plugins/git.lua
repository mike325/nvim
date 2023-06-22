if vim.fn.executable 'git' == 0 then
    return {}
end

return {
    {
        'tpope/vim-fugitive',
        dependencies = {
            { 'junegunn/gv.vim', cmd = 'GV' },
        },
        cmd = { 'G' },
        event = { 'CursorHold', 'CursorHoldI' },
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
                local mappings = {
                    ['n ]c'] = {
                        "&diff ? ']c' : '<cmd>lua require\"gitsigns.actions\".next_hunk()<CR>'",
                        { expr = true },
                    },
                    ['n [c'] = {
                        "&diff ? '[c' : '<cmd>lua require\"gitsigns.actions\".prev_hunk()<CR>'",
                        { expr = true },
                    },

                    ['n =s'] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
                    ['v =s'] = '<cmd>lua require"gitsigns".stage_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
                    ['n =S'] = '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>',
                    ['n =u'] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
                    ['v =u'] = '<cmd>lua require"gitsigns".reset_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
                    ['n =U'] = '<cmd>lua require"gitsigns".reset_buffer()<CR>',
                    ['n =f'] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',
                    ['n =M'] = '<cmd>lua require"gitsigns".blame_line({full = false, ignore_whitespace = true})<CR>',

                    -- Text objects
                    ['o ih'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
                    ['x ih'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
                    ['o ah'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
                    ['x ah'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
                }
                for lhs, rhs in pairs(mappings) do
                    local opts = { buffer = bufnr, noremap = true }
                    vim.keymap.set(lhs:sub(1, 1), lhs:sub(3, #lhs), rhs[1], vim.tbl_extend('force', opts, rhs[2] or {}))
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

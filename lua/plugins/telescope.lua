return {
    {
        'nvim-telescope/telescope.nvim',
        config = function()
            require 'configs.telescope'
        end,
        dependencies = {
            { 'nvim-lua/plenary.nvim' },
            { 'nvim-lua/popup.nvim' },
        },
        event = 'CursorHold',
        cmd = 'Telescope',
        keys = { '<C-p>', '<C-b>' },
    },
    {
        'AckslD/nvim-neoclip.lua',
        config = function()
            local db_path
            local has_sqlite = require('sys').has_sqlite
            if has_sqlite then
                db_path = require('sys').db_root .. '/neoclip.sqlite3'
            end
            require('neoclip').setup {
                enable_persistent_history = has_sqlite,
                db_path = db_path,
                default_register = '+',
                keys = {
                    telescope = {
                        i = {
                            select = '<CR>',
                            paste = '<A-p>',
                            paste_behind = '<A-P>',
                        },
                        n = {
                            select = '<CR>',
                            paste = 'p',
                            paste_behind = 'P',
                        },
                    },
                },
            }
            -- Since we need to load after telescope, it should be safe to call this here
            require('telescope').load_extension 'neoclip'
        end,
        -- Windows throws an error complaining it has an invalid syntax, I look in to it later
        cond = vim.fn.has 'win32' == 0,
        priority = 100,
        event = 'TextYankPost',
        dependencies = {
            { 'nvim-telescope/telescope.nvim' },
        },
    },
}

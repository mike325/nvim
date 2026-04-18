return {
    {
        'github/copilot.vim',
        enabled = false,
    },
    {
        'folke/sidekick.nvim',
        opts = {
            -- add any options here
            cli = {
                mux = {
                    backend = 'tmux',
                    enabled = true,
                },
            },
        },
        keys = {
            {
                '<C-Space>',
                function()
                    -- if there is a next edit, jump to it, otherwise apply it if any
                    if not require('sidekick').nes_jump_or_apply() then
                        return '<C-Space>' -- fallback to normal tab
                    end
                end,
                expr = true,
                desc = 'Goto/Apply Next Edit Suggestion',
            },
            {
                '<leader>sr',
                function()
                    require('sidekick.nes').clear()
                end,
                desc = 'Clear NES suggestions',
            },
            {
                '<leader>st',
                function()
                    require('sidekick.cli').toggle()
                end,
                desc = 'Sidekick Toggle CLI',
            },
            {
                '<leader>ss',
                function()
                    require('sidekick.cli').send { msg = '{this}' }
                end,
                mode = { 'x', 'n' },
                desc = 'Send This',
            },
        },
    },
}

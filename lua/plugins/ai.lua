return {
    {
        'github/copilot.vim',
        enabled = false,
    },
    {
        'folke/sidekick.nvim',
        lazy = false,
        -- enabled = false,
        opts = {
            -- add any options here
            cli = {
                mux = {
                    backend = 'tmux',
                    create = 'split', ---@type "terminal"|"window"|"split"
                    enabled = false,
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
                [[<leader>\t]],
                function()
                    local name
                    if vim.fn.executable 'opencode' == 1 then
                        name = 'opencode'
                    end
                    require('sidekick.cli').toggle { name = name, focus = true }
                end,
                desc = 'Sidekick Toggle CLI',
            },
            {
                [[<leader>\r]],
                function()
                    require('sidekick.nes').clear()
                end,
                desc = 'Clear NES suggestions',
            },
            {
                [[<leader>\f]],
                function()
                    require('sidekick.cli').send { msg = '{file}' }
                end,
                mode = { 'x', 'n' },
                desc = 'Send current file',
            },
            {
                [[<leader>\p]],
                function()
                    require('sidekick.cli').prompt()
                end,
                mode = { 'n', 'x' },
                desc = 'Sidekick Select Prompt',
            },
        },
    },
}

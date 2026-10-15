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
                -- context = {},
                prompts = {
                    -- luacheck: ignore 631
                    committed_changes = 'Review the committed changes in this branch, use git log and patch to extract the changes, be as brief as possible',
                    -- luacheck: ignore 631
                    working_changes = 'Review the current git changes in this branch, use git diff to extract the changes, be as brief as possible',
                    diagnostics = 'Fix the diagnostics in {file}\n{diagnostics}',
                    document = 'Add documentation to {function|line}',
                    explain = 'Explain {this}',
                    -- simple context prompts
                    buffers = '{buffers}',
                    file = '{file}',
                    line = '{line}',
                    position = '{position}',
                    quickfix = '{quickfix}',
                    selection = '{selection}',
                    ['function'] = '{function}',
                    class = '{class}',
                    -- custom function prompts
                    arglist = function(ctx)
                        local prompt = 'From these files:\n%s\n'
                        local files = table.concat(
                            vim.iter(vim.fn.argv())
                                :map(function(item)
                                    return '@' .. item
                                end)
                                :totable(),
                            '\n'
                        )
                        return string.format(prompt, files)
                    end,
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

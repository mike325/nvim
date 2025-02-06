local compiler
if vim.fn.has 'win32' == 1 or vim.fn.has 'win64' == 1 then
    compiler = vim.fn.executable 'gcc' == 1
else
    compiler = vim.fn.executable 'gcc' == 1 or vim.fn.executable 'clang' == 1
end

return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
            require 'configs.treesitter'
        end,
        cond = compiler ~= nil,
        -- lazy = false,
        -- priority = 1,
        event = 'FileType',
        dependencies = {
            { 'nvim-treesitter/nvim-treesitter-refactor' },
            { 'nvim-treesitter/nvim-treesitter-textobjects' },
            { 'nvim-treesitter/nvim-treesitter-context' },
        },
    },
    -- { 'David-Kunz/markid' },
    -- { 'nvim-treesitter/nvim-tree-docs' },
    {
        'ziontee113/query-secretary',
        dependencies = {
            { 'nvim-treesitter/nvim-treesitter' },
        },
        cmd = { 'TSSecretary' },
        keys = { '<M-q>' },
        config = function()
            local nvim = require 'nvim'

            vim.keymap.set('n', '<M-q>', function()
                require('query-secretary').query_window_initiate()
            end, { desc = 'TS Query editing tool' })
            nvim.command.set('TSSecretary', function()
                require('query-secretary').query_window_initiate()
            end, { desc = 'Opens TS secretary window' })
        end,
    },
    {
        'Badhi/nvim-treesitter-cpp-tools',
        name = 'nt-cpp-tools',
        cmd = {
            'TSCppDefineClassFunc',
            'TSCppMakeConcreteClass',
            'TSCppRuleOf3',
            'TSCppRuleOf5',
        },
        dependencies = {
            { 'nvim-treesitter/nvim-treesitter' },
        },
    },
    {
        'danymat/neogen',
        config = function()
            require 'configs.neogen'
        end,
        cmd = { 'Neogen' },
        dependencies = {
            { 'nvim-treesitter/nvim-treesitter' },
        },
    },
}

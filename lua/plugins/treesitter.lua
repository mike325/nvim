local compiler
if vim.fn.has 'win32' == 1 or vim.fn.has 'win64' == 1 then
    compiler = vim.fn.executable 'gcc' == 1
else
    compiler = vim.fn.executable 'gcc' == 1 or vim.fn.executable 'clang' == 1
end

local branch = 'master'

local function get_missing_parsers()
    local extensions = { windows = 'dll', unix = 'so' }
    local ext = jit.os == 'Windows' and extensions.windows or extensions.unix
    local parsers = {}
    for parser in vim.iter(vim.api.nvim_get_runtime_file('parser/*.' .. ext, true)) do
        local bs_parser = vim.fs.basename(parser):gsub('%.%w+$', '')
        parsers[bs_parser] = true
    end
    local builtin = require('utils.treesitter').languages.builtin
    local extra_langs = require('utils.treesitter').languages.extras
    local ts_langs = vim.list_extend(vim.deepcopy(builtin), extra_langs)
    return vim.iter(ts_langs)
        :filter(function(lang)
            return not parsers[lang]
        end)
        :totable()
end

return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        branch = branch,
        cond = compiler ~= nil,
        config = function(plugin)
            if plugin.branch == 'master' then
                require 'configs.treesitter'
            elseif plugin.branch == 'main' then
                require('nvim-treesitter').setup {
                    -- Directory to install parsers and queries to (prepended to `runtimepath` to have priority)
                    install_dir = vim.fn.stdpath 'state' .. '/parsers',
                }

                local install_langs = get_missing_parsers()
                if #install_langs > 0 and vim.fn.executable 'tree-sitter' == 1 then
                    require('nvim-treesitter').install(install_langs)
                end
            end
        end,
        -- lazy = false,
        -- priority = 1,
        event = 'FileType',
        dependencies = {
            { 'nvim-treesitter/nvim-treesitter-textobjects', branch = branch },
            { 'nvim-treesitter/nvim-treesitter-refactor', enabled = branch ~= 'main' },
        },
    },
    {
        'nvim-treesitter/nvim-treesitter-context',
        opts = {
            enable = true,
            max_lines = 3,
            multiline_threshold = 1,
            min_window_height = 20,
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
            require('query-secretary').setup {
                predicates = {
                    'eq',
                    'any-of',
                    'contains',
                    'match',
                    'lua-match',
                }, -- when press "p" (predicates)

                -- default overrides
                keymaps = {
                    toggle_field_name = { 'n' },
                },
            }

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

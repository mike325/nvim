local compiler
if vim.fn.has 'win32' == 1 or vim.fn.has 'win64' == 1 then
    compiler = vim.fn.executable 'gcc' == 1
else
    compiler = vim.fn.executable 'gcc' == 1 or vim.fn.executable 'clang' == 1
end

local branch = 'main'

return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        branch = branch,
        config = function(plugin)
            if plugin.branch == 'master' then
                require 'configs.treesitter'
            elseif plugin.branch == 'main' then
                require('nvim-treesitter').setup {
                    -- Directory to install parsers and queries to (prepended to `runtimepath` to have priority)
                    install_dir = vim.fn.stdpath 'state' .. '/parsers',
                }

                local languages = {
                    'bash',
                    'cmake',
                    'comment',
                    'cpp',
                    'dockerfile',
                    'editorconfig',
                    'git_config',
                    'git_rebase',
                    'gitattributes',
                    'gitcommit',
                    'gitignore',
                    'go',
                    'ini',
                    'java',
                    'json',
                    -- 'jsonc',
                    'make',
                    'matlab',
                    'perl',
                    'python',
                    'rst',
                    'rust',
                    'ssh_config',
                    'todotxt',
                    'toml',
                    'yaml',
                    'zig',
                }

                require('nvim-treesitter').install(languages)

                table.insert(languages, 'sh')
                vim.api.nvim_create_autocmd({ 'FileType' }, {
                    desc = 'Basic TS setup when nvim-treesitter is not install',
                    group = vim.api.nvim_create_augroup('TreesitterSetup', { clear = true }),
                    pattern = table.concat(languages, ','),
                    callback = function(args)
                        local ft_mapping = {
                            sh = 'bash',
                        }
                        local filetype = vim.bo[args.buf].filetype
                        if vim.version.ge(vim.version(), { 0, 9 }) then
                            ft_mapping.help = 'vimdoc'
                        end
                        vim.treesitter.start(args.buf, ft_mapping[filetype] or filetype)
                    end,
                })

                vim.api.nvim_create_autocmd('FileType', {
                    desc = 'Setup treesitter fold expression',
                    group = vim.api.nvim_create_augroup('TreesitterFold', { clear = true }),
                    pattern = table.concat(languages, ','),
                    callback = function()
                        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                        vim.wo.foldmethod = 'expr'
                        vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
                    end,
                })
            end
        end,
        cond = compiler ~= nil,
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

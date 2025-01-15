local sys = require 'sys'

local lua_runtime = vim.split(package.path, ';')
table.insert(lua_runtime, 'lua/?.lua')
table.insert(lua_runtime, 'lua/?/init.lua')

local servers = {
    go = { { exec = 'gopls' } },
    java = { { exec = 'jdtls' } },
    sh = {
        { exec = 'bash-language-server', config = 'bashls', cmd = { 'bash-language-server', 'start' } },
    },
    dockerfile = {
        { exec = 'docker-langserver', config = 'dockerls', cmd = { 'docker-langserver', '--stdio' } },
    },
    kotlin = { { exec = 'kotlin-language-server', config = 'kotlin_language_server' } },
    rust = {
        { exec = 'rust-analyzer', config = 'rust_analyzer' },
        { exec = 'rustup', config = 'rust_analyzer', cmd = { 'rustup', 'run', 'stable', 'rust-analyzer' } },
    },
    tex = {
        {
            exec = 'texlab',
            options = {
                capabilities = {
                    textDocument = {
                        completion = {
                            completionItem = { snippetSupport = true },
                        },
                    },
                },
                settings = {
                    bibtex = {
                        formatting = {
                            lineLength = 120,
                        },
                    },
                    latex = {
                        forwardSearch = {
                            args = {},
                            onSave = false,
                        },
                        build = {
                            args = {
                                '-outdir=texlab',
                                '-pdf',
                                '-interaction=nonstopmode',
                                '-synctex=1',
                                '%f',
                            },
                            executable = 'latexmk',
                            onSave = true,
                        },
                        lint = {
                            onChange = true,
                        },
                    },
                },
            },
        },
    },
    vim = {
        {
            exec = 'vim-language-server',
            cmd = { 'vim-language-server', '--stdio' },
            config = 'vimls',
        },
    },
    lua = {
        {
            exec = 'lua-language-server',
            config = 'lua_ls',
            options = {
                settings = {
                    Lua = {
                        hint = {
                            enable = true,
                        },
                        -- completion = {
                        --     keywordSnippet = 'Enable',
                        --     callSnippet = 'Both',
                        -- },
                        runtime = {
                            -- Tell the language server which version of Lua you're using
                            -- (most likely LuaJIT in the case of Neovim)
                            version = 'LuaJIT',
                            -- Setup your lua path
                            -- path = lua_runtime,
                        },
                        workspace = {
                            -- Make the server aware of Neovim runtime files
                            -- library = vim.api.nvim_get_runtime_file('', true),
                            checkThirdParty = false,
                            library = {
                                vim.env.VIMRUNTIME,
                            },
                        },
                        telemetry = {
                            enable = false,
                        },
                        diagnostics = {
                            globals = {
                                'packer_plugins',
                                'bit',
                                'vim',
                                'nvim',
                                'python',
                                'P',
                                'RELOAD',
                                'PASTE',
                                'STORAGE',
                                'use',
                                'use_rocks',
                                'describe',
                                'it',
                                'before_each',
                                'after_each',
                                'setup',
                                'teardown',
                                'assert',
                            },
                        },
                    },
                },
            },
        },
    },
    python = {
        {
            exec = 'pylsp',
            options = {
                cmd = {
                    'pylsp',
                    '--check-parent-process',
                    '--log-file=/tmp/pylsp.log',
                },
                capabilities = {
                    textDocument = {
                        completion = {
                            completionItem = { snippetSupport = true },
                        },
                    },
                },
                settings = {
                    pylsp = {
                        plugins = {
                            jedi = {
                                extra_paths = {},
                            },
                            jedi_completion = {
                                enabled = true,
                                fuzzy = true,
                                include_params = true,
                            },
                            flake8 = {
                                enabled = true,
                                config = './.flake8',
                            },
                            ruff = {
                                enabled = false, -- Enable the plugin
                                formatEnabled = false, -- Enable formatting using ruffs formatter
                            },
                            pylsp_mypy = { enabled = true },
                            pyflakes = { enabled = true },
                            mccabe = { enabled = true },
                            pylint = { enabled = true },
                            pycodestyle = { enabled = false },
                            black = { enabled = false },
                        },
                    },
                },
            },
        },
        {
            exec = 'basedpyright',
            cmd = {
                'basedpyright',
                -- '--stdio',
                -- '--pythonplatform',
                -- 'Linux',
                -- '--pythonversion',
                -- '3.8',
                '--threads',
                '4',
            },
            options = {
                settings = {
                    python = {
                        analysis = {
                            autoSearchPaths = true,
                            diagnosticMode = 'workspace',
                            useLibraryCodeForTypes = true,
                            typeCheckingMode = 'basic', -- "off", "basic", "strict"
                            verboseOutput = true,
                            -- extraPaths = {},
                            reportMissingImports = 'none',
                            ['dummy-variables-rgx'] = '(Fake+[a-zA-Z0-9]*?$)|(Stub+[a-zA-Z0-9]*?$)',
                        },
                    },
                },
            },
        },
        {
            exec = 'pylyzer',
            cmd = { 'pylyzer', '--server' },
            options = {
                settings = {
                    python = {
                        checkOnType = false,
                        diagnostics = false,
                        inlayHints = true,
                        smartCompletion = true,
                    },
                },
            },
        },
        {
            exec = 'ruff',
            cmd = {
                'ruff',
                'server',
                '--preview',
                -- '--config',
                -- './ruff.toml',
            },
        },
        {
            exec = 'jedi-language-server',
            config = 'jedi_language_server',
            options = {
                init_options = {
                    disableSnippets = false,
                },
                -- capabilities = {
                --     textDocument = {
                --         completion = {
                --             completionItem = { snippetSupport=true }
                --         }
                --     }
                -- },
            },
        },
    },
    c = {
        {
            exec = 'clangd',
            options = {
                cmd = {
                    'clangd',
                    '--fallback-style=Google',
                    '--clang-tidy',
                    '--header-insertion=iwyu',
                    '--function-arg-placeholders',
                    '--completion-style=bundled',
                    -- '--pch-storage=memory',
                    '--background-index',
                    '--malloc-trim',
                    '--log=error',
                },
                cmd_env = {
                    -- NOTE: pchs directory is not created by default, needs to be manually created
                    TMPDIR = './.cache/clangd/pchs/',
                },
                capabilities = {
                    offsetEncoding = { 'utf-16' }, -- TODO: Check if this cause side effects
                    textDocument = {
                        completion = {
                            completionItem = { snippetSupport = true },
                        },
                    },
                },
                init_options = {
                    usePlaceholders = true,
                    completeUnimported = true,
                    clangdFileStatus = true,
                },
            },
            commands = {
                Switch = {
                    function()
                        require('configs.lsp.utils').switch_source_header_splitcmd(0, 'edit')
                    end,
                    description = 'Open source/header in current buffer',
                },
                SwitchVSplit = {
                    function()
                        require('configs.lsp.utils').switch_source_header_splitcmd(0, 'vsplit')
                    end,
                    description = 'Open source/header in a new vsplit',
                },
                SwitchSplit = {
                    function()
                        require('configs.lsp.utils').switch_source_header_splitcmd(0, 'split')
                    end,
                    description = 'Open source/header in a new split',
                },
            },
        },
        {
            exec = 'ccls',
            options = {
                cmd = { 'ccls', '--log-file=' .. sys.tmp 'ccls.log' },
                capabilities = {
                    textDocument = {
                        completion = {
                            completionItem = { snippetSupport = true },
                        },
                    },
                },
                settings = {
                    init_options = {
                        compilationDatabaseDirectory = 'build',
                        index = {
                            threads = 0,
                        },
                        -- clang = {
                        --     excludeArgs = { "-frounding-math"} ;
                        -- },
                    },
                    ccls = {
                        cache = {
                            directory = sys.cache .. '/ccls',
                        },
                        completion = {
                            filterAndSort = true,
                            caseSensitivity = 1,
                            detailedLabel = false,
                        },
                    },
                },
            },
        },
    },
}

servers.cpp = servers.c
servers.objc = servers.c
servers.objcpp = servers.c
servers.cuda = servers.c

servers.Dockerfile = servers.dockerfile

servers.bib = servers.tex

return servers

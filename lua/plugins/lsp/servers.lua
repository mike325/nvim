local sys = require 'sys'

local system_name = ''
if sys.name == 'osx' then
    system_name = 'macOS'
elseif sys.name == 'linux' then
    system_name = 'Linux'
elseif sys.name == 'windows' then
    system_name = 'Windows'
else
    vim.notify('Unsupported system for sumneko', 'ERROR', { title = 'LSP' })
end

local function switch_source_header_splitcmd(bufnr, splitcmd)
    bufnr = require('lspconfig').util.validate_bufnr(bufnr)
    local params = { uri = vim.uri_from_bufnr(bufnr) }
    vim.lsp.buf_request(bufnr, 'textDocument/switchSourceHeader', params, function(err, _, result)
        if err then
            error(debug.traceback(tostring(err)))
        end
        if not result then
            vim.notify('Corresponding file can’t be determined', 'ERROR', { title = 'Clangd' })
            return
        end
        vim.cmd(splitcmd .. ' ' .. vim.uri_to_fname(result))
    end)
end

local sumneko_root_path = sys.cache .. '/lspconfig/sumneko_lua/lua-language-server'
local sumneko_binary = sumneko_root_path .. '/bin/' .. system_name .. '/lua-language-server'
local sumneko_runtime = vim.split(package.path, ';')
table.insert(sumneko_runtime, 'lua/?.lua')
table.insert(sumneko_runtime, 'lua/?/init.lua')

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
        { exec = 'rls' },
        { exec = 'rust-analyzer', config = 'rust_analyzer' },
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
            config = 'sumneko_lua',
            options = {
                cmd = { sumneko_binary, '-E', sumneko_root_path .. '/main.lua' },
                capabilities = {
                    textDocument = {
                        completion = {
                            completionItem = { snippetSupport = true },
                        },
                    },
                },
                settings = {
                    Lua = {
                        completion = {
                            keywordSnippet = 'Enable',
                            callSnippet = 'Both',
                        },
                        runtime = {
                            -- Tell the language server which version of Lua you're using
                            -- (most likely LuaJIT in the case of Neovim)
                            version = 'LuaJIT',
                            -- Setup your lua path
                            path = sumneko_runtime,
                        },
                        workspace = {
                            -- Make the server aware of Neovim runtime files
                            library = vim.api.nvim_get_runtime_file('', true),
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
                            },
                        },
                    },
                },
            },
        },
    },
    python = {
        {
            config = 'pyright',
            exec = 'pyright-langserver',
            options = {
                settings = {
                    python = {
                        analysis = {
                            autoSearchPaths = true,
                            diagnosticMode = 'workspace',
                            useLibraryCodeForTypes = true,
                            typeCheckingMode = 'basic', -- "off", "basic", "strict"
                            -- extraPaths = {},
                        },
                    },
                },
            },
        },
        {
            exec = 'pylsp',
            options = {
                cmd = {
                    'pylsp',
                    '--check-parent-process',
                    '--log-file=' .. sys.tmp 'pylsp.log',
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
                            jedi_completion = {
                                include_params = true,
                            },
                            mccabe = {
                                threshold = 20,
                            },
                            pycodestyle = {
                                maxLineLength = 120,
                                ignore = RELOAD('filetypes.python').pyignores,
                            },
                        },
                    },
                },
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
                    '--index',
                    '--background-index',
                    '--suggest-missing-includes',
                    '--clang-tidy',
                    '--header-insertion=iwyu',
                    '--function-arg-placeholders',
                    '--completion-style=detailed',
                    '--log=verbose',
                },
                capabilities = {
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
                        switch_source_header_splitcmd(0, 'edit')
                    end,
                    description = 'Open source/header in current buffer',
                },
                SwitchVSplit = {
                    function()
                        switch_source_header_splitcmd(0, 'vsplit')
                    end,
                    description = 'Open source/header in a new vsplit',
                },
                SwitchSplit = {
                    function()
                        switch_source_header_splitcmd(0, 'split')
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

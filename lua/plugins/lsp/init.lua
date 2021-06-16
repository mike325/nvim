-- luacheck: max line length 135
local sys  = require'sys'
local nvim = require'nvim'

local load_module = require'utils.helpers'.load_module
local get_icon    = require'utils.helpers'.get_icon
local executable  = require'utils.files'.executable
local is_dir      = require'utils.files'.is_dir
local split       = require'utils.strings'.split

local plugins = nvim.plugins

-- local set_command = require'nvim.commands'.set_command
-- local set_autocmd = require'nvim.autocmds'.set_autocmd
local set_mapping = require'nvim.mappings'.set_mapping

local lsp = load_module'lspconfig'

if lsp == nil then
    return false
end

local system_name = ''
if sys.name == 'mac'  then
    system_name = "macOS"
elseif sys.name == 'linux' then
    system_name = "Linux"
elseif sys.name == 'windows' then
    system_name = "Windows"
else
    print("Unsupported system for sumneko")
end

local diagnostics = true

local has_saga,_ = pcall(require,'lspsaga')
local has_telescope,telescope = pcall(require, 'telescope.builtin')

local sumneko_root_path = sys.cache..'/lspconfig/sumneko_lua/lua-language-server'
local sumneko_binary = sumneko_root_path..'/bin/'..system_name..'/lua-language-server'
local sumneko_runtime = vim.split(package.path, ';')
table.insert(sumneko_runtime, "lua/?.lua")
table.insert(sumneko_runtime, "lua/?/init.lua")

local servers = {
    go         = { { exec = 'gopls'}, },
    java       = { { exec = 'jdtls'}, },
    sh         = { { exec = 'bash-language-server',   config = 'bashls'}, },
    dockerfile = { { exec = 'docker-langserver',      config = 'dockerls'}, },
    kotlin     = { { exec = 'kotlin-language-server', config = 'kotlin_language_server'}, },
    rust = {
        { exec = 'rls', },
        { exec = 'rust-analyzer', config = 'rust_analyzer', },
    },
    tex = {
        {
            exec = 'texlab',
            options = {
                capabilities = {
                    textDocument = {
                        completion = {
                            completionItem = { snippetSupport = true }
                        }
                    }
                },
                settings = {
                    bibtex = {
                        formatting = {
                        lineLength = 120
                        }
                    },
                    latex = {
                        forwardSearch = {
                            args = {},
                            onSave = false
                        },
                        build = {
                            args = { '-outdir=texlab', '-pdf', '-interaction=nonstopmode', '-synctex=1', '%f' },
                            executable = "latexmk",
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
            config = 'vimls',
        },
    },
    lua = {
        {
            config = 'sumneko_lua',
            options = {
                cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"},
                capabilities = {
                    textDocument = {
                        completion = {
                            completionItem = { snippetSupport = true }
                        }
                    }
                },
                settings = {
                    Lua = {
                        completion= {
                            keywordSnippet = "Enable",
                            callSnippet = "Both"
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
                            library = vim.api.nvim_get_runtime_file("", true),
                        },
                        diagnostics = {
                            globals = {
                                'bit',
                                'vim',
                                'use',
                                -- 'utils',
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
                            diagnosticMode = "workspace",
                            useLibraryCodeForTypes = true,
                            typeCheckingMode = 'basic',  -- "off", "basic", "strict"
                            -- extraPaths = {},
                        },
                    },
                },
            },
        },
        {
            exec = 'pyls',
            options = {
                cmd = {
                    'pyls',
                    '--check-parent-process',
                    '--log-file=' .. sys.tmp('pyls.log'),
                },
                capabilities = {
                    textDocument = {
                        completion = {
                            completionItem = { snippetSupport = true }
                        }
                    }
                },
                settings = {
                    pyls = {
                        plugins = {
                            mccabe = {
                                threshold = 20,
                            },
                            pycodestyle = {
                                maxLineLength = 120,
                                ignore = {
                                    -- 'E121', --
                                    -- 'E123', --
                                    -- 'E126', --
                                    'E203', -- Whitespace before :
                                    -- 'E221', --
                                    'E226', -- Whitespace around operators
                                    -- 'E228', --
                                    'E231', -- Missing whitespace after ','
                                    -- 'E24',  --
                                    -- 'E251', --
                                    'E261', -- 2 spaces before inline comment
                                    'E262', -- Comments should start with '#'
                                    'E265', -- Block comment should start with '#'
                                    -- 'E27',  --
                                    'E302', -- Expected 2 lines between funcs/classes
                                    -- 'E501', --
                                    -- 'E701', --
                                    -- 'E704', --
                                    -- 'H233', --
                                    'W391', -- Blank line and the EOF
                                    -- 'W503', --
                                    -- 'W504', --
                                },
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
            }
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
                            completionItem = { snippetSupport = true }
                        }
                    }
                },
                init_options = {
                    usePlaceholders = true,
                    completeUnimported = true,
                    clangdFileStatus = true
                },
            }
        },
        {
            exec = 'ccls',
            options = {
                cmd = { 'ccls', '--log-file=' .. sys.tmp('ccls.log') },
                capabilities = {
                    textDocument = {
                        completion = {
                            completionItem = { snippetSupport = true }
                        }
                    }
                },
                settings = {
                    init_options = {
                        compilationDatabaseDirectory = "build";
                        index = {
                            threads = 0;
                        },
                        -- clang = {
                        --     excludeArgs = { "-frounding-math"} ;
                        -- },
                    },
                    ccls = {
                        cache = {
                            directory = sys.cache..'/ccls'
                        },
                        completion = {
                            filterAndSort = true,
                            caseSensitivity = 1,
                            detailedLabel = false,
                        },
                    }
                },
            },
        },
    },
}

local function on_attach(client, bufnr)
    vim.bo.omnifunc = 'v:lua.vim.lsp.omnifunc'
    bufnr = bufnr or nvim.get_current_buf()
    local lua_cmd = '<cmd>lua %s<CR>'

    local mappings = {
        ['<C-]>'] = {
            capability = 'goto_definition',
            mapping = lua_cmd:format(
                'vim.lsp.buf.definition()'
            ),
        },
        ['gd'] = {
            capability = 'declaration',
            mapping = lua_cmd:format('vim.lsp.buf.declaration()'),
        },
        ['gi'] = {
            capability = 'implementation',
            mapping = lua_cmd:format('vim.lsp.buf.implementation()'),
        },
        ['gr'] = {
            capability = 'find_references',
            mapping = lua_cmd:format(
                (has_telescope and "require'telescope.builtin'.lsp_references{}") or
                (has_saga and "require'lspsaga.provider'.lsp_finder()") or
                'vim.lsp.buf.references()'
            ),
        },
        ['K'] = {
            capability = 'hover',
            mapping = lua_cmd:format(
                has_saga and "require('lspsaga.hover').render_hover_doc()" or 'vim.lsp.buf.hover()'

            ),
        },
        ['<leader>r'] = {
            capability = 'rename',
            mapping = lua_cmd:format(
                has_saga and "require('lspsaga.rename').rename()" or 'vim.lsp.buf.rename()'
            ),
        },
        ['ga'] = {
            capability = 'code_action',
            mapping = lua_cmd:format(
                has_saga and "require('lspsaga.codeaction').code_action()" or 'vim.lsp.buf.code_action()'
            ),
        },
        ['gh'] = {
            capability = 'signature_help',
            mapping = lua_cmd:format(
                has_saga and "require('lspsaga.signaturehelp').signature_help()" or
                'vim.lsp.buf.signature_help()'
            ),
        },
        ['=L'] = {
            mapping = lua_cmd:format('vim.lsp.diagnostic.set_loclist()'),
        },
        ['=d'] = {
            mapping = lua_cmd:format(
                has_saga and
                "require'lspsaga.diagnostic'.show_line_diagnostics()" or
                'vim.lsp.diagnostic.show_line_diagnostics()'
            ),
        },
        [']d'] = {
            mapping = lua_cmd:format(
                has_saga and
                "require'lspsaga.diagnostic'.lsp_jump_diagnostic_next()" or
                'vim.lsp.diagnostic.goto_next{wrap=false}'
            ),
        },
        ['[d'] = {
            mapping = lua_cmd:format(
                has_saga and
                "require'lspsaga.diagnostic'.lsp_jump_diagnostic_prev()" or
                'vim.lsp.diagnostic.goto_prev{wrap=false}'
            ),
        },
        -- ['<space>wa'] = '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>',
        -- ['<space>wr'] = '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>',
        -- ['<space>wl'] = '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',
        -- ['<leader>D'] = '<cmd>lua vim.lsp.buf.type_definition()<CR>',
    }

    -- if has_saga then
    --     set_mapping {
    --         mode = 'n',
    --         lhs = '<C-f>',
    --         rhs = [[<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>]],
    --         args = { silent = true, buffer = bufnr, noremap = true},
    --     }
    --     set_mapping {
    --         mode = 'n',
    --         lhs = '<C-b>',
    --         rhs = [[<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>]],
    --         args = { silent = true, buffer = bufnr, noremap = true},
    --     }
    -- end

    for mapping,val in pairs(mappings) do
        if not val.capability or client.resolved_capabilities[val.capability] then
            set_mapping {
                mode = 'n',
                lhs = mapping,
                rhs = val.mapping,
                args = { silent = true, buffer = bufnr, noremap = true},
            }
        end
    end

    if client.resolved_capabilities.document_formatting then
        set_mapping {
            mode = 'n',
            lhs = '=F',
            rhs =  vim.lsp.buf.formatting,
            args = {silent = true, buffer = bufnr, noremap = true},
        }
    end

    if client.resolved_capabilities.document_range_formatting then
        set_mapping {
            mode = 'n',
            lhs = 'gq',
            rhs = '<cmd>set opfunc=neovim#lsp_format<CR>g@',
            args = {silent = true, buffer = bufnr, noremap = true},
        }

        set_mapping {
            mode = 'v',
            lhs = 'gq',
            rhs = ':<C-U>call neovim#lsp_format(visualmode(), v:true)<CR>',
            args = {silent = true, buffer = bufnr, noremap = true},
        }
    end

    -- Disable neomake for lsp buffers
    if plugins['neomake'] then
        pcall(vim.fn['neomake#CancelJobs'], 0)
        pcall(vim.fn['neomake#cmd#clean'], 1)
        pcall(vim.cmd, 'silent call neomake#cmd#disable(b:)')
    end

    require('vim.lsp.protocol').CompletionItemKind = {
        '';  -- Text          = 1;
        '';  -- Method        = 2;
        'ƒ';  -- Function      = 3;
        '';  -- Constructor   = 4;
        '識'; -- Field         = 5;
        '';  -- Variable      = 6;
        '';  -- Class         = 7;
        'ﰮ';  -- Interface     = 8;
        '';  -- Module        = 9;
        '';  -- Property      = 10;
        '';  -- Unit          = 11;
        '';  -- Value         = 12;
        '了'; -- Enum          = 13;
        '';  -- Keyword       = 14;
        '﬌';  -- Snippet       = 15;
        '';  -- Color         = 16;
        '';  -- File          = 17;
        '渚'; -- Reference     = 18;
        '';  -- Folder        = 19;
        '';  -- EnumMember    = 20;
        '';  -- Constant      = 21;
        '';  -- Struct        = 22;
        '鬒'; -- Event         = 23;
        'Ψ';  -- Operator      = 24;
        '';  -- TypeParameter = 25;
    }

    -- set_autocmd{
    --     event   = 'CursorHold',
    --     pattern = '<buffer>',
    --     cmd     = [[lua vim.lsp.buf.hover()]],
    --     group   = 'LSPAutocmds',
    -- }

end

-- TODO: Make commands capability-dependent
local commands = {
    Type           = {vim.lsp.buf.type_definition},
    Declaration    = {vim.lsp.buf.declaration},
    OutgoingCalls  = {vim.lsp.buf.outgoing_calls},
    IncommingCalls = {vim.lsp.buf.incoming_calls},
    Implementation = {vim.lsp.buf.implementation},
    Format         = {vim.lsp.buf.formatting},
    LSPToggleDiagnostics = {function()
        diagnostics = not diagnostics
        _G['vim'].lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
            vim.lsp.diagnostic.on_publish_diagnostics, {
                underline = diagnostics,
                signs = diagnostics,
                virtual_text = diagnostics and {
                    spacing = 2,
                    prefix = '❯',
                } or false,
                update_in_insert = true,
            }
        )
    end},
    Rename = {function()
        if has_saga then
            require('lspsaga.rename').rename()
        else
            vim.lsp.buf.rename{}
        end
    end},
    Signature = {function()
        if has_saga then
            require('lspsaga.signaturehelp').signature_help()
        else
            vim.lsp.buf.signature_help{}
        end
    end},
    Hover = {function()
        if has_saga then
            require('lspsaga.hover').render_hover_doc()
        else
            vim.lsp.buf.hover{}
        end
    end},
    Definition = {function()
        if has_saga then
            require'lspsaga.provider'.lsp_finder()
        elseif has_telescope then
            telescope.lsp_definitions{}
        else
            vim.lsp.buf.definition()
        end
    end},
    References = {function()
        if has_telescope then
            telescope.lsp_references{}
        elseif has_saga then
            require'lspsaga.provider'.lsp_finder()
        else
            vim.lsp.buf.references()
        end
    end,},
    Diagnostic = {function()
        if has_telescope then
            telescope.lsp_document_diagnostics{}
        else
            vim.lsp.buf.set_loclist()
        end
    end},
    DocSymbols = {function()
        if has_telescope then
            telescope.lsp_document_symbols{}
        else
            vim.lsp.buf.document_symbol()
        end
    end,},
    WorkSymbols = {function()
        if has_telescope then
            telescope.lsp_workspace_symbols{}
        else
            vim.lsp.buf.workspace_symbol()
        end
    end,},
    CodeAction = {function()
        if has_saga then
            require'lspsaga.codeaction'.code_action()
        elseif has_telescope then
            telescope.lsp_code_actions{}
        else
            vim.lsp.buf.lsp_code_actions()
        end
    end,},
}

local available_languages = {}
for language,options in pairs(servers) do
    for _,server in pairs(options) do
        local dir = is_dir(sys.cache..'/lspconfig/'..(server.config or server.exec) )
        local exec = server.exec ~= nil and executable(server.exec) or false
        if exec or dir then
            local config = server.config or server.exec
            local init = server.options or {}
            init.commands = commands
            init.on_attach = on_attach
            lsp[config].setup(init)
            available_languages[#available_languages + 1] = language
            if language == 'c' then
                available_languages[#available_languages + 1] = 'cpp'
                available_languages[#available_languages + 1] = 'objc'
                available_languages[#available_languages + 1] = 'objcpp'
            elseif language == 'dockerfile' then
                available_languages[#available_languages + 1] = 'Dockerfile'
            elseif language == 'tex' then
                available_languages[#available_languages + 1] = 'bib'
            end
            break
        end
    end
end

-- Expose languages to VimL
vim.g.lsp_languages = available_languages

vim.cmd('sign define LspDiagnosticsSignError       text='..get_icon('error')..' texthl=LspDiagnosticsSignError linehl= numhl=')
vim.cmd('sign define LspDiagnosticsSignWarning     text='..get_icon('warn')..'  texthl=LspDiagnosticsSignWarning linehl= numhl=')
vim.cmd('sign define LspDiagnosticsSignHint        text='..get_icon('hint')..'  texthl=LspDiagnosticsSignHint linehl= numhl=')
vim.cmd('sign define LspDiagnosticsSignInformation text='..get_icon('info')..'  texthl=LspDiagnosticsSignInformation linehl= numhl=')

_G['vim'].lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        underline = true,
        virtual_text = {
            spacing = 2,
            prefix = '❯',
        },
        signs = true,
        update_in_insert = true,
    }
)

return #available_languages > 0 and available_languages or false

-- luacheck: max line length 180
local sys  = require'sys'
local nvim = require'nvim'

local load_module = require'tools'.helpers.load_module
local executable  = require'tools'.files.executable
local is_dir = require'tools'.files.is_dir

local plugins = nvim.plugins

-- local set_command = nvim.commands.set_command
local set_autocmd = nvim.autocmds.set_autocmd
local set_mapping = nvim.mappings.set_mapping

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

local sumneko_root_path = sys.cache..'/lspconfig/sumneko_lua/lua-language-server'
local sumneko_binary = sumneko_root_path..'/bin/'..system_name..'/lua-language-server'

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
                            args = { '-pdf', '-interaction=nonstopmode', '-synctex=1', '%f' },
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
                settings = {
                    Lua = {
                        runtime = {
                            -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                            version = 'LuaJIT',
                            -- Setup your lua path
                            path = vim.split(package.path, ';'),
                        },
                        workspace = {
                            -- Make the server aware of Neovim runtime files
                            library = {
                                [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                                [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
                            },
                        },
                        diagnostics = {
                            globals = {
                                'vim',
                                'nvim',
                                'tools',
                            },
                        },
                    },
                },
            },
        },
    },
    python = {
        {
            config = 'pyls_ms',
            -- cmd = { 'dotnet', 'exec', 'path/to/Microsoft.Python.languageServer.dll'  };
        },
        {
            exec = 'pyls',
            options = {
                cmd = {
                    'pyls',
                    '--check-parent-process',
                    '--log-file=' .. sys.tmp('pyls.log'),
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
                                    'E203',
                                },
                            },
                        },
                    },
                },
            },
        },
        { exec = 'jedi-language-server', config = 'jedi_language_server' },
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
                    '--log=verbose',
                },
            }
        },
        {
            exec = 'ccls',
            options = {
                cmd = { 'ccls', '--log-file=' .. sys.tmp('ccls.log') },
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

local function on_attach(client)
    require'nvim'.bo.omnifunc = 'v:lua.vim.lsp.omnifunc'
    -- local nvim = require'nvim'

    local mappings = {
        ['<C-]>'] = '<cmd>lua vim.lsp.buf.definition()<CR>',
        ['gd']    = '<cmd>lua vim.lsp.buf.declaration()<CR>',
        -- ['gD']    = '<cmd>lua vim.lsp.buf.implementation()<CR>',
        ['gr ']   = '<cmd>lua vim.lsp.buf.references()<CR>',
        ['K']     = '<cmd>lua vim.lsp.buf.hover()<CR>',
        ['=d']    = '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>',
        [']d']    = '<cmd>lua vim.lsp.diagnostic.goto_next { wrap = false }<CR>',
        ['[d']    = '<cmd>lua vim.lsp.diagnostic.goto_prev { wrap = false }<CR>',
    }

    for mapping,val in pairs(mappings) do
        set_mapping {
            mode = 'n',
            lhs = mapping,
            rhs = val,
            args = { silent = true, buffer = true, noremap = true},
        }
    end

    -- Disable neomake for lsp buffers
    if plugins['neomake'] ~= nil then
        set_autocmd{
            event   = 'FileType',
            pattern = '<buffer>',
            cmd     = [[silent! call neomake#cmd#disable(b:)]],
            group   = 'LSPAutocmds'
        }
    end

    -- set_autocmd{
    --     event   = 'CursorHold',
    --     pattern = '<buffer>',
    --     cmd     = [[lua vim.lsp.buf.hover()]],
    --     group   = 'LSPAutocmds',
    -- }

end

local commands = {
    Type           = {vim.lsp.buf.type_definition},
    Hover          = {vim.lsp.buf.hover},
    Rename         = {vim.lsp.buf.rename},
    Signature      = {vim.lsp.buf.signature_help},
    Definition     = {vim.lsp.buf.definition},
    Declaration    = {vim.lsp.buf.declaration},
    Diagnostics    = {vim.lsp.diagnostic.set_loclist},
    OutgoingCalls  = {vim.lsp.buf.outgoing_calls},
    IncommingCalls = {vim.lsp.buf.incoming_calls},
    Implementation = {vim.lsp.buf.implementation},
    References = {function()
        local load_module = require'tools'.helpers.load_module
        local telescope = load_module'plugins.telescope'
        if telescope then
            require'telescope.builtin'.lsp_references{}
        else
            vim.lsp.buf.references()
        end
    end,},
    DocSymbols = {function()
        local load_module = require'tools'.helpers.load_module
        local telescope = load_module'plugins.telescope'
        if telescope then
            require'telescope.builtin'.lsp_document_symbols{}
        else
            vim.lsp.buf.document_symbol()
        end
    end,},
    WorkSymbols = {function()
        local load_module = require'tools'.helpers.load_module
        local telescope = load_module'plugins.telescope'
        if telescope then
            require'telescope.builtin'.lsp_workspace_symbols{}
        else
            vim.lsp.buf.workspace_symbol()
        end

    end,},
    CodeAction = {function()
        local load_module = require'tools'.helpers.load_module
        local telescope = load_module'plugins.telescope'
        if telescope then
            require'telescope.builtin'.lsp_code_actions{}
        else
            vim.lsp.buf.lsp_code_actions()
        end
    end,},
}

local available_languages = {}
for language,options in pairs(servers) do
    for _,server in pairs(options) do
        local dir = is_dir(sys.cache..'/lspconfig/'..(server['config'] or server['exec']) )
        local exec = server['exec'] ~= nil and executable(server['exec']) or false
        if exec or dir then
            local init = server['options'] ~= nil and server['options'] or {}
            local config = server['config'] ~= nil and server['config'] or server['exec']
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
nvim.g.lsp_languages = available_languages

vim.cmd [[sign define LspDiagnosticsSignError   text=✖ texthl=LspDiagnosticsSignError   linehl= numhl=]]
vim.cmd [[sign define LspDiagnosticsSignWarning text=⚠ texthl=LspDiagnosticsSignWarning linehl= numhl=]]

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

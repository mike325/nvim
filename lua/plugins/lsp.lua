-- luacheck: max line length 180
local sys         = require'sys'
local nvim        = require'nvim'
local load_module = require'tools'.helpers.load_module

local plugins          = nvim.plugins
local executable       = nvim.executable
local isdirectory      = nvim.isdirectory
local nvim_set_autocmd = nvim.nvim_set_autocmd
-- local nvim_set_command = nvim.nvim_set_command

local lsp = load_module'lspconfig'

if lsp == nil then
    return false
end

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
                            }
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

local available_languages = {}

for language,options in pairs(servers) do
    for _,server in pairs(options) do
        local dir = isdirectory(sys.cache..'/lspconfig/'..(server['config'] or server['exec']) )
        local exec = server['exec'] ~= nil and executable(server['exec']) or false
        if exec or dir then
            local init = server['options'] ~= nil and server['options'] or {}
            local config = server['config'] ~= nil and server['config'] or server['exec']
            -- print('Server: '..config)
            -- print('Config: ', vim.inspect(init))
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

vim.cmd [[sign define LspDiagnosticsSignError   text=✖ texthl=LspDiagnosticsSignError       linehl= numhl=]]
vim.cmd [[sign define LspDiagnosticsSignWarning text=⚠ texthl=LspDiagnosticsSignWarning     linehl= numhl=]]

if #available_languages == 0 then
    return false
end

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

-- nvim_set_autocmd{
--     event   = 'FileType',
--     pattern = available_languages,
--     cmd     = [[autocmd CursorHold <buffer> lua vim.lsp.buf.hover()]],
--     group   = 'LSPAutocmds',
--     nested  = true
-- }

nvim_set_autocmd{
    event   = 'FileType',
    pattern = available_languages,
    cmd     = 'setlocal omnifunc=v:lua.vim.lsp.omnifunc',
    group   = 'LSPAutocmds',
}

nvim_set_autocmd{
    event   = 'FileType',
    pattern = available_languages,
    cmd     = 'nnoremap <buffer><silent> <c-]> :lua vim.lsp.buf.definition()<CR>',
    group   = 'LSPAutocmds',
}

nvim_set_autocmd{
    event   = 'FileType',
    pattern = available_languages,
    cmd     = 'nnoremap <buffer><silent> gd :lua vim.lsp.buf.declaration()<CR>',
    group   = 'LSPAutocmds',
}

nvim_set_autocmd{
    event   = 'FileType',
    pattern = available_languages,
    cmd     = 'nnoremap <buffer><silent> gD :lua vim.lsp.buf.implementation()<CR>',
    group   = 'LSPAutocmds',
}

nvim_set_autocmd{
    event   = 'FileType',
    pattern = available_languages,
    cmd     = 'nnoremap <buffer><silent> gr :lua vim.lsp.buf.references()<CR>',
    group   = 'LSPAutocmds',
}

nvim_set_autocmd{
    event   = 'FileType',
    pattern = available_languages,
    cmd     = 'nnoremap <buffer><silent> K :lua vim.lsp.buf.hover()<CR>',
    group   = 'LSPAutocmds',
}

nvim_set_autocmd{
    event   = 'FileType',
    pattern = available_languages,
    cmd     = [[lua require'nvim'.nvim_set_command{ lhs = 'Declaration', rhs = 'lua vim.lsp.buf.declaration()', args = {buffer = true, force = true} }]],
    group   = 'LSPAutocmds',
}

nvim_set_autocmd{
    event   = 'FileType',
    pattern = available_languages,
    cmd     = [[lua require'nvim'.nvim_set_command{ lhs = 'Diagnostics', rhs = 'lua vim.lsp.diagnostic.set_loclist()', args = {buffer = true, force = true} }]],
    group   = 'LSPAutocmds',
}

nvim_set_autocmd{
    event   = 'FileType',
    pattern = available_languages,
    cmd     = 'nnoremap <buffer><silent> =d :lua vim.lsp.diagnostic.show_line_diagnostics()<CR>',
    group   = 'LSPAutocmds',
}

nvim_set_autocmd{
    event   = 'FileType',
    pattern = available_languages,
    cmd     = [[lua require'nvim'.nvim_set_command{ lhs = 'Definition', rhs = 'lua vim.lsp.buf.definition()', args = {buffer = true, force = true} }]],
    group   = 'LSPAutocmds',
}

nvim_set_autocmd{
    event   = 'FileType',
    pattern = available_languages,
    cmd     = [[lua require'nvim'.nvim_set_command{ lhs = 'References', rhs = 'lua vim.lsp.buf.references()', args = {buffer = true, force = true} }]],
    group   = 'LSPAutocmds',
}

nvim_set_autocmd{
    event   = 'FileType',
    pattern = available_languages,
    cmd     = [[lua require'nvim'.nvim_set_command{ lhs = 'Rename', rhs = 'lua vim.lsp.buf.rename()', args = {buffer = true, force = true} }]],
    group   = 'LSPAutocmds'
}

nvim_set_autocmd{
    event   = 'FileType',
    pattern = available_languages,
    cmd     = [[lua require'nvim'.nvim_set_command{ lhs = 'Action', rhs = 'lua vim.lsp.buf.code_action()', args = {buffer = true, force = true} }]],
    group   = 'LSPAutocmds'
}

nvim_set_autocmd{
    event   = 'FileType',
    pattern = available_languages,
    cmd     = [[lua require'nvim'.nvim_set_command{ lhs = 'OutgoingCalls', rhs = 'lua vim.lsp.buf.outgoing_calls()', args = {buffer = true, force = true} }]],
    group   = 'LSPAutocmds'
}

nvim_set_autocmd{
    event   = 'FileType',
    pattern = available_languages,
    cmd     = [[lua require'nvim'.nvim_set_command{ lhs = 'IncommingCalls', rhs = 'lua vim.lsp.buf.incoming_calls()', args = {buffer = true, force = true} }]],
    group   = 'LSPAutocmds'
}

nvim_set_autocmd{
    event   = 'FileType',
    pattern = available_languages,
    cmd     = [[lua require'nvim'.nvim_set_command{ lhs = 'DocSymbols', rhs = 'lua vim.lsp.buf.document_symbol()', args = {buffer = true, force = true} }]],
    group   = 'LSPAutocmds'
}

nvim_set_autocmd{
    event   = 'FileType',
    pattern = available_languages,
    cmd     = [[lua require'nvim'.nvim_set_command{ lhs = 'Hover', rhs = 'lua vim.lsp.buf.hover()', args = {buffer = true, force = true} }]],
    group   = 'LSPAutocmds'
}

nvim_set_autocmd{
    event   = 'FileType',
    pattern = available_languages,
    cmd     = [[lua require'nvim'.nvim_set_command{ lhs = 'Implementation', rhs = 'lua vim.lsp.buf.implementation()', args = {buffer = true, force = true} }]],
    group   = 'LSPAutocmds'
}

nvim_set_autocmd{
    event   = 'FileType',
    pattern = available_languages,
    cmd     = [[lua require'nvim'.nvim_set_command{ lhs = 'Signature', rhs = 'lua vim.lsp.buf.signature_help()', args = {buffer = true, force = true} }]],
    group   = 'LSPAutocmds'
}

nvim_set_autocmd{
    event   = 'FileType',
    pattern = available_languages,
    cmd     = [[lua require'nvim'.nvim_set_command{ lhs = 'Type' , rhs = 'lua vim.lsp.buf.type_definition()', args = {buffer = true, force = true} }]],
    group   = 'LSPAutocmds'
}

nvim_set_autocmd{
    event   = 'FileType',
    pattern = available_languages,
    cmd     = [[nnoremap ]d <cmd>lua vim.lsp.diagnostic.goto_next { wrap = false }<CR>]],
    group   = 'LSPAutocmds'
}

nvim_set_autocmd{
    event   = 'FileType',
    pattern = available_languages,
    cmd     = [[nnoremap [d <cmd>lua vim.lsp.diagnostic.goto_prev { wrap = false }<CR>]],
    group   = 'LSPAutocmds'
}

-- Disable neomake for lsp buffers
if plugins['neomake'] ~= nil then
    nvim_set_autocmd{
        event   = 'FileType',
        pattern = available_languages,
        cmd     = [[silent! call neomake#cmd#disable(b:)]],
        group   = 'LSPAutocmds'
    }
end

return available_languages

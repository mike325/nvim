-- luacheck: max line length 180
local sys         = require'sys'
local nvim        = require'nvim'
local load_module = require'tools'.load_module

local plugins          = nvim.plugins
local executable       = nvim.executable
local isdirectory      = nvim.isdirectory
local nvim_set_autocmd = nvim.nvim_set_autocmd
-- local nvim_set_command = nvim.nvim_set_command

local lsp = load_module('lspconfig')

if lsp == nil then
    return false
end

local diagnostics = load_module('diagnostic')
if diagnostics ~= nil then
    nvim.g.diagnostic_enable_virtual_text = 1
    -- nvim.g.diagnostic_auto_popup_while_jump = 0
    -- nvim.fn.sign_define("lspdiagnosticserrorsign", {"text" : "e", "texthl" : "lspdiagnosticserror"})
    -- nvim.fn.sign_define("lspdiagnosticswarningsign", {"text" : "w", "texthl" : "lspdiagnosticswarning"})
    -- nvim.fn.sign_define("lspdiagnosticinformationsign", {"text" : "i", "texthl" : "lspdiagnosticsinformation"})
    -- nvim.fn.sign_define("LspDiagnosticHintSign", {"text" : "H", "texthl" : "LspDiagnosticsHint"})
end

local servers = {
    sh         = { bashls        = { name = 'bash-language-server'}, },
    rust       = { rust_analyzer = { name = 'rust_analyzer'}, },
    go         = { gopls         = { name = 'gopls'}, },
    dockerfile = { dockerls      = { name = 'docker-langserver'}, },
    tex = {
        texlab = {
            name = 'texlab',
            options = {
                settings = {
                    latex = {
                        build = {
                            -- args = { "-pdf", "-interaction=nonstopmode", "-synctex=1" },
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
        vimls = {
            name = 'vimls',
            executable = 'vim-language-server',
        },
    },
    lua = {
        sumneko_lua = {
            name = 'sumneko_lua',
            options = {
                settings = {
                    Lua = {
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
        pyls = {
            name = 'pyls',
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
        jedi_language_server = { name = 'jedi-language-server' },
    },
    c = {
        clangd = {
            name = 'clangd',
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
        ccls = {
            name = 'ccls',
            options = {
                cmd = { 'ccls', '--log-file=' .. sys.tmp('ccls.log') },
                init_options = {
                    cache = {
                        directory = sys.cache..'/ccls'
                    },
                    highlight = {
                        lsRanges = true;
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
}

local available_languages = {}

for language,options in pairs(servers) do
    for option,server in pairs(options) do
        local dir = isdirectory(sys.home .. '/.cache/nvim/nvim_lsp/' .. server['name'])
        local exec = executable(server['name']) or (server['executable'] ~= nil and executable(server['executable']))
        if exec or dir then
            local init = server['options'] ~= nil and server['options'] or {}
            if diagnostics ~= nil then
                init['on_attach'] = diagnostics.on_attach
            end
            lsp[option].setup(init)
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
nvim.g.available_languages = available_languages

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
    cmd     = 'nnoremap <buffer><silent> =d :lua vim.lsp.util.show_line_diagnostics()<CR>',
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
    cmd     = [[lua require'nvim'.nvim_set_command{ lhs = 'Diagnostics', rhs = 'lua vim.lsp.util.show_line_diagnostics()', args = {buffer = true, force = true} }]],
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

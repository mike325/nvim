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
    sh         = { { name = 'bash-language-server', config = 'bashls'}, },
    rust       = { { name = 'rls'}, },
    go         = { { name = 'gopls'}, },
    dockerfile = { { name = 'docker-langserver', config = 'dockerls'}, },
    java       = { { name = 'jdtls'}, },
    tex = {
        {
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
        {
            name = 'vimls',
            executable = 'vim-language-server',
        },
    },
    lua = {
        {
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
        { name = 'pyls_ms' },
        {
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
        { name = 'jedi-language-server', config = 'jedi_language_server' },
    },
    c = {
        {
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
        {
            name = 'ccls',
            options = {
                cmd = { 'ccls', '--log-file=' .. sys.tmp('ccls.log') },
                settings = {
                    ccls = {
                        cache = {
                            directory = sys.cache..'/ccls'
                        },
                        -- highlight = {
                        --     lsRanges = true;
                        -- },
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
        local dir = isdirectory(sys.home .. '/.cache/nvim/lspconfig/' .. server['name'])
        local exec = executable(server['name']) or (server['executable'] ~= nil and executable(server['executable']))
        if exec or dir then
            local init = server['options'] ~= nil and server['options'] or {}
            config = server['config'] ~= nil and server['config'] or server['name']
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
nvim.g.available_languages = available_languages

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

vim.cmd [[sign define LspDiagnosticsSignError   text=✖ texthl=LspDiagnosticsSignError       linehl= numhl=]]
vim.cmd [[sign define LspDiagnosticsSignWarning text=⚠ texthl=LspDiagnosticsSignWarning     linehl= numhl=]]

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

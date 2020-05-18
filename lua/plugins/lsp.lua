local nvim = require('nvim')

local plugs = require('nvim').plugs
local sys = require('sys')
local executable = require('nvim').fn.executable
local isdirectory = require('nvim').fn.isdirectory
local nvim_set_autocmd = require('nvim').nvim_set_autocmd
-- local nvim_set_command = require('nvim').nvim_set_command

local ok, lsp = pcall(require, 'nvim_lsp')

if not ok then
    return nil
end

local ok, diagnostics = pcall(require, 'diagnostic')
if ok then
    nvim.g.diagnostic_enable_virtual_text = 1
    -- nvim.g.diagnostic_auto_popup_while_jump = 0
    -- nvim.fn.sign_define("lspdiagnosticserrorsign", {"text" : "e", "texthl" : "lspdiagnosticserror"})
    -- nvim.fn.sign_define("lspdiagnosticswarningsign", {"text" : "w", "texthl" : "lspdiagnosticswarning"})
    -- nvim.fn.sign_define("lspdiagnosticinformationsign", {"text" : "i", "texthl" : "lspdiagnosticsinformation"})
    -- nvim.fn.sign_define("LspDiagnosticHintSign", {"text" : "H", "texthl" : "LspDiagnosticsHint"})
else
    diagnostics = nil
end

-- local ok, completion = pcall(require, 'completion')
-- if ok then
--     -- nvim.g.completion_enable_snippet = 'UltiSnips'
-- -- else
--     completion = nil
-- end

local servers = {
    sh         = { bashls        = { name = 'bash-language-server'}, },
    rust       = { rust_analyzer = { name = 'rust_analyzer'}, },
    go         = { gopls         = { name = 'gopls'}, },
    tex        = { texlab        = { name = 'texlab'}, },
    dockerfile = { dockerls      = { name = 'docker-langserver'}, },
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
        local dir = isdirectory(sys.home .. '/.cache/nvim/nvim_lsp/' .. server['name']) == 1
        local exec = executable(server['name']) == 1 or
                     (server['executable'] ~= nil and executable(server['executable']) == 1)
        if exec or dir then
            local init = server['options'] ~= nil and server['options'] or {}
            if diagnostics ~= nil then
                init['on_attach'] = diagnostics.on_attach
            end
            -- if completion ~= nil then
            --     init['on_attach'] = completion.on_attach
            -- end
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

nvim_set_autocmd('FileType', available_languages, 'setlocal omnifunc=v:lua.vim.lsp.omnifunc', {group = 'NvimLSP', create = true})

nvim_set_autocmd('FileType', available_languages, 'nnoremap <buffer><silent> <c-]> :lua vim.lsp.buf.definition()<CR>', {group = 'NvimLSP'})
nvim_set_autocmd('FileType', available_languages, 'nnoremap <buffer><silent> gd    :lua vim.lsp.buf.declaration()<CR>', {group = 'NvimLSP'})
nvim_set_autocmd('FileType', available_languages, 'nnoremap <buffer><silent> gD    :lua vim.lsp.buf.implementation()<CR>', {group = 'NvimLSP'})
nvim_set_autocmd('FileType', available_languages, 'nnoremap <buffer><silent> gr    :lua vim.lsp.buf.references()<CR>', {group = 'NvimLSP'})
nvim_set_autocmd('FileType', available_languages, 'nnoremap <buffer><silent> K     :lua vim.lsp.buf.hover()<CR>', {group = 'NvimLSP'})

nvim_set_autocmd(
    'FileType',
    available_languages,
    "lua require'nvim'.nvim_set_command('Declaration', 'lua vim.lsp.buf.declaration()', {buffer = true, force = true})",
    {group = 'NvimLSP'}
)

nvim_set_autocmd(
    'FileType',
    available_languages,
    "lua require'nvim'.nvim_set_command('Definition', 'lua vim.lsp.buf.definition()', {buffer = true, force = true})",
    {group = 'NvimLSP'}
)

nvim_set_autocmd(
    'FileType',
    available_languages,
    "lua require'nvim'.nvim_set_command('References', 'lua vim.lsp.buf.references()', {buffer = true, force = true})",
    {group = 'NvimLSP'}
)

nvim_set_autocmd(
    'FileType',
    available_languages,
    "lua require'nvim'.nvim_set_command('Hover', 'lua vim.lsp.buf.hover()', {buffer = true, force = true})",
    {group = 'NvimLSP'}
)

-- nvim_set_autocmd(
--     'FileType',
--     available_languages,
--     "autocmd CursorHold <buffer> lua vim.lsp.buf.hover()",
--     {group = 'NvimLSP', nested = true}
-- )

nvim_set_autocmd(
    'FileType',
    available_languages,
    "lua require'nvim'.nvim_set_command('Implementation', 'lua vim.lsp.buf.implementation()', {buffer = true, force = true})",
    {group = 'NvimLSP'}
)

nvim_set_autocmd(
    'FileType',
    available_languages,
    "lua require'nvim'.nvim_set_command('Signature', 'lua vim.lsp.buf.signature_help()', {buffer = true, force = true})",
    {group = 'NvimLSP'}
)

nvim_set_autocmd(
    'FileType',
    available_languages,
    "lua require'nvim'.nvim_set_command('Type' , 'lua vim.lsp.buf.type_definition()', {buffer = true, force = true})",
    {group = 'NvimLSP'}
)

-- Disable neomake for lsp buffers
if plugs['neomake'] ~= nil then
    nvim_set_autocmd(
        'FileType',
        available_languages,
        "silent! call neomake#cmd#disable(b:)",
        {group = 'NvimLSP'}
    )
end

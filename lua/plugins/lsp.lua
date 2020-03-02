-- local nvim = require('nvim')
local sys = require('sys')
-- local plugs = require('nvim').plugs
local executable = require('nvim').fn.executable
local isdirectory = require('nvim').fn.isdirectory
local nvim_set_autocmd = require('nvim').nvim_set_autocmd
-- local nvim_set_command = require('nvim').nvim_set_command

local ok, lsp = pcall(require, 'nvim_lsp')

if not ok then
    return nil
end

local servers = {
    sh         = { bashls        = { name = 'bash-language-server'}, },
    rust       = { rust_analyzer = { name = 'rust_analyzer'}, },
    go         = { gopls         = { name = 'gopls'}, },
    tex        = { texlab        = { name = 'texlab'}, },
    python     = { pyls          = { name = 'pyls'}, },
    vim        = { vimls         = { name = 'vimls'}, },
    lua        = { sumneko_lua   = { name = 'sumneko_lua'}, },
    dockerfile = { dockerls      = { name = 'docker-langserver'}, },
    c = {
        ccls = {
            name = 'ccls',
            options = {
                init_options = {
                    highlight = {
                        lsRanges = true;
                    },
                    completion = {
                        caseSensitivity = 1,
                        detailedLabel = false,
                        filterAndSort = true,
                    },
                },
            },
        },
        clangd = { name = 'clangd', },
    },
}

local available_languages = {}

for language,options in pairs(servers) do
    for option,server in pairs(options) do
        if executable(server['name']) == 1 or isdirectory(sys.home .. '/.cache/nvim/nvim_lsp/' .. server['name']) == 1 then
            local init = server['options'] ~= nil and server['options'] or {}
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

nvim_set_autocmd(
    'FileType',
    available_languages,
    "autocmd CursorHold <buffer> lua vim.lsp.buf.hover()",
    {group = 'NvimLSP', nested = true}
)

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

do
    local method = 'textDocument/publishDiagnostics'
    local default_callback = vim.lsp.callbacks[method]
    vim.lsp.callbacks[method] = function(err, method, result, client_id)
        default_callback(err, method, result, client_id)
        if result and result.diagnostics then
            for _, v in ipairs(result.diagnostics) do
                v.uri = v.uri or result.uri
            end
            vim.lsp.util.set_loclist(result.diagnostics)
        end
    end
end

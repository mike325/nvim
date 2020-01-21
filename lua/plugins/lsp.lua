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
    sh     = { bashls        = 'bash-language-server', },
    docker = { dockerls      = 'docker-language-server', },
    rust   = { rust_analyzer = 'rust_analyzer', },
    go     = { gopls         = 'gopls', },
    tex    = { texlab        = 'texlab', },
    python = { pyls          = 'pyls', },
    vim    = { vimls         = 'vimls', },
    lua    = { sumneko_lua   = 'sumneko_lua', },
    c = { -- Since both clangd and ccls works with C,Cpp,ObjC and ObjCpp; just 1 setup is ok
        clangd = 'clangd',
        ccls   = 'ccls',
    },
}

local available_languages = {}

for language,options in pairs(servers) do
    for option,server in pairs(options) do
        if executable(server) == 1 or isdirectory(sys.home .. '/.cache/nvim/nvim_lsp/' .. server) == 1 then
            lsp[option].setup({})
            available_languages[#available_languages + 1] = language
            if language == 'c' then
                available_languages[#available_languages + 1] = 'cpp'
                available_languages[#available_languages + 1] = 'objc'
                available_languages[#available_languages + 1] = 'objcpp'
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

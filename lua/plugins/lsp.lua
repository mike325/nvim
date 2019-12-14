local nvim = require('nvim')
local executable = require('nvim').fn.executable
local nvim_set_autocmd = require('nvim').nvim_set_autocmd
local nvim_set_command = require('nvim').nvim_set_command

local ok, lsp = pcall(require, 'nvim_lsp')

if not ok then
    print('Failed to initialize LSP')
    print('LSP Error '..lsp)
    return nil
end

local servers = {
    sh     = { bashls        = 'bash-language-server', },
    docker = { dockerls      = 'docker-language-server', },
    rust   = { rust_analyzer = 'rust_analyzer', },
    go     = { gopls         = 'gopls', },
    latex  = { texlab        = 'texlab', },
    python = { pyls          = 'pyls', },
    c      = {
        ccls   = 'ccls',
        clangd = 'clangd',
    },
    cpp      = {
        ccls   = 'ccls',
        clangd = 'clangd',
    },
}

local available_languages = {}

for language,options in pairs(servers) do
    for option,server in pairs(options) do
        if executable(server) then
            lsp[option].setup({})
            available_languages[#available_languages + 1] = language
            break
        end
    end
end

nvim_set_autocmd('FileType', available_languages, 'setlocal omnifunc=v:lua.vim.lsp.omnifunc', {group = 'NvimLSP', create = true})

nvim_set_autocmd('FileType', available_languages, 'nnoremap <buffer><silent> gD :lua vim.lsp.buf.definition()<CR>', {group = 'NvimLSP'})
nvim_set_autocmd('FileType', available_languages, 'nnoremap <buffer><silent> K :lua vim.lsp.buf.hover()<CR>', {group = 'NvimLSP'})

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
    "lua require'nvim'.nvim_set_command('Hover', 'lua vim.lsp.buf.hover()', {buffer = true, force = true})",
    {group = 'NvimLSP'}
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

local nvim = require('nvim')
local plugins = require('nvim').plugins
local nvim_set_autocmd = require('nvim').nvim_set_autocmd
local nvim_set_mapping = require('nvim').nvim_set_mapping
local nvim_set_command = require('nvim').nvim_set_command
local load_module = require('tools').load_module

local telescope = load_module('telescope')

if telescope == nil then
    return nil
end

local lsp_languages = require('plugins/lsp')
local treesitter_languages = require('plugins/treesitter')

telescope.setup{
    defaults = {
        shorten_path = true,
    },
}

local noremap = {noremap = true}

nvim_set_mapping('n', '<C-b>', [[<cmd>lua require'telescope.builtin'.buffers{}<CR>]], noremap)
nvim_set_mapping('n', '<C-q>', [[<cmd>lua require'telescope.builtin'.quickfix{}<CR>]], noremap)
-- nvim_set_mapping('n', '<C-l>', [[<cmd>lua require'telescope.builtin'.loclist{}<CR>]], noremap)

-- require'telescope.builtin'.command_history{}

nvim_set_command(
    'Grep',
    [[lua require'telescope.builtin'.live_grep{}]],
    {force=true}
)

nvim_set_command(
    'Oldfiles',
    [[lua require'telescope.builtin'.oldfiles{}]],
    {force=true}
)

if lsp_languages ~= nil then
    nvim_set_autocmd(
        'FileType',
        lsp_languages,
        [[command! -buffer LSPReferences lua require'telescope.builtin'.lsp_references{}]],
        {group = 'LSPAutocmds'}
    )
    nvim_set_autocmd(
        'FileType',
        lsp_languages,
        [[command! -buffer LSPDocSymbols lua require'telescope.builtin'.lsp_document_symbols{}]],
        {group = 'LSPAutocmds'}
    )
    nvim_set_autocmd(
        'FileType',
        lsp_languages,
        [[command! -buffer LSPWorkSymbols lua require'telescope.builtin'.lsp_workspace_symbols{}]],
        {group = 'LSPAutocmds'}
    )
end

if treesitter_languages ~= nil then
    nvim_set_autocmd(
        'FileType',
        treesitter_languages,
        [[command! -buffer TSSymbols lua require'telescope.builtin'.treesitter{}]],
        {group = 'TreesitterAutocmds'}
    )
end

return true

local nvim = require('nvim')
local plugins = require('nvim').plugins
local nvim_set_autocmd = require('nvim').nvim_set_autocmd
local load_module = require('tools').load_module
-- local nvim_set_command = require('nvim').nvim_set_command

local completion = load_module('completion')
local lsp = require('plugins/lsp')
local treesitter = require('plugins/treesitter')

-- print('LSP: ', vim.inspect(lsp))
-- print('Treesitter: ', vim.inspect(treesitter))

if completion ~= nil then

    if plugins['ultisnips']  then
        nvim.g.completion_enable_snippet = 'UltiSnips'
    end

    -- TODO: Add confirm key completion handler
    nvim.g.completion_matching_strategy_list = { 'exact', 'substring', 'fuzzy'}
    nvim.g.completion_confirm_key            = ''
    nvim.g.completion_enable_auto_signature  = 0
    nvim.g.completion_matching_ignore_case   = 1
    nvim.g.completion_trigger_on_delete      = 1
    nvim.g.completion_enable_auto_hover      = 0
    nvim.g.completion_enable_auto_paren      = 0
    nvim.g.completion_auto_change_source     = 1

    local spell_check = {'gitcommit', 'markdown', 'tex'}

    local completion_chain = {
        default = {
            default = {
                {complete_items = {'snippet'}},
                {complete_items = { 'path' }, triggered_only = {'/'}},
                {mode = '<c-p>'},
                {mode = '<c-n>'}
            },
            -- func = {}
            -- string = {}
            -- comment = {},
        },
    }

    if lsp ~= nil then
        for _,language in pairs(lsp) do
            -- print('LSP Language: ', language)
            if completion_chain[language] == nil then
                -- print('Adding ', language, ' to completion chain')
                completion_chain[language] = {
                    {complete_items = {'lsp', 'snippet'}},
                    {complete_items = { 'path' }, triggered_only = {'/'}},
                    {mode = '<c-p>'},
                    {mode = '<c-n>'},
                }
                if language == 'vim' then
                    table.insert(completion_chain[language], 3, {mode = 'cmd'})
                end
            end
        end
    end

    if treesitter ~= nil and plugins['completion-treesitter'] ~= nil then
        for _,language in pairs(treesitter) do
            -- print('Treesitter Language: ', language)
            if completion_chain[language] == nil then
                -- print('Adding ', language, ' to completion chain')
                completion_chain[language] = {
                    {complete_items = {'ts', 'snippet'}},
                    {complete_items = { 'path' }, triggered_only = {'/'}},
                    {mode = '<c-p>'},
                    {mode = '<c-n>'},
                }
            end
        end
    end

    if completion_chain.vim == nil then
        completion_chain.vim = {
            {complete_items = {'snippet'}},
            {complete_items = { 'path' }, triggered_only = {'/'}},
            {mode = 'cmd'},
            {mode = '<c-p>'},
            {mode = '<c-n>'},
        }
    end

    -- for _,language in pairs(spell_check) do
    --     if completion_chain[language] == nil then
    --         completion_chain[language] = {
    --             {complete_items = {'snippet'}},
    --             {complete_items = { 'path' }, triggered_only = {'/'}},
    --             {mode = 'spel'},
    --             {mode = '<c-p>'},
    --             {mode = '<c-n>'},
    --         }
    --     else
    --         table.insert(completion_chain[language], 3, {mode = 'spel'})
    --     end
    -- end

    nvim.g.completion_chain_complete_list = completion_chain

    nvim_set_autocmd(
        'BufEnter',
        '*',
        [[lua require'completion'.on_attach()]],
        {create = true, group = 'Completion'}
    )

    -- TODO: Create Pull request to use buffer-variables
    nvim_set_autocmd(
        'BufEnter',
        '*',
        [[ let g:completion_trigger_character = ['.'] ]],
        {group = 'Completion'}
    )

    if lsp.cpp ~= nil or treesitter.cpp ~= nil then
        nvim_set_autocmd(
            'BufEnter',
            {'*.cpp', '*.hpp', '*.cc', '*.cxx'},
            [[ let g:completion_trigger_character = ['.', '::', '->'] ]],
            {group = 'Completion'}
        )
    end

elseif lsp ~= nil and plugins['vim-mucomplete'] ~= nil then
    nvim_set_autocmd(
        'FileType',
        lsp,
        [[call plugins#vim_mucomplete#setOmni()]],
        {create = true, group = 'Completion'}
    )
end

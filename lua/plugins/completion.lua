local nvim        = require'nvim'
local load_module = require'tools'.helpers.load_module
local has_attrs   = require'tools'.tables.has_attrs

local plugins          = nvim.plugins
local nvim_set_autocmd = nvim.nvim_set_autocmd

local completion = load_module('completion')

local lsp = require'plugins/lsp'
local treesitter = require'plugins/treesitter'

if completion ~= nil then

    if plugins.ultisnips then
        nvim.g.completion_enable_snippet = 'UltiSnips'
    end

    nvim.g.completion_matching_strategy_list = {
        'exact',
        'fuzzy',
        'substring',
    }

    nvim.g.completion_matching_ignore_case   = 1
    nvim.g.completion_matching_smart_case    = 1
    nvim.g.completion_confirm_key            = ''
    nvim.g.completion_sorting                = 'none'
    nvim.g.completion_trigger_on_delete      = 1
    nvim.g.completion_auto_change_source     = 1
    nvim.g.completion_enable_auto_signature  = 0
    nvim.g.completion_enable_auto_hover      = 0
    nvim.g.completion_enable_auto_paren      = 1

    -- local spell_check = {'gitcommit', 'markdown', 'tex', 'text', 'plaintext'}

    local completion_chain = {
        default = {
            default = {
                {complete_items = { 'path' }, triggered_only = {'/'}},
                {mode = '<c-p>'},
                {mode = '<c-n>'}
            },
            -- func = {}
            -- string = {}
            -- comment = {},
        },
    }

    local items = { complete_items = {} }

    -- if lsp then
    --     items.complete_items[#items.complete_items + 1] = 'lsp'
    -- end

    -- if treesitter then
    --     items.complete_items[#items.complete_items + 1] = 'ts'
    -- end

    if nvim.g.completion_enable_snippet then
        items.complete_items[#items.complete_items + 1] = 'snippet'
    end

    if #items.complete_items > 0 then
        table.insert(completion_chain.default.default, 1, items)
    end

    if lsp then
        for _,language in pairs(lsp) do
            if completion_chain[language] == nil then
                completion_chain[language] = {
                    default = {
                        {complete_items = {'lsp', 'snippet'}},
                        {complete_items = { 'path' }, triggered_only = {'/'}},
                        {mode = '<c-p>'},
                        {mode = '<c-n>'},
                    }
                }
                if language == 'vim' then
                    table.insert(completion_chain[language], 3, {mode = 'cmd'})
                -- elseif spell_check[language] ~= nil then
                --     table.insert(completion_chain[language], 3, {mode = 'spel'})
                end
            end
        end
    end

    if treesitter and plugins['completion-treesitter'] ~= nil then
        for _,language in pairs(treesitter) do
            if completion_chain[language] == nil then
                completion_chain[language] = {
                    default = {
                        {complete_items = {'ts', 'snippet'}},
                        {complete_items = { 'path' }, triggered_only = {'/'}},
                        {mode = '<c-p>'},
                        {mode = '<c-n>'},
                    }
                }
            end
            -- if spell_check[language] ~= nil then
            --     table.insert(completion_chain[language], 3, {mode = 'spel'})
            -- end
        end
    end

    if completion_chain.vim == nil then
        completion_chain.vim = {
            default = {
                {complete_items = {'snippet'}},
                {complete_items = { 'path' }, triggered_only = {'/'}},
                {mode = 'cmd'},
                {mode = '<c-p>'},
                {mode = '<c-n>'},
            }
        }
    end

    -- for _,language in pairs(spell_check) do
    --     if completion_chain[language] == nil then
    --         completion_chain[language] = {
    --             default = {
    --                 {complete_items = { 'path' }, triggered_only = {'/'}},
    --                 {mode = 'spel'},
    --                 {mode = '<c-p>'},
    --                 {mode = '<c-n>'},
    --             }
    --         }
    --     end
    -- end

    nvim.g.completion_chain_complete_list = completion_chain

    nvim_set_autocmd{
        event   = 'BufEnter',
        pattern = '*',
        cmd     = [[lua require'completion'.on_attach()]],
        group   = 'Completion',
    }

    -- TODO: Create Pull request to use buffer-variables
    nvim_set_autocmd{
        event   = 'BufEnter',
        pattern = '*',
        cmd     = [[ let g:completion_trigger_character = ['.'] ]],
        group   = 'Completion',
    }

    if has_attrs(lsp, 'cpp') or has_attrs(treesitter, 'cpp') then
        nvim_set_autocmd{
            event   = 'BufEnter',
            pattern = {'*.cpp', '*.hpp', '*.cc', '*.cxx'},
            cmd     = [[ let g:completion_trigger_character = ['.', '::', '->'] ]],
            group   = 'Completion',
        }
    end

    if has_attrs(lsp, 'lua') or has_attrs(treesitter, 'lua') then
        nvim_set_autocmd{
            event   = 'BufEnter',
            pattern = {'*.lua'},
            cmd     = [[ let g:completion_trigger_character = ['.', ':'] ]],
            group   = 'Completion',
        }
    end

elseif lsp and plugins['vim-mucomplete'] ~= nil then
    nvim_set_autocmd{
        event   = 'FileType',
        pattern = lsp,
        cmd     = [[call plugins#vim_mucomplete#setOmni()]],
        group   = 'Completion',
    }
    return false
end

return true

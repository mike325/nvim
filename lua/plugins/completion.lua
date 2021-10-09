local load_module = require('utils.helpers').load_module

local plugins = require('neovim').plugins

local set_autocmd = require('neovim.autocmds').set_autocmd
-- local set_command = require'neovim.commands'.set_command
-- local set_mapping = require'neovim.mappings'.set_mapping

local completion = load_module 'completion'
local compe = load_module 'compe'
local cmp = load_module 'cmp'

local lsp = require 'plugins.lsp'
local treesitter = require 'plugins.treesitter'

local function completion_chain()
    local chain = {
        default = {
            default = {
                { complete_items = { 'path' }, triggered_only = { '/' } },
                { mode = '<c-p>' },
                { mode = '<c-n>' },
            },
            -- func = {}
            string = {
                { mode = '<c-p>' },
                { mode = '<c-n>' },
            },
            comment = {
                { mode = '<c-p>' },
                { mode = '<c-n>' },
            },
        },
    }

    local items = { complete_items = {} }

    local spell_check = { 'gitcommit', 'markdown', 'tex', 'text', 'plaintext' }

    -- if lsp then
    --     items.complete_items[#items.complete_items + 1] = 'lsp'
    -- end

    -- if treesitter then
    --     items.complete_items[#items.complete_items + 1] = 'ts'
    -- end

    if vim.g.completion_enable_snippet then
        items.complete_items[#items.complete_items + 1] = 'snippet'
    end

    if #items.complete_items > 0 then
        table.insert(chain.default.default, 1, items)
    end

    if lsp then
        for _, language in pairs(lsp) do
            if chain[language] == nil then
                chain[language] = {
                    default = {
                        { complete_items = { 'lsp', 'snippet' } },
                        { complete_items = { 'path' }, triggered_only = { '/' } },
                        { mode = 'omni' },
                        { mode = '<c-p>' },
                        { mode = '<c-n>' },
                    },
                }

                chain[language].string = chain.default.string
                chain[language].comment = chain.default.comment

                if language == 'vim' then
                    table.insert(chain[language].default, 3, { mode = 'cmd' })
                elseif spell_check[language] ~= nil then
                    table.insert(chain[language].default, 2, { mode = 'dict' })
                end
            end
        end
    end

    if treesitter and plugins['completion-treesitter'] ~= nil then
        for _, language in pairs(treesitter) do
            if chain[language] == nil then
                chain[language] = {
                    default = {
                        { complete_items = { 'ts', 'snippet' } },
                        { complete_items = { 'path' }, triggered_only = { '/' } },
                        { mode = '<c-p>' },
                        { mode = '<c-n>' },
                    },
                }
            end
            if spell_check[language] ~= nil then
                table.insert(chain[language].default, 3, { mode = 'dict' })
            end
        end
    end

    for _, language in pairs(spell_check) do
        if chain[language] == nil then
            chain[language] = {
                default = {
                    { complete_items = { 'path' }, triggered_only = { '/' } },
                    { mode = 'dict' },
                    { mode = '<c-p>' },
                    { mode = '<c-n>' },
                },
            }
        end
    end

    if chain.vim == nil then
        chain.vim = {
            default = {
                { complete_items = { 'snippet' } },
                { complete_items = { 'path' }, triggered_only = { '/' } },
                { mode = 'cmd' },
                { mode = '<c-p>' },
                { mode = '<c-n>' },
            },
        }
    end

    return chain
end

if cmp ~= nil then
    local vsnip = load_module 'vsnip'
    local luasnip = load_module 'luasnip'
    local ultisnips = plugins.ultisnips

    local sources = {
        { name = 'nvim_lsp' },
    }

    if ultisnips then
        table.insert(sources, { name = 'ultisnips' })
    elseif vsnip then
        table.insert(sources, { name = 'vsnip' })
    elseif luasnip then
        table.insert(sources, { name = 'luasnip' })
    end

    table.insert(sources, { name = 'buffer' })

    cmp.setup {
        snippet = {
            expand = function(args)
                if ultisnips then
                    -- For `ultisnips` user.
                    vim.fn['UltiSnips#Anon'](args.body)
                elseif vsnip then
                    -- For `vsnip` user.
                    vim.fn['vsnip#anonymous'](args.body)
                elseif luasnip then
                    -- For `luasnip` user.
                    require('luasnip').lsp_expand(args.body)
                end
            end,
        },
        mapping = {
            -- ['<C-d>'] = cmp.mapping.scroll_docs(-4),
            -- ['<C-f>'] = cmp.mapping.scroll_docs(4),
            -- ['<C-Space>'] = cmp.mapping.complete(),
            -- ['<C-e>'] = cmp.mapping.close(),
            -- ['<CR>'] = cmp.mapping.confirm({ select = true }),
        },
        sources = sources,
    }

    -- if lsp then
    --     -- Setup lspconfig.
    --     require('lspconfig')[%YOUR_LSP_SERVER%].setup {
    --         capabilities = require('cmp_nvim_lsp').update_capabilities(
    --             vim.lsp.protocol.make_client_capabilities()
    --         )
    --     }
    -- end
elseif compe ~= nil then
    compe.setup {
        enabled = true,
        autocomplete = true,
        debug = false,
        min_length = 1,
        preselect = 'enable', -- 'enable' || 'disable' || 'always',
        throttle_time = 80,
        source_timeout = 200,
        incomplete_delay = 400,
        max_abbr_width = 100,
        max_kind_width = 100,
        max_menu_width = 100,
        documentation = true,
        -- allow_prefix_unmatch = false,
        source = {
            path = true,
            buffer = true,
            emoji = true,
            calc = true,
            treesitter = treesitter ~= nil,
            -- tags = true,
            nvim_lsp = lsp ~= nil,
            nvim_lua = true,
            vsnip = plugins.vsnip ~= nil,
            luasnip = plugins.luasnip ~= nil,
            ultisnips = plugins.ultisnips ~= nil,
            snippets_nvim = plugins['snippets.nvim'] ~= nil,
            neorg = plugins.neorg ~= nil,
        },
    }
elseif completion ~= nil then
    if plugins.ultisnips then
        vim.g.completion_enable_snippet = 'UltiSnips'
    end

    -- vim.g.completion_sorting                = 'none'  -- 'alphabet' -- 'length'
    vim.g.completion_matching_ignore_case = 1
    vim.g.completion_matching_smart_case = 1
    vim.g.completion_confirm_key = ''
    vim.g.completion_trigger_on_delete = 1
    vim.g.completion_auto_change_source = 1
    vim.g.completion_enable_auto_paren = 1
    vim.g.completion_enable_auto_signature = 1
    vim.g.completion_enable_auto_hover = 1
    vim.g.completion_trigger_keyword_length = 1

    vim.g.completion_matching_strategy_list = {
        'exact',
        'fuzzy',
        'substring',
    }

    vim.g.completion_items_priority = {
        Method = 10,
        Field = 8,
        Function = 7,
        Module = 7,
        Variable = 7,
        Interface = 5,
        Constant = 5,
        Class = 5,
        UltiSnips = 5,
        Keyword = 4,
        ['vim-vsnip'] = 1,
        Buffers = 1,
        TabNine = 0,
        File = 0,
        Text = 0,
    }

    vim.g.completion_chain_complete_list = completion_chain()

    set_autocmd {
        event = 'BufEnter',
        pattern = '*',
        cmd = [[lua require'completion'.on_attach()]],
        group = 'Completion',
    }

    -- TODO: Create Pull request to use buffer-variables
    set_autocmd {
        event = 'BufEnter',
        pattern = '*',
        cmd = [[ let g:completion_trigger_character = ['.'] ]],
        group = 'Completion',
    }

    if vim.tbl_contains(lsp, 'cpp') or vim.tbl_contains(treesitter, 'cpp') then
        set_autocmd {
            event = 'BufEnter',
            pattern = { '*.c', '*.h', '*.cpp', '*.hpp', '*.cc', '*.cxx' },
            cmd = [[ let g:completion_trigger_character = ['.', '::', '->'] ]],
            group = 'Completion',
        }
    end

    if vim.tbl_contains(lsp, 'lua') or vim.tbl_contains(treesitter, 'lua') then
        set_autocmd {
            event = 'BufEnter',
            pattern = { '*.lua' },
            cmd = [[ let g:completion_trigger_character = ['.', ':'] ]],
            group = 'Completion',
        }
    end
elseif lsp and plugins['vim-mucomplete'] ~= nil then
    set_autocmd {
        event = 'FileType',
        pattern = lsp,
        cmd = [[call plugins#vim_mucomplete#setOmni()]],
        group = 'Completion',
    }
end

return cmp ~= nil or compe ~= nil or completion ~= nil

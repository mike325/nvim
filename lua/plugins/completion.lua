local load_module = require('utils.helpers').load_module

local plugins = require('neovim').plugins

-- local set_autocmd = require('neovim.autocmds').set_autocmd
-- local set_command = require'neovim.commands'.set_command
-- local set_mapping = require'neovim.mappings'.set_mapping

local cmp = load_module 'cmp'
if not cmp then
    return false
end

-- local lsp = require 'plugins.lsp'
-- local treesitter = require 'plugins.treesitter'

local vsnip = load_module 'vsnip'
local luasnip = load_module 'luasnip'
local ultisnips = plugins.ultisnips
local lspkind = require 'lspkind'

local sources = {
    { name = 'nvim_lsp' },
    { name = 'nvim_lua' },
    { name = 'path' },
}

if ultisnips then
    table.insert(sources, { name = 'ultisnips' })
elseif vsnip then
    table.insert(sources, { name = 'vsnip' })
elseif luasnip then
    table.insert(sources, { name = 'luasnip' })
end

table.insert(sources, { name = 'buffer' })

local next_item = function(fallback)
    if cmp.visible() then
        cmp.select_next_item()
    else
        -- The fallback function is treated as original mapped key. In this case, it might be `<Tab>`.
        fallback()
    end
end

local prev_item = function(fallback)
    if cmp.visible() then
        cmp.select_prev_item()
    else
        -- The fallback function is treated as original mapped key. In this case, it might be `<Tab>`.
        fallback()
    end
end

-- TODO: improve snippets support
cmp.setup {
    snippet = {
        expand = function(args)
            if ultisnips then
                vim.fn['UltiSnips#Anon'](args.body)
            elseif vsnip then
                vim.fn['vsnip#anonymous'](args.body)
            elseif luasnip then
                require('luasnip').lsp_expand(args.body)
            end
        end,
    },
    mapping = {
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        -- ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.close(),
        ['<C-y>'] = cmp.mapping.confirm {
            behavior = cmp.SelectBehavior.Insert,
            select = true,
        },
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.SelectBehavior.Insert,
            select = true,
        },
        ['<Tab>'] = next_item,
        ['<S-Tab>'] = prev_item,
        ['<C-n>'] = next_item,
        ['<C-p>'] = prev_item,
    },
    sources = sources,
    formatting = {
        format = lspkind.cmp_format {
            with_text = true,
            menu = {
                buffer = '[buffer]',
                nvim_lsp = '[LSP]',
                nvim_lua = '[API]',
                path = '[path]',
                luasnip = '[snip]',
                ultisnips = '[snip]',
            },
        },
    },
    experimental = {
        native_menu = false,
        ghost_text = true,
    },
}

return true

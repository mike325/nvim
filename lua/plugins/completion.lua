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
}

if ultisnips then
    table.insert(sources, { name = 'ultisnips' })
elseif vsnip then
    table.insert(sources, { name = 'vsnip' })
elseif luasnip then
    table.insert(sources, { name = 'luasnip', opts = { use_show_condition = false } })
end

vim.list_extend(sources, { { name = 'buffer' }, { name = 'path' } })

local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match '%s' == nil
end

-- local t = function(str)
--     return vim.api.nvim_replace_termcodes(str, true, true, true)
-- end

local next_item = function(fallback)
    if cmp.visible() then
        cmp.select_next_item()
    elseif luasnip and luasnip.jumpable(1) then
        luasnip.jump(1)
    elseif ultisnips and vim.fn['UltiSnips#CanJumpForwards']() == 1 then
        vim.fn['UltiSnips#JumpForwards']()
        -- vim.api.nvim_feedkeys(t '<Plug>(ultisnips_jump_forward)', 'm', true)
    elseif has_words_before() then
        cmp.complete()
    else
        -- The fallback function is treated as original mapped key. In this case, it might be `<Tab>`.
        fallback()
    end
end

local prev_item = function(fallback)
    if cmp.visible() then
        cmp.select_prev_item()
    elseif luasnip and luasnip.jumpable(-1) then
        luasnip.jump(-1)
    elseif ultisnips and vim.fn['UltiSnips#CanJumpBackwards']() == 1 then
        vim.fn['UltiSnips#JumpBackwards']()
        -- vim.api.nvim_feedkeys(t '<Plug>(ultisnips_jump_backward)', 'm', true)
    else
        fallback()
    end
end

local enter_item = function(fallback)
    if luasnip and luasnip.expandable() then
        luasnip.expand()
    elseif ultisnips and vim.fn['UltiSnips#CanExpandSnippet']() == 1 then
        vim.fn['UltiSnips#ExpandSnippet']()
    elseif cmp.visible() then
        if not cmp.get_selected_entry() then
            cmp.close()
        else
            cmp.confirm { behavior = cmp.ConfirmBehavior.Replace, select = false }
        end
    else
        fallback()
    end
end

local close = function(fallback)
    -- if ultisnips and vim.fn['UltiSnips#CanExpandSnippet']() == 1 then
    --     vim.fn['UltiSnips#ExpandSnippet']()
    if luasnip and luasnip.choice_active() then
        luasnip.change_choice(1)
    elseif cmp.visible() then
        cmp.close()
    else
        fallback()
    end
end

cmp.setup {
    snippet = {
        expand = function(args)
            if ultisnips then
                vim.fn['UltiSnips#Anon'](args.body)
            elseif luasnip then
                require('luasnip').lsp_expand(args.body)
            elseif vsnip then
                vim.fn['vsnip#anonymous'](args.body)
            end
        end,
    },
    mapping = {
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-y>'] = cmp.mapping.confirm {
            behavior = cmp.SelectBehavior.Insert,
            select = true,
        },
        ['<C-e>'] = cmp.mapping(close, { 'i', 's' }),
        ['<CR>'] = cmp.mapping(enter_item, { 'i', 's' }),
        ['<Tab>'] = cmp.mapping(next_item, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(prev_item, { 'i', 's' }),
        ['<C-n>'] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
        ['<C-p>'] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
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
                vsnip = '[snip]',
            },
        },
    },
    experimental = {
        native_menu = false,
        ghost_text = true,
    },
}

return true

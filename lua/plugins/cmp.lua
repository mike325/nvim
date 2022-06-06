local load_module = require('utils.helpers').load_module

local nvim = require 'neovim'
local executable = require('utils.files').executable

local cmp = load_module 'cmp'
if not cmp then
    return false
end

local luasnip = load_module 'luasnip'
local orgmode = load_module 'orgmode'
local ultisnips = nvim.plugins.ultisnips
local lspkind = require 'lspkind'

local custom_comparators = {
    clangd_comparator = load_module 'clangd_extensions.cmp_scores',
    underscore = load_module 'cmp-under-comparator',
}

local comparators = vim.deepcopy(cmp.get_config().sorting.comparators)

for _, comparator in ipairs(custom_comparators) do
    table.insert(comparators, 4, comparator)
end

local function has_treesitter()
    if nvim.has 'win32' or nvim.has 'win64' then
        return executable 'gcc'
    end
    return executable 'gcc' or executable 'clang'
end

local sources = {
    { name = 'nvim_lua' },
    { name = 'nvim_lsp' },
    { name = 'nvim_lsp_signature_help' },
}

if has_treesitter() then
    table.insert(sources, { name = 'treesitter' })
end

if luasnip then
    table.insert(sources, { name = 'luasnip', option = { use_show_condition = false } })
elseif ultisnips then
    table.insert(sources, { name = 'ultisnips' })
end

if orgmode then
    table.insert(sources, { name = 'orgmode' })
end

vim.list_extend(sources, { { name = 'buffer' }, { name = 'path' } })

local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match '%s' == nil
end

local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local next_item = function(fallback)
    local neogen = load_module 'neogen'
    local ls = load_module 'luasnip'

    if cmp.visible() then
        cmp.select_next_item()
    elseif ls and ls.jumpable(1) then
        ls.jump(1)
    elseif neogen and neogen.jumpable() then
        vim.fn.feedkeys(t "<cmd>lua require('neogen').jump_next()<CR>", '')
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
    local neogen = load_module 'neogen'
    local ls = load_module 'luasnip'

    if cmp.visible() then
        cmp.select_prev_item()
    elseif ls and ls.jumpable(-1) then
        ls.jump(-1)
    elseif ultisnips and vim.fn['UltiSnips#CanJumpBackwards']() == 1 then
        vim.fn['UltiSnips#JumpBackwards']()
        -- vim.api.nvim_feedkeys(t '<Plug>(ultisnips_jump_backward)', 'm', true)
    elseif neogen and neogen.jumpable(-1) then
        vim.fn.feedkeys(t "<cmd>lua require('neogen').jump_prev()<CR>", '')
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
    sources = cmp.config.sources(sources),
    formatting = {
        format = lspkind.cmp_format {
            with_text = true,
            menu = {
                buffer = '[BUFFER]',
                treesitter = '[TS]',
                nvim_lsp = '[LSP]',
                nvim_lua = '[API]',
                path = '[PATH]',
                luasnip = '[SNIP]',
                ultisnips = '[SNIP]',
                vsnip = '[SNIP]',
            },
        },
    },
    experimental = {
        native_menu = false,
        ghost_text = true,
    },
    sorting = {
        comparators = comparators,
    },
}

return true

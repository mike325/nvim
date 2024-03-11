local nvim = require 'nvim'
local executable = require('utils.files').executable

local cmp = vim.F.npcall(require, 'cmp')
if not cmp then
    return false
end

local orgmode = vim.F.npcall(require, 'orgmode')

local lspkind = vim.F.npcall(require, 'lspkind')
local format
if lspkind then
    format = {
        format = lspkind.cmp_format {
            maxwidth = 50,
            ellipsis_char = '...',
            with_text = true,
            menu = {
                buffer = '[BUFFER]',
                treesitter = '[TS]',
                nvim_lsp = '[LSP]',
                nvim_lua = '[API]',
                path = '[PATH]',
                luasnip = '[SNIP]',
                vsnip = '[SNIP]',
                snippets = '[SNIP]',
            },
        },
    }
end

local custom_comparators = {
    clangd_comparator = vim.F.npcall(require, 'clangd_extensions.cmp_scores'),
    underscore = vim.F.npcall(require, 'cmp-under-comparator'),
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

if nvim.plugins.LuaSnip then
    table.insert(sources, { name = 'luasnip', option = { use_show_condition = false } })
end

if orgmode then
    table.insert(sources, { name = 'orgmode' })
end

vim.list_extend(sources, { { name = 'buffer' }, { name = 'path' } })

local function has_words_before()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match '%s' == nil
end

local function replace_termcodes(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local function next_item(fallback)
    local neogen = vim.F.npcall(require, 'neogen')

    local ls = vim.F.npcall(require, 'luasnip')
    if ls then
        ls.unlink_current_if_deleted()
    end

    if cmp.visible() then
        cmp.select_next_item()
    elseif ls and ls.locally_jumpable(1) then
        ls.jump(1)
    elseif vim.snippet and vim.snippet.jumpable(1) then
        vim.snippet.jump(1)
    elseif neogen and neogen.jumpable() then
        vim.fn.feedkeys(replace_termcodes "<cmd>lua require('neogen').jump_next()<CR>", '')
    elseif has_words_before() then
        cmp.complete()
    else
        -- The fallback function is treated as original mapped key. In this case, it might be `<Tab>`.
        fallback()
    end
end

local function prev_item(fallback)
    local neogen = vim.F.npcall(require, 'neogen')

    local ls = vim.F.npcall(require, 'luasnip')
    if ls then
        ls.unlink_current_if_deleted()
    end

    if cmp.visible() then
        cmp.select_prev_item()
    elseif ls and ls.locally_jumpable(-1) then
        ls.jump(-1)
    elseif vim.snippet and vim.snippet.jumpable(-1) then
        vim.snippet.jump(-1)
    elseif neogen and neogen.jumpable(-1) then
        vim.fn.feedkeys(replace_termcodes "<cmd>lua require('neogen').jump_prev()<CR>", '')
    else
        fallback()
    end
end

local function enter_item(fallback)

    local ls = vim.F.npcall(require, 'luasnip')
    if ls and ls.expandable() then
        ls.expand()
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

local function close(fallback)

    local ls = vim.F.npcall(require, 'luasnip')
    if ls and ls.choice_active() then
        ls.change_choice(1)
    elseif cmp.visible() then
        cmp.close()
    else
        fallback()
    end
end

cmp.setup {
    view = {
        docs = {
            auto_open = true,
        },
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    snippet = {
        expand = function(args)
            local ls = vim.F.npcall(require, 'luasnip')
            if ls then
                ls.lsp_expand(args.body)
            end
        end,
    },
    -- completion = {
    --     keyword_length = 1,
    -- },
    mapping = {
        ['<C-d>'] = function()
            if cmp.visible_docs() then
                cmp.close_docs()
            else
                cmp.open_docs()
            end
        end,
        ['<C-k>'] = cmp.mapping.scroll_docs(4),
        ['<C-j>'] = cmp.mapping.scroll_docs(-4),
        ['<C-y>'] = cmp.mapping.confirm {
            behavior = cmp.SelectBehavior.Insert,
            select = true,
        },
        -- TODO: May move this functions to utils.functions to auto reload them
        ['<C-e>'] = cmp.mapping(close, { 'i', 's' }),
        ['<CR>'] = cmp.mapping(enter_item, { 'i', 's' }),
        ['<Tab>'] = cmp.mapping(next_item, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(prev_item, { 'i', 's' }),
        ['<C-n>'] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
        ['<C-p>'] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
    },
    sources = cmp.config.sources(sources),
    formatting = format,
    experimental = {
        ghost_text = true,
    },
    sorting = {
        comparators = comparators,
    },
}

-- cmp.setup.cmdline({ '/', '?' }, {
--     completion = {
--         keyword_length = 2,
--     },
--     mapping = cmp.mapping.preset.cmdline(),
--     sources = {
--         { name = 'treesitter' },
--         { name = 'buffer' },
--     },
-- })

-- cmp.setup.cmdline(':', {
--     completion = {
--         keyword_length = 2,
--     },
--     mapping = cmp.mapping.preset.cmdline(),
--     sources = cmp.config.sources {
--         { name = 'path' },
--     },
-- })

return true

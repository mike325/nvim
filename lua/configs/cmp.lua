local cmp = vim.F.npcall(require, 'cmp')
if not cmp then
    return false
end

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

local custom_comparators = {}

local underscore = vim.F.npcall(require, 'cmp-under-comparator')
if underscore then
    custom_comparators.underscore = underscore.under
end

local comparators = vim.deepcopy(cmp.get_config().sorting.comparators)
for _, comparator in pairs(custom_comparators) do
    table.insert(comparators, 2, comparator)
end

local function has_treesitter()
    local nvim = require 'nvim'
    local executable = require('utils.files').executable

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

local nvim = require 'nvim'
if nvim.plugins.LuaSnip then
    table.insert(sources, { name = 'luasnip', option = { use_show_condition = false } })
end

if vim.F.npcall(require, 'orgmode') then
    table.insert(sources, { name = 'orgmode' })
end

vim.list_extend(sources, { { name = 'buffer' }, { name = 'path' } })

cmp.setup {
    enabled = function()
        local blacklist = {
            TelescopePrompt = true,
        }
        local ft = vim.bo.filetype
        if nvim.plugins.YouCompleteMe and vim.g.ycm_enabled then
            vim.tbl_extend('force', blacklist, { python = true })
            local bufname = vim.api.nvim_buf_get_name(0)
            local ext = require('utils.files').extension
            if blacklist[ft] or (bufname ~= '' and ext(bufname) == 'py') then
                return false
            end
        end
        return not blacklist[ft]
    end,
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
        ['<C-e>'] = vim.NIL,
        ['<CR>'] = vim.NIL,
        ['<Tab>'] = vim.NIL,
        ['<S-Tab>'] = vim.NIL,
        ['<C-n>'] = vim.NIL,
        ['<C-p>'] = vim.NIL,
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

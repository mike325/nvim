local ls = vim.F.npcall(require, 'luasnip')
if not ls then
    return false
end

local nvim = require 'nvim'

ls.config.setup {
    -- history = true,
    -- region_check_events = 'InsertEnter,InsertLeave',
    -- NOTE: Live update snippets
    update_events = { 'InsertLeave', 'TextChangedI' }, -- TextChanged,TextChangedI
    store_selection_keys = '<CR>',
    ext_opts = {
        [require('luasnip.util.types').choiceNode] = {
            snippet_passive = {
                virt_text = { { '●', 'Comment' } },
            },
        },
    },
}

-- TODO: Add file watcher to auto reload snippets on changes
local function load_snippets(ft)
    local runtimepaths = {
        ['lua/snippets'] = {
            default_priority = 1000,
        },
        ['luasnippets'] = {
            default_priority = 2000,
        },
    }

    local ok
    local snip_msg = ''
    ft = ft or vim.bo.filetype

    for runtimepath, opts in pairs(runtimepaths) do
        for _, snips in ipairs(vim.api.nvim_get_runtime_file(vim.fs.joinpath(runtimepath, 'all.lua'), true)) do
            ok, snip_msg = pcall(dofile, snips)
            if not ok then
                goto fail
            end
            opts.key = snips
            ls.add_snippets('all', snip_msg, opts)
        end

        for _, snips in ipairs(vim.api.nvim_get_runtime_file(vim.fs.joinpath(runtimepath, ft .. '.lua'), true)) do
            ok, snip_msg = pcall(dofile, snips)
            if not ok then
                goto fail
            end
            opts.key = snips
            ls.add_snippets(ft, snip_msg, opts)
        end
    end

    ::fail::

    return ok, snip_msg
end

nvim.command.set('SnippetEdit', function()
    require('luasnip.loaders').edit_snippet_files()
end, { nargs = '?', complete = 'filetype' })

-- TODO: Improve this reload function
nvim.command.set('SnippetReload', function()
    local ok, msg = load_snippets()
    if ok then
        vim.notify 'Snippets Reloaded!'
    else
        vim.notify(msg, vim.log.levels.ERROR, { title = 'Luasnip' })
    end
end)

nvim.command.set('SnippetUnlink', function()
    vim.cmd.LuaSnipUnlinkCurrent()
end)

if #ls.get_snippets 'all' == 0 then
    ls.add_snippets('all', require 'snippets.all')
end

-- TODO: may add changes to this to "manually" load files using autocmds to better control hot/auto reload
-- require('luasnip.loaders.from_lua').lazy_load {
--     paths = snippet_paths,
--     priority = 1000,
--     override_priority = 1000,
-- }

-- NOTE: This will load all snippets found in the runtimepath located in the luasnippets
-- require('luasnip.loaders.from_lua').lazy_load {
--     priority = 2000,
--     override_priority = 2000,
-- }

vim.api.nvim_create_autocmd('Filetype', {
    desc = 'Auto load ft snippet using custom loader',
    group = vim.api.nvim_create_augroup('AutoLoadSnippets', { clear = true }),
    pattern = '*',
    callback = function()
        load_snippets()
    end,
})

return true

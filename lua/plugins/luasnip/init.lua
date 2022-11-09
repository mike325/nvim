local load_module = require('utils.functions').load_module
local ls = load_module 'luasnip'
if not ls then
    return false
end

local nvim = require 'neovim'

local snippet_paths = {
    './lua/snippets/',
}

ls.config.setup {
    -- history = true,
    -- region_check_events = 'InsertEnter,InsertLeave',
    -- NOTE: Live update snippets
    update_events = 'InsertLeave,TextChangedI', -- TextChanged,TextChangedI
    store_selection_keys = '<CR>',
    ext_opts = {
        [require('luasnip.util.types').choiceNode] = {
            snippet_passive = {
                virt_text = { { '●', 'Comment' } },
            },
        },
    },
}

nvim.command.set('SnippetEdit', function(opts)
    require('luasnip.loaders').edit_snippet_files()
end, { nargs = '?', complete = 'filetype' })

-- TODO: Improve this reload function
nvim.command.set('SnippetReload', function()
    ls.cleanup()

    local runtimepaths = {
        'lua/snippets/',
        'luasnippets/',
    }

    local errors = false
    local ok, snip_msg
    for _, runtimepath in ipairs(runtimepaths) do
        for _, snips in ipairs(vim.api.nvim_get_runtime_file(runtimepath .. 'all.lua', true)) do
            ok, snip_msg = pcall(dofile, snips)
            if not ok then
                errors = true
                break
            end
            ls.add_snippets('all', snip_msg, { key = snips })
        end

        if errors then
            break
        end

        local ft = vim.opt_local.filetype:get()
        for _, snips in ipairs(vim.api.nvim_get_runtime_file(runtimepath .. ft .. '.lua', true)) do
            ok, snip_msg = pcall(dofile, snips)
            if not ok then
                errors = true
                break
            end
            ls.add_snippets(ft, snip_msg, { key = snips })
        end

        if errors then
            break
        end
    end

    if not errors then
        vim.notify 'Snippets Reloaded!'
    else
        vim.notify(snip_msg, 'ERROR', { title = 'Luasnip' })
    end
end)

nvim.command.set('SnippetUnlink', function()
    vim.cmd.LuaSnipUnlinkCurrent()
end)

if #ls.get_snippets 'all' == 0 then
    ls.add_snippets('all', require 'snippets.all')
end

-- TODO: may add changes to this to "manually" load files using autocmds to better control hot/auto reload
require('luasnip.loaders.from_lua').lazy_load {
    paths = snippet_paths,
    priority = 1000,
    override_priority = 1000,
}

-- NOTE: This will load all snippets found in the runtimepath located in the luasnippets
require('luasnip.loaders.from_lua').lazy_load {
    priority = 2000,
    override_priority = 2000,
}

return true

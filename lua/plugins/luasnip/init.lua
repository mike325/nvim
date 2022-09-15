local load_module = require('utils.functions').load_module
local ls = load_module 'luasnip'
if not ls then
    return false
end

local sys = require 'sys'
local nvim = require 'neovim'

local snippet_paths = {
    sys.base .. '/lua/snippets/',
    './snippets/',
}

ls.config.setup {
    -- history = true,
    -- region_check_events = 'InsertEnter,InsertLeave',
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

nvim.command.set('SnippetReload', function()
    -- ls.cleanup()

    local ok, snip_msg = pcall(RELOAD, 'snippets.all')
    if not ok then
        vim.notify('Failed to update General snippets\n' .. snip_msg, 'ERROR', { title = 'Luasnip' })
        return
    end

    ls.add_snippets('all', snip_msg)

    local ft = vim.opt_local.filetype:get()
    local snippet = 'snippets.' .. ft
    local is_file = require('utils.files').is_file
    local base = sys.base

    if is_file(('%s/lua/%s.lua'):format(base, snippet:gsub('%.', '/'))) then
        ok, snip_msg = pcall(RELOAD, snippet)
        if ok then
            ls.add_snippets(ft, snip_msg)
            vim.notify 'Snippets Reloaded!'
        else
            vim.notify(snip_msg, 'ERROR', { title = 'Luasnip' })
        end
    else
        vim.notify(snip_msg, 'ERROR', { title = 'Luasnip' })
    end
end)

nvim.command.set('SnippetUnlink', function()
    vim.cmd [[LuaSnipUnlinkCurrent]]
end)

if #ls.get_snippets 'all' == 0 then
    ls.add_snippets('all', require 'snippets.all')
end

require('luasnip.loaders.from_lua').lazy_load {
    paths = snippet_paths,
}

return true

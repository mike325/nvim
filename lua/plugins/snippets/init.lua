local load_module = require('utils.helpers').load_module
local ls = load_module 'luasnip'
if not ls then
    return false
end

local set_autocmd = require('neovim.autocmds').set_autocmd
local nvim = require 'neovim'

local types = require 'luasnip.util.types'

ls.config.set_config {
    history = true,
    -- Update more often, :h events for more info.
    updateevents = 'TextChanged,TextChangedI',
    store_selection_keys = '<CR>',
    ext_opts = {
        [types.choiceNode] = {
            snippet_passive = {
                virt_text = { { '●', 'Comment' } },
            },
        },
    },
    -- treesitter-hl has 100, use something higher (default is 200).
    -- ext_base_prio = 300,
    -- minimal increase in priority.
    -- ext_prio_increase = 1,
    -- enable_autosnippets = true,
}

RELOAD 'plugins.snippets.all'

set_autocmd { event = 'FileType', pattern = '*', group = 'Snippets' }
set_autocmd {
    event = 'FileType',
    pattern = '*',
    cmd = [[lua pcall(RELOAD, "plugins.snippets."..vim.opt_local.filetype:get())]],
    group = 'Snippets',
}

nvim.command.set('SnippetEdit', function(opts)
    local ft = opts.args ~= '' and opts.args or vim.opt_local.filetype:get()
    local base = require('sys').base
    vim.cmd(('edit %s/lua/plugins/snippets/%s.lua'):format(base, ft))
end, { nargs = '?', complete = 'filetype' })

nvim.command.set('SnippetReload', function()
    RELOAD 'plugins.snippets.all'

    local snippet = 'plugins.snippets.' .. vim.opt_local.filetype:get()
    local is_file = require('utils.files').is_file
    local base = require('sys').base

    if is_file(('%s/lua/%s.lua'):format(base, snippet:gsub('%.', '/'))) then
        local ok, msg = pcall(RELOAD, snippet)
        if ok then
            vim.notify 'Snippets Reloaded!'
        else
            vim.notify(msg, 'ERROR', { title = 'Luasnip' })
        end
    else
        vim.notify('Missing snippets file', 'ERROR', { title = 'Luasnip' })
    end
end)

nvim.command.set('SnippetUnlink', function()
    vim.cmd [[LuaSnipUnlinkCurrent]]
end)

return true

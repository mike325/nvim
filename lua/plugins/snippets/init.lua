local load_module = require('utils.helpers').load_module
local ls = load_module 'luasnip'
if not ls then
    return false
end

local set_autocmd = require('neovim.autocmds').set_autocmd
local set_command = require('neovim.commands').set_command

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

set_command {
    lhs = 'SnippetEdit',
    rhs = function(ft)
        ft = (ft and ft ~= '') and ft or vim.opt_local.filetype:get()
        local base = require('sys').base
        vim.cmd(('edit %s/lua/plugins/snippets/%s.lua'):format(base, ft))
    end,
    args = { nargs = '?', force = true, complete = 'filetype' },
}

set_command {
    lhs = 'SnippetReload',
    rhs = function()
        -- ls.cleanup()

        local ok, msg = pcall(RELOAD, 'plugins.snippets.all')
        if not ok then
            vim.notify('Failed to update General snippets\n' .. msg, 'ERROR', { title = 'Luasnip' })
            return
        end

        local snippet = 'plugins.snippets.' .. vim.opt_local.filetype:get()
        local is_file = require('utils.files').is_file
        local base = require('sys').base

        if is_file(('%s/lua/%s.lua'):format(base, snippet:gsub('%.', '/'))) then
            ok, msg = pcall(RELOAD, snippet)
            if ok then
                vim.notify 'Snippets Reloaded!'
            else
                vim.notify(msg, 'ERROR', { title = 'Luasnip' })
            end
        else
            vim.notify('Missing snippets file', 'ERROR', { title = 'Luasnip' })
        end
    end,
    args = { force = true },
}

set_command {
    lhs = 'SnippetUnlink',
    rhs = function()
        vim.cmd [[LuaSnipUnlinkCurrent]]
    end,
    args = { force = true },
}

return true

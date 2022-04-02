local load_module = require('utils.helpers').load_module
local ls = load_module 'luasnip'
if not ls then
    return false
end

local set_command = require('neovim.commands').set_command
local sys = require 'sys'
local nvim = require 'neovim'

local types = require 'luasnip.util.types'

ls.config.setup {
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

-- TODO: May replace this with the recommended function from Luasnip help
set_command {
    lhs = 'SnippetEdit',
    rhs = function(ft)
        ft = (ft and ft ~= '') and ft or vim.opt_local.filetype:get()
        local base = sys.base
        vim.cmd(('topleft vsplit %s/lua/snippets/%s.lua'):format(base, ft))
        nvim.ex.wincmd 'L'
    end,
    args = { nargs = '?', force = true, complete = 'filetype' },
}

set_command {
    lhs = 'SnippetReload',
    rhs = function()
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

if #ls.get_snippets 'all' == 0 then
    ls.add_snippets('all', require 'snippets.all')
end

require('luasnip.loaders.from_lua').lazy_load {
    paths = {
        sys.base .. '/lua/snippets/',
        './snippets/',
    },
}

return true

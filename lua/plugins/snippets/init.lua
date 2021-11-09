local load_module = require('utils.helpers').load_module
local ls = load_module 'luasnip'
if not ls then
    return false
end

local set_autocmd = require('neovim.autocmds').set_autocmd
-- local set_mapping = require('neovim.mappings').set_mapping
local set_command = require('neovim.commands').set_command

local types = require 'luasnip.util.types'

ls.config.set_config {
    history = true,
    -- Update more often, :h events for more info.
    updateevents = 'TextChanged,TextChangedI',
    store_selection_keys = '<CR>',
    ext_opts = {
        -- [types.textNode] = {
        --     snippet_passive = {
        --         hl_group = "GruvboxGreen"
        --     }
        -- },
        -- [types.insertNode] = {
        --     active = {
        --         virt_text = {{"InsertNode", "Comment"}}
        --     },
        --     -- active = {
        --     --     hl_group = "WarningMsg"
        --     -- },
        --     -- pasive = {
        --     --     hl_group = "Comment"
        --     -- }
        -- },
        [types.choiceNode] = {
            active = {
                virt_text = { { 'choiceNode', 'Comment' } },
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
    lhs = 'SnippetCleanup',
    rhs = 'lua require"luasnip".cleanup()',
    args = { force = true },
}

set_command {
    lhs = 'SnippetReload',
    rhs = function()
        RELOAD 'plugins.snippets.all'
        if pcall(RELOAD, 'plugins.snippets.' .. vim.opt_local.filetype:get()) then
            vim.notify 'Snippets Reloaded!'
        end
    end,
    args = { force = true },
}

return true

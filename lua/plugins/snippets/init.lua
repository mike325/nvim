local load_module = require('utils.helpers').load_module
local ls = load_module 'luasnip'
if not ls then
    return false
end

local set_autocmd = require('neovim.autocmds').set_autocmd
local set_mapping = require('neovim.mappings').set_mapping

local s = ls.snippet
-- local sn = ls.snippet_node
-- local t = ls.text_node
-- local isn = ls.indent_snippet_node
-- local i = ls.insert_node
local f = ls.function_node
-- local c = ls.choice_node
-- local d = ls.dynamic_node
-- local l = require("luasnip.extras").lambda
-- local r = require("luasnip.extras").rep
local p = require('luasnip.extras').partial
-- local m = require("luasnip.extras").match
-- local n = require("luasnip.extras").nonempty
-- local dl = require("luasnip.extras").dynamic_lambda
-- local fmt = require("luasnip.extras.fmt").fmt
-- local fmta = require("luasnip.extras.fmt").fmta
-- local types = require("luasnip.util.types")
-- local events = require("luasnip.util.events")
-- local conds = require("luasnip.extras.expand_conditions")

ls.config.set_config {
    history = true,
    -- Update more often, :h events for more info.
    updateevents = 'TextChanged,TextChangedI',
    store_selection_keys = '<CR>',
    -- enable_autosnippets = true,
    -- ext_base_prio = 300,
    -- ext_prio_increase = 1,
}

local function notes(note)
    note = note:upper()
    if note:sub(#note, #note) ~= ':' then
        note = note .. ': '
    end
    return require('plugins.snippets.utils').get_comment(note)
end

-- stylua: ignore
ls.snippets = {
    all = {
        s('note', p(notes, 'note')),
        s('todo', p(notes, 'todo')),
        s('fix', p(notes, 'fix')),
        s('fixme', p(notes, 'fixme')),
        s('warn', p(notes, 'warn')),
        s('bug', p(notes, 'bug')),
        s('improve', p(notes, 'improve')),
        s(
            'date',
            f(function(args, snip)
                -- stylua: ignore
                return os.date '%D'
            end, {})),
    },
}

set_autocmd {
    event = 'FileType',
    pattern = '*',
    cmd = [[lua pcall(RELOAD, "plugins.snippets."..vim.opt_local.filetype:get())]],
    group = 'Snippets',
}

set_mapping {
    mode = 'n',
    lhs = '<leader>s',
    rhs = "lua require'luasnip'.cleanup()",
    args = { noremap = true, silent = true },
}

return true

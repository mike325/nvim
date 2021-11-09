local load_module = require('utils.helpers').load_module
local ls = load_module 'luasnip'
if not ls then
    return false
end

local s = ls.snippet
-- local sn = ls.snippet_node
-- local t = ls.text_node
-- local isn = ls.indent_snippet_node
-- local i = ls.insert_node
-- local f = ls.function_node
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

-- local utils = RELOAD('plugins.snippets.utils')
-- local saved_text = utils.saved_text
-- local get_comment = utils.get_comment
-- local surround_with_func = utils.surround_with_func

local function notes(note)
    note = note:upper()
    if note:sub(#note, #note) ~= ':' then
        note = note .. ': '
    end
    return require('plugins.snippets.utils').get_comment(note)
end

if not ls.snippets then
    ls.snippets = {}
end

-- stylua: ignore
ls.snippets.all = {
    s('note', p(notes, 'note')),
    s('todo', p(notes, 'todo')),
    s('fix', p(notes, 'fix')),
    s('fixme', p(notes, 'fixme')),
    s('warn', p(notes, 'warn')),
    s('bug', p(notes, 'bug')),
    s('improve', p(notes, 'improve')),
    s('date', p(os.date, '%D')),
    s('#!', {
        p(function()
            -- stylua: ignore
            local ft = vim.opt_local.filetype:get()
            -- stylua: ignore
            local executables = {
                python = 'python3'
            }
            -- stylua: ignore
            return '#!/usr/bin/env '.. (executables[ft] or ft)
        end),
    })
}

local ls = vim.F.npcall(require, 'luasnip')
if not ls then
    return false
end

local s = ls.snippet
local sn = ls.snippet_node
-- local t = ls.text_node
-- local isn = ls.indent_snippet_node
local i = ls.insert_node
-- local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
-- local l = require('luasnip.extras').lambda
-- local r = require('luasnip.extras').rep
-- local p = require('luasnip.extras').partial
-- local m = require('luasnip.extras').match
-- local n = require('luasnip.extras').nonempty
-- local dl = require('luasnip.extras').dynamic_lambda
local fmt = require('luasnip.extras.fmt').fmt
-- local fmta = require('luasnip.extras.fmt').fmta
-- local types = require 'luasnip.util.types'
-- local events = require 'luasnip.util.events'
-- local conds = require 'luasnip.extras.expand_conditions'

local utils = RELOAD 'plugins.luasnip.utils'
local saved_text = utils.saved_text
-- local get_comment = utils.get_comment
-- local surround_with_func = utils.surround_with_func

-- stylua: ignore
local snippets = {
    s('inc', fmt([[#include {}]], {
        c(1, {
            sn(nil, fmt('<{}>', {i(1, 'stdio.h')})),
            sn(nil, fmt('"{}"', {i(1, 'stdio.h')})),
        }),
    })),
    s('def', fmt([[#define {}]], {
        i(1, 'MACRO'),
    })),
    s('idef', fmt([[
    #ifdef {}
    {}
    #endif
    ]], {
        i(1, 'MACRO'),
        d(2, saved_text, {}, {user_args = {{indent = false}}}),
    })),
}

local clike = RELOAD 'snippets.c_like'
for _, csnip in ipairs(clike) do
    local has_snip = false
    for _, snip in ipairs(snippets) do
        if snip.dscr == csnip.dscr then
            has_snip = true
            break
        end
    end
    if not has_snip then
        table.insert(snippets, csnip)
    end
end

return snippets
-- ls.add_snippets('c', snippets, { key = 'c_init' })

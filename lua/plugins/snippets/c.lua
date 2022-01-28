local load_module = require('utils.helpers').load_module
local ls = load_module 'luasnip'
if not ls then
    return false
end

local s = ls.snippet
-- local sn = ls.snippet_node
local t = ls.text_node
-- local isn = ls.indent_snippet_node
local i = ls.insert_node
-- local f = ls.function_node
-- local c = ls.choice_node
-- local d = ls.dynamic_node
-- local l = require('luasnip.extras').lambda
-- local r = require('luasnip.extras').rep
-- local p = require('luasnip.extras').partial
-- local m = require('luasnip.extras').match
-- local n = require('luasnip.extras').nonempty
-- local dl = require('luasnip.extras').dynamic_lambda
-- local fmt = require('luasnip.extras.fmt').fmt
-- local fmta = require('luasnip.extras.fmt').fmta
-- local types = require 'luasnip.util.types'
-- local events = require 'luasnip.util.events'
-- local conds = require 'luasnip.extras.expand_conditions'

-- local utils = RELOAD('plugins.snippets.utils')
-- local saved_text = utils.saved_text
-- local get_comment = utils.get_comment
-- local surround_with_func = utils.surround_with_func

if not ls.snippets then
    ls.snippets = {}
end

-- local utils = RELOAD 'plugins.snippets.utils'
-- local return_value = utils.return_value
-- local surround_with_func = utils.surround_with_func

local clike = RELOAD 'plugins.snippets.c_like'

-- ls.snippets.c = {}

-- stylua: ignore
ls.snippets.c  = {
    s('inc', {
        t{'#include <'}, i(1, 'header'), t{'>'},
    }),
}

for _, csnip in ipairs(clike) do
    local has_snip = false
    for _, snip in ipairs(ls.snippets.c) do
        if snip.dscr == csnip.dscr then
            has_snip = true
            break
        end
    end
    if not has_snip then
        table.insert(ls.snippets.c, csnip)
    end
end

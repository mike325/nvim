local ls = vim.F.npcall(require, 'luasnip')
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
local r = require('luasnip.extras').rep
local p = require('luasnip.extras').partial
-- local m = require('luasnip.extras').match
-- local n = require('luasnip.extras').nonempty
-- local dl = require('luasnip.extras').dynamic_lambda
local fmt = require('luasnip.extras.fmt').fmt
-- local fmta = require('luasnip.extras.fmt').fmta
-- local types = require 'luasnip.util.types'
-- local events = require 'luasnip.util.events'
-- local conds = require 'luasnip.extras.expand_conditions'

local function commit_summary(init)
    local notes = {
        f = 'feat',
        x = 'fix',
        fi = 'fix',
        r = 'refactor',
        ref = 'refactor',
        perf = 'performance',
        c = 'chore',
    }

    init = init:lower()
    init = notes[init] or init
    if vim.g.gitsigns_head then
        vim.g.branch = vim.g.gitsigns_head
    else
        vim.g.branch = RELOAD('utils.git').status().branch
    end

    local feat_pattern = {
        '^([fF][eE][rR][-/]%d+)[-/]',
    }

    if vim.g.branch then
        for _, pattern in ipairs(feat_pattern) do
            local feature = vim.g.branch:match(pattern)
            if feature then
                init = init .. ('(%s)'):format(feature)
                break
            end
        end
    end

    return init .. ': '
end

-- stylua: ignore
return {
    s('f',  { p(commit_summary, 'feat'),     i(1), t{'', '', ''}, i(2) }),
    s('x',  { p(commit_summary, 'fix'),      i(1), t{'', '', ''}, i(2) }),
    s('r',  { p(commit_summary, 'refactor'), i(1), t{'', '', ''}, i(2) }),
    s('c',  { p(commit_summary, 'chore'),    i(1), t{'', '', ''}, i(2) }),
    s('d',  { p(commit_summary, 'docs'),     i(1), t{'', '', ''}, i(2) }),
    s('p',  { p(commit_summary, 'perf'),     i(1), t{'', '', ''}, i(2) }),
    s('t',  { p(commit_summary, 'test'),     i(1), t{'', '', ''}, i(2) }),
    s('ci', { p(commit_summary, 'ci'),       i(1), t{'', '', ''}, i(2) }),
    s('link', { t{'['}, i(1, 'description'), t{'](https://'}, i(2, {'url'}), t{')'}, }),
    s('url', { t{'['}, i(1, 'description'), t{'](https://'}, i(2, {'url'}), t{')'}, }),
    s('ghpr', fmt([[[#{}](https://github.com/{}/{}/pull/{})]], {
        r(3),
        i(1, 'username'),
        i(2, 'repo'),
        i(3, 'pr'),
    })),
    s('ghiss', fmt([[[#{}](https://github.com/{}/{}/issues/{})]], {
        r(3),
        i(1, 'username'),
        i(2, 'repo'),
        i(3, 'issue'),
    })),
}

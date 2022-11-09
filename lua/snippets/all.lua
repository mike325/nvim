local load_module = require('utils.functions').load_module
local ls = load_module 'luasnip'
if not ls then
    return false
end

local sys = require 'sys'

local utils = RELOAD 'plugins.luasnip.utils'

local s = ls.snippet
-- local sn = ls.snippet_node
-- local t = ls.text_node
-- local isn = ls.indent_snippet_node
-- local i = ls.insert_node
local f = ls.function_node
-- local c = ls.choice_node
-- local d = ls.dynamic_node
-- local l = require('luasnip.extras').lambda
-- local r = require('luasnip.extras').rep
local p = require('luasnip.extras').partial
-- local m = require('luasnip.extras').match
-- local n = require('luasnip.extras').nonempty
-- local dl = require('luasnip.extras').dynamic_lambda
-- local fmt = require('luasnip.extras.fmt').fmt
-- local fmta = require('luasnip.extras.fmt').fmta
-- local types = require 'luasnip.util.types'
-- local events = require 'luasnip.util.events'
-- local conds = require 'luasnip.extras.expand_conditions'

-- local utils = RELOAD('snippets.utils')
-- local saved_text = utils.saved_text
-- local get_comment = utils.get_comment
-- local surround_with_func = utils.surround_with_func

local function notes(note)
    if vim.bo.filetype ~= 'gitcommit' then
        note = ('%s(%s): '):format(note:upper(), sys.username)
    else
        note = ('%s: '):format(note:upper())
    end
    return RELOAD('plugins.luasnip.utils').get_comment(note)
end

local return_value = utils.return_value
local get_comment = utils.get_comment

-- TODO: Shoul this chaeck for TS and see if we are in a comment/string ?
local function license(_, _, user_args)
    local licenses = {
        mit = {
            'The MIT License (MIT)',
            '',
            'Copyright (c) ${CURRENT_YEAR} ${NAME}',
            '',
            'Permission is hereby granted, free of charge, to any person obtaining a copy',
            'of this software and associated documentation files (the "Software"), to deal',
            'in the Software without restriction, including without limitation the rights',
            'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell',
            'copies of the Software, and to permit persons to whom the Software is',
            'furnished to do so, subject to the following conditions:',
            '',
            'The above copyright notice and this permission notice shall be included in all',
            'copies or substantial portions of the Software.',
            '',
            'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR',
            'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,',
            'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE',
            'AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER',
            'LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,',
            'OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE',
            'SOFTWARE.',
        },
    }

    local ft = vim.opt_local.filetype:get()

    local actual_license = licenses[user_args[1]] or licenses.mit
    for idx, line in ipairs(actual_license) do
        if line:match '%${CURRENT_YEAR}' then
            actual_license[idx] = actual_license[idx]:gsub('%${CURRENT_YEAR}', os.date '%Y')
        end
        if line:match '%${NAME}' then
            -- TODO: Use actual name or maybe add dynamic insert node?
            actual_license[idx] = actual_license[idx]:gsub('%${NAME}', sys.username)
        end
    end

    local plain_fts = {
        text = 1,
        plaintext = 1,
        latex = 1,
        markdown = 1,
    }

    local cursor = vim.api.nvim_win_get_cursor(0)
    local range = { cursor[1] - 1, cursor[2], cursor[1] - 1, cursor[2] }

    if ft == '' or plain_fts[ft] or require('utils.treesitter').is_in_node(range, 'string') then
        return actual_license
    end
    return get_comment(actual_license)
end

-- stylua: ignore
local general_snips = {
    s('date', p(os.date, '%Y-%m-%d')),
    s('ret', return_value(true)),
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
    }),
    s('mitl', f(license, {}, {user_args = {'mit'}})),
    s('aut', p(function()
        -- TODO: Read actual gitconfig to get current git author
        if vim.env.WORK_USER then
            return vim.env.WORK_USER
        elseif vim.env.GIT_USER then
            return vim.env.GIT_USER
        end
        return 'Mike' -- vim.env.USER or vim.env.USERNAME
    end)),
}

local annotations = {
    'note',
    'todo',
    'fix',
    'fixme',
    'warn',
    'bug',
    'improve',
}

for _, annotation in ipairs(annotations) do
    table.insert(general_snips, s(annotation, p(notes, annotation)))
end

-- ls.add_snippets('all', general_snips, { key = 'all_init' })
return general_snips

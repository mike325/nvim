local ls = vim.F.npcall(require, 'luasnip')
if not ls then
    return false
end

local sys = require 'sys'

local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
-- local isn = ls.indent_snippet_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
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

local utils = RELOAD 'configs.luasnip.utils'

-- local saved_text = utils.saved_text
-- local surround_with_func = utils.surround_with_func
local get_comment = RELOAD('utils.buffers').get_comment
local return_value = utils.return_value

local function notes(_, _, old_state, user_args)
    local nodes = {}
    old_state = old_state or {}
    user_args = user_args or {}
    local annotation = user_args.annotation

    local annotation_nodes = {}
    local interactive_node = 1
    if vim.bo.filetype == 'gitcommit' then
        table.insert(annotation_nodes, t { ('%s: '):format(annotation:upper()) })
    else
        table.insert(annotation_nodes, t { annotation:upper() })
        table.insert(
            annotation_nodes,
            c(interactive_node, {
                sn(nil, {
                    t { '(' },
                    i(1, sys.username),
                    t { ')' },
                }),
                i(1, ''),
            })
        )
        table.insert(annotation_nodes, t { ': ' })
        interactive_node = interactive_node + 1
    end

    local is_in_comment = RELOAD('utils.treesitter').is_in_node 'comment'
    if not is_in_comment then
        local comment_str = (get_comment():gsub('%%s', ''))
        table.insert(nodes, t { comment_str })
    end

    nodes = vim.list_extend(nodes, annotation_nodes)
    table.insert(nodes, i(interactive_node, ''))

    local snip_node = sn(nil, nodes)
    snip_node.old_state = old_state
    return snip_node
end

-- TODO: Should this check for TS and see if we are in a comment/string ?
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

    local ft = vim.bo.filetype

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

    if ft == '' or plain_fts[ft] or RELOAD('utils.treesitter').is_in_node 'string' then
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
            local ft = vim.bo.filetype
            -- stylua: ignore
            local executables = {
                python = 'python3'
            }

            -- stylua: ignore
            if ft == 'lua' then
                -- stylua: ignore
                if require('sys').name ~= 'windows' then
                    local env_version = vim.version.parse(vim.fn.system('env --version'))
                    if vim.version.ge(env_version, {8, 30})  then
                        local env_path = require('utils.files').exepath('env')
                        return string.format('#!%s -S nvim -l', env_path)
                    end
                end
                return string.format('#!%s -l', vim.v.progpath)
            end

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
    'deprecated',
}

for _, annotation in ipairs(annotations) do
    local snip = #annotation <= 4 and annotation or annotation:sub(1, 4)
    table.insert(general_snips, s(snip, d(1, notes, {}, { user_args = { { annotation = annotation } } })))
end

-- ls.add_snippets('all', general_snips, { key = 'all_init' })
return general_snips

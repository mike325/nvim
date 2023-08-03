local ls = vim.F.npcall(require, 'luasnip')
if not ls then
    return false
end

-- local ts_locals = require "nvim-treesitter.locals"
-- local ts_utils = require "nvim-treesitter.ts_utils"

-- local s = ls.snippet
local sn = ls.snippet_node
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

local M = {}

-- TODO: Update this with TS support
function M.get_comment(text)
    vim.validate {
        text = {
            text,
            function(x)
                return not x or type(x) == type '' or vim.tbl_islist(x)
            end,
            'text must be either a string or an array of lines',
        },
    }
    local comment = vim.opt_local.commentstring:get()
    comment = comment ~= '' and comment or '// %s'
    if not comment:match '%s%%s' then
        comment = comment:format ' %s'
    end
    local comment_str
    if text then
        if vim.tbl_islist(text) then
            comment_str = {}
            for _, line in ipairs(text) do
                local commented = comment:format(line)
                if line == '' then
                    commented = vim.trim(commented)
                end
                table.insert(comment_str, commented)
            end
        else
            comment_str = comment:format(text)
        end
    end
    return comment_str or comment
end

function M.saved_text(args, snip, old_state, user_args)
    local nodes = {}
    old_state = old_state or {}
    user_args = user_args or {}

    local indent = user_args.indent and '\t' or ''

    if snip.snippet.env and snip.snippet.env.SELECT_DEDENT and #snip.snippet.env.SELECT_DEDENT > 0 then
        local lines = vim.deepcopy(snip.snippet.env.SELECT_DEDENT)
        -- local indent_level = require'utils.buffers'.get_indent_block_level(lines)
        -- lines = require'utils.buffers'.indent(lines, -indent_level)
        -- TODO: We may need to use an indent indepente node to avoid indenting empty lines
        for idx = 1, #lines do
            local line = indent .. lines[idx]
            local node = idx == #lines and { line } or { line, '' }
            table.insert(nodes, t(node))
        end
    else
        local text = user_args.text or M.get_comment 'code'
        if indent ~= '' then
            table.insert(nodes, t(indent))
        end
        table.insert(nodes, i(1, text))
    end

    local snip_node = sn(nil, nodes)
    snip_node.old_state = old_state
    return snip_node
end

function M.surround_with_func(args, snip, old_state, user_args)
    local nodes = {}
    old_state = old_state or {}
    user_args = user_args or {}

    if snip.snippet.env and snip.snippet.env.SELECT_RAW and #snip.snippet.env.SELECT_RAW == 1 then
        local node = snip.snippet.env.SELECT_RAW[1]
        table.insert(nodes, t(node))
    else
        local text = user_args.text or 'placeholder'
        table.insert(nodes, i(1, text))
    end

    local snip_node = sn(nil, nodes)
    snip_node.old_state = old_state
    return snip_node
end

function M.copy(args)
    return args[1]
end

function M.return_value()
    local clike = {
        c = true,
        cpp = true,
        java = true,
    }

    local snippet = { t { 'return ' }, i(1, 'value') }

    if clike[vim.bo.filetype] then
        table.insert(snippet, t { ';' })
    end

    return snippet
end

function M.else_clause(args, snip, old_state, placeholder)
    local nodes = {}
    local ft = vim.opt_local.filetype:get()

    if snip.captures[1] == 'e' then
        if ft == 'lua' then
            table.insert(nodes, t { '', 'else', '\t' })
            table.insert(nodes, i(1, M.get_comment 'code'))
        elseif ft == 'python' then
            table.insert(nodes, t { '', 'else:', '\t' })
            table.insert(nodes, i(1, 'pass'))
        elseif ft == 'sh' or ft == 'bash' or ft == 'zsh' then
            table.insert(nodes, t { 'else', '\t' })
            table.insert(nodes, i(1, ':'))
            table.insert(nodes, t { '', '' })
        elseif ft == 'go' or ft == 'rust' then
            table.insert(nodes, t { ' else {', '\t' })
            table.insert(nodes, i(1, M.get_comment 'code'))
            table.insert(nodes, t { '', '}' })
        else
            table.insert(nodes, t { '', 'else {', '\t' })
            table.insert(nodes, i(1, M.get_comment 'code'))
            table.insert(nodes, t { '', '}' })
        end
    else
        table.insert(nodes, t { '' })
    end

    local snip_node = sn(nil, nodes)
    snip_node.old_state = old_state
    return snip_node
end

-- C/C++ only
function M.add_statement_and_include(statement, include, include_type)
    vim.validate {
        statement = { statement, 'string' },
        include = { include, 'string', true },
        include_type = { include_type, 'string', true },
    }
    include = include or statement
    include_type = include_type or 'sys'

    local cpp = RELOAD 'utils.treesitter.cpp'
    cpp.add_include(include, include_type)
    return statement
end

return M

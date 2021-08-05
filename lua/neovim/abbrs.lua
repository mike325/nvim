-- luacheck: globals unpack vim
-- local i = vim.inspect
local api = vim.api

local M = {}

function M.set_abbr(abbr)
    local echoerr = require'utils'.messages.echoerr

    if not require'utils'.tables.has_attrs(abbr, {'mode', 'lhs'}) then
        echoerr('Missing arguments, set_abbr need a mode and a lhs attribbutes', 'Nvim Abbrs')
        return false
    end

    local command = {}
    local extras = {}

    local modes = {
        insert  = "i",
        command = "c",
    }

    local lhs = abbr.lhs
    local rhs = abbr.rhs
    local args = type(abbr.args) == 'table' and abbr.args or {abbr.args}
    local mode = modes[abbr.mode] or abbr.mode

    if args.buffer ~= nil  then
        table.insert(extras, '<buffer>')
    end

    if args.expr ~= nil and rhs ~= nil then
        table.insert(extras, '<expr>')
    end

    for _, v in pairs(extras) do
        table.insert(command, v)
    end

    if mode == 'i' or mode == 'insert' then
        if rhs == nil then
            table.insert(command, 1, 'iunabbrev')
            table.insert(command, lhs)
        else
            table.insert(command, 1, 'iabbrev')
            table.insert(command, lhs)
            table.insert(command, rhs)
        end
    elseif mode == 'c' or mode == 'command' then
        if rhs == nil then
            table.insert(command, 1, 'cunabbrev')
            table.insert(command, lhs)
        else
            table.insert(command, 1, 'cabbrev')
            table.insert(command, lhs)
            table.insert(command, rhs)
        end
    else
        echoerr('Unsupported mode: '..vim.inspect(mode), 'Nvim Abbrs')
        return false
    end

    if args.silent ~= nil then
        table.insert(command, 1, 'silent!')
    end

    api.nvim_command(table.concat(command, ' '))
end

return M

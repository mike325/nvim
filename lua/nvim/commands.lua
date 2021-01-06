-- luacheck: globals unpack vim
-- local i = vim.inspect
local api = vim.api
local has_attrs = require'tools.tables'.has_attrs
local echoerr = require'tools.messages'.echoerr

local M = {}

function M.set_command(command)
    if not has_attrs(command, {'lhs'}) then
        echoerr('Missing arguments, set_command need a mode and a lhs attribbutes')
        return false
    end

    local lhs  = command.lhs
    local rhs  = command.rhs
    local args = type(command.args) == 'table' and command.args or {command.args}

    local command_str = {'command'}

    if rhs == nil then
        command_str = {'delcommand'}
        command_str[#command_str + 1] = lhs
    else

        if args.force then
            command_str = {'command!'}
            args.force = nil
        end

        local attr
        for name,val in pairs(args) do
            if val ~= false then
                attr = '-'..name
                if type(val) ~= 'boolean' then
                    attr = attr..'='..val
                end
                command_str[#command_str + 1] = attr
            end
        end
        command_str[#command_str + 1] = lhs
        command_str[#command_str + 1] = rhs
    end

    api.nvim_command(table.concat(command_str, ' '))
end

return M

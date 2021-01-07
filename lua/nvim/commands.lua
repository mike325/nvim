-- luacheck: globals unpack vim
-- local i = vim.inspect
local api = vim.api
local has_attrs = require'tools.tables'.has_attrs
local echoerr = require'tools.messages'.echoerr

local M = {
    funcs = {
        g = {},
        b = {},
    }
}

function M.set_command(command)
    if not has_attrs(command, {'lhs'}) then
        echoerr('Missing arguments, set_command need a mode and a lhs attribbutes')
        return false
    end

    local cmd, nargs
    local scope = 'g'
    local lhs  = command.lhs
    local rhs  = command.rhs
    local args = type(command.args) == 'table' and command.args or {command.args}

    if rhs == nil then
        cmd = {'delcommand'}
        cmd[#cmd + 1] = lhs
    elseif args.force then
        cmd = {'command!'}
        args.force = nil
    else
        cmd = {'command'}
    end

    local attr
    for name,val in pairs(args) do
        if val then
            attr = '-'..name
            if type(val) ~= 'boolean' then
                if attr == '-nargs' then
                    nargs = val
                end
                attr = attr..'='..val
            end
            if attr == 'buffer' then
                scope = 'b'
            end
            cmd[#cmd + 1] = attr
        end
    end
    cmd[#cmd + 1] = lhs

    if type(rhs) == 'string' then
        cmd[#cmd + 1] = rhs
    elseif type(rhs) == 'function' then
        M.funcs[scope][lhs] = rhs
        local nparams = debug.getinfo(rhs).nparams
        local wrapper = string.format(
            [[lua require'nvim'.commands.funcs['%s']['%s'](%s)]],
            scope, lhs, nparams > 0 and '<f-args>' or ''
        )
        if nargs == nil then
            if nparams == 1 then
                nargs = '-nargs=1'
            elseif  nparams > 1 then
                nargs = '-nargs=*'
            end
        end
        cmd[#cmd + 1] = wrapper
    end

    api.nvim_command(table.concat(cmd, ' '))
    if rhs == nil and M.funcs[scope][lhs] ~= nil then
        M.funcs[scope][lhs] = nil
    end
end

return M

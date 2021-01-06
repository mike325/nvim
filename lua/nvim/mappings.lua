local api       = vim.api
local has_attrs = require'tools.tables'.has_attrs
local echoerr   = require'tools.messages'.echoerr

local transform_mapping = require'nvim.utils'.transform_mapping

local M = {}

function M.get_mapping(mapping)

    if not has_attrs(mapping, {'mode', 'lhs'}) then
        echoerr('Missing arguments, get_mapping need a mode and a lhs attribbutes')
        return false
    end

    local result
    local mappings

    local modes = {
        normal   = "n",
        visual   = "v",
        operator = "o",
        insert   = "i",
        command  = "c",
        select   = "s",
        langmap  = "l",
        terminal = "t",
    }

    local lhs = transform_mapping(mapping.lhs)
    local args = type(mapping.args) == 'table' and mapping.args or {mapping.args}
    local mode = modes[mapping.mode] ~= nil and modes[mapping.mode] or mapping.mode

    if args.buffer ~= nil and args.buffer == true then
        mappings = api.nvim_buf_get_keymap(mode)
    else
        mappings = api.nvim_get_keymap(mode)
    end

    for _,map in pairs(mappings) do
        if map['lhs'] == lhs then
            result = map['rhs']
            break
        end
    end

    return result
end

function M.set_mapping(mapping)

    if not has_attrs(mapping, {'mode', 'lhs'}) then
        echoerr('Missing arguments, set_mapping need a mode and a lhs attribbutes')
        return false
    end

    local modes = {
        normal   = "n",
        visual   = "v",
        operator = "o",
        insert   = "i",
        command  = "c",
        select   = "s",
        langmap  = "l",
        terminal = "t",
    }

    local args = type(mapping.args) == 'table' and mapping.args or {mapping.args}
    local mode = modes[mapping.mode] ~= nil and modes[mapping.mode] or mapping.mode
    local lhs = mapping.lhs
    local rhs = mapping.rhs

    if args.buffer ~= nil then
        local buf = type(args.buffer) == 'boolean' and 0 or args.buffer
        args.buffer = nil

        if rhs ~= nil then
            api.nvim_buf_set_keymap(buf, mode, lhs, rhs, args)
        else
            api.nvim_buf_del_keymap(buf, mode, lhs)
        end
    else
        args = args == nil and {} or args
        if rhs ~= nil then
            api.nvim_set_keymap(mode, lhs, rhs, args)
        else
            api.nvim_del_keymap(mode, lhs)
        end
    end
end

return M

local api       = vim.api
local has_attrs = require'tools.tables'.has_attrs
local echoerr   = require'tools.messages'.echoerr

local transform_mapping = require'nvim.utils'.transform_mapping

local modes = {
    normal   = "n",
    visual   = "v",
    operator = "o",
    insert   = "i",
    command  = "c",
    select   = "s",
    terminal = "t",
}

local M = {
    funcs = {
        g = {},
        b = {},
    }
}

-- local maps = {}
for _,mode in pairs(modes) do
    -- maps[mode..'map'] = 1
    -- maps[mode..'noremap'] = 1
    M.funcs.g[mode] = {}
    M.funcs.b[mode] = {}
end

function M.get_mapping(mapping)

    if not has_attrs(mapping, {'mode', 'lhs'}) then
        echoerr('Missing arguments, get_mapping need a mode and a lhs attribbutes')
        return false
    end

    local mappings
    local result = nil

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

    local args = type(mapping.args) == 'table' and mapping.args or {mapping.args}
    local mode = modes[mapping.mode] ~= nil and modes[mapping.mode] or mapping.mode
    local lhs = mapping.lhs
    local rhs = mapping.rhs

    lhs = lhs:gsub('<leader>', api.nvim_get_var('mapleader'))

    if args.buffer ~= nil then
        local buf = type(args.buffer) == 'number' and args.buffer or 0
        args.buffer = nil

        if rhs ~= nil and type(rhs) == 'string' then
            api.nvim_buf_set_keymap(buf, mode, lhs, rhs, args)
        elseif rhs ~= nil and type(rhs) == 'function' then
            M.funcs['b'][mode][lhs] = rhs
            local wrapper = string.format(
                [[<cmd>lua require'nvim'.mappings.funcs['b']['%s']['%s']()<CR>]],
                mode, lhs
            )
            api.nvim_buf_set_keymap(buf, mode, lhs, wrapper, args)
        else
            api.nvim_buf_del_keymap(buf, mode, lhs)
            if M.funcs['b'][mode]['lhs'] ~= nil then
                M.funcs['b'][mode]['lhs'] = nil
            end
        end
    else
        args = args == nil and {} or args
        if rhs ~= nil and type(rhs) == 'string' then
            api.nvim_set_keymap(mode, lhs, rhs, args)
        elseif rhs ~= nil and type(rhs) == 'function' then
            M.funcs['g'][mode][lhs] = rhs
            local wrapper = string.format(
                [[<cmd>lua require'nvim'.mappings.funcs['g']['%s']['%s']()<CR>]],
                mode, lhs -- , debug.getinfo(rhs).nparams > 0 and '<f-args>' or ''
            )
            api.nvim_set_keymap(mode, lhs, wrapper, args)
        else
            api.nvim_del_keymap(mode, lhs)
            if M.funcs['g'][mode]['lhs'] ~= nil then
                M.funcs['g'][mode]['lhs'] = nil
            end
        end
    end
end


setmetatable(M, {
    __index = function(self, k)
        -- local ok

        local mt = getmetatable(self)
        local x = mt[k]
        if x ~= nil then
            return x
        end

        -- if maps[x] ~= nil then
        --     x = M.get_mapping()
        -- end

        return x
    end,
    -- __newindex = function(self, k, v)
    -- end
})

return M

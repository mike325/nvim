local api       = vim.api
local has_attrs = require'tools.tables'.has_attrs
local echoerr   = require'tools.messages'.echoerr

local transform_mapping = require'nvim.utils'.transform_mapping

local modes = {
    normal   = "n",
    insert   = "i",
    vis_sel  = "v",
    visual   = "x",
    select   = "s",
    operator = "o",
    command  = "c",
    terminal = "t",
}

local M = {
    funcs = {
        g = {},
        b = {},
    }
}

local function set_modes(obj)
    for _,mode in pairs(modes) do
        if obj[mode] == nil then
            obj[mode] = {}
        end
    end
    return obj
end

M.funcs.g = set_modes(M.funcs.g)

local function get_wrapper(info)
    local scope = info.scope
    local mode = info.mode
    local lhs = info.lhs
    local bufnr = require'nvim'.win.get_buf(0)

    lhs = lhs:gsub('<leader>', api.nvim_get_var('mapleader'))
    lhs = lhs:gsub('<C-', '^')

    local cmd = [[<cmd>lua require'nvim'.mappings.funcs]]
    cmd = cmd..("['%s']"):format(scope)

    if scope == 'b' then
        cmd = cmd..("['%s']"):format(bufnr)
    end

    cmd = cmd..("['%s']"):format(mode)
    cmd = cmd..("['%s']"):format(lhs)
    cmd = cmd..'()<CR>'

    return cmd
end

local function func_handle(info)
    local scope = info.scope
    local mode = info.mode
    local lhs = info.lhs
    local rhs = info.rhs
    local bufnr = tostring(require'nvim'.win.get_buf(0))

    lhs = lhs:gsub('<leader>', api.nvim_get_var('mapleader'))
    lhs = lhs:gsub('<C-', '^')

    if scope == 'b' then
        if M.funcs.b[bufnr] == nil then
            M.funcs.b[bufnr] = {}
            M.funcs.b[bufnr] = set_modes(M.funcs.b[bufnr])
        end
        M.funcs.b[bufnr][mode][lhs] = rhs
    else
        M.funcs.g[mode][lhs] = rhs
    end

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
    local scope

    if args.buffer ~= nil then
        local buf = type(args.buffer) == 'number' and args.buffer or 0
        scope = 'b'
        args.buffer = nil

        if rhs ~= nil and type(rhs) == 'string' then
            api.nvim_buf_set_keymap(buf, mode, lhs, rhs, args)
        elseif rhs ~= nil and type(rhs) == 'function' then
            local wrapper = get_wrapper {
                lhs   = lhs,
                mode  = mode,
                scope = scope,
            }
            api.nvim_buf_set_keymap(buf, mode, lhs, wrapper, args)
        else
            api.nvim_buf_del_keymap(buf, mode, lhs)
        end
    else
        args = args == nil and {} or args
        scope = 'g'
        if rhs ~= nil and type(rhs) == 'string' then
            api.nvim_set_keymap(mode, lhs, rhs, args)
        elseif rhs ~= nil and type(rhs) == 'function' then
            local wrapper = get_wrapper {
                lhs   = lhs,
                mode  = mode,
                scope = scope,
            }
            api.nvim_set_keymap(mode, lhs, wrapper, args)
        else
            api.nvim_del_keymap(mode, lhs)
        end
    end

    if rhs ~= 'string' then
        func_handle {
            rhs   = rhs,
            lhs   = lhs,
            mode  = mode,
            scope = scope,
        }
    end

end


setmetatable(M, {
    __index = function(self, k)
        local mt = getmetatable(self)
        local x = mt[k]
        if x ~= nil then
            return x
        end

        return x
    end,
    -- __newindex = function(self, k, v)
    -- end
})

return M

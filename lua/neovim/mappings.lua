local api = vim.api

local transform_mapping = require'neovim.utils'.transform_mapping
local funcs = STORAGE.mappings

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

local M = {}

local function set_modes(obj)
    for _,mode in pairs(modes) do
        if obj[mode] == nil then
            obj[mode] = {}
        end
    end
    return obj
end

funcs.g = set_modes(funcs.g)

local function get_wrapper(info)
    local scope = info.scope
    local mode = info.mode
    local lhs = info.lhs
    local expr = info.expr
    local cmd

    cmd = expr and [=[luaeval("]=] or [[<cmd>lua ]]

    cmd = cmd..[[STORAGE.mappings]]
    cmd = cmd..("['%s']"):format(scope)

    if scope == 'b' then
        local bufnr = type(info.buf) == 'number' and info.buf or require'neovim'.get_current_buf()
        cmd = cmd..("['%s']"):format(bufnr)
    end

    lhs = lhs:gsub('<leader>', api.nvim_get_var('mapleader'))
    lhs = lhs:gsub('<C-', '^')

    cmd = cmd..("['%s']"):format(mode)
    cmd = cmd..("['%s']"):format(lhs)
    cmd = cmd..'()'

    cmd = expr and cmd..[=[")]=] or cmd..'<CR>'

    return cmd
end

local function func_handle(info)
    local scope = info.scope
    local mode = info.mode
    local lhs = info.lhs
    local rhs = info.rhs

    lhs = lhs:gsub('<leader>', api.nvim_get_var('mapleader'))
    lhs = lhs:gsub('<C-', '^')

    if scope == 'b' then
        local bufnr = type(info.buf) == 'number' and info.buf or require'neovim'.get_current_buf()
        bufnr = tostring(bufnr)
        if funcs.b[bufnr] == nil then
            funcs.b[bufnr] = {}
            funcs.b[bufnr] = set_modes(funcs.b[bufnr])
        end
        funcs.b[bufnr][mode][lhs] = rhs

        if not vim.b.wipe_maps then
            vim.cmd(
                ([[autocmd BufWipeout <buffer=%s> lua STORAGE.mappings.b['%s'] = nil ]]):format(bufnr, bufnr)
            )
            vim.b.wipe_maps = true
        end

    else
        funcs.g[mode][lhs] = rhs
    end

end

function M.get_mapping(mapping)

    local has_attrs = require'utils'.tables.has_attrs
    if not has_attrs(mapping, {'mode', 'lhs'}) then
        require'utils'.messages.echoerr('Missing arguments, get_mapping need a mode and a lhs attribbutes')
        return false
    end

    local mappings = {}
    local result = nil

    local lhs = transform_mapping(mapping.lhs)
    lhs= lhs:gsub('<leader>', vim.g.mapleader)

    local args = type(mapping.args) == type({}) and mapping.args or {mapping.args}
    local mode = modes[mapping.mode] or mapping.mode

    if args.buffer then
        local buf = type(args.buffer) == type(true) and 0 or args.buffer
        mappings = api.nvim_buf_get_keymap(buf, mode)
    else
        mappings = api.nvim_get_keymap(mode)
    end

    for _,map in pairs(mappings) do
        if map['lhs'] == lhs then
            result = map
            break
        end
    end

    return result
end

local function fix_mappings(args)
    for attr,val in pairs(args) do
        if type(val) == type(1) and (val == 1 or val == 0) then
            args[attr] = val == 1
        end
    end
    return args
end

function M.set_mapping(mapping)

    local has_attrs = require'utils'.tables.has_attrs
    if not has_attrs(mapping, {'mode', 'lhs'}) then
        require'utils'.messages.echoerr('Missing arguments, set_mapping need a mode and a lhs attribbutes')
        return false
    end

    assert(
        type(mapping.mode) == type('') or type(mapping.mode) == type({}),
        'Mode must be a string or a list of strings'
    )

    local args = type(mapping.args) == 'table' and mapping.args or {mapping.args}
    -- local mode = modes[mapping.mode] ~= nil and modes[mapping.mode] or mapping.mode
    local lhs = mapping.lhs
    if lhs:find(vim.g.mapleader) then
        lhs = lhs:gsub(vim.g.mapleader, '<leader>')
    end
    local rhs = mapping.rhs
    local expr = false
    local scope, buf
    local mapping_modes = type(mapping.mode) == type('') and {mapping.mode} or mapping.mode

    for attr, val in pairs(args) do
        if attr == 'expr' then
            expr = val
        elseif attr == 'buffer' then
            buf = type(val) == type(0) and val or 0
        end
    end

    for _,mode in pairs(mapping_modes) do
        mode = modes[mode] or mode
        if buf ~= nil then
            scope = 'b'
            args.buffer = nil

            if rhs ~= nil and type(rhs) == 'string' then
                api.nvim_buf_set_keymap(buf, mode, lhs, rhs, fix_mappings(args))
            elseif rhs and type(rhs) == 'function' then
                local wrapper = get_wrapper {
                    lhs   = lhs,
                    mode  = mode,
                    scope = scope,
                    expr = expr,
                    buf = buf,
                }
                api.nvim_buf_set_keymap(buf, mode, lhs, wrapper, fix_mappings(args))
            else
                pcall(api.nvim_buf_del_keymap, buf, mode, lhs)
            end
        else
            args = args == nil and {} or args
            scope = 'g'
            if rhs ~= nil and type(rhs) == 'string' then
                api.nvim_set_keymap(mode, lhs, rhs, fix_mappings(args))
            elseif rhs and type(rhs) == 'function' then
                local wrapper = get_wrapper {
                    lhs   = lhs,
                    mode  = mode,
                    scope = scope,
                    expr = expr,
                }
                api.nvim_set_keymap(mode, lhs, wrapper, fix_mappings(args))
            else
                pcall(api.nvim_del_keymap, mode, lhs)
            end
        end

        if rhs and type(rhs) == 'function' then
            func_handle {
                rhs   = rhs,
                lhs   = lhs,
                mode  = mode,
                scope = scope,
                buf = buf,
            }
        end
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

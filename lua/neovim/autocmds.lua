local api = vim.api

local M = {
    funcs = {
        g = {},
        b = {},
    }
}

function M.create_autogrp(autogrp)
    api.nvim_command('augroup '..autogrp..' | autocmd! | autogrp end')
end

function M.get_autocmd(autocmd)

    local has_attrs = require'utils'.tables.has_attrs
    if not has_attrs(autocmd, {'event'}) and not has_attrs(autocmd, {'group'}) then
        vim.notify(
            'Missing arguments!! get_autocmd need event or group attribbute',
            'ERROR',
            {title='Nvim Autocmd'}
        )
        return false
    end

    local autocmd_str = {'autocmd'}

    autocmd_str[#autocmd_str + 1] = autocmd.group ~= nil and autocmd.group or nil
    autocmd_str[#autocmd_str + 1] = autocmd.event ~= nil and autocmd.event or nil

    local ok, _ = pcall(api.nvim_exec, table.concat(autocmd_str, ' '), true)

    if not ok then
        return nil
    end

    return true
    -- TODO: Work in parse autocmd output
end

function M.has_autocmd(autocmd)
    return M.get_autocmd(autocmd) ~= nil
end

function M.set_autocmd(autocmd)

    local has_attrs = require'utils'.tables.has_attrs
    if not has_attrs(autocmd, {'event'}) then
        vim.notify(
            'Missing arguments!! set_autocmd need event attribbute',
            'ERROR',
            {title='Nvim Autocmd'}
        )
        return false
    end

    local autocmd_str = {'autocmd'}

    local once    = autocmd.once    ~= nil and '++once'        or nil
    local nested  = autocmd.nested  ~= nil and '++nested'      or nil
    local cmd     = autocmd.cmd     ~= nil and autocmd.cmd     or nil
    local event   = autocmd.event   ~= nil and autocmd.event   or nil
    local group   = autocmd.group   ~= nil and autocmd.group   or nil
    local clean   = autocmd.clean   ~= nil and autocmd.clean   or nil
    local pattern = autocmd.pattern ~= nil and autocmd.pattern or nil

    if group ~= nil then
        autocmd_str[#autocmd_str + 1] = group
    end

    if event ~= nil then
        if type(event) == 'table' then
            event = table.concat(event, ',')
        end

        autocmd_str[#autocmd_str + 1] = event
    end

    if pattern ~= nil then
        if type(pattern) == 'table' then
            pattern = table.concat(pattern, ',')
        end

        autocmd_str[#autocmd_str + 1] = pattern
    end

    if once ~= nil then
        autocmd_str[#autocmd_str + 1] = once
    end

    if nested ~= nil then
        autocmd_str[#autocmd_str + 1] = nested
    end

    if cmd == nil then
        autocmd_str[1] = 'autocmd!'
    else
        autocmd_str[#autocmd_str + 1] = cmd
    end

    if clean ~= nil and group ~= nil then
        M.create_autogrp(group)
    elseif group ~= nil and not M.has_autocmd { group = group } then
        M.create_autogrp(group)
    end

    api.nvim_command(table.concat(autocmd_str, ' '))
end

return M

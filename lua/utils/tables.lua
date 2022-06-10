local M = {}

function M.has_attrs(tbl, attrs)
    vim.validate {
        table = { tbl, 'table' },
        attrs = {
            attrs,
            function()
                return attrs ~= nil
            end,
            'any value',
        },
    }

    if type(attrs) ~= type(tbl) then
        for _, val in pairs(tbl) do
            if val == attrs then
                return true
            end
        end
    else
        local has_attr = true
        for _, attr in pairs(attrs) do
            has_attr = M.has_attrs(tbl, attr)
            if not has_attr then
                break
            end
        end
        if has_attr then
            return true
        end
    end
    return false
end

function M.uniq_list(lst)
    vim.validate { list = { lst, 'table' } }
    assert(vim.tbl_islist(lst), debug.traceback 'Uniq only works with array-like tables')

    local tmp = {}
    for _, node in ipairs(lst) do
        if not vim.tbl_contains(tmp, node) then
            table.insert(tmp, node)
        end
    end
    return tmp
end

function M.uniq_unorder(lst)
    vim.validate { list = { lst, 'table' } }
    assert(vim.tbl_islist(lst), debug.traceback 'Uniq only works with array-like tables')

    local uniq_items = {}
    for _, node in ipairs(lst) do
        uniq_items[node] = true
    end

    return vim.tbl_keys(uniq_items)
end

function M.merge_uniq_list(dest, src)
    vim.validate { source = { src, 'table' }, destination = { dest, 'table' } }
    assert(vim.tbl_islist(dest) and vim.tbl_islist(src), debug.traceback 'Source and dest must be arrays')

    dest = M.uniq_list(dest)
    for _, node in ipairs(src) do
        if not vim.tbl_contains(dest, node) then
            table.insert(dest, node)
        end
    end
    return dest
end

function M.merge_uniq_unorder(dest, src)
    vim.validate { source = { src, 'table' }, destination = { dest, 'table' } }
    assert(vim.tbl_islist(dest) and vim.tbl_islist(src), debug.traceback 'Source and dest must be arrays')

    local uniq_items = {}

    for _, node in ipairs(src) do
        uniq_items[node] = true
    end

    for _, node in ipairs(dest) do
        uniq_items[node] = true
    end

    return vim.tbl_keys(uniq_items)
end

function M.clear_lst(lst)
    vim.validate { list = { lst, 'table' } }
    assert(vim.tbl_islist(lst), debug.traceback 'List must be an array')
    local tmp = {}

    for _, val in pairs(lst) do
        if type(val) == type '' then
            val = val:gsub('%s+$', '')
            if not val:match '^%s*$' then
                tmp[#tmp + 1] = val
            end
        else
            tmp[#tmp + 1] = val
        end
    end

    return tmp
end

function M.str_to_clean_tbl(cmd_string, sep)
    vim.validate {
        cmd = { cmd_string, 'string' },
        separator = { sep, 'string', true },
    }
    sep = sep or ' '
    return M.clear_lst(vim.split(vim.trim(cmd_string), sep, true))
end

-- NOTE: Took from http://lua-users.org/wiki/CopyTable
function M.shallowcopy(orig)
    vim.validate { table = { orig, 'table' } }
    local copy
    if type(orig) == type {} then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function M.isempty(tbl)
    vim.validate {
        tbl = { tbl, 'table' },
    }
    return #tbl == 0 and next(tbl) == nil
end

return M

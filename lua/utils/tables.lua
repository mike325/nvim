-- NOTE: This functions must be as standalone as possible since they may be load from other programs as
--       wezterm
local M = {}

if not debug then
    _G['debug'] = {
        traceback = function(msg)
            return msg
        end,
    }
end

-- NOTE: This functions are available in Neovim's runtime, but since I consider some of the useful outside of neovim
--       I decided to replicate them to use in other apps
function M.tbl_contains(tbl, value)
    assert(type(tbl) == type {}, debug.traceback('Invalid type for tbl: ' .. type(tbl)))
    for _, node in pairs(tbl) do
        if node == value then
            return true
        elseif type(node) == type(value) and type(value) == type {} then
            return M.tbl_contains(node, value)
        end
    end
    return false
end

function M.list_contains(lst, value)
    assert(type(lst) == type {}, debug.traceback('Invalid type for lst: ' .. type(lst)))
    for _, node in ipairs(lst) do
        if node == value then
            return true
        end
    end
    return false
end

function M.tbl_islist(tbl)
    if type(tbl) ~= type {} then
        return false
    end
    local i = 0
    for idx, _ in pairs(tbl) do
        i = i + 1
        if idx ~= i then
            return false
        end
    end
    return true
end

function M.tbl_keys(tbl)
    assert(type(tbl) == type {}, debug.traceback('Invalid type for tbl: ' .. type(tbl)))
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    return keys
end

function M.tbl_values(tbl)
    assert(type(tbl) == type {}, debug.traceback('Invalid type for tbl: ' .. type(tbl)))
    local values = {}
    for _, value in pairs(tbl) do
        table.insert(values, value)
    end
    return values
end

function M.tbl_filter(func, tbl)
    assert(type(tbl) == type {}, debug.traceback('Invalid type for tbl: ' .. type(tbl)))
    assert(type(func) == 'function', debug.traceback('Invalid type for func: ' .. type(tbl)))

    local tmp = {}
    for k, v in pairs(tbl) do
        if func(v) then
            tmp[k] = v
        end
    end

    return tmp
end

function M.tbl_map(func, tbl)
    assert(type(tbl) == type {}, debug.traceback('Invalid type for tbl: ' .. type(tbl)))
    assert(type(func) == 'function', debug.traceback('Invalid type for func: ' .. type(tbl)))

    local tmp = {}
    for k, v in pairs(tbl) do
        tmp[k] = func(v)
    end

    return tmp
end

function M.list_extend(dest, src)
    assert(type(src) == type {}, debug.traceback('Invalid type for src: ' .. type(src)))
    assert(type(dest) == type {}, debug.traceback('Invalid type for dest: ' .. type(dest)))

    for _, node in ipairs(src) do
        table.insert(dest, node)
    end
    return dest
end

-- END OF NEOVIM RUNTIME DUPLICATES

function M.has_attrs(tbl, attrs)
    assert(type(tbl) == type {}, debug.traceback('Invalid type for tbl: ' .. type(tbl)))

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
    assert(type(lst) == type {}, debug.traceback 'Uniq only works with array-like tables')

    local tmp = {}
    local tmp_hash = {}
    for _, node in ipairs(lst) do
        if tmp_hash[node] == nil then
            table.insert(tmp, node)
            tmp_hash[node] = true
        end
    end
    return tmp
end

function M.uniq_unorder(lst)
    assert(M.tbl_islist(lst), debug.traceback 'Uniq only works with array-like tables')

    local uniq_items = {}
    for _, node in ipairs(lst) do
        uniq_items[node] = true
    end

    return M.tbl_keys(uniq_items)
end

function M.merge_uniq_list(dest, src)
    assert(M.tbl_islist(dest) and M.tbl_islist(src), debug.traceback 'Source and dest must be arrays')

    dest = M.uniq_list(dest)
    for _, node in ipairs(src) do
        if not M.tbl_contains(dest, node) then
            table.insert(dest, node)
        end
    end
    return dest
end

function M.merge_uniq_unorder(dest, src)
    assert(M.tbl_islist(dest) and M.tbl_islist(src), debug.traceback 'Source and dest must be arrays')

    local uniq_items = {}

    for _, node in ipairs(src) do
        uniq_items[node] = true
    end

    for _, node in ipairs(dest) do
        uniq_items[node] = true
    end

    return M.tbl_keys(uniq_items)
end

-- NOTE: Should this function also trim trailing spaces ?
function M.clear_lst(lst)
    assert(M.tbl_islist(lst), debug.traceback 'List must be an array')
    return vim.tbl_map(
        function(v)
            return type(v) == type '' and v:gsub('%s+$', '') or v
        end,
        vim.tbl_filter(function(v)
            if type(v) == type '' then
                return not v:match '^%s*$'
            end
            return true
        end, lst)
    )
end

function M.str_to_clean_tbl(cmd_string, sep)
    assert(type(cmd_string) == type '', debug.traceback('Invalid type for cmd_string: ' .. type(cmd_string)))
    assert(sep == nil or type(sep) == type '', debug.traceback('Invalid type for sep: ' .. type(sep)))

    local utils = require 'utils.strings'
    sep = sep or '%s+'
    return M.clear_lst(utils.split(utils.trim(cmd_string), sep, true))
end

-- NOTE: Took from http://lua-users.org/wiki/CopyTable
function M.shallowcopy(orig)
    assert(type(orig) == type {}, debug.traceback('Invalid type for orig: ' .. type(orig)))

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
    assert(type(tbl) == type {}, debug.traceback('Invalid type for tbl: ' .. type(tbl)))
    return #tbl == 0 and next(tbl) == nil
end

-- NOTE: This is intendent for wezterm, which does not have inspect
function M.inspect(t)
    local special = {
        ['function'] = true,
        userdata = true,
    }
    if special[type(t)] then
        return ('<%s>'):format(type(t))
    elseif type(t) ~= 'table' then
        return t
    end
    local tbl = '{'
    if M.tbl_islist(t) then
        for _, v in ipairs(t) do
            if type(v) == 'table' or special[type(v)] then
                v = M.inspect(v)
            elseif type(v) == 'string' then
                v = ('"%s"'):format(v)
            end
            tbl = tbl .. (' %s,'):format(v)
        end
    else
        for k, v in pairs(t) do
            if type(k) == 'table' or special[type(k)] then
                k = M.inspect(k)
            elseif type(k) == 'number' then
                k = ('[%s]'):format(k)
            end
            if type(v) == 'table' or special[type(v)] then
                v = M.inspect(v)
            elseif type(v) == 'string' then
                v = ('"%s"'):format(v)
            end
            tbl = tbl .. (' %s = %s,'):format(k, v)
        end
    end
    if tbl:sub(-1) == ',' then
        tbl = tbl:sub(1, #tbl - 1)
    end
    tbl = tbl .. ' }'
    return tbl
end

return M

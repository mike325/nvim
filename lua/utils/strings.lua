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

function M.split_components(str, pattern)
    assert(type(str) == type '', debug.traceback('Invalid type for str: ' .. type(str)))
    assert(type(pattern) == type '', debug.traceback('Invalid type for pattern: ' .. type(pattern)))
    local t = {}
    for v in string.gmatch(str, pattern) do
        t[#t + 1] = v
    end
    return t
end

function M.split(str, sep, plain)
    assert(type(str) == type '', debug.traceback('Invalid type for str: ' .. type(str)))
    assert(sep == nil or type(sep) == type '', debug.traceback('Invalid type for sep: ' .. type(sep)))
    assert(plain == nil or type(plain) == type(true), debug.traceback('Invalid type for plain: ' .. type(plain)))

    sep = sep or '%s'
    local t = {}
    for s in string.gmatch(str, '([^' .. sep .. ']+)') do
        table.insert(t, s)
    end
    return t
end

function M.str_to_clean_tbl(cmd_string)
    return require('utils.tables').str_to_clean_tbl(cmd_string)
end

function M.empty(str)
    return str == ''
end

function M.trim(str)
    return str:gsub('^%s*', ''):gsub('%s*$', '')
end

return M

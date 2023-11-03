-- NOTE: This functions must be as standalone as possible since they may be load from other programs as
--       wezterm
local M = {}

-- base64 character table string
local b64_lookup_table = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

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

function M.capitalize(str)
    if #str == 1 or #str == 0 then
        return #str == 0 and str or str:upper()
    end
    return str:sub(1, 1):upper() .. str:sub(2, #str):lower()
end

-- NOTE: took from http://lua-users.org/wiki/BaseSixtyFour
function M.base64_encode(data)
    return (
        (data:gsub('.', function(x)
            local r, b = '', x:byte()
            for i = 8, 1, -1 do
                r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0')
            end
            return r
        end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
            if #x < 6 then
                return ''
            end
            local c = 0
            for i = 1, 6 do
                c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0)
            end
            return b64_lookup_table:sub(c + 1, c + 1)
        end) .. ({ '', '==', '=' })[#data % 3 + 1]
    )
end

-- NOTE: took from http://lua-users.org/wiki/BaseSixtyFour
function M.base64_decode(data)
    data = string.gsub(data, '[^' .. b64_lookup_table .. '=]', '')
    return (
        data:gsub('.', function(x)
            if x == '=' then
                return ''
            end
            local r, f = '', (b64_lookup_table:find(x) - 1)
            for i = 6, 1, -1 do
                r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and '1' or '0')
            end
            return r
        end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
            if #x ~= 8 then
                return ''
            end
            local c = 0
            for i = 1, 8 do
                c = c + (x:sub(i, i) == '1' and 2 ^ (8 - i) or 0)
            end
            return string.char(c)
        end)
    )
end

return M

local M = {}

function M.split_components(str, pattern)
    vim.validate { str = { str, 'string' }, pattern = { pattern, 'string' } }
    local t = {}
    for v in string.gmatch(str, pattern) do
        t[#t + 1] = v
    end
    return t
end

function M.split(str, sep)
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

return M

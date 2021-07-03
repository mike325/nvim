local M = {}

function M.transform_mapping(lhs)
    if lhs:sub(1, 3) == '<c-' or lhs:sub(1, 3) == '<a-' or lhs:sub(1, 3) == '<s-' then
        lhs = string.upper(lhs:sub(1, 3)) .. lhs:sub(4, #lhs)
    elseif vim.api.nvim_eval(([[ '%s' =~? '<\(cr\|del\|esc\|bs\|tab\)>' ]]):format(lhs)) then
        lhs = lhs:upper()
    end

    return lhs
end

return M

local M = {}

function M.has_attrs(tbl, attrs)
    if type(tbl) == 'table' then
        if tbl[attrs] ~= nil then
            return true
        elseif type(attrs) ~= 'table' then
            for _,val in pairs(tbl) do
                if val == attrs then
                    return true
                end
            end
        else
            -- Checking table with list
            local is_tbl = false
            local has_attrs = true
            for _,attr in pairs(attrs) do
                if tbl[attr] == nil then
                    has_attrs = false
                    break
                else
                    is_tbl = true
                end
            end
            if has_attrs then
                return true
            end

            -- Checking for list with list
            if not is_tbl and not has_attrs then
                local has_attr
                has_attrs = true
                for _,attr in pairs(attrs) do
                    has_attr = false
                    for _,val in pairs(tbl) do
                        if val == attr then
                            has_attr = true
                            break
                        end
                    end
                    if not has_attr then
                        has_attrs = false
                        break
                    end
                end
                if has_attrs then
                    return true
                end
            end
        end
    end
    return false
end

function M.clear_lst(lst)
    local tmp = lst

    for idx,val in pairs(lst) do
        val = vim.trim(val)
        if #val == 0 or val == [[\n]] then
            table.remove(tmp, idx)
        end
    end

    return tmp
end

function M.str_to_clean_tbl(cmd_string)
    return M.clear_lst(vim.split(vim.trim(cmd_string), ' ', true))
end

return M

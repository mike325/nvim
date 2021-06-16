local echowarn = require'utils.messages'.echowarn

local M = {}

function M.parser(data)

    assert(
        type(data) == type('') or
        type(data) == type({}),
        'Invalid data: '..vim.inspect(data)
    )

    data = type(data) ~= 'table' and split(data, '\n') or data

    local data_tbl = {
        global = {},
        sections = {},
    }

    local section = nil
    local subsection = nil
    local subsections = {}
    local isglobal = true

    for _,line in pairs(data) do
        if not line:match('^%s*;.*') and not line:match('^%s*#.*') and not line:match('^%s*$') then
            if line:match('^%s*%[%s*.+%s+".+"%s*]$') then
                isglobal = false
                section = line:match('^%s*%[(.+)%s+".+"%s*]$')
                if not data_tbl.sections[section] then
                    data_tbl.sections[section] = {}
                end
                subsection = line:match('"(.+)"%s*]$')
                assert(
                    not data_tbl.sections[section][subsection],
                    'Repeated subsection: '..subsection..' in section: '..section..' '..vim.inspect(data_tbl)
                )
                data_tbl.sections[section][subsection] = {}
                subsections[section] = subsection
            elseif line:match('^%s*%[%s*.+%s*]$') then
                isglobal = false
                section = line:match('^%s*%[%s*(.+)%s*]$')
                if not subsections[section] then
                    assert(not data_tbl.sections[section], 'Repeated section: '..section)
                    data_tbl.sections[section] = {}
                end
                subsection = nil
            elseif ( section or isglobal ) and line:match('^%s*%a[%w_%.-]*%s*=%s*.+$') then
                local clean_line = line:gsub('%s+;.+$', ''):gsub('%s+#.+$', '')
                local attr = clean_line:match('^%s*(%a[%w_%.-]*)%s*=')
                local val = clean_line:match('=%s*(.+)$')
                val = vim.trim(val)

                if val == 'true' or val == 'false' then
                    val = val == 'true'
                elseif val:match('^%d+$') then
                    val = tonumber(val)
                elseif val:match('^0[box][%da-fA-F]+$') then
                    if val:sub(2, 2) == 'x' and val:match('^0[xX][%da-fA-F]+$') then
                        val = tonumber(val, 16)
                    elseif val:sub(2, 2) == 'b' and val:match('^0b[01]+$') then
                        val = tonumber(val:match('^0b([01]+)$'), 2)
                    elseif val:sub(2, 2) == 'o' and val:match('^0o[0-7]+$') then
                        val = tonumber(val:match('^0o([0-7]+)$'), 8)
                    end
                elseif (val:sub(1,1) == '"' or val:sub(1,1) == "'") and val:sub(#val,#val) == val:sub(1, 1) then
                    local qtype = val:sub(1,1)
                    val = val:match(('^%s(.*)%s$'):format(qtype, qtype))
                end


                if isglobal then
                    -- print('Global Attr:',attr, 'Value:',val)
                    data_tbl.global[attr] = val
                elseif not subsection then
                    -- print('Section:', section, 'Attr:',attr, 'Value:',val)
                    data_tbl.sections[section][attr] = val
                else
                    -- print('Section:', section, 'Subsection:', subsection, 'Attr:',attr, 'Value:',val)
                    data_tbl.sections[section][subsection][attr] = val
                end
            else
                echowarn('Unmatched line: '..line)
                section = nil
                subsection = nil
            end
        end
    end
    return data_tbl
end

return M

local nvim = require'nvim'

if tools.helpers == nil then
    tools.helpers = {}
end

function tools.helpers.rename(old, new, bang)

    new = new:gsub('\\', '/')
    old = old:gsub('\\', '/')

    if nvim.fn.filereadable(new) == 0 or bang == 1 then

        if nvim.fn.filereadable(old) == 0 then
            nvim.ex.write(old)
        end

        if nvim.fn.bufloaded(new) == 1 then
            nvim.ex['bwipeout!'](new)
        end

        if nvim.fn.rename(old, new) == 0 then
            local cursor_pos = nvim.win.get_cursor(0)

            nvim.ex.edit(new)
            nvim.ex['bwipeout!'](old)

            nvim.win.set_cursor(0, cursor_pos)

            return true
        else
            nvim.echoerr('Failed to rename '..old)
        end
    elseif nvim.fn.filereadable(new) == 1 then
        nvim.echoerr('File: '..new..' exists, use ! to override, it')
    end

    return false
end

function tools.helpers.delete(target, bang)
    target = target:gsub('\\', '/')
    if nvim.fn.filereadable(target) == 1 or nvim.fn.bufloaded(target) == 1 then
        if nvim.fn.filereadable(target) == 1 then
            if nvim.fn.delete(target) == -1 then
                nvim.echoerr('Failed to delete the file: '..target)
            end
        end
        if nvim.fn.bufloaded(target) == 1 then
            local command = bang == 1 and 'bwipeout! ' or 'bdelete! '
            local ok, error_code = pcall(nvim.command, command..target)
            if not ok and error_code:match('Vim(.%w+.)\\?:E94') then
                nvim.echoerr('Failed to remove buffer '..target)
            end
        end
    elseif nvim.fn.isdirectory(target) == 1 then
        local flag = bang == 1 and 'rf' or 'd'
        if nvim.fn.delete(target, flag) == -1 then
            nvim.echoerr('Failed to remove the directory: '..target)
        end
    else
        nvim.echoerr('Non removable target: '..target)
    end
end

return tools.helpers

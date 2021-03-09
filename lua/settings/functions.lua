local nvim = require'nvim'
local sys = require'sys'
local is_file = require'tools'.files.is_file
local chmod = require'tools'.files.chmod
local set_autocmd = nvim.autocmds.set_autocmd

local M = {}

function M.make_executable()
    if sys.name == 'windows' then
        return
    end

    local shebang = nvim.buf.get_lines(0, 0, 1, true)[1]
    if not shebang:match('^#!.+') then
        return
    end

    local filename = nvim.fn.expand('%')
    if is_file(filename) then
        local fileinfo = vim.loop.fs_stat(filename)
        local filemode = fileinfo.mode - 32768

        if fileinfo.uid ~= sys.user.uid or bit.band(filemode, 0x40) ~= 0 then
            return
        end
    end

    M.exec_on_save()
end

function M.exec_on_save()
    set_autocmd{
        event   = 'BufWritePost',
        pattern = ('<buffer=%d>'):format(nvim.win.get_buf(0)),
        cmd     = ([[lua require'settings.functions'.chmod_exec()]]),
        group   = 'LuaAutocmds',
        once    = true,
    }
end

function M.chmod_exec()
    local filename = nvim.fn.expand('%')
    if not is_file(filename) or sys.name == 'windows' then
        return
    end

    local fileinfo = vim.loop.fs_stat(filename)
    local filemode = fileinfo.mode - 32768
    chmod(filename, bit.bor(filemode, 0x48), 10)
end

return M

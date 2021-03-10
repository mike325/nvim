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

function M.opfun_grep(select, visual)
    local select_save = nvim.o.selection
    nvim.o.selection = 'inclusive'
    local reg_save = nvim.reg['@']

    -- TODO: migrate to neovim's api functions ?
    if visual then
        nvim.ex['normal!']('gvy')
    elseif select == 'line' then
        nvim.ex['normal!']("'[V']y")
    else -- char/block
        nvim.ex['normal!']("`[v`]y")
    end

    local cmd = ('%s %s'):format(nvim.bo.grepprg or nvim.o.grepprg, nvim.fn.shellescape(nvim.reg['@']))

    require'jobs'.send_job{
        cmd = cmd,
        qf = {
            jump = true,
            efm = nvim.o.grepformat,
            context = 'AsyncGrep',
            title = cmd,
        },
    }

    nvim.o.selection = select_save
    nvim.reg['@'] = reg_save
end

return M

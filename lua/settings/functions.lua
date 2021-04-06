local nvim = require'nvim'
local sys  = require'sys'

local is_file         = require'tools'.files.is_file
local chmod           = require'tools'.files.chmod
local getcwd          = require'tools'.files.getcwd
local realpath        = require'tools'.files.realpath
local subpath_in_path = require'tools'.files.subpath_in_path
-- local clear_lst       = require'tools'.tables.clear_lst
local select_filelist = require'tools'.helpers.select_filelist
local split           = require'tools'.strings.split

local set_autocmd = nvim.autocmds.set_autocmd

local M = {
    filelists = {},
}

function M.make_executable()
    if sys.name == 'windows' then
        return
    end

    local shebang = nvim.buf.get_lines(0, 0, 1, true)[1]
    if not shebang or not shebang:match('^#!.+') then
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

function M.send_grep_job(args)
    local cmd = split(nvim.bo.grepprg or nvim.o.grepprg, ' ')
    -- print('Type: ', type(args), 'Value:', vim.inspect(args))
    cmd[#cmd + 1] = args

    require'jobs'.send_job{
        cmd = cmd,
        qf = {
            jump = true,
            efm = nvim.o.grepformat,
            context = 'AsyncGrep',
            title = cmd,
        },
    }
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

    M.send_grep_job(nvim.reg['@'])

    nvim.o.selection = select_save
    nvim.reg['@'] = reg_save
end

local function get_files(path, is_git)
    local seeker = select_filelist(is_git, true)
    require'jobs'.send_job{
        cmd = seeker,
        opts = {
            cwd = path,
            on_exit = function(jobid, rc, _)
                local jobs = require'jobs'.jobs
                if rc == 0 then
                    if jobs[jobid].streams and #jobs[jobid].streams.stdout > 0 then
                        M.filelists[path] = jobs[jobid].streams.stdout
                    end
                end
            end
        }
    }
end

function M.get_path_files()
    local paths = split(nvim.bo.path or nvim.o.path, ',')
    local cwd = realpath(getcwd())

    get_files(cwd, nvim.b.project_root.is_git)
    for _,path in pairs(paths) do
        local rpath = realpath(path)
        if rpath ~= '.' and
           rpath ~= cwd and
           not subpath_in_path(cwd, rpath) and
           not M.filelists[rpath] then
            get_files(rpath)
        end
    end
end

return M

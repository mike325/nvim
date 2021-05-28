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

local echowarn = require'tools'.messages.echowarn
local echoerr  = require'tools'.messages.echoerr

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
            on_fail = {
                open = true,
                jump = false,
            },
            jump = true,
            context = 'AsyncGrep',
            title = cmd,
            efm = nvim.o.grepformat,
        },
        opts = {
            on_exit = function(jobid, rc, _)
                local job = require'jobs'.jobs[jobid]
                local dump_to_qf = require'tools'.helpers.dump_to_qf

                local streams = job.streams or {}
                local stdout = streams.stdout or {}
                local stderr = streams.stderr or {}

                local qf_opts = job.qf or {}
                qf_opts.context = qf_opts.context or cmd[1]
                qf_opts.title = qf_opts.title or cmd[1]..' output'
                if rc == 0 then
                    if #stdout > 0 then
                        qf_opts.lines = stdout
                        dump_to_qf(qf_opts)
                    else
                        echowarn('No results matching: '..args)
                    end
                elseif rc ~= 0 and #stderr == 0 then
                    echowarn('No results matching: '..args)
                else
                    if qf_opts.on_fail then
                        if qf_opts.on_fail.open then
                            qf_opts.open = rc ~= 0
                        end
                        if qf_opts.on_fail.jump then
                            qf_opts.jump = rc ~= 0
                        end
                    end

                    echoerr(('%s exited with code %s'):format(
                        cmd[1],
                        rc
                    ))

                    qf_opts.lines = stderr
                    dump_to_qf(qf_opts)
                end
            end
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

function M.opfun_lsp_format()
    local buf = nvim.get_current_buf()
    local startpos = nvim.buf.get_mark(buf, '[')
    -- startpos[2] = 0
    local endpos = nvim.buf.get_mark(buf, ']')
    -- local endline = nvim.buf.get_lines(buf, endpos[1], endpos[1] + 1, false)[1]
    -- endpos[2] = #endline

    vim.lsp.buf.range_formatting({}, startpos, endpos)
end

function M.toggle_comments(first, last)
    local cursor = nvim.win.get_cursor(0)
    local lines = nvim.buf.get_lines(0, first, last, false)

    local commentstring = nvim.bo.commentstring:gsub('%s+', '')
    local indent_level
    local comment = false
    local allempty = true

    local comment_match = '^%s*'..commentstring:format('.*'):gsub('%-', '%%-'):gsub('/%*', '/%%*'):gsub('%*/', '%%*/')

    for _,line in pairs(lines) do
        if #line > 0 then
            allempty = false
            local _,level = line:find('^%s+')
            if not indent_level or not level or level < indent_level then
                indent_level = not level and 0 or level
            end
            if not comment and not line:match(comment_match) then
                comment = true
            end
        end
    end

    if allempty then
        indent_level = 0
        comment = true
    end

    indent_level = indent_level + 1

    local spaces = ''
    if comment then
        for _=1,indent_level - 1 do
            spaces = spaces .. ' '
        end
    end

    for i=1,#lines do
        if comment then
            local tocomment = lines[i]:sub(indent_level, #lines[i])
            local uncomment = (#lines[i] == 0 and indent_level > 1) and spaces or lines[i]:sub(1, indent_level - 1)
            local format = #lines[i] == 0 and tocomment or ' '..tocomment
            lines[i] = uncomment .. commentstring:format(format)
        else
            local indent_match = '^%s+'
            local uncomment_match = '^%s*'..commentstring:format('%s?(.*)')
                                                         :gsub('%-', '%%-')
                                                         :gsub('/%*', '/%%*')
                                                         :gsub('%*/', '%%*/')
            local indent = lines[i]:match(indent_match) or ''
            local data = lines[i]:match(uncomment_match)
            lines[i] = #data > 0 and indent .. data or ''
        end
    end

    nvim.buf.set_lines(0, first, last, false, lines)
    nvim.win.set_cursor(0, cursor)
end

function M.opfun_comment(_, visual)
    local select_save = nvim.o.selection
    nvim.o.selection = 'inclusive'
    local reg_save = nvim.reg['@']

    if visual then
        nvim.ex['normal!']('gvy')
    else
        nvim.ex['normal!']("'[V']y")
    end

    local sel_start = nvim.buf.get_mark(0, '[')
    local sel_end = nvim.buf.get_mark(0, ']')

    M.toggle_comments(sel_start[1] - 1, sel_end[1])

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
                local job = require'jobs'.jobs[jobid]
                if rc == 0 then
                    if job.streams and #job.streams.stdout > 0 then
                        M.filelists[path] = job.streams.stdout
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

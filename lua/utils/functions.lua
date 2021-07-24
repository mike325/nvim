local nvim = require'neovim'
local sys  = require'sys'

local is_file         = require'utils.files'.is_file
local chmod           = require'utils.files'.chmod
local getcwd          = require'utils.files'.getcwd
local realpath        = require'utils.files'.realpath
local subpath_in_path = require'utils.files'.subpath_in_path
-- local clear_lst       = require'utils.tables'.clear_lst
local select_filelist = require'utils.helpers'.select_filelist
local split           = require'utils.strings'.split

local echowarn = require'utils.messages'.echowarn
local echoerr  = require'utils.messages'.echoerr

local set_autocmd = require'neovim.autocmds'.set_autocmd

local M = {}

function M.make_executable()
    if sys.name == 'windows' then
        return
    end

    local shebang = nvim.buf.get_lines(0, 0, 1, true)[1]
    if not shebang or not shebang:match('^#!.+') then
        return
    end

    local filename = vim.fn.expand('%')
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
        cmd     = ([[lua require'utils'.functions.chmod_exec()]]),
        group   = 'LuaAutocmds',
        once    = true,
    }
end

function M.chmod_exec()
    local filename = vim.fn.expand('%')
    if not is_file(filename) or sys.name == 'windows' then
        return
    end

    local fileinfo = vim.loop.fs_stat(filename)
    local filemode = fileinfo.mode - 32768
    chmod(filename, bit.bor(filemode, 0x48), 10)
end

function M.send_grep_job(args)
    assert(
        type(args) == type('') or type(args) == type({}),
        debug.traceback('Invalid args'..vim.inspect(args))
    )

    local cmd = split(vim.bo.grepprg or vim.o.grepprg, ' ')

    if type(args) == type({}) then
        vim.list_extend(cmd, args)
    else
        table.insert(cmd, args)
    end

    local Job = RELOAD'jobs'
    local grep = Job:new{
        cmd = cmd,
        silent = true,
        qf = {
            on_fail = {
                open = true,
                jump = false,
            },
            jump = true,
            context = 'AsyncGrep',
            title = 'AsyncGrep',
            efm = vim.o.grepformat,
        },
    }

    grep:add_callback(function(job, rc)
        local search = type(args) == type({}) and args[#args] or args
        if rc == 0 and job:is_empty() then
            echowarn('No matching results '..search)
        elseif rc ~= 0 then
            if job:is_empty() then
                echowarn('No matching results '..search)
            else
                echoerr(('%s exited with code %s'):format(
                    cmd[1],
                    rc
                ))
            end
        end
    end)
    grep:start()

end

function M.opfun_grep(select, visual)
    local select_save = vim.o.selection
    vim.o.selection = 'inclusive'
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

    vim.o.selection = select_save
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

    local commentstring = vim.bo.commentstring:gsub('%s+', '')
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
    local select_save = vim.o.selection
    vim.o.selection = 'inclusive'
    local reg_save = nvim.reg['@']

    if visual then
        nvim.ex['normal!']('gvy')
    else
        nvim.ex['normal!']("'[V']y")
    end

    local sel_start = nvim.buf.get_mark(0, '[')
    local sel_end = nvim.buf.get_mark(0, ']')

    M.toggle_comments(sel_start[1] - 1, sel_end[1])

    vim.o.selection = select_save
    nvim.reg['@'] = reg_save
end

local function get_files(path, is_git)
    local seeker = select_filelist(is_git, true)
    local Job = RELOAD('jobs')
    local get_files = Job:new{
        cmd = seeker,
        silent = true,
    }
    get_files:callback_on_success(function(job)
        STORAGE.filelists[path] = job:output()
    end)
    get_files:start()
end

function M.get_path_files()
    local paths = split(vim.bo.path or vim.o.path, ',')
    local cwd = realpath(getcwd())

    get_files(cwd, vim.b.project_root.is_git)
    for _,path in pairs(paths) do
        local rpath = realpath(path)
        if rpath ~= '.' and
           rpath ~= cwd and
           not subpath_in_path(cwd, rpath) and
           not STORAGE.filelists[rpath] then
            get_files(rpath)
        end
    end
end

return M

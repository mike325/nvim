local nvim = require'neovim'
local sys  = require'sys'

local split = require'utils.strings'.split
local set_autocmd = require'neovim.autocmds'.set_autocmd

local M = {}

function M.make_executable()

    if sys.name == 'windows' then
        return
    end

    local is_file = require'utils.files'.is_file

    local shebang = nvim.buf.get_lines(0, 0, 1, true)[1]
    if not shebang or not shebang:match('^#!.+') then
        set_autocmd{
            event   = 'BufWritePre',
            pattern = ('<buffer=%d>'):format(nvim.win.get_buf(0)),
            cmd     = [[lua require'utils'.functions.make_executable()]],
            group   = 'MakeExecutable',
            once    = true,
        }
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

    set_autocmd{
        event   = 'BufWritePost',
        pattern = ('<buffer=%d>'):format(nvim.win.get_buf(0)),
        cmd     = [[lua require'utils'.functions.chmod_exec()]],
        group   = 'MakeExecutable',
        once    = true,
    }
end

function M.chmod_exec()
    local filename = vim.fn.expand('%')
    local is_file = require'utils.files'.is_file

    if not is_file(filename) or sys.name == 'windows' then
        return
    end

    local fileinfo = vim.loop.fs_stat(filename)
    local filemode = fileinfo.mode - 32768
    require'utils.files'.chmod(filename, bit.bor(filemode, 0x48), 10)
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

    local grep = RELOAD'jobs':new{
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
            efm = vim.opt.grepformat:get(),
        },
    }

    grep:add_callback(function(job, rc)
        local search = type(args) == type({}) and args[#args] or args
        if rc == 0 and job:is_empty() then
            vim.notify('No matching results '..search, 'WARN', {title='Grep'})
        elseif rc ~= 0 then
            if job:is_empty() then
                vim.notify('No matching results '..search, 'WARN', {title='Grep'})
            else
                vim.notify(
                    ('%s exited with code %s'):format(
                        cmd[1],
                        rc
                    ),
                    'ERROR',
                    {title='Grep'}
                )
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
            if not comment and not line:match(comment_match) then
                comment = true
                break
            end
        end
    end

    if allempty then
        -- indent_level = 0
        comment = true
    end

    indent_level = require'utils.buffers'.get_indent_block(lines) + 1

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

function M.get_ssh_hosts()
    local ssh_config = sys.home..'/.ssh/config'
    local is_file = require'utils.files'.is_file

    if is_file(ssh_config) then
        local host = ''
        require'utils.files'.readfile(ssh_config, function(data)
            for _,line in pairs(data) do
                if line and line ~= '' and line:match('Host [a-zA-Z0-9_-%.]+') then
                    host = split(line, ' ')[2]
                elseif line:match('%s+Hostname [a-zA-Z0-9_-%.]+') and host ~= '' then
                    STORAGE.hosts[host] = split(line, ' ')[2]
                    host = ''
                end
            end
            -- vim.tbl_add_reverse_lookup(STORAGE.hosts)
        end)
    end
end

function M.get_git_dir(callback)
    assert(require'utils.files'.executable('git'), 'Missing git')
    -- assert(type(callback) == 'function', 'Missing callback function')

    local j = RELOAD'jobs':new{
        cmd = {'git', 'rev-parse', '--git-dir' },
        silent = true,
    }
    j:callback_on_success(function(job)
        local dir = table.concat(job:output(), '')
        pcall(callback, require'utils.files'.realpath(dir))
    end)
    j:start()
end

function M.external_formatprg(args)
    assert(
        type(args) == type({}) and args.cmd,
        debug.traceback('Missing command')
    )

    local cmd = args.cmd
    local buf = args.buffer or vim.api.nvim_get_current_buf()

    local indent = require'utils'.buffers.indent

    local first = args.first or (vim.v.lnum - 1)
    local last = args.last or (first + vim.v.count)

    local lines = vim.api.nvim_buf_get_lines(buf, first, last, false)
    local indent_level = require'utils'.buffers.get_indent_block_level(lines)
    local tmpfile = vim.fn.tempname()

    require'utils'.files.writefile(
        tmpfile,
        indent(lines, -indent_level)
    )

    table.insert(cmd, tmpfile)

    local formatprg = RELOAD'jobs':new{
        cmd = cmd,
        silent = true,
        qf = {
            dump = false,
            on_fail = {
                open = true,
                jump = false,
                dump = true,
            },
            loc = true,
            win = vim.api.nvim_get_current_win(),
            context = 'Format',
            title = 'Format',
            efm = args.efm,
        },
    }

    formatprg:callback_on_success(function(job)
        local fmt_lines = require'utils'.files.readfile(tmpfile)
        fmt_lines = indent(fmt_lines, indent_level)
        vim.api.nvim_buf_set_lines(buf, first, last, false, fmt_lines)
    end)

    formatprg:start()
end

function M.async_execute(opts)
    assert(type(opts) == type({}), debug.traceback('Invalid opts'))
    assert(opts.cmd, debug.traceback('Missing cmd'))
    -- assert(not opts.args, debug.traceback('Missing args'))

    local cmd = opts.cmd
    local args = opts.args

    local script = RELOAD('jobs'):new{
        cmd = cmd,
        args = args,
        progress = true,
        verify_exec = opts.verify_exec,
        -- opts = {
        --     cwd = require'utils'.files.getcwd(),
        --     pty = true,
        -- },
        qf = {
            dump = false,
            on_fail = {
                jump = true,
                open = true,
                dump = true,
            },
            context = 'AsyncExecute',
            title = 'AsyncExecute',
        },
    }
    if opts.callbacks then
        script:add_callback(opts.callbacks)
    end

    if opts.callback_on_failure then
        script:callback_on_failure(opts.callback_on_failure)
    end

    if opts.callback_on_success then
        script:callback_on_success(opts.callback_on_success)
    end

    script:start()
    script:progress()
end


function M.open(uri)
    local cmd
    local args = {}
    if sys.name == 'windows' then
        cmd = 'powershell'
        vim.list_extend(args, {'-noexit', '-executionpolicy', 'bypass', 'Start-Process'})
    elseif sys.name == 'linux' then
        cmd = 'xdg-open'
    else
        -- Problably macos
        cmd = 'open'
    end

    table.insert(args, uri)

    local open = RELOAD'jobs':new{
        cmd = cmd,
        args = args,
        qf = {
            dump = false,
            on_fail = {
                dump = true,
                jump = false,
                open = true,
            },
            context = 'Open',
            title = 'Open',
        },
    }
    open:start()
end

return M

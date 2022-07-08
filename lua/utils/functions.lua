local nvim = require 'neovim'
local sys = require 'sys'

local is_file = require('utils.files').is_file
local split = require('utils.strings').split
local executable = require('utils.files').executable
local replace_indent = require('utils.buffers').replace_indent

local M = {}

function M.make_executable()
    if sys.name == 'windows' then
        return
    end

    local shebang = nvim.buf.get_lines(0, 0, 1, true)[1]
    if not shebang or not shebang:match '^#!.+' then
        nvim.autocmd.add('BufWritePre', {
            group = 'MakeExecutable',
            buffer = nvim.win.get_buf(0),
            callback = function()
                require('utils.functions').make_executable()
            end,
            once = true,
        })
        return
    end

    local filename = vim.fn.expand '%'
    if is_file(filename) then
        local fileinfo = vim.loop.fs_stat(filename)
        local filemode = fileinfo.mode - 32768

        if fileinfo.uid ~= sys.user.uid or bit.band(filemode, 0x40) ~= 0 then
            return
        end
    end

    nvim.autocmd.add('BufWritePost', {
        group = 'MakeExecutable',
        buffer = nvim.win.get_buf(0),
        callback = function()
            require('utils.functions').chmod_exec()
        end,
        once = true,
    })
end

function M.chmod_exec()
    local filename = vim.fn.expand '%'

    if not is_file(filename) or sys.name == 'windows' then
        return
    end

    local fileinfo = vim.loop.fs_stat(filename)
    local filemode = fileinfo.mode - 32768
    require('utils.files').chmod(filename, bit.bor(filemode, 0x48), 10)
end

function M.send_grep_job(args)
    vim.validate {
        args = {
            args,
            function(a)
                return type(a) == type '' or vim.tbl_islist(a)
            end,
            'a string or an array of args',
        },
    }

    local cmd = split(vim.bo.grepprg or vim.o.grepprg, ' ')

    if not vim.tbl_islist(args) then
        args = { args }
    end

    vim.list_extend(cmd, args)

    local grep = require('jobs'):new {
        cmd = cmd,
        silent = true,
        opts = {
            cwd = require('utils.files').getcwd(),
            stdin = 'null',
        },
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
        local search = type(args) == type {} and args[#args] or args
        if rc == 0 and job:is_empty() then
            vim.notify('No matching results ' .. search, 'WARN', { title = 'Grep' })
        elseif rc ~= 0 then
            if job:is_empty() then
                vim.notify('No matching results ' .. search, 'WARN', { title = 'Grep' })
            else
                vim.notify(('%s exited with code %s'):format(cmd[1], rc), 'ERROR', { title = 'Grep' })
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
        nvim.ex['normal!'] 'gvy'
    elseif select == 'line' then
        nvim.ex['normal!'] "'[V']y"
    else -- char/block
        nvim.ex['normal!'] '`[v`]y'
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

    local comment_match = '^%s*' .. commentstring:format('.*'):gsub('%-', '%%-'):gsub('/%*', '/%%*'):gsub('%*/', '%%*/')

    for _, line in pairs(lines) do
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

    indent_level = require('utils.buffers').get_indent_block(lines) + 1

    local spaces = ''
    if comment then
        for _ = 1, indent_level - 1 do
            spaces = spaces .. ' '
        end
    end

    for i = 1, #lines do
        if comment then
            local tocomment = lines[i]:sub(indent_level, #lines[i])
            local uncomment = (#lines[i] == 0 and indent_level > 1) and spaces or lines[i]:sub(1, indent_level - 1)
            local format = #lines[i] == 0 and tocomment or ' ' .. tocomment
            lines[i] = uncomment .. commentstring:format(format)
        else
            local indent_match = '^%s+'
            local uncomment_match = '^%s*'
                .. commentstring:format('%s?(.*)'):gsub('%-', '%%-'):gsub('/%*', '/%%*'):gsub('%*/', '%%*/')
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
        nvim.ex['normal!'] 'gvy'
    else
        nvim.ex['normal!'] "'[V']y"
    end

    local sel_start = nvim.buf.get_mark(0, '[')
    local sel_end = nvim.buf.get_mark(0, ']')

    M.toggle_comments(sel_start[1] - 1, sel_end[1])

    vim.o.selection = select_save
    nvim.reg['@'] = reg_save
end

function M.get_ssh_hosts()
    local ssh_config = sys.home .. '/.ssh/config'

    if is_file(ssh_config) then
        local host = ''
        require('utils.files').readfile(ssh_config, true, function(data)
            for _, line in pairs(data) do
                if line and line ~= '' and line:match '[hH]ost%s+[a-zA-Z0-9_-%.]+' then
                    host = split(line, ' ')[2]
                elseif line:match '%s+[hH]ostname%s+[a-zA-Z0-9_-%.]+' and host ~= '' then
                    local addr = split(line, ' ')[2]
                    STORAGE.hosts[host] = addr
                    host = ''
                end
            end
            -- vim.tbl_add_reverse_lookup(STORAGE.hosts)
        end)
    end
end

function M.get_git_dir(callback)
    vim.validate { callback = { callback, 'function' } }
    assert(executable 'git', 'Missing git')

    local j = require('jobs'):new {
        cmd = { 'git', 'rev-parse', '--git-dir' },
        silent = true,
    }
    j:callback_on_success(function(job)
        local dir = table.concat(job:output(), '')
        pcall(callback, require('utils.files').realpath(dir))
    end)
    j:start()
end

function M.external_formatprg(args)
    assert(type(args) == type {} and args.cmd, debug.traceback 'Missing command')

    local cmd = args.cmd
    local buf = args.buffer or vim.api.nvim_get_current_buf()

    local indent = require('utils.buffers').indent

    local first = args.first or (vim.v.lnum - 1)
    local last = args.last or (first + vim.v.count)

    local lines = vim.api.nvim_buf_get_lines(buf, first, last, false)
    local indent_level = require('utils.buffers').get_indent_block_level(lines)
    local tmpfile = vim.fn.tempname()

    require('utils.files').writefile(tmpfile, indent(lines, -indent_level))

    table.insert(cmd, tmpfile)

    local formatprg = require('jobs'):new {
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

    formatprg:callback_on_success(function(_)
        local fmt_lines = require('utils.files').readfile(tmpfile)
        fmt_lines = indent(fmt_lines, indent_level)
        vim.api.nvim_buf_set_lines(buf, first, last, false, fmt_lines)
    end)

    formatprg:start()
end

function M.async_execute(opts)
    assert(type(opts) == type {}, debug.traceback 'Invalid opts')
    assert(opts.cmd, debug.traceback 'Missing cmd')
    -- assert(not opts.args, debug.traceback('Missing args'))

    local cmd = opts.cmd
    local args = opts.args

    if opts.progress == nil then
        opts.progress = true
    end

    local script = require('jobs'):new {
        cmd = cmd,
        args = args,
        silent = opts.silent,
        progress = opts.progress,
        verify_exec = opts.verify_exec,
        opts = {
            cwd = opts.cwd or require('utils.files').getcwd(),
            -- pty = true,
        },
        qf = {
            dump = false,
            on_fail = {
                jump = true,
                open = true,
                dump = true,
            },
            context = opts.context or 'AsyncExecute',
            title = opts.title or 'AsyncExecute',
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

    if opts.auto_close then
        script:callback_on_success(function(_)
            if vim.t.progress_win then
                nvim.win.close(vim.t.progress_win, true)
            end
        end)
    end

    if opts.pre_execute then
        opts.pre_execute = vim.tbl_islist(opts.pre_execute) and opts.pre_execute or { opts.pre_execute }
        for _, func in ipairs(opts.pre_execute) do
            func()
        end
    end

    script:start()
    if opts.progress then
        script:progress()
    end
end

function M.open(uri)
    local cmd
    local args = {}
    if sys.name == 'windows' then
        cmd = 'powershell'
        vim.list_extend(args, { '-noexit', '-executionpolicy', 'bypass', 'Start-Process' })
    elseif sys.name == 'linux' then
        cmd = 'xdg-open'
    else
        -- Problably macos
        cmd = 'open'
    end

    table.insert(args, uri)

    local open = require('jobs'):new {
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

-- TODO: Improve python folding text
function M.foldtext()
    local indent_level =
        require('utils.buffers').get_indent_block(vim.api.nvim_buf_get_lines(0, vim.v.foldstart, vim.v.foldend, false))
    local indent_string = require('utils.buffers').get_indent_string(indent_level)
    local foldtext = '%s %s %s %s'
    return foldtext:format(
        indent_string .. '+-',
        vim.trim(vim.fn.getline(vim.v.foldstart)),
        ('-- %s lines folded --'):format(vim.v.foldend - vim.v.foldstart),
        vim.trim(vim.fn.getline(vim.v.foldend))
    )
end

function M.set_compiler(compiler, opts)
    vim.validate {
        compiler = { compiler, 'string' },
        opts = { opts, 'table', true },
    }

    opts = opts or {}

    local language = opts.language or vim.opt_local.filetype:get()
    local option = opts.option or 'makeprg'

    local cmd = { compiler }
    local compiler_data = RELOAD('filetypes.' .. language)[option][compiler] or {}

    local has_config = false
    if opts.configs then
        for _, config in ipairs(opts.configs) do
            if is_file(config) then
                has_config = true
                break
            end
        end
    end

    -- TODO: Add option to pass config path as compiler arg
    if not has_config and compiler_data then
        vim.list_extend(cmd, compiler_data)
    end

    table.insert(cmd, '%')

    local has_cmd = nvim.has.command 'CompilerSet'

    if not has_cmd then
        nvim.command.set('CompilerSet', function(command)
            vim.cmd(('setlocal %s'):format(command.args))
        end, { nargs = 1, buffer = true })
    end

    nvim.ex.CompilerSet('makeprg=' .. table.concat(replace_indent(cmd), '\\ '))

    local efm = compiler_data.efm
    if efm then
        nvim.ex.CompilerSet('errorformat=' .. table.concat(efm, ','):gsub(' ', '\\ '))
    end

    vim.b.current_compiler = compiler

    if not has_cmd then
        nvim.command.del('CompilerSet', true)
    end
end

return M

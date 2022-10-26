local sys = require 'sys'
local nvim = require 'neovim'

local M = {}

M.cscope_queries = {
    symbol = 'find s', -- 0
    definition = 'find g', -- 1
    calling = 'find d', -- 2
    callers = 'find c', -- 3
    text = 'find t', -- 4
    file = 'find f', -- 7
    include = 'find i', -- 8
    assing = 'find a', -- 9
}

M.precommit_efm = {
    '%f:%l:%c: %t%n %m',
    '%f:%l:%c:%t: %m',
    '%f:%l:%c: %m',
    '%f:%l: %trror: %m',
    '%f:%l: %tarning: %m',
    '%f:%l: %tote: %m',
    '%f:%l:%m',
    '%f: %trror: %m',
    '%f: %tarning: %m',
    '%f: %tote: %m',
    '%f: Failed to json decode (%m: line %l column %c (char %*\\\\d))',
    '%f: Failed to json decode (%m)',
    '%E%f:%l:%c: fatal error: %m',
    '%E%f:%l:%c: error: %m',
    '%W%f:%l:%c: warning: %m',
    'Diff in %f:',
    '+++ %f',
    'reformatted %f',
}

function M.backspace()
    local ok, _ = pcall(nvim.ex.pop)
    if not ok then
        local key = nvim.replace_termcodes('<C-o>', true, false, true)
        nvim.feedkeys(key, 'n', true)
        -- local jumps
        -- ok, jumps = pcall(nvim.exec, 'jumps', true)
        -- if ok and #jumps > 0 then
        --     jumps = vim.split(jumps, '\n')
        --     table.remove(jumps, 1)
        --     table.remove(jumps, #jumps)
        --     local current_jump
        --     for i=1,#jumps do
        --         local jump = vim.trim(jumps[i]);
        --         jump = split(jump, ' ');
        --         if jump[1] == 0 then
        --             current_jump = i;
        --         end
        --         jumps[i] = jump;
        --     end
        --     if current_jump > 1 then
        --         local current_buf = nvim.win.get_buf(0)
        --         local jump_buf = jumps[current_jump - 1][4]
        --         if current_buf ~= jump_buf then
        --             if not nvim.buf.is_valid(jump_buf) or not nvim.buf.is_loaded(jump_buf) then
        --                 nvim.ex.edit(jump_buf)
        --             end
        --         end
        --         nvim.win.set_cursor(0, jumps[current_jump - 1][2], jumps[current_jump - 1][3])
        --     end
        -- end
    end
end

function M.nicenext(dir)
    local view = vim.fn.winsaveview()
    vim.cmd('silent! normal! ' .. dir)
    if view.topline ~= vim.fn.winsaveview().topline then
        vim.cmd 'silent! normal! zz'
    end
end

function M.smart_insert()
    local current_line = vim.fn.line '.'
    local last_line = vim.fn.line '$'
    local buftype = vim.bo.buftype
    if #vim.fn.getline '.' == 0 and last_line ~= current_line and buftype ~= 'terminal' then
        return '"_ddO'
    end
    return 'i'
end

function M.smart_quit()
    local tabs = nvim.list_tabpages()
    local wins = nvim.tab.list_wins(0)
    if #wins > 1 and vim.fn.expand '%' ~= '[Command Line]' then
        nvim.win.hide(0)
    elseif #tabs > 1 then
        nvim.ex['tabclose!']()
    else
        nvim.exec('quit!', false)
    end
end

function M.floating_terminal(opts)
    local cmd = opts.args
    local shell
    local executable = RELOAD('utils.files').executable

    if cmd ~= '' then
        shell = cmd
    elseif sys.name == 'windows' then
        if vim.regex([[^cmd\(\.exe\)\?$]]):match_str(vim.opt.shell:get()) then
            shell = 'powershell -noexit -executionpolicy bypass '
        else
            shell = vim.opt.shell:get()
        end
    else
        shell = vim.fn.fnamemodify(vim.env.SHELL or '', ':t')
        if vim.regex([[\(t\)\?csh]]):match_str(shell) then
            shell = executable 'zsh' and 'zsh' or (executable 'bash' and 'bash' or shell)
        end
    end

    local win = RELOAD('utils.windows').big_center()

    vim.wo[win].number = false
    vim.wo[win].relativenumber = false

    -- nvim.ex.edit('term://'..)
    vim.fn.termopen(shell)

    if cmd ~= '' then
        nvim.ex.startinsert()
    end
end

function M.toggle_mouse()
    if vim.o.mouse == '' then
        vim.o.mouse = 'a'
        print 'Mouse Enabled'
    else
        vim.o.mouse = ''
        print 'Mouse Disbled'
    end
end

function M.bufkill(opts)
    local bang = opts.bang
    local count = 0
    for _, buf in pairs(nvim.list_bufs()) do
        if not nvim.buf.is_valid(buf) or (bang and not nvim.buf.is_loaded(buf)) then
            nvim.ex['bwipeout!'](buf)
            count = count + 1
        end
    end
    if count > 0 then
        print(count, 'buffers deleted')
    end
end

function M.trim(opts)
    local args = opts.args:lower()
    if args ~= '' and args ~= 'enable' and args ~= 'disable' and args ~= '?' then
        vim.notify('Invalid arg: ' .. args, 'ERROR', { title = 'Trim' })
        return
    end

    local function get_trim_state()
        if vim.t.disable_trim or vim.g.disable_trim then
            print((' Disabled by %s variable'):format(vim.g.disable_trim and 'global' or 'project'))
        else
            print(vim.b.trim and ' Trim' or ' NoTrim')
        end
    end

    if args == '?' then
        get_trim_state()
        return
    end

    local enable
    if args == '' then
        enable = not vim.b.trim
    else
        enable = args == 'enable'
    end

    if opts.bang and enable then
        vim.t.disable_trim = nil
        vim.b.trim = true
    elseif opts.bang and not enable then
        vim.t.disable_trim = true
        vim.b.trim = false
    elseif not opts.bang then
        vim.b.trim = enable
    end

    if args == '' or (enable and (vim.t.disable_trim or vim.g.disable_trim)) then
        get_trim_state()
    end
end

function M.chmod(opts)
    local utils = RELOAD 'utils.files'
    local is_file = utils.is_file

    local mode = opts.args
    if not mode:match '^%d+$' then
        vim.notify('Not a valid permissions mode: ' .. mode, 'ERROR', { title = 'Chmod' })
        return
    end
    local filename = vim.fn.expand '%'
    local chmod = utils.chmod
    if is_file(filename) then
        chmod(filename, mode)
    end
end

function M.move_file(opts)
    local utils = RELOAD 'utils.files'

    local is_file = utils.is_file
    local is_dir = utils.is_dir

    local new_path = opts.args
    local bang = opts.bang

    local current_path = vim.fn.expand '%:p'

    if is_file(current_path) and is_dir(new_path) then
        new_path = new_path .. '/' .. vim.fn.fnamemodify(current_path, ':t')
    end
    utils.rename(current_path, new_path, bang)
end

function M.rename_file(opts)
    local current_path = vim.fn.expand '%:p'
    local current_dir = vim.fn.expand '%:h'
    RELOAD('utils.files').rename(current_path, current_dir .. '/' .. opts.args, opts.bang)
end

function M.cfind(opts)
    local finder = RELOAD('utils.functions').select_filelist(false, true)

    if finder[1] == 'fd' or finder[1] == 'fdfind' or finder[1] == 'rg' then
        table.insert(finder, '-uuu')
    end
    local find = RELOAD('jobs'):new {
        cmd = vim.list_extend(finder, opts.fargs),
        progress = false,
        opts = {
            stdin = 'null',
        },
        qf = {
            on_fail = {
                open = true,
                jump = false,
            },
            dump = true,
            open = true,
            jump = false,
            context = 'CFinder',
            title = 'CFinder',
            efm = '%f',
        },
    }
    find:start()
end

function M.async_makeprg(opts)
    local args = opts.fargs

    local ok, val = pcall(nvim.buf.get_option, 0, 'makeprg')
    local cmd = ok and val or vim.o.makeprg

    if cmd:sub(#cmd, #cmd) == '%' then
        cmd = cmd:gsub('%%', vim.fn.expand '%')
    end

    cmd = cmd .. table.concat(args, ' ')
    RELOAD('utils.functions').async_execute {
        cmd = cmd,
        progress = false,
        auto_close = true,
        context = 'AsyncLint',
        title = 'AsyncLint',
        callback_on_success = function()
            nvim.ex.checktime()
        end,
    }
end

function M.cscope(cword, query)
    cword = (cword and cword ~= '') and cword or vim.fn.expand '<cword>'
    query = M.cscope_queries[query] or 'find g'
    local ok, err = pcall(nvim.ex.cscope, query .. ' ' .. cword)
    if not ok then
        vim.notify('Error!\n' .. err, 'ERROR', { title = 'cscope' })
    end
end

-- TODO: Improve this with globs and pattern matching
function M.convert_path(path, send, host)
    local utils = RELOAD 'utils.files'

    path = vim.fs.normalize(path)

    local remote_path -- = './'
    local hosts, paths, projects

    local path_json = vim.fs.normalize '~/.config/remotes/paths.json'
    if utils.is_file(path_json) then
        local configs = utils.read_json(path_json) or {}
        hosts = configs.hosts or {}
        paths = hosts[host] or configs.paths or {}
        projects = configs.projects or {}
    else
        paths = {}
        projects = {}
    end

    local project = path:match 'projects/([%w%d%.-_]+)'
    if not project then
        for short, full in pairs(projects) do
            if short ~= 'default' and path:match('/(' .. short .. ')[%w%d%.-_]*') then
                project = full
                break
            end
        end
        if not project then
            project = nvim.env.PROJECT or projects.default or 'mike'
        end
    end

    for loc, remote in pairs(paths) do
        if loc:match '%%PROJECT' then
            loc = loc:gsub('%%PROJECT', project)
        end
        loc = vim.fs.normalize(loc)
        if path:match('^' .. loc) then
            local tail = path:gsub('^' .. loc, '')
            if remote:match '%%PROJECT' then
                remote = remote:gsub('%%PROJECT', project)
            end
            remote_path = remote .. '/' .. tail
            break
        end
    end

    if not remote_path then
        remote_path = vim.fs.dirname(path):gsub(sys.home:gsub('\\', '/'), '.') .. '/'
        if not send then
            remote_path = remote_path .. vim.fs.basename(path)
        end
    end

    return remote_path
end

function M.remote_cmd(host, send)
    local utils = RELOAD 'utils.files'

    local filename = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
    local foward_slash = sys.name == 'windows' and not vim.opt.shellslash:get()
    if foward_slash then
        filename = filename:gsub('\\', '/')
    end
    local virtual_filename

    if filename:match '^%w+://' then
        local prefix = filename:match '^%w+://'
        filename = filename:gsub('^%w+://', '')
        if prefix == 'fugitive://' then
            filename = filename:gsub('%.git//?[%w%d]+//?', '')
        end
        virtual_filename = vim.fn.tempname()
        if foward_slash then
            virtual_filename = virtual_filename:gsub('\\', '/')
        end
    end

    vim.validate {
        filename = {
            filename,
            function(f)
                return utils.is_file(f) or virtual_filename
            end,
            'a valid file',
        },
    }

    if virtual_filename and send then
        utils.writefile(virtual_filename, nvim.buf.get_lines(0, 0, -1, true))
        -- else
        --     filename = realpath(vim.fs.normalize(filename))
        --     if foward_slash then
        --         filename = filename:gsub('\\', '/')
        --     end
    end

    local remote_path = ('%s:%s'):format(host, M.convert_path(filename, send, host))
    local rcmd = [[scp -r "%s" "%s"]]
    if send then
        rcmd = rcmd:format(virtual_filename or filename, remote_path)
    else
        rcmd = rcmd:format(remote_path, virtual_filename or filename)
    end
    return rcmd
end

function M.get_host(host)
    if not host or host == '' then
        host = vim.fn.input('Enter hostname > ', '', 'customlist,v:lua._completions.ssh_hosts_completion')
    end
    return host
end

function M.remote_file(host, send)
    host = M.get_host(host)
    if not host or host == '' then
        vim.notify('Missing hostname', 'ERROR')
        return
    end

    host = STORAGE.hosts[host] or host

    local cmd = M.remote_cmd(host, send)
    local sync = RELOAD('jobs'):new {
        cmd = cmd,
        opts = {
            pty = true,
        },
    }
    sync:callback_on_success(function(_)
        nvim.ex.checktime()
    end)
    sync:callback_on_failure(function(job)
        vim.notify(table.concat(job:output(), '\n'), 'ERROR', { title = 'SyncFile' })
    end)
    sync:start()
end

function M.scratch_buffer(opts)
    local ft = opts.args ~= '' and opts.args or vim.bo.filetype
    local scratchs = STORAGE.scratchs
    scratchs[ft] = scratchs[ft] or vim.fn.tempname()
    local buf = vim.fn.bufnr(scratchs[ft], true)

    if ft and ft ~= '' then
        vim.bo[buf].filetype = ft
    end
    vim.bo[buf].bufhidden = 'hide'

    local wins = nvim.tab.list_wins(0)
    local scratch_win

    for _, win in pairs(wins) do
        if nvim.win.get_buf(win) == buf then
            scratch_win = win
            break
        end
    end

    if not scratch_win then
        scratch_win = nvim.open_win(buf, true, { relative = 'editor', width = 1, height = 1, row = 1, col = 1 })
    end

    nvim.set_current_win(scratch_win)
    nvim.ex.wincmd 'K'
end

function M.messages(opts)
    local args = opts.args
    if args == '' then
        local messages = nvim.exec('messages', true)
        messages = vim.tbl_filter(function(v)
            return not v:match '^%s*$'
        end, vim.split(messages, '\n+'))

        -- WARN: This is a WA to avoid EFM detecting ^I as part of a file in lua tracebacks
        for idx, msg in ipairs(messages) do
            messages[idx] = nvim.replace_termcodes(msg, true, false, true)
            if msg:match '%^I' and #msg > 2 then
                messages[idx] = msg:gsub('%^I', '')
            end
        end

        vim.fn.setqflist({}, ' ', {
            lines = messages,
            title = 'Messages',
            context = 'Messages',
        })
        nvim.ex.Qopen()
    else
        nvim.ex.messages 'clear'
        local context = vim.fn.getqflist({ context = 1 }).context
        if context == 'Messages' then
            RELOAD('utils.functions').clear_qf()
            nvim.ex.cclose()
        end
    end
end

function M.precommit(opts)
    local args = opts.fargs
    local precommit = RELOAD('jobs'):new {
        cmd = 'pre-commit',
        args = args,
        -- progress = true,
        qf = {
            efm = M.precommit_efm,
            dump = false,
            on_fail = {
                dump = true,
                jump = false,
                open = true,
            },
            context = 'PreCommit',
            title = 'PreCommit',
        },
    }
    precommit:start()
    -- precommit:progress()
end

function M.repl(opts)
    local cmd = opts.fargs

    if #cmd == 0 or (#cmd == 1 and cmd[1] == '') then
        if vim.b.relp_cmd then
            cmd = vim.b.relp_cmd
        else
            cmd = vim.opt_local.filetype:get()
        end
    end

    local direction = vim.opt.splitbelow:get() and 'botright' or 'topleft'
    vim.api.nvim_exec(direction .. ' 20new', false)

    local win = vim.api.nvim_get_current_win()

    vim.wo[win].number = false
    vim.wo[win].relativenumber = false

    vim.fn.termopen(type(cmd) == type {} and table.concat(cmd, ' ') or cmd)
    nvim.ex.startinsert()
end

function M.zoom_links(opts)
    local utils = RELOAD 'utils.files'

    local links = {}
    if utils.is_file '~/.config/zoom/links.json' then
        links = utils.read_json '~/.config/zoom/links.json'
    end

    if links[opts.args] then
        RELOAD('utils.functions').open(links[opts.args])
    else
        vim.notify('Missing Zoom link ' .. opts.args, 'ERROR', { title = 'Zoom' })
    end
end

function M.edit(args)
    local utils = RELOAD 'utils.files'

    local globs = args.fargs
    for _, g in ipairs(globs) do
        if utils.is_file(g) then
            nvim.ex.edit(g)
        elseif g:match '%*' then
            local files = vim.fn.glob(g, false, true, false)
            for _, f in ipairs(files) do
                if utils.is_file(f) then
                    nvim.ex.edit(f)
                end
            end
        end
    end
end

function M.diff_files(args)
    local utils = RELOAD 'utils.files'

    local files = args.fargs
    if #files ~= 2 and #files ~= 3 then
        vim.notify('Can only diff 2 or 3 files files', 'ERROR', { title = 'DiffFiles' })
        return false
    end

    for _, f in ipairs(files) do
        if not utils.is_file(f) then
            vim.notify(f .. ' is not a regular file or the file does not exits', 'ERROR', { title = 'DiffFiles' })
            return false
        end
    end
    local only = true
    for _, f in ipairs(files) do
        if only then
            only = false
            nvim.ex.tabnew()
        else
            nvim.ex.vsplit()
        end
        nvim.ex.edit(f)
    end

    for _, w in ipairs(nvim.tab.list_wins(0)) do
        local buf = nvim.win.get_buf(w)
        nvim.buf.call(buf, function()
            nvim.ex.diffthis()
        end)
    end
end

function M.toggle_diagnostics()
    vim.g.show_diagnostics = not vim.g.show_diagnostics
    if vim.g.show_diagnostics then
        vim.diagnostic.show()
    else
        vim.diagnostic.hide()
    end
end

function M.custom_compiler(opts)
    local files = RELOAD 'utils.files'

    local path = sys.base .. '/after/compiler/'
    local compiler = opts.args
    local compilers = vim.tbl_map(vim.fs.basename, files.get_files(path))
    if vim.tbl_contains(compilers, compiler .. '.lua') then
        nvim.command.set('CompilerSet', function(command)
            vim.cmd(('setlocal %s'):format(command.args))
        end, { nargs = 1, buffer = true })

        nvim.ex.luafile(path .. compiler .. '.lua')

        nvim.command.del('CompilerSet', true)
    else
        local language = vim.opt_local.filetype:get()
        local has_compiler, compiler_data = pcall(RELOAD, 'filetypes.' .. language)

        if has_compiler and (compiler_data.makeprg or compiler_data.formatprg) then
            local set_compiler = RELOAD('utils.functions').set_compiler

            if compiler_data.makeprg[compiler] then
                set_compiler(compiler)
            elseif compiler_data.formatprg[compiler] then
                set_compiler(compiler, { option = 'formatprg' })
            else
                has_compiler = not has_compiler
            end
        end

        if not has_compiler then
            nvim.ex.compiler(compiler)
        end
    end
end

function M.autoformat()
    vim.b.disable_autoformat = not vim.b.disable_autoformat
    print('Autoformat', vim.b.disable_autoformat and 'disabled' or 'enabled')
end

function M.create_snapshot(opts)
    local ok, packer = pcall(require, 'packer')
    if ok then
        local date = os.date '%Y-%m-%d'
        local raw_ver = nvim.version()
        local version = table.concat({ raw_ver.major, raw_ver.minor, raw_ver.patch }, '.')
        local name = opts.args ~= '' and opts.args or 'clean'
        local snapshot = ('%s-nvim-%s-%s.json'):format(name, version, date)
        local success, msg = pcall(packer.snapshot, snapshot)
        if success then
            vim.notify('Snapshot: ' .. snapshot .. ' created', 'INFO', { title = 'Packer' })
        else
            vim.notify('Failed to create snapshot:\n' .. vim.inspect(msg), 'ERROR', { title = 'Packer' })
        end
    end
end

function M.wall(opts)
    for _, win in ipairs(nvim.tab.list_wins(0)) do
        -- local buf = nvim.win.get_buf(win)
        nvim.win.call(win, function()
            nvim.ex.update()
        end)
    end
end

function M.alternate_grep(opts)
    vim.t.lock_grep = not vim.t.lock_grep
    local is_git = false
    if vim.t.lock_grep then
        require('utils.functions').set_grep(is_git, true)
    else
        if vim.b.project_root then
            is_git = vim.b.project_root.is_git
        end
        require('utils.functions').set_grep(is_git, true)
    end
    local grepprg = require('utils.functions').select_grep(is_git, nil, true)
    print(' Using: ' .. grepprg[1] .. ' as grepprg')
end

function M.swap_window()
    if not nvim.t.swap_window then
        nvim.t.swap_window = 1
        nvim.t.swap_cursor = nvim.win.get_cursor(0)
        nvim.t.swap_base_tab = nvim.tab.get_number(0)
        nvim.t.swap_base_win = nvim.tab.get_win(0)
        nvim.t.swap_base_buf = nvim.win.get_buf(0)
    else
        local swap_new_tab = nvim.tab.get_number(0)
        local swap_new_win = nvim.tab.get_win(0)
        local swap_new_buf = nvim.win.get_buf(0)
        if
            swap_new_tab == nvim.t.swap_base_tab
            and swap_new_win ~= nvim.t.swap_base_win
            and swap_new_buf ~= nvim.t.swap_base_buf
        then
            nvim.win.set_buf(0, nvim.t.swap_base_buf)
            nvim.win.set_buf(nvim.t.swap_base_win, swap_new_buf)
            nvim.win.set_cursor(0, nvim.t.swap_cursor)
            nvim.ex['normal!'] 'zz'
        end
        nvim.t.swap_window = nil
        nvim.t.swap_cursor = nil
        nvim.t.swap_base_tab = nil
        nvim.t.swap_base_win = nil
        nvim.t.swap_base_buf = nil
    end
end

local jobs = STORAGE.jobs
local function kill_job(jobid)
    if not jobid then
        local ids = {}
        local cmds = {}
        local jobidx = 1
        for idx, job in pairs(jobs) do
            ids[#ids + 1] = idx
            local cmd = type(job._cmd) == type '' and job._cmd or table.concat(job._cmd, ' ')
            cmds[#cmds + 1] = ('%s: %s'):format(jobidx, cmd)
            jobidx = jobidx + 1
        end
        if #cmds > 0 then
            local idx = vim.fn.inputlist(cmds)
            jobid = ids[idx]
        else
            vim.notify('No jobs to kill', 'WARN', { title = 'Job Killer' })
        end
    end

    if type(jobid) == type '' and jobid:match '^%d+$' then
        jobid = tonumber(jobid)
    end

    if type(jobid) == type(1) and jobid > 0 then
        pcall(vim.fn.jobstop, jobid)
    end
end

function M.kill_job(opts)
    local jobid = opts.args
    if jobid == '' then
        jobid = nil
    end
    kill_job(jobid)
end

function M.toggle_progress_win()
    if not vim.t.progress_win or not vim.api.nvim_win_is_valid(vim.t.progress_win) then
        require('utils.windows').progress()
    else
        vim.api.nvim_win_close(vim.t.progress_win, true)
    end
end

function M.gradle(opts)
    local args = opts.fargs
    local cmd = { 'gradle', '--quiet' }

    cmd = vim.list_extend(cmd, args)
    RELOAD('utils.functions').async_execute {
        cmd = cmd,
        progress = true,
        auto_close = true,
        context = 'Gradle',
        title = 'Gradle',
        efm = table.concat(vim.opt_global.efm:get(), ','),
    }
end

function M.reload_configs(opts)
    local configs = {
        mappings = 'mappings',
        commands = 'mappings',
        autocmds = 'autocmds',
        options = 'options',
    }

    if opts.args == 'all' or opts.args == '' then
        vim.notify('Reloading all configs', 'INFO')
        for _, v in ipairs(configs) do
            vim.cmd.source(vim.fn.stdpath 'config' .. '/plugin/' .. v .. '.lua')
        end
    elseif configs[opts.args] then
        vim.notify('Reloading: ' .. opts.args, 'INFO')
        vim.cmd.source(vim.fn.stdpath 'config' .. '/plugin/' .. opts.args .. '.lua')
    else
        vim.notify('Invalid config name: ' .. opts.args, 'ERROR', { title = 'Reloader' })
    end
end

function M.alternate(opts)
    opts.buf = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())

    local prefix = opts.buf:match '^%w+://'
    opts.buf = opts.buf:gsub('^%w+://', '')
    if prefix == 'fugitive://' then
        opts.buf = opts.buf:gsub('%.git//?[%w%d]+//?', '')
    end

    if require('utils.files').is_file(opts.buf) then
        opts.buf = vim.loop.fs_realpath(opts.buf)
    end

    local candidates, _
    -- TODO: alternates should be buffer local
    local alternates = vim.g.alternates or {}
    if not alternates[opts.buf] or opts.bang then
        _, candidates = RELOAD('threads.related').alternate_src_header(vim.json.encode(opts))
        if #candidates > 0 then
            candidates = vim.json.decode(candidates)
            alternates[opts.buf] = candidates
            vim.g.alternates = alternates
        end
    else
        candidates = alternates[opts.buf]
    end

    if #candidates > 1 then
        vim.ui.select(candidates, { prompt = 'Alternate: ' }, function(choise)
            nvim.ex.edit(choise)
        end)
    elseif #candidates == 1 then
        nvim.ex.edit(candidates[1])
    else
        vim.notify('No alternate file found', 'WARN')
    end
end

function M.alt_makefiles(opts)
    opts.buf = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())

    local prefix = opts.buf:match '^%w+://'
    opts.buf = opts.buf:gsub('^%w+://', '')
    if prefix == 'fugitive://' then
        opts.buf = opts.buf:gsub('%.git//?[%w%d]+//?', '')
    end

    opts.basedir = vim.fs.dirname(opts.buf)

    local candidates, _
    local makefiles = vim.g.makefiles or {}
    if not makefiles[opts.basedir] or opts.bang then
        _, candidates = RELOAD('threads.related').related_makefiles(vim.json.encode(opts))
        candidates = vim.json.decode(candidates)
        makefiles = vim.g.makefiles or {}
        makefiles[opts.basedir] = candidates
        vim.g.makefiles = makefiles
    else
        candidates = vim.g.makefiles[opts.basedir]
    end

    if #candidates > 1 then
        vim.ui.select(candidates, { prompt = 'Makefile: ' }, function(choise)
            nvim.ex.edit(choise)
        end)
    elseif #candidates == 1 then
        nvim.ex.edit(candidates[1])
    else
        vim.notify('No makefiles file found', 'WARN')
    end
end

function M.alternate_test(opts)
    opts.buf = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())

    local prefix = opts.buf:match '^%w+://'
    opts.buf = opts.buf:gsub('^%w+://', '')
    if prefix == 'fugitive://' then
        opts.buf = opts.buf:gsub('%.git//?[%w%d]+//?', '')
    end

    if require('utils.files').is_file(opts.buf) then
        opts.buf = vim.loop.fs_realpath(opts.buf)
    end

    local candidates, _
    local alternates = vim.g.tests or {}
    if not alternates[opts.buf] or opts.bang then
        _, candidates = RELOAD('threads.related').alternate_test(vim.json.encode(opts))
        if #candidates > 0 then
            candidates = vim.json.decode(candidates)
            alternates[opts.buf] = candidates
            vim.g.tests = alternates
        end
    else
        candidates = alternates[opts.buf]
    end

    if #candidates > 1 then
        vim.ui.select(candidates, { prompt = 'Test: ' }, function(choise)
            nvim.ex.edit(choise)
        end)
    elseif #candidates == 1 then
        nvim.ex.edit(candidates[1])
    else
        vim.notify('No test file found', 'WARN')
    end
end

return M

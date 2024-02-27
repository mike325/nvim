local sys = require 'sys'
local nvim = require 'nvim'

local M = {}

M.cscope_queries = {
    symbol = 'find s', -- 0
    definition = 'find g', -- 1
    calling = 'find d', -- 2
    callers = 'find c', -- 3
    text = 'find t', -- 4
    file = 'find f', -- 7
    include = 'find i', -- 8
    assign = 'find a', -- 9
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
    local ok, _ = pcall(vim.cmd.pop)
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
        --                 vim.cmd.edit{ args = {jump_buf} }
        --             end
        --         end
        --         nvim.win.set_cursor(0, jumps[current_jump - 1][2], jumps[current_jump - 1][3])
        --     end
        -- end
    end
end

function M.nicenext(dir)
    local view = vim.fn.winsaveview()
    local ok, msg = pcall(vim.cmd.normal, { args = { dir }, bang = true })
    if ok and view.topline ~= vim.fn.winsaveview().topline then
        vim.cmd.normal { args = { 'zz' }, bang = true }
    elseif not ok then
        local err = (msg:match 'Vim:E486: Pattern not found:.*')
        vim.api.nvim_err_writeln(err or msg)
    end
end

function M.smart_insert()
    local current_line = vim.fn.line '.'
    local last_line = vim.fn.line '$'
    local buftype = vim.bo.buftype
    if #vim.api.nvim_get_current_line() == 0 and last_line ~= current_line and buftype ~= 'terminal' then
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
        vim.cmd.tabclose { bang = true }
    else
        vim.cmd.quit { bang = true }
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

    vim.fn.termopen(shell)

    if cmd ~= '' then
        vim.cmd.startinsert()
    end
end

function M.toggle_mouse()
    if vim.o.mouse == '' then
        vim.o.mouse = 'a'
        print 'Mouse Enabled'
    else
        vim.o.mouse = ''
        print 'Mouse Disabled'
    end
end

function M.bufkill(opts)
    opts = opts or {}
    local bang = opts.bang
    local removed = 0
    if opts.rm_empty then
        removed = removed + RELOAD('utils.buffers').remove_empty(opts)
    end
    for _, buf in pairs(nvim.list_bufs()) do
        local is_valid = nvim.buf.is_valid(buf)
        local is_unloaded = bang and not nvim.buf.is_loaded(buf)
        if not is_valid or is_unloaded then
            vim.cmd.bwipeout { bang = true, args = { buf } }
            removed = removed + 1
        end
    end
    if removed > 0 then
        print(' ', removed, 'buffers deleted')
    end
    return removed
end

function M.trim(opts)
    local args = opts.args:lower()
    if args ~= '' and args ~= 'enable' and args ~= 'disable' and args ~= '?' then
        vim.notify('Invalid arg: ' .. args, vim.log.levels.ERROR, { title = 'Trim' })
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
        vim.notify('Not a valid permissions mode: ' .. mode, vim.log.levels.ERROR, { title = 'Chmod' })
        return
    end
    local filename = vim.api.nvim_buf_get_name(0)
    local chmod = utils.chmod
    if is_file(filename) then
        chmod(filename, mode)
    end
end

function M.move_file(opts)
    local utils = RELOAD 'utils.files'

    local is_file = utils.is_file
    local is_dir = utils.is_dir

    local location = opts.args
    local bang = opts.bang

    local filename = vim.api.nvim_buf_get_name(0)
    if is_file(filename) and is_dir(location) then
        location = location .. '/' .. vim.fs.basename(filename)
    end
    utils.rename(filename, location, bang)
end

function M.rename_file(opts)
    local filename = vim.api.nvim_buf_get_name(0)
    local dirname = vim.fs.dirname(filename)
    RELOAD('utils.files').rename(filename, dirname .. '/' .. opts.args, opts.bang)
end

function M.find(opts)
    vim.validate {
        opts = { opts, 'table' },
        args = { opts.args, 'table', true },
        target = { opts.target, 'string', true },
        cb = { opts.cb, 'function', true },
    }

    local finder = RELOAD('utils.functions').select_filelist(false, true)

    local fast_finders = {
        fd = true,
        fdfind = true,
        rg = true,
    }

    if fast_finders[finder[1]] then
        table.insert(finder, '-uuu')
        local args = opts.args
        if not args then
            args = { opts.target }
        end
        local find = RELOAD('jobs'):new {
            cmd = vim.list_extend(finder, args),
            progress = false,
            opts = { stdin = 'null' },
            callbacks = function(job, rc)
                if rc == 0 and opts.cb then
                    opts.cb(vim.tbl_filter(function(v)
                        return v ~= ''
                    end, job:output()))
                elseif rc ~= 0 then
                    vim.notify('Error!\n' .. table.concat(job:output(), '\n'), vim.log.levels.ERROR, { title = 'Find' })
                end
            end,
        }
        find:start()
        if not opts.cb then
            local rc = find:wait()
            return rc == 0 and vim.tbl_filter(function(v)
                return v ~= ''
            end, find:output()) or {}
        end
    else
        local target = ''
        -- NOTE: Since this is a "cmdline" utility, transform "glob" to lua pattern
        if opts.target:match '%*' then
            for _, s in ipairs(vim.split(opts.target, '')) do
                target = target .. (s == '*' and '.*' or vim.pesc(s))
            end
        -- elseif opts.target:match '[%[%]*+?^$]' then
        --     target = function(filename)
        --         return filename:match(opts.target) ~= nil
        --     end
        else
            target = opts.target
        end
        if opts.cb then
            -- NOTE: Fallback to native finder which works everywhere
            RELOAD('threads.functions').async_find {
                target = target,
                cb = function(data)
                    opts.cb(data)
                end,
            }
        else
            return vim.fs.find(target, { type = 'file', limit = math.huge })
        end
    end
end

function M.async_makeprg(opts)
    local args = opts.fargs
    for idx, arg in ipairs(args) do
        args[idx] = vim.fn.expand(arg)
    end

    local ok, val = pcall(nvim.buf.get_option, 0, 'makeprg')
    local cmd = ok and val or vim.o.makeprg

    if cmd:sub(#cmd, #cmd) == '%' then
        cmd = cmd:gsub('%%', vim.api.nvim_buf_get_name(0))
    end

    cmd = string.format('%s %s', cmd, table.concat(args, ' '))
    local title = cmd:gsub('%s+.*', '')
    RELOAD('utils.functions').async_execute {
        cmd = cmd,
        progress = false,
        auto_close = true,
        title = title:sub(1, 1):upper() .. title:sub(2, #title),
        callbacks_on_success = function()
            vim.cmd.checktime()
        end,
        callbacks_on_failure = function(_)
            RELOAD('utils.qf').qf_to_diagnostic(title)
        end,
    }
end

-- NOTE: This does not work from neovim >= 0.8
function M.cscope(cword, query)
    cword = (cword and cword ~= '') and cword or vim.fn.expand '<cword>'
    query = M.cscope_queries[query] or 'find g'
    local ok, err = pcall(vim.cmd.cscope, { args = query, cword })
    if not ok then
        vim.notify('Error!\n' .. err, vim.log.levels.ERROR, { title = 'cscope' })
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
    local forward_slash = sys.name == 'windows' and not vim.opt.shellslash:get()
    if forward_slash then
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
        if forward_slash then
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
        --     if forward_slash then
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

function M.get_host(host, send)
    if not host or host == '' then
        local prompt = 'Enter hostname > '
        if send ~= nil then
            prompt = send and 'Send file to > ' or 'Get file from > '
        end
        host = vim.fn.input(prompt, '', "customlist,v:lua.require'completions'.ssh_hosts_completion")
    end
    return host
end

function M.remote_file(host, send)
    host = M.get_host(host, send)
    if not host or host == '' then
        vim.notify('Missing hostname', vim.log.levels.ERROR)
        return
    end

    if STORAGE.hosts[host] then
        host = STORAGE.hosts[host].hostname
    end

    local cmd = M.remote_cmd(host, send)
    local sync = RELOAD('jobs'):new {
        cmd = cmd,
        opts = {
            pty = true,
        },
        callbacks_on_success = function(_)
            vim.cmd.checktime()
        end,
        callbacks_on_failure = function(job)
            vim.notify(table.concat(job:output(), '\n'), vim.log.levels.ERROR, { title = 'SyncFile' })
        end,
    }
    sync:start()
end

function M.scratch_buffer(opts)
    local ft = opts.args ~= '' and opts.args or vim.bo.filetype
    local scratches = STORAGE.scratches
    scratches[ft] = scratches[ft] or vim.fn.tempname()
    local buf = vim.fn.bufnr(scratches[ft], true)

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
    vim.cmd.wincmd 'K'
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

        local efm = vim.opt_global.efm:get()
        table.insert(efm, 1, '%trror executing vim.schedule lua callback: %f:%l:%m')

        RELOAD('utils.qf').set_list {
            items = messages,
            title = 'Messages',
            open = true,
            efm = efm,
        }
    else
        vim.cmd.messages 'clear'
        local title = vim.fn.getqflist({ title = 1 }).title
        if title == 'Messages' then
            RELOAD('utils.qf').clear()
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
    vim.cmd { cmd = 'new', range = { 20 }, mods = { split = direction } }

    local win = vim.api.nvim_get_current_win()

    vim.wo[win].number = false
    vim.wo[win].relativenumber = false

    vim.fn.termopen(type(cmd) == type {} and table.concat(cmd, ' ') or cmd)
    vim.cmd.startinsert()
end

function M.zoom_links(opts)
    local utils = RELOAD 'utils.files'

    local links = {}
    if utils.is_file '~/.config/zoom/links.json' then
        links = utils.read_json '~/.config/zoom/links.json'
    end

    if links[opts.args] then
        vim.ui.open(links[opts.args])
    else
        vim.notify('Missing Zoom link ' .. opts.args, vim.log.levels.ERROR, { title = 'Zoom' })
    end
end

function M.edit(args)
    local utils = RELOAD 'utils.files'

    local globs = args.fargs
    local cwd = vim.pesc(vim.loop.cwd() .. '/')
    for _, g in ipairs(globs) do
        if utils.is_file(g) then
            vim.cmd.edit((g:gsub(cwd, '')))
        elseif g:match '%*' then
            local files = vim.fn.glob(g, false, true, false)
            for _, f in ipairs(files) do
                if utils.is_file(f) then
                    vim.cmd.edit((f:gsub(cwd, '')))
                end
            end
        end
    end
end

function M.diff_files(args)
    local utils = RELOAD 'utils.files'

    local files = args.fargs
    if #files ~= 2 and #files ~= 3 then
        vim.notify('Can only diff 2 or 3 files files', vim.log.levels.ERROR, { title = 'DiffFiles' })
        return false
    end

    for _, f in ipairs(files) do
        if not utils.is_file(f) then
            vim.notify(
                f .. ' is not a regular file or the file does not exits',
                vim.log.levels.ERROR,
                { title = 'DiffFiles' }
            )
            return false
        end
    end
    local only = true
    for _, f in ipairs(files) do
        if only then
            only = false
            vim.cmd.tabnew()
        else
            vim.cmd.vsplit()
        end
        local cwd = vim.pesc(vim.loop.cwd() .. '/')
        vim.cmd.edit((f:gsub(cwd, '')))
    end

    for _, w in ipairs(nvim.tab.list_wins(0)) do
        nvim.buf.call(vim.api.nvim_win_get_buf(w), function()
            vim.cmd.diffthis()
        end)
    end
end

function M.toggle_diagnostics(ns, force)
    vim.validate {
        ns = { ns, 'number', true },
        force = { force, 'boolean', true },
    }

    vim.g.show_diagnostics = not vim.g.show_diagnostics
    local buf = not force and vim.api.nvim_get_current_buf() or nil
    if vim.g.show_diagnostics then
        vim.diagnostic.enable(buf, ns)
        vim.diagnostic.show(ns, buf)
    else
        vim.diagnostic.disable(buf, ns)
        vim.diagnostic.hide(ns, buf)
    end
end

function M.custom_compiler(opts)
    local compiler = opts.args
    local base_path = 'after/compiler/'
    local compilers = vim.tbl_map(vim.fs.basename, vim.api.nvim_get_runtime_file(base_path .. '*.lua', true))
    if vim.list_contains(compilers, (compiler:gsub('%.lua$', ''))) then
        vim.cmd.runtime { bang = true, args = { base_path .. compiler } }
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
            vim.cmd.compiler(compiler)
        end
    end
end

function M.autoformat(opts)
    if opts.args == 'enable' then
        vim.b.autoformat = true
    elseif opts.args == 'disable' then
        vim.b.autoformat = false
    else
        if vim.b.autoformat == nil then
            vim.b.autoformat = true
        end
        vim.b.autoformat = not vim.b.autoformat
    end
    print('Autoformat', vim.b.autoformat and 'enabled' or 'disabled')
end

function M.wall(_)
    for _, win in ipairs(nvim.tab.list_wins(0)) do
        nvim.buf.call(nvim.win.get_buf(win), function()
            vim.cmd.update()
        end)
    end
end

function M.alternate_grep(_)
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
            vim.cmd.normal { bang = true, args = { 'zz' } }
        end
        nvim.t.swap_window = nil
        nvim.t.swap_cursor = nil
        nvim.t.swap_base_tab = nil
        nvim.t.swap_base_win = nil
        nvim.t.swap_base_buf = nil
    end
end

local function kill_job(jobid)
    if not jobid then
        local ids = {}
        local cmds = {}
        local jobidx = 1
        for idx, job in pairs(STORAGE.jobs) do
            ids[#ids + 1] = idx
            local cmd = type(job._cmd) == type '' and job._cmd or table.concat(job._cmd, ' ')
            cmds[#cmds + 1] = ('%s: %s'):format(jobidx, cmd)
            jobidx = jobidx + 1
        end
        if #cmds > 0 then
            local idx = vim.fn.inputlist(cmds)
            jobid = ids[idx]
        else
            vim.notify('No jobs to kill', vim.log.levels.WARN, { title = 'Job Killer' })
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

    local lua_file_path = '%s/lua/configs/%s.lua'

    local config_dir = vim.fn.stdpath 'config'
    if opts.args == 'all' or opts.args == '' then
        for _, v in ipairs(configs) do
            vim.cmd.source(lua_file_path:format(config_dir, v))
        end
        vim.notify('All configs reloaded!', vim.log.levels.INFO)
    elseif configs[opts.args] then
        vim.cmd.source(lua_file_path:format(config_dir, opts.args))
        vim.notify(opts.args .. ' reloaded!', vim.log.levels.INFO)
    else
        vim.notify('Invalid config name: ' .. opts.args, vim.log.levels.ERROR, { title = 'Reloader' })
    end
end

local function select_from_lst(args, prompt)
    vim.validate {
        args = { args, { 'string', 'table' } },
        prompt = { prompt, 'string', true },
    }

    prompt = prompt or 'Select file: '
    local cwd = vim.pesc(vim.loop.cwd() .. '/')
    if #args > 1 then
        vim.ui.select(
            args,
            { prompt = prompt },
            vim.schedule_wrap(function(choice)
                vim.cmd.edit((choice:gsub(cwd, '')))
            end)
        )
    elseif #args == 1 then
        vim.cmd.edit((args[1]:gsub(cwd, '')))
    else
        vim.notify('No file found', vim.log.levels.WARN)
    end
end

function M.alternate(opts)
    local bufnr = vim.api.nvim_get_current_buf()
    opts.buf = vim.api.nvim_buf_get_name(bufnr)

    -- NOTE: ignore scratch buffers
    if opts.buf == '' and vim.bo[bufnr].buftype ~= '' then
        return
    end

    -- TODO: Add support for clangd switch header/src command
    -- local found = RELOAD('configs.lsp.utils').switch_source_header_splitcmd(bufnr, 'edit')
    -- if found then
    --     return
    -- end

    local prefix = opts.buf:match '^%w+://'
    opts.buf = opts.buf:gsub('^%w+://', '')
    if prefix == 'fugitive://' then
        opts.buf = opts.buf:gsub('%.git//?[%w%d]+//?', '')
    end

    if require('utils.files').is_file(opts.buf) then
        opts.buf = vim.loop.fs_realpath(opts.buf)
    end

    local candidates
    local buf = opts.buf
    local bang = opts.bang

    -- TODO: alternates should be buffer local
    local alternates = vim.g.alternates or {}
    if not alternates[buf] or bang then
        local results = RELOAD('threads.related').alternate_src_header(RELOAD('threads').add_thread_context(opts))
        candidates = results.candidates or {}
        if #candidates > 0 then
            alternates[buf] = candidates
            vim.g.alternates = alternates
        end
    else
        candidates = alternates[buf]
    end

    select_from_lst(candidates, 'Alternate: ')
end

function M.alt_makefiles(opts)
    local bufnr = vim.api.nvim_get_current_buf()
    opts.buf = vim.api.nvim_buf_get_name(bufnr)

    -- NOTE: ignore scratch buffers
    if opts.buf == '' and vim.bo[bufnr].buftype ~= '' then
        return
    end

    local prefix = opts.buf:match '^%w+://'
    opts.buf = opts.buf:gsub('^%w+://', '')
    if prefix == 'fugitive://' then
        opts.buf = opts.buf:gsub('%.git//?[%w%d]+//?', '')
    end

    opts.basedir = vim.fs.dirname(opts.buf)

    local candidates
    local makefiles = vim.g.makefiles or {}
    if not makefiles[opts.basedir] or opts.bang then
        opts = RELOAD('threads.related').related_makefiles(opts)
        candidates = opts.candidates or {}
        if #candidates > 0 then
            makefiles = vim.g.makefiles or {}
            makefiles[opts.basedir] = candidates
            vim.g.makefiles = makefiles
        end
    else
        candidates = vim.g.makefiles[opts.basedir]
    end

    select_from_lst(candidates, 'Makefile: ')
end

function M.alternate_test(opts)
    local bufnr = vim.api.nvim_get_current_buf()
    opts.buf = vim.api.nvim_buf_get_name(bufnr)

    -- NOTE: ignore scratch buffers
    if opts.buf == '' and vim.bo[bufnr].buftype ~= '' then
        return
    end

    local prefix = opts.buf:match '^%w+://'
    opts.buf = opts.buf:gsub('^%w+://', '')
    if prefix == 'fugitive://' then
        opts.buf = opts.buf:gsub('%.git//?[%w%d]+//?', '')
    end

    if require('utils.files').is_file(opts.buf) then
        opts.buf = vim.loop.fs_realpath(opts.buf)
    end

    local candidates
    local alternates = vim.g.tests or {}
    if not alternates[opts.buf] or opts.bang then
        opts = RELOAD('threads.related').alternate_test(RELOAD('threads').add_thread_context(opts))
        candidates = opts.candidates or {}
        if #candidates > 0 then
            alternates[opts.key] = candidates
            vim.g.tests = alternates
        end
    else
        candidates = alternates[opts.buf]
    end

    select_from_lst(candidates, 'Test: ')
end

function M.show_background_jobs()
    if next(STORAGE.jobs) == nil then
        return
    end

    if vim.t.job_info and nvim.win.is_valid(vim.t.job_info) then
        nvim.win.close(vim.t.job_info, true)
        vim.t.job_info = nil
        return
    else
        vim.t.job_info = RELOAD('utils.windows').lower_window()
    end

    -- TODO: Add auto update of the current jobs if the window stays open
    local buf = nvim.win.get_buf(vim.t.job_info)
    local lines = {}
    for id, job in pairs(STORAGE.jobs) do
        local cmd = type(job._cmd) == type '' and job._cmd or table.concat(job._cmd, ' ')
        table.insert(lines, ('%s: %s'):format(id, cmd))
    end
    nvim.buf.set_lines(buf, 0, -1, false, lines)
end

function M.show_job_progress(opts)
    local id = tostring(opts.fargs[1]:match '^%d+')
    if STORAGE.jobs[id] then
        local job = STORAGE.jobs[id]
        job:progress()
    end
end

function M.add_nl(down)
    local cursor_pos = nvim.win.get_cursor(0)
    local lines = { '' }
    local count = vim.v['count1']
    if count > 1 then
        for _ = 2, count, 1 do
            table.insert(lines, '')
        end
    end

    local cmd
    if not down then
        cursor_pos[1] = cursor_pos[1] + count
        cmd = '[ '
    else
        cmd = '] '
    end

    nvim.put(lines, 'l', down, true)
    nvim.win.set_cursor(0, cursor_pos)
    pcall(vim.fn['repeat#set'], cmd, count)
end

function M.move_line(down)
    -- local cmd
    local lines = { '' }
    local count = vim.v.count1

    if count > 1 then
        for _ = 2, count, 1 do
            table.insert(lines, '')
        end
    end

    if down then
        -- cmd = ']e'
        count = vim.fn.line '$' < vim.fn.line '.' + count and vim.fn.line '$' or vim.fn.line '.' + count
    else
        -- cmd = '[e'
        count = vim.fn.line '.' - count - 1 < 1 and 1 or vim.fn.line '.' - count - 1
    end

    vim.cmd.move(count)
    vim.cmd.normal { bang = true, args = { '==' } }
    -- TODO: Make repeat work
    -- pcall(vim.fn['repeat#set'], cmd, count)
end

function M.vnc(hostname, opts)
    vim.validate {
        hostname = { hostname, 'string' },
        opts = { opts, 'table', true },
    }
    local executable = RELOAD('utils.files').executable

    local components = vim.split(hostname, ':')
    hostname = components[1]
    local port = components[2] or '1' -- '10'

    if STORAGE.hosts[hostname] then
        hostname = STORAGE.hosts[hostname].hostname
    end

    if vim.env.SSH_CONNECTION then
        RELOAD('utils.functions').send_osc1337('vnc', hostname .. ':' .. port)
    elseif executable 'vncviewer' then
        local args = { hostname }
        vim.list_extend(args, opts or {})
        local vnc = RELOAD('jobs'):new {
            cmd = 'vncviewer',
            args = args,
            qf = {
                dump = false,
                on_fail = {
                    dump = true,
                    jump = false,
                    open = true,
                },
                title = 'VNC',
            },
        }
        vnc:start()
    else
        vim.notify('Missing vncviewer executable', vim.log.levels.ERROR, { title = 'VNC' })
    end
end

return M

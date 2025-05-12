local sys = require 'sys'
local nvim = require 'nvim'

local M = {}

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

        vim.list_extend(finder, args)
        local find = vim.system(finder, { text = true }, function(job)
            if job.code == 0 and opts.cb then
                local output = vim.split(job.stdout, '\n', { trimempty = true })
                opts.cb(output)
            elseif job.code ~= 0 then
                vim.notify('Error!\n' .. job.stdout, vim.log.levels.ERROR, { title = 'Find' })
            end
        end)

        if not opts.cb then
            local rc = find:wait()
            if rc.code == 0 then
                return vim.split(rc.stdout, '\n', { trimempty = true })
            end
            return {}
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
            local blacklist = {
                ['.git'] = true,
                ['.svn'] = true,
                ['.cache'] = true,
                ['__pycache__'] = true,
                ['.vscode'] = true,
                ['.vscode_clangd_setup'] = true,
                ['node_modules'] = true,
            }

            local candidates = {}
            local path = '.'
            for fname, ftype in vim.fs.dir(path) do
                if ftype == 'file' then
                    if
                        (type(target) == type '' and target == fname)
                        or (type(target) == type {} and vim.list_contains(target, fname))
                        or (type(target) == 'function' and target(fname))
                    then
                        table.insert(candidates, vim.fs.joinpath(path, fname))
                    end
                elseif not blacklist[fname] then
                    local results =
                        vim.fs.find(target, { type = 'file', limit = math.huge, path = vim.fs.joinpath(path, fname) })
                    if #results > 0 then
                        candidates = vim.list_extend(candidates, results)
                    end
                end
            end
            return candidates
        end
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
    local forward_slash = sys.name == 'windows' and not vim.go.shellslash
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

function M.remote_file(host, send)
    host = RELOAD('utils.network').get_ssh_host(host)
    if not host then
        return
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
        messages = vim.split(messages, '\n+', { trimempty = true })

        -- WARN: This is a WA to avoid EFM detecting ^I as part of a file in lua tracebacks
        for idx, msg in ipairs(messages) do
            messages[idx] = vim.keycode(msg)
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

function M.repl(opts)
    local cmd = opts.fargs

    if #cmd == 0 or (#cmd == 1 and cmd[1] == '') then
        if vim.b.relp_cmd then
            cmd = vim.b.relp_cmd
        else
            cmd = vim.bo.filetype
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
        local cwd = vim.pesc(vim.uv.cwd() .. '/')
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
        vim.diagnostic.enable(false, { bufnr = buf, ns_id = ns })
        vim.diagnostic.hide(ns, buf)
    end
end

function M.custom_compiler(opts)
    local compiler = opts.args
    local base_path = 'after/compiler/'
    local compilers = vim.tbl_map(vim.fs.basename, vim.api.nvim_get_runtime_file(base_path .. '*.lua', true))
    local mapped = vim.tbl_map(function(c)
        return (c:gsub('%.lua$', ''))
    end, compilers)
    if vim.list_contains(mapped, compiler) then
        vim.cmd.runtime { bang = true, args = { base_path .. compiler .. '.lua' } }
    else
        local language = vim.bo.filetype
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

function M.alternate_grep(_)
    vim.t.lock_grep = not vim.t.lock_grep
    local is_git = false
    if not vim.t.lock_grep then
        is_git = vim.t.is_in_git
    end
    require('utils.functions').set_grep(is_git, true)
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

function M.toggle_progress_win()
    if not vim.t.progress_win or not vim.api.nvim_win_is_valid(vim.t.progress_win) then
        require('utils.windows').progress()
    else
        vim.api.nvim_win_close(vim.t.progress_win, true)
    end
end

function M.reload_configs(files)
    vim.validate {
        files = { files, { 'table', 'string' } },
    }

    if type(files) == type '' then
        files = { files }
    end

    if #files == 0 then
        vim.notify('No files to reload', vim.log.levels.WARN, { title = 'Reloader' })
        return
    end

    local success = {}
    local fail = {}

    for _, fname in ipairs(files) do
        if pcall(vim.cmd.source, fname) then
            table.insert(success, fname)
        else
            table.insert(fail, fname)
        end
    end

    if #fail > 0 then
        vim.notify(
            string.format('Failed to reload:\n %s', table.concat(fail, '\n ')),
            vim.log.levels.ERROR,
            { title = 'Reloader' }
        )
    elseif #success == 1 then
        vim.notify(string.format('Successfully reloaded:\n%s', success[1]), vim.log.levels.INFO, { title = 'Reloader' })
    else
        vim.notify(
            string.format('Successfully reloaded %d files', #success),
            vim.log.levels.INFO,
            { title = 'Reloader' }
        )
    end
end

local function select_from_lst(args, prompt)
    vim.validate {
        args = { args, { 'string', 'table' } },
        prompt = { prompt, 'string', true },
    }

    prompt = prompt or 'Select file: '
    local cwd = vim.pesc(vim.uv.cwd() .. '/')
    if #args > 1 then
        vim.ui.select(
            args,
            { prompt = prompt },
            vim.schedule_wrap(function(choice)
                if choice then
                    vim.cmd.edit((choice:gsub(cwd, '')))
                end
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

    -- local server = vim.lsp.get_clients({ name = 'clangd', bufnr = bufnr })[1]
    -- if server then
    --     local found = RELOAD('configs.lsp.utils').switch_source_header_splitcmd(bufnr, 'edit')
    --     if found then
    --         return
    --     end
    -- end

    local prefix = opts.buf:match '^%w+://'
    opts.buf = opts.buf:gsub('^%w+://', '')
    if prefix == 'fugitive://' then
        opts.buf = opts.buf:gsub('%.git//?[%w%d]+//?', '')
    end

    if require('utils.files').is_file(opts.buf) then
        opts.buf = vim.uv.fs_realpath(opts.buf)
    end

    local candidates = {}
    local alternates = vim.g.alternates or {}
    local buf = opts.buf
    local bang = opts.bang

    if not alternates[buf] or bang then
        local extensions = {
            c = { 'h' },
            h = { 'c' },
            cc = { 'hpp', 'hxx' },
            cpp = { 'hpp', 'hxx' },
            cxx = { 'hpp', 'hxx' },
            hpp = { 'cpp', 'cxx', 'cc' },
            hxx = { 'cpp', 'cxx', 'cc' },
        }
        local bn = vim.fs.basename(buf)
        local ext = require('utils.files').extension(bn)
        local name_no_ext = bn:gsub('%.' .. ext .. '$', '')
        local alternat_dict = {}
        for _, path in ipairs(vim.split(vim.bo.path, ',')) do
            if path ~= '' and require('utils.files').is_dir(path) then
                for item, itype in vim.fs.dir(path, {}) do
                    if itype == 'file' then
                        local iext = require('utils.files').extension(item)
                        if
                            name_no_ext == (item:gsub('%.' .. iext .. '$', ''))
                            and vim.list_contains(extensions[ext], iext)
                            and not alternat_dict[vim.fs.joinpath(path, item)]
                        then
                            table.insert(candidates, vim.fs.joinpath(path, item))
                            alternat_dict[vim.fs.joinpath(path, item)] = true
                        end
                    end
                end
            end
        end

        if #candidates == 0 then
            local results = RELOAD('threads.related').alternate_src_header(RELOAD('threads').add_thread_context(opts))
            if results.candidates then
                candidates = vim.list_extend(candidates, results.candidates)
            end
        end

        if #candidates > 0 then
            alternates[buf] = require('utils.tables').uniq_unorder(candidates)
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
        opts.buf = vim.uv.fs_realpath(opts.buf)
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

function M.show_background_tasks()
    if next(ASYNC.tasks) == nil then
        return
    end

    if vim.t.task_info and nvim.win.is_valid(vim.t.task_info) then
        nvim.win.close(vim.t.task_info, true)
        vim.t.task_info = nil
        return
    else
        vim.t.task_info = RELOAD('utils.windows').lower_window()
    end

    -- TODO: Add auto update of the current tasks if the window stays open
    local buf = nvim.win.get_buf(vim.t.task_info)
    local lines = {}
    for hash, task in pairs(ASYNC.tasks) do
        local cmd = vim.json.decode(vim.base64.decode(hash)).cmd
        lines[#lines + 1] = ('%s: %s'):format(task.pid, table.concat(cmd, ' '))
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

return M

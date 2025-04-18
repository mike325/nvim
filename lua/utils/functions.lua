local nvim = require 'nvim'

local replace_indent = require('utils.buffers').replace_indent
local executable = require('utils.files').executable
local is_file = require('utils.files').is_file
local getcwd = require('utils.files').getcwd

local M = {}

function M.external_formatprg(args)
    vim.validate {
        args = { args, 'table' },
        cmd = { args.cmd, 'table' },
    }

    local cmd = args.cmd
    local bufnr = args.bufnr or vim.api.nvim_get_current_buf()

    local buf_utils = RELOAD 'utils.buffers'

    local first = args.first or (vim.v.lnum - 1)
    local last = args.last or (first + vim.v.count)

    local lines = vim.api.nvim_buf_get_lines(bufnr, first, last, false)
    local indent_level = buf_utils.get_indent_block_level(lines)
    local tmpfile = vim.fn.tempname()

    require('utils.files').writefile(tmpfile, buf_utils.indent(lines, -indent_level))

    table.insert(cmd, tmpfile)

    local view = vim.fn.winsaveview()

    local formatprg = RELOAD('jobs'):new {
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
            title = 'Format',
            efm = args.efm,
        },
        callbacks_on_success = function(_)
            local fmt_lines = require('utils.files').readfile(tmpfile)
            fmt_lines = buf_utils.indent(fmt_lines, indent_level)
            vim.api.nvim_buf_set_lines(bufnr, first, last, false, fmt_lines)
            vim.fn.winrestview(view)
        end,
    }

    formatprg:start()
end

function M.external_linterprg(args)
    vim.validate {
        args = { args, 'table' },
        cmd = { args.cmd, 'table' },
    }

    local cmd = args.cmd
    local bufnr = args.buffer or vim.api.nvim_get_current_buf()
    local efm = args.efm
    if not efm then
        efm = vim.bo.efm ~= '' and vim.bo.efm or vim.go.efm
    end
    table.insert(cmd, vim.api.nvim_buf_get_name(bufnr))

    local linter = RELOAD('jobs'):new {
        cmd = cmd,
        silent = true,
        callbacks_on_failure = function(job, _)
            local items = vim.fn.getqflist({ lines = job:output(), efm = efm }).items
            RELOAD('utils.qf').qf_to_diagnostic(cmd[1], false, items)
        end,
    }

    linter:start()
end

function M.async_execute(opts)
    vim.validate {
        opts = { opts, 'table' },
        cmd = { opts.cmd, { 'table', 'string' } },
    }

    local cmd = opts.cmd
    local args = opts.args

    if opts.progress == nil then
        opts.progress = true
    end

    local dump = opts.dump
    if dump == nil then
        dump = false
    end

    local script = RELOAD('jobs'):new {
        cmd = cmd,
        args = args,
        silent = opts.silent,
        progress = opts.progress,
        verify_exec = opts.verify_exec,
        parse_errors = opts.parse_errors,
        opts = {
            cwd = opts.cwd or require('utils.files').getcwd(),
            on_stdout = opts.on_stdout,
            on_stderr = opts.on_stderr,
            on_exit = opts.on_exit,
            pty = opts.pty,
        },
        qf = {
            dump = dump,
            open = dump,
            on_fail = {
                jump = true,
                open = true,
                dump = true,
            },
            efm = opts.efm,
            title = opts.title or 'AsyncExecute',
        },
        callbacks = opts.callbacks,
        callbacks_on_failure = opts.callbacks_on_failure,
        callbacks_on_success = opts.callbacks_on_success,
    }

    if opts.auto_close or opts.autoclose then
        script:callbacks_on_success(function(_)
            if vim.t.progress_win and not vim.g.active_job then
                nvim.win.close(vim.t.progress_win, true)
            end
        end)
    end

    if opts.pre_execute then
        opts.pre_execute = vim.islist(opts.pre_execute) and opts.pre_execute or { opts.pre_execute }
        for _, func in ipairs(opts.pre_execute) do
            func()
        end
    end

    script:start()
    if opts.progress then
        script:progress()
    end
end

-- TODO: Improve python folding text
function M.foldtext()
    local lines = vim.api.nvim_buf_get_lines(0, vim.v.foldstart, vim.v.foldend, false)
    local indent_level = require('utils.buffers').get_indent_block(lines)
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

    local language = opts.language or vim.bo.filetype
    local option = opts.option or 'makeprg'

    local function get_args(configs, configflag, fallback_args)
        if configs and configflag then
            local config_files = vim.fs.find(configs, { upward = true, type = 'file' })
            if config_files[1] then
                return { configflag, config_files[1] }
            end
        elseif opts.global_config and is_file(opts.global_config) then
            return { configflag, opts.global_config }
        end

        return fallback_args
    end

    local cmd = { compiler }
    if opts.subcmd or opts.subcommand then
        table.insert(cmd, opts.subcmd or opts.subcommand)
    end

    local efm = opts.efm or opts.errorformat
    if not efm then
        efm = vim.go.efm
    end

    local args
    local ft_compilers = vim.F.npcall(RELOAD, 'filetypes.' .. language)
    if ft_compilers and ft_compilers[option] then
        local compiler_data = ft_compilers[option][compiler]
        if compiler_data then
            args = compiler_data
            efm = opts.efm or opts.errorformat or compiler_data.efm or compiler_data.errorformat or efm
        end
    end

    if opts.args then
        args = type(opts.args) == type {} and opts.args or { opts.args }
    end

    local extra_args = get_args(opts.configs, opts.config_flag, args or {})
    vim.list_extend(cmd, extra_args)

    local has_cmd = nvim.has.command 'CompilerSet'
    if not has_cmd then
        nvim.command.set('CompilerSet', function(command)
            -- TODO: Migrate this into opt_local API
            vim.cmd(('setlocal %s'):format(command.args))
        end, { nargs = 1, buffer = true })
    end

    vim.cmd.CompilerSet('makeprg=' .. table.concat(replace_indent(cmd), '\\ '))

    if efm then
        efm = type(efm) == type {} and table.concat(efm, ',') or efm
        -- TODO: fix this with non local options
        vim.bo.efm = efm
    end

    vim.b.current_compiler = compiler

    if not has_cmd then
        nvim.command.del('CompilerSet', true)
    end
end

function M.load_module(name)
    return vim.F.npcall(require, name)
end

function M.find_project_root(path)
    assert(type(path) == 'string' and path ~= '', ([[Not a path: "%s"]]):format(path))
    local root
    local vcs_markers = { '.git', '.svn', '.hg' }
    local dir = vim.fn.fnamemodify(path, ':p')

    for _, marker in pairs(vcs_markers) do
        root = vim.fs.find(marker, { path = dir, upward = true })[1]
        if root then
            break
        end
    end

    return not root and getcwd() or vim.fs.dirname(root)
end

function M.ignores(tool, excludes, lst)
    vim.validate {
        tool = { tool, 'string' },
        excludes = { excludes, { 'string', 'table' } },
        lst = { lst, 'boolean', true },
    }

    if lst == nil then
        lst = false
    end

    if not vim.islist(excludes) then
        excludes = { excludes }
    end

    local ignores = {
        fd = {},
        find = { '-regextype', 'egrep', '!', [[\(]] },
        rg = {},
        ag = {},
        grep = {},
        -- findstr = {},
    }

    if #excludes == 0 or not ignores[tool] then
        return lst and {} or ''
    end

    for i = 1, #excludes do
        if excludes[i] ~= '' then
            table.insert(ignores.fd, '--exclude=' .. excludes[i])
            table.insert(ignores.find, '-iwholename ' .. excludes[i])
            if i < #excludes then
                table.insert(ignores.find, '-or')
            end
            table.insert(ignores.ag, ' --ignore ' .. excludes[i])
            table.insert(ignores.grep, '--exclude=' .. excludes[i])
            table.insert(ignores.rg, ' --iglob=!' .. excludes[i])
        end
    end

    table.insert(ignores.find, [[\)]])

    -- if is_file(sys.home .. '/.config/git/ignore') then
    --     ignores.rg = ' --ignore-file '.. sys.home .. '/.config/git/ignore '
    --     ignores.fd = ' --ignore-file '.. sys.home .. '/.config/git/ignore '
    -- end

    return lst and ignores[tool] or table.concat(ignores[tool], ' ')
end

function M.grep(tool, attr, lst)
    local property = (attr and attr ~= '') and attr or 'grepprg'
    local excludes = vim.split(vim.o.backupskip, ',+')

    -- local modern_git = STORAGE.modern_git

    local greplist = {
        git = {
            grepprg = 'git --no-pager grep --column --no-color -Iin ',
            grepformat = '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m',
        },
        rg = {
            grepprg = 'rg -SHn --no-binary --trim --color=never --no-heading --column --no-search-zip --hidden '
                .. M.ignores('rg', excludes)
                .. ' ',
            grepformat = '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m',
        },
        ag = {
            grepprg = 'ag -S --follow --nogroup --nocolor --hidden --vimgrep ' .. M.ignores('ag', excludes) .. ' ',
            grepformat = '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m',
        },
        grep = {
            grepprg = 'grep -RHiIn --color=never ' .. M.ignores('grep', excludes) .. ' ',
            grepformat = '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m',
        },
        findstr = {
            grepprg = 'findstr -rspn ',
            grepformat = '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m',
        },
    }

    local grep = lst and {} or ''
    if executable(tool) and greplist[tool] ~= nil then
        grep = greplist[tool][property]
        grep = lst and vim.split(grep, '%s+') or grep
    end

    if vim.islist(grep) then
        grep = vim.tbl_filter(function(k)
            return not k:match '^%s*$'
        end, grep)
    end

    return grep
end

function M.filelist(tool, lst)
    local excludes = vim.split(vim.o.backupskip, ',+')

    -- TODO: find in windows works different
    local filetool = {
        git = 'git --no-pager ls-files -c --exclude-standard',
        fd = 'fd --type=file --hidden --color=never ' .. M.ignores('fd', excludes) .. ' ',
        rg = 'rg --no-binary --color=never --no-search-zip --hidden --trim --files '
            .. M.ignores('rg', excludes)
            .. ' ',
        ag = 'ag -l --follow --nocolor --nogroup --hidden ' .. M.ignores('ag', excludes) .. '-g ""',
        find = 'find . -type f ' .. M.ignores('find', excludes) .. " -iname '*' ",
    }

    filetool.fdfind = string.gsub(filetool.fd, '^fd', 'fdfind')

    local filelist = lst and {} or ''
    if executable(tool) and filetool[tool] ~= nil then
        filelist = filetool[tool]
    elseif tool == 'fd' and not executable 'fd' and executable 'fdfind' then
        filelist = filetool.fdfind
    end

    if #filelist > 0 then
        filelist = lst and vim.split(filelist, '%s+') or filelist
    end

    if vim.islist(filelist) then
        filelist = vim.tbl_filter(function(k)
            return not k:match '^%s*$'
        end, filelist)
    end

    return filelist
end

function M.select_filelist(is_git, lst)
    local filelist = ''

    local utils = {
        'fd',
        'rg',
        'ag',
        'find',
    }

    if executable 'git' and is_git then
        filelist = M.filelist('git', lst)
    else
        for _, lister in pairs(utils) do
            filelist = M.filelist(lister, lst)
            if #filelist > 0 then
                break
            end
        end
    end

    return filelist
end

function M.select_grep(is_git, attr, lst)
    local property = (attr and attr ~= '') and attr or 'grepprg'

    local grepprg = ''

    local utils = {
        'rg',
        'ag',
        'grep',
        'findstr',
    }

    if executable 'git' and is_git then
        grepprg = M.grep('git', property, lst)
    else
        for _, grep in pairs(utils) do
            grepprg = M.grep(grep, property, lst)
            if #grepprg > 0 then
                break
            end
        end
    end

    return grepprg
end

function M.set_grep(is_git, is_local)
    if is_local then
        vim.bo.grepprg = M.select_grep(is_git)
    else
        vim.o.grepprg = M.select_grep(is_git)
    end
    vim.o.grepformat = M.select_grep(is_git, 'grepformat')
end

function M.spelllangs(lang)
    if lang and lang ~= '' then
        vim.bo.spelllang = lang
    end
    vim.print(vim.bo.spelllang)
end

function M.set_abbrs(old_lang, new_lang)
    if old_lang == new_lang or vim.bo.spelllang ~= new_lang then
        return
    end
    local abolish = RELOAD('configs.abolish').abolish
    local capitalize = require('utils.strings').capitalize

    if nvim.has.cmd 'Abolish' then
        if abolish[old_lang] ~= nil then
            for base, _ in pairs(abolish[old_lang]) do
                vim.cmd.Abolish { args = { '-delete', '-buffer', base } }
            end
        end
        if abolish[new_lang] ~= nil then
            for base, replace in pairs(abolish[new_lang]) do
                vim.cmd.Abolish { args = { '-buffer', base, replace } }
            end
        end
    else
        if abolish[old_lang] ~= nil then
            for base, _ in pairs(abolish[old_lang]) do
                -- TODO: Use abolish transformations
                if not base:match '%{' then
                    pcall(vim.keymap.del, 'ia', base, { buffer = true })
                    pcall(vim.keymap.del, 'ia', base:upper(), { buffer = true })
                    pcall(vim.keymap.del, 'ia', capitalize(base), { buffer = true })
                end
            end
        end
        if abolish[new_lang] ~= nil then
            for base, replace in pairs(abolish[new_lang]) do
                if not base:match '%{' and not replace:match '%{' then
                    vim.keymap.set('ia', base, replace, { buffer = true })
                    vim.keymap.set('ia', base:upper(), replace:upper(), { buffer = true })
                    vim.keymap.set('ia', capitalize(base), capitalize(replace), { buffer = true })
                end
            end
        end
    end
end

function M.python(version, args)
    local py2 = vim.g.python_host_prog
    local py3 = vim.g.python3_host_prog

    local pyversion = version == 3 and py3 or py2

    if pyversion == nil or pyversion == '' then
        vim.notify(
            'Python' .. pyversion .. ' is not available in the system',
            vim.log.levels.ERROR,
            { title = 'Python' }
        )
        return -1
    end

    local split_type = vim.o.splitbelow and 'botright' or 'topleft'
    vim.cmd { cmd = 'split', args = { 'term://' .. pyversion .. ' ' .. args }, mods = { split = split_type } }
end

function M.autoformat(cmd, args)
    if vim.b.autoformat == false or vim.t.autoformat == false or vim.g.autoformat == false then
        return
    end

    local view = vim.fn.winsaveview()
    local formatter = RELOAD('jobs'):new {
        cmd = cmd,
        args = args,
        silent = true,
        callbacks_on_success = function()
            vim.cmd.checktime()
            vim.fn.winrestview(view)
            -- vim.cmd.edit()
        end,
    }
    formatter:start()
end

function M.scp_edit(opts)
    opts = opts or {}
    local host = opts.host
    local filename = opts.filename
    local path = opts.path
    local port = opts.port

    local function get_remote_file(hostname, remote_file, remote_path, host_port)
        vim.validate {
            hostname = { hostname, 'string' },
            remote_file = { remote_file, 'string' },
            remote_path = { remote_path, 'string', true },
            host_port = { host_port, { 'string', 'number' }, true },
        }

        if STORAGE.hosts[hostname] then
            host_port = STORAGE.hosts[hostname].port or host_port
            hostname = RELOAD('utils.network').get_ssh_host(hostname)
        end

        if remote_path and remote_path ~= '' then
            remote_file = remote_path .. '/' .. remote_file
        end

        local virtual_filename = ('scp://%s:%s/%s'):format(hostname, host_port or '22', remote_file)
        vim.cmd.edit(virtual_filename)
    end

    local function filename_input(hostname, remote_path, host_port)
        vim.validate {
            hostname = { hostname, 'string' },
            remote_path = { remote_path, 'string', true },
            host_port = { host_port, { 'string', 'number' }, true },
        }

        if not filename or filename == '' then
            if STORAGE.hosts[hostname] then
                host_port = STORAGE.hosts[hostname].port or host_port
                hostname = RELOAD('utils.network').get_ssh_host(hostname)
            end

            vim.ui.select(
                vim.split(
                    vim.system({ 'ssh', '-p', host_port or '22', hostname, 'ls', remote_path or '.' }, { text = true })
                        :wait().stdout,
                    '\n',
                    { trimempty = true }
                ),
                { prompt = 'Select File/Buffer attribute: ' },
                vim.schedule_wrap(function(choice)
                    if not choice then
                        vim.notify('Missing filename!', vim.log.levels.ERROR, { title = 'SCPEdit' })
                        return
                    end
                    filename = choice
                    get_remote_file(host, filename, path, port)
                end)
            )
        else
            get_remote_file(host, filename, path, port)
        end
    end

    if not host or host == '' then
        vim.ui.input({
            prompt = 'Enter hostname > ',
            completion = "customlist,v:lua.require'completions'.ssh_hosts_completion",
        }, function(input)
            if not input then
                vim.notify('Missing hostname!', vim.log.levels.ERROR, { title = 'SCPEdit' })
                return
            end
            host = input
            filename_input(host, path, port)
        end)
    elseif not filename or filename == '' then
        filename_input(host, path, port)
    else
        get_remote_file(host, filename, path, port)
    end
end

function M.typos_check(buf)
    buf = buf or vim.api.nvim_get_current_buf()
    local bufname = vim.api.nvim_buf_get_name(buf)

    local cmd = {
        'typos',
        '--format',
        'brief',
        bufname,
    }

    local title = 'Typos'
    local typos = RELOAD('jobs'):new {
        cmd = cmd,
        silent = true,
        callbacks = function(job, rc)
            local qf_utils = RELOAD 'utils.qf'
            local output = RELOAD('utils.tables').remove_empty(job:output())
            local diagnostic_ns_name = vim.api.nvim_create_namespace(title:lower())
            if rc ~= 0 and #output > 0 then
                local items = vim.fn.getqflist({ lines = output, efm = vim.go.efm }).items
                qf_utils.qf_to_diagnostic(diagnostic_ns_name, 0, items)
            elseif vim.api.nvim_buf_is_valid(buf) then
                vim.diagnostic.reset(diagnostic_ns_name, buf)
            end
        end,
    }
    typos:start()
end

function M.lint_buffer(linter, opts)
    vim.validate {
        linter = { linter, 'string' },
        opts = { opts, 'table', true },
    }

    opts = opts or {}

    local language = opts.language or opts.filetype or vim.bo.filetype
    local buf = opts.buf or vim.api.nvim_get_current_buf()
    local bufname = opts.bufname or opts.filename or vim.api.nvim_buf_get_name(buf)

    local function get_args(configs, configflag, fallback_args)
        if configs and configflag then
            local config_files = vim.fs.find(configs, { upward = true, type = 'file' })
            if config_files[1] then
                return { configflag, config_files[1] }
            end
        elseif opts.global_config and is_file(opts.global_config) then
            return { configflag, opts.global_config }
        end

        return fallback_args
    end

    local cmd = { linter }
    if opts.subcmd or opts.subcommand then
        table.insert(cmd, opts.subcmd or opts.subcommand)
    end

    local efm = opts.efm or opts.errorformat
    if not efm then
        efm = vim.go.efm
    end

    local args
    local ft_linters = vim.F.npcall(RELOAD, 'filetypes.' .. language)
    if ft_linters and ft_linters.makeprg then
        local linter_data = ft_linters.makeprg[linter]
        if linter_data then
            args = linter_data
            efm = opts.efm or opts.errorformat or linter_data.efm or linter_data.errorformat or efm
        end
    end

    if type(efm) == type {} then
        efm = table.concat(efm, '\n')
    end

    if opts.args then
        args = type(opts.args) == type {} and opts.args or { opts.args }
    end

    local extra_args = get_args(opts.configs, opts.config_flag, args or {})
    vim.list_extend(cmd, extra_args)
    table.insert(cmd, bufname)

    local title = require('utils.strings').capitalize(linter)
    local linter_job = RELOAD('jobs'):new {
        cmd = cmd,
        silent = true,
        callbacks = function(job, rc)
            local qf_utils = RELOAD 'utils.qf'
            local output = RELOAD('utils.tables').remove_empty(job:output())
            local diagnostic_ns_name = vim.api.nvim_create_namespace(title:lower())
            if rc ~= 0 and #output > 0 then
                local items = vim.fn.getqflist({ lines = output, efm = efm }).items
                qf_utils.qf_to_diagnostic(diagnostic_ns_name, 0, items)
            elseif vim.api.nvim_buf_is_valid(buf) then
                vim.diagnostic.reset(diagnostic_ns_name, buf)
            end
        end,
    }
    linter_job:start()
end

return M

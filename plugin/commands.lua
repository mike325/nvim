local sys = require 'sys'
local nvim = require 'nvim'
local executable = require('utils.files').executable
local completions = RELOAD 'completions'
local comp_utils = RELOAD 'completions.utils'

--- @class Command.Opts
--- @inlinedoc
--- @field name (string) Command name
--- @field args (string) The args passed to the command, if any
--- @field fargs (string[]) The args split by unescaped whitespace
---                         (when more than one argument is allowed), if any <f-args>
--- @field bang (boolean?) "true" if the command was executed with a ! modifier <bang>
--- @field line1 (number) The starting line of the command range <line1>
--- @field line2 (number) The final line of the command range <line2>
--- @field range (number) The number of items in the command range: 0, 1, or 2 <range>
--- @field count (number) Any count supplied <count>
--- @field reg (string) The optional register, if specified <reg>
--- @field mods (string) Command modifiers, if any <mods>
--- @field smods (table) Command modifiers in a structured format.

if sys.name ~= 'windows' then
    --- @param opts Command.Opts
    nvim.command.set('Chmod', function(opts)
        local mode = opts.args
        if not mode:match '^%d+$' then
            vim.notify('Not a valid permissions mode: ' .. mode, vim.log.levels.ERROR, { title = 'Chmod' })
            return
        end

        local utils = require 'utils.files'
        local filename = vim.api.nvim_buf_get_name(0)
        if utils.is_file(filename) then
            utils.chmod(filename, mode)
        end
    end, { nargs = 1, desc = 'Change the permission of the current buffer/file' })
end

nvim.command.set('ClearQf', function()
    require('utils.qf').clear()
end)

nvim.command.set('ClearLoc', function()
    require('utils.qf').clear(nvim.get_current_win())
end)

--- @param opts Command.Opts
nvim.command.set('Terminal', function(opts)
    require('mappings.commands').floating_terminal(opts)
end, { nargs = '*', desc = 'Show big center floating terminal window' })

nvim.command.set('MouseToggle', function()
    require('mappings.commands').toggle_mouse()
end, { desc = 'Enable/Disable Mouse support' })

--- @param opts Command.Opts
nvim.command.set('BufKill', function(opts)
    opts = opts or {}
    opts.rm_no_cwd = vim.list_contains(opts.fargs, '-cwd')
    opts.rm_empty = vim.list_contains(opts.fargs, '-empty')
    RELOAD('mappings').bufkill(opts)
end, {
    desc = 'Remove unloaded hidden buffers',
    bang = true,
    nargs = '*',
    complete = comp_utils.get_completion { '-cwd', '-empty' },
})

nvim.command.set('RelativeNumbersToggle', 'set relativenumber! relativenumber?')
nvim.command.set('ModifiableToggle', 'setlocal modifiable! modifiable?')
nvim.command.set('CursorLineToggle', 'setlocal cursorline! cursorline?')
nvim.command.set('ScrollBindToggle', 'setlocal scrollbind! scrollbind?')
nvim.command.set('HlSearchToggle', 'setlocal hlsearch! hlsearch?')
nvim.command.set('NumbersToggle', 'setlocal number! number?')
nvim.command.set('SpellToggle', 'setlocal spell! spell?')
nvim.command.set('WrapToggle', 'setlocal wrap! wrap?')

nvim.command.set('VerboseToggle', function(opts)
    local val = opts.args ~= '' and tonumber(opts.args) or nil
    if val then
        vim.o.verbose = val
    else
        vim.o.verbose = vim.o.verbose > 0 and 0 or 1
    end
    vim.lsp.log.set_level(vim.o.verbose > 0 and vim.log.levels.INFO or vim.log.levels.WARN)
    vim.print(' Verbose: ' .. (vim.o.verbose > 0 and 'true' or 'false'))
end, { desc = 'Enable/Disable verbose output', nargs = '*' })

--- @param opts Command.Opts
nvim.command.set('Trim', function(opts)
    RELOAD('mappings').trim(opts)
end, {
    desc = 'Enable/Disable auto trim of trailing white spaces',
    nargs = '?',
    complete = completions.toggle,
    bang = true,
})

if executable 'gonvim' then
    nvim.command.set(
        'GonvimSettngs',
        "execute('edit ~/.gonvim/setting.toml')",
        { desc = "Shortcut to edit gonvim's setting.toml" }
    )
end

--- @param opts Command.Opts
nvim.command.set('FileType', function(opts)
    vim.bo.filetype = opts.args ~= '' and opts.args or 'text'
end, { nargs = '?', complete = 'filetype', desc = 'Set filetype' })

--- @param opts Command.Opts
nvim.command.set('FileFormat', function(opts)
    vim.bo.filetype = opts.args ~= '' and opts.args or 'unix'
end, {
    nargs = '?',
    complete = comp_utils.get_completion(vim.split(vim.go.fileformats, ',')),
    desc = 'Set file format',
})

--- @param opts Command.Opts
nvim.command.set('SpellLang', function(opts)
    RELOAD('utils.functions').spelllangs(opts.args)
end, { nargs = '?', complete = completions.spells, desc = 'Enable/Disable spelling' })

--- @param opts Command.Opts
nvim.command.set('Qopen', function(opts)
    local size = tonumber(opts.args)
    if size then
        size = size + 1
    end
    require('utils.qf').toggle { size = size }
end, { nargs = '?', desc = 'Open quickfix' })

--- @param opts Command.Opts
nvim.command.set('MoveFile', function(opts)
    RELOAD('mappings').move_file(opts)
end, { bang = true, nargs = 1, complete = 'file', desc = 'Move current file to another location' })

--- @param opts Command.Opts
nvim.command.set('RenameFile', function(opts)
    local filename = vim.api.nvim_buf_get_name(0)
    local dirname = vim.fs.dirname(filename)
    RELOAD('utils.files').rename(filename, vim.fs.joinpath(dirname, opts.args), opts.bang)
end, { bang = true, nargs = 1, complete = 'file', desc = 'Rename current file to another location' })

--- @param opts Command.Opts
nvim.command.set('Mkdir', function(opts)
    require('utils.files').mkdir(opts.args, opts.bang)
end, { bang = true, nargs = 1, complete = 'dir', desc = 'mkdir wrapper' })

--- @param opts Command.Opts
nvim.command.set('RemoveFile', function(opts)
    local target = opts.args ~= '' and opts.args or vim.api.nvim_buf_get_name(0)
    local utils = require 'utils.files'
    utils.delete(utils.realpath(target), opts.bang)
end, { bang = true, nargs = '?', complete = 'file', desc = 'Remove current file and close the window' })

--- @param opts Command.Opts
nvim.command.set('CopyFile', function(opts)
    local utils = require 'utils.files'
    local src = vim.api.nvim_buf_get_name(0)
    local dest = opts.fargs[1]
    utils.copy(src, dest, opts.bang)
end, { bang = true, nargs = 1, complete = 'file', desc = 'Copy current file to another location' })

--- @param opts Command.Opts
nvim.command.set('Grep', function(opts)
    local search = opts.fargs[#opts.fargs]
    opts.fargs[#opts.fargs] = nil

    local args = opts.fargs
    if #args > 0 then
        local grepprg = vim.bo.grepprg ~= '' and vim.bo.grepprg or vim.o.grepprg
        grepprg = vim.split(grepprg, '%s+', { trimempty = true })

        vim.list_extend(args, vim.list_slice(grepprg, 2, #grepprg))
    end
    RELOAD('utils.async').grep { search = search, args = args }
end, { nargs = '+', complete = 'file' })

--- @param opts Command.Opts
nvim.command.set('LGrep', function(opts)
    local search = opts.fargs[#opts.fargs]
    opts.fargs[#opts.fargs] = nil

    local args = opts.fargs
    if #args > 0 then
        local grepprg = vim.bo.grepprg ~= '' and vim.bo.grepprg or vim.o.grepprg
        grepprg = vim.split(grepprg, '%s+', { trimempty = true })

        vim.list_extend(args, vim.list_slice(grepprg, 2, #grepprg))
    end

    RELOAD('utils.async').grep { loc = true, search = search, args = args }
end, { nargs = '+', complete = 'file' })

local function find_files(opts, win)
    local title = (not win and 'C' or 'L') .. 'Find'
    local args = {
        args = opts.fargs,
        target = opts.args,
        cb = function(results)
            if #results > 0 then
                RELOAD('utils.qf').dump_files(results, {
                    open = true,
                    jump = false,
                    title = title,
                }, win)
            else
                vim.notify('No files matching: ' .. opts.fargs[#opts.fargs], vim.log.levels.ERROR, { title = title })
            end
        end,
    }
    RELOAD('mappings').find(args)
end

--- @param opts Command.Opts
nvim.command.set('CFind', function(opts)
    find_files(opts)
end, { bang = true, nargs = '+', complete = 'file', desc = 'Async and recursive :find' })

--- @param opts Command.Opts
nvim.command.set('LFind', function(opts)
    find_files(opts, nvim.get_current_win())
end, { bang = true, nargs = '+', complete = 'file', desc = 'Async and recursive :lfind' })

--- @param opts Command.Opts
nvim.command.set('Make', function(opts)
    RELOAD('utils.async').makeprg { args = opts.fargs, progress = true }
end, { nargs = '*', desc = 'Async execution of current makeprg' })

--- @param opts Command.Opts
nvim.command.set('Exec', function(opts)
    local cmd = opts.fargs
    if opts.fargs[1] == '-shell' then
        cmd = { vim.go.shell }
        local flags = vim.split(vim.go.shellcmdflag, ' ', { trimempty = true })
        vim.list_extend(cmd, flags)
        table.insert(cmd, table.concat(vim.iter(opts.fargs):slice(2, #opts.fargs):totable(), ' '))
    end

    RELOAD('utils.async').makeprg {
        makeprg = cmd,
        notify = true,
        open = true,
        jump = false,
    }
end, { bang = true, nargs = '+', complete = 'shellcmd', desc = 'Async execution of the given cmd' })

nvim.command.set('DumpOutput', function(_)
    if ASYNC.output:peek() then
        local outputs = vim.iter(ASYNC.output()):totable()
        local items = vim.iter(outputs)
            :map(function(item)
                return string.format('%s - %s', item.code, table.concat(item.cmd, ' '))
            end)
            :totable()
        vim.ui.select(items, { prompt = 'Select output:' }, function(choice, idx)
            if choice then
                local output = outputs[idx].stdout ~= '' and outputs[idx].stdout or outputs[idx].stderr
                local data = vim.iter(vim.split(output, '\n', { trimempty = true }))
                    :filter(function(line)
                        return not line:match '^%s*$'
                    end)
                    :map(function(line)
                        return (line:gsub('\t', string.rep(' ', 4)))
                    end)
                    :totable()
                if #data > 0 then
                    require('utils.qf').set_list { items = data, open = true, jump = false }
                else
                    vim.notify('No data to dump', vim.log.levels.WARN, { title = 'Dump' })
                end
            end
        end)
    end
end, { nargs = '*', desc = 'Dump the output of the last commands' })

if executable 'scp' then
    --- @param opts Command.Opts
    nvim.command.set('SendFile', function(opts)
        RELOAD('mappings').remote_file(opts.args, true)
    end, {
        nargs = '*',
        complete = completions.ssh_hosts_completion,
        desc = 'Send current file to a remote location',
    })

    --- @param opts Command.Opts
    nvim.command.set('GetFile', function(opts)
        RELOAD('mappings').remote_file(opts.args, false)
    end, {
        nargs = '*',
        complete = completions.ssh_hosts_completion,
        desc = 'Get current file from a remote location',
    })

    --- @param opts Command.Opts
    nvim.command.set('SCPEdit', function(opts)
        local args = {
            host = opts.fargs[1],
            filename = opts.fargs[2],
        }
        RELOAD('utils.functions').scp_edit(args)
    end, { nargs = '*', desc = 'Edit remote file using scp', complete = completions.ssh_hosts_completion })
end

--- @param opts Command.Opts
nvim.command.set('Scratch', function(opts)
    RELOAD('mappings').scratch_buffer(opts)
end, {
    nargs = '?',
    complete = 'filetype',
    desc = 'Create a scratch buffer of the current or given filetype',
})

nvim.command.set('ConcealLevel', function()
    local conncall = vim.wo.conceallevel or 0
    vim.wo.conceallevel = conncall > 0 and 0 or 2
end, { desc = 'Toggle conceal level between 0 and 2' })

--- @param opts Command.Opts
nvim.command.set('Messages', function(opts)
    RELOAD('mappings').messages(opts)
end, { nargs = '?', complete = 'messages', desc = 'Populate quickfix with the :messages list' })

if executable 'pre-commit' then
    --- @param opts Command.Opts
    nvim.command.set('PreCommit', function(opts)
        local efm = {
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

        local args = opts.fargs
        local cmd = { 'pre-commit' }
        if opts.bang and #args == 0 then
            args = { 'run', '--all' }
        end
        vim.list_extend(cmd, args)
        require('async').report(cmd, { open = true, jump = true, efm = efm, progress = true })
    end, { bang = true, nargs = '*' })
end

nvim.command.set('Repl', function(opts)
    RELOAD('mappings').repl(opts)
end, { nargs = '*', complete = 'filetype' })

-- TODO: May need to add a check for "zoom" executable but this should work even inside WSL
--- @param opts Command.Opts
nvim.command.set('Zoom', function(opts)
    RELOAD('mappings').zoom_links(opts)
end, { nargs = 1, complete = completions.zoom_links, desc = 'Open Zoom call in a specific room' })

--- @param opts Command.Opts
nvim.command.set('Edit', function(opts)
    RELOAD('mappings.commands').edit(opts)
end, { nargs = '*', complete = 'file', desc = 'Open multiple files' })

--- @param opts Command.Opts
nvim.command.set('DiffFiles', function(opts)
    RELOAD('mappings').diff_files(opts)
end, { nargs = '+', complete = 'file', desc = 'Open a new tab in diff mode with the given files' })

--- @param opts Command.Opts
nvim.command.set('Reloader', function(opts)
    local get_files = function(path)
        local files = {}
        path = vim.fs.joinpath(vim.fn.stdpath 'config', path)
        for fname, ftype in vim.fs.dir(path) do
            if ftype == 'file' then
                local basename = require('utils.files').filename(vim.fs.basename(fname))
                files[basename] = vim.fs.joinpath(path, fname)
            end
        end
        return files
    end

    local plugins = get_files 'plugin'
    local after_plugins = get_files 'after/plugin'
    local files = {}
    if opts.args == 'all' or opts.args == '' then
        vim.list_extend(files, vim.tbl_values(plugins))
        vim.list_extend(files, vim.tbl_values(after_plugins))
    elseif plugins[opts.args] or after_plugins[opts.args] then
        if plugins[opts.args] then
            table.insert(files, plugins[opts.args])
        end

        if after_plugins[opts.args] then
            table.insert(files, after_plugins[opts.args])
        end
    else
        vim.notify('Invalid config name: ' .. opts.args, vim.log.levels.ERROR, { title = 'Reloader' })
        return
    end

    RELOAD('mappings').reload_configs(files)
end, {
    nargs = '?',
    desc = 'Change between git grep and the best available alternative',
    complete = completions.reload_configs,
})

--- @param opts Command.Opts
nvim.command.set('AutoFormat', function(opts)
    RELOAD('mappings').autoformat(opts)
end, { nargs = '?', complete = completions.toggle, bang = true, desc = 'Toggle Autoformat autocmd' })

nvim.command.set('Wall', function()
    local modified = vim.tbl_filter(function(buf)
        return vim.bo[buf].modified and not vim.bo[buf].readonly
    end, vim.api.nvim_list_bufs())
    for _, buf in ipairs(modified) do
        vim.api.nvim_buf_call(buf, function()
            vim.cmd.update { mods = { noautocmd = true } }
        end)
    end
end, { desc = 'Save all modified buffers' })

nvim.command.set('AlternateGrep', function()
    RELOAD('mappings').alternate_grep()
end, { nargs = 0, desc = 'Change between git grep and the best available alternative' })

--- @param opts Command.Opts
nvim.command.set('Alternate', function(opts)
    RELOAD('mappings').alternate(opts)
end, { nargs = 0, desc = 'Alternate between files', bang = true })

--- @param opts Command.Opts
nvim.command.set('A', function(opts)
    RELOAD('mappings').alternate(opts)
end, { nargs = 0, desc = 'Alternate between files', bang = true })

--- @param opts Command.Opts
nvim.command.set('AlternateTest', function(opts)
    RELOAD('mappings').alternate_test(opts)
end, { nargs = 0, desc = 'Alternate between source and test files', bang = true })

--- @param opts Command.Opts
nvim.command.set('T', function(opts)
    RELOAD('mappings').alternate_test(opts)
end, { nargs = 0, desc = 'Alternate between source and test files', bang = true })

--- @param opts Command.Opts
nvim.command.set('NotificationServer', function(opts)
    opts.enable = opts.args == 'enable' or opts.args == ''
    RELOAD('servers.notifications').start_server(opts)
end, { nargs = 1, complete = completions.toggle, bang = true })

--- @param opts Command.Opts
nvim.command.set('RemoveEmpty', function(opts)
    local removed = RELOAD('utils.buffers').remove_empty(opts)
    if removed > 0 then
        print(' ', removed, ' buffers cleaned!')
    end
end, { nargs = 0, bang = true, desc = 'Remove empty buffers' })

nvim.command.set('Qf2Diag', function()
    RELOAD('utils.qf').qf_to_diagnostic()
end)

nvim.command.set('Loc2Diag', function()
    RELOAD('utils.qf').qf_to_diagnostic(nil, true)
end)

--- @param opts Command.Opts
nvim.command.set('VirtualLines', function(opts)
    local action = opts.args:gsub('^%-+', '')

    local options = {
        virtual_text = not opts.bang,
    }

    if nvim.has { 0, 11 } then
        options.virtual_lines = not opts.bang
    end

    if action == 'text' then
        options.virtual_lines = nil
        if not opts.bang then
            options.virtual_text = {
                spacing = 2,
                prefix = '❯',
            }
        end
    elseif action == 'lines' then
        options.virtual_text = nil
    elseif not opts.bang and nvim.has { 0, 11 } then
        options.virtual_text = false
    end

    vim.diagnostic.config(options)
end, {
    nargs = '?',
    bang = true,
    desc = 'Toggle Virtual lines and virtual text',
    complete = completions.diagnostics_virtual_lines,
})

--- @param opts Command.Opts
nvim.command.set('Diagnostics', function(opts)
    local action = opts.fargs[1]:gsub('^%-+', '')
    local all_namespaces = vim.iter(vim.diagnostic.get_namespaces()):fold({}, function(diag_ns, ns)
        diag_ns[ns.name] = ns
        diag_ns[ns.name].id = vim.api.nvim_create_namespace(ns.name)
        return diag_ns
    end)

    local namespaces = vim.list_slice(opts.fargs, 2, #opts.fargs)
    if #namespaces == 0 then
        namespaces = vim.tbl_keys(all_namespaces)
    end

    if action == 'dump' then
        local severity = namespaces[1]
        table.remove(namespaces, 1)
        if severity then
            if not vim.log.levels[severity] then
                error(debug.traceback(string.format('Invalid severity: %s', vim.inspect(severity))))
            end
            severity = { min = severity }
        end
        if opts.bang then
            vim.diagnostic.setqflist { severity = severity }
            vim.cmd.wincmd 'J'
        else
            vim.diagnostic.setloclist { severity = severity }
        end
    else
        action = action == 'clear' and 'reset' or action
        if not vim.diagnostic[action] then
            error(debug.traceback(string.format('Invalid diagnostic action: %s', action)))
        end
        local buf = not opts.bang and vim.api.nvim_get_current_buf() or nil
        for ns in vim.iter(namespaces) do
            local ns_id = all_namespaces[ns].id
            if action == 'enable' or action == 'disable' then
                vim.diagnostic[action](buf, ns_id)
            else
                vim.diagnostic[action](ns_id, buf)
            end
        end
    end
end, {
    bang = true,
    nargs = '+',
    desc = 'Manage Diagnostics actions on NS and buffers',
    complete = completions.diagnostics_completion,
})

nvim.command.set('KillJob', function(_)
    -- local pid = opts.args ~= '' and opts.args or nil
    RELOAD('mappings.commands').kill_task()
end, { nargs = '?', bang = true, desc = 'Kill the selected job' })

--- @param opts Command.Opts
nvim.command.set('Progress', function(opts)
    RELOAD('mappings').show_job_progress(opts)
end, { nargs = 1, desc = 'Show progress of the selected job', complete = completions.background_jobs })

--- @param opts Command.Opts
nvim.command.set('CLevel', function(opts)
    opts.level = opts.args
    RELOAD('utils.qf').filter_qf_diagnostics(opts)
end, {
    nargs = 1,
    bang = true,
    desc = 'Filter the quickfix by diagnostcis level',
    complete = completions.diagnostics_level,
})

--- @param opts Command.Opts
nvim.command.set('LLevel', function(opts)
    opts.win = vim.api.nvim_get_current_win()
    opts.level = opts.args
    RELOAD('utils.qf').filter_qf_diagnostics(opts)
end, {
    nargs = 1,
    bang = true,
    desc = 'Filter the location list by diagnostcis level',
    complete = completions.diagnostics_level,
})

if executable 'git' then
    local qf_completion_items = { '-hunks', '-qf', '-open', '-background' }

    --- @param opts Command.Opts
    nvim.command.set('OpenChanges', function(opts)
        local action = 'open'
        local revision
        for _, arg in ipairs(opts.fargs) do
            if arg:match '^%-' then
                action = (arg:gsub('^%-+', ''))
            else
                revision = arg
            end
        end

        if opts.bang and (not revision or revision == '') then
            vim.notify(
                'Missing revision, opening changes from latest HEAD',
                vim.log.levels.WARN,
                { title = 'OpenChanges' }
            )
            revision = nil
        end

        RELOAD('utils.buffers').open_changes { action = action, revision = revision, clear = true }
    end, {
        bang = true,
        nargs = '*',
        complete = comp_utils.get_completion(qf_completion_items),
        desc = 'Open all modified files in the current git repository',
    })

    --- @param opts Command.Opts
    nvim.command.set('OpenConflicts', function(opts)
        RELOAD('utils.buffers').open_conflicts(opts)
    end, {
        nargs = '?',
        complete = comp_utils.get_completion(qf_completion_items),
        desc = 'Open conflict files in the current git repository',
    })
end

-- NOTE: This could be smarter and list the hunks in the QF
nvim.command.set('ModifiedDump', function(_)
    RELOAD('utils.qf').dump_files(
        vim.tbl_filter(function(buf)
            return vim.bo[buf].modified
        end, vim.api.nvim_list_bufs()),
        { open = true }
    )
end, {
    desc = 'Dump all unsaved files into the QF',
})

nvim.command.set('Qf2Loc', function(_)
    local qfutils = RELOAD 'utils.qf'
    qfutils.qf_loclist_switcher { loc = true }
end, { desc = "Move the current QF to the window's location list" })

nvim.command.set('Loc2Qf', function(_)
    local qfutils = RELOAD 'utils.qf'
    qfutils.qf_loclist_switcher()
end, { desc = "Move the current window's location list to the QF" })

--- @param opts Command.Opts
nvim.command.set('TrimWhites', function(opts)
    RELOAD('utils.files').trimwhites(nvim.get_current_buf(), { opts.line1 - 1, opts.line2 })
end, { range = '%', desc = 'Alias to <,>s/\\s\\+$//g' })

nvim.command.set('ParseSSHConfig', function(_)
    local hosts = RELOAD('threads.parsers').sshconfig()
    for host, attrs in pairs(hosts) do
        STORAGE.hosts[host] = attrs
    end
end, { desc = 'Parse SSH config' })

--- @param opts Command.Opts
nvim.command.set('VNC', function(opts)
    RELOAD('mappings.commands').vnc(opts.args, { '-Quality=high' })
end, { complete = completions.ssh_hosts_completion, nargs = 1, desc = 'Open a VNC connection to the given host' })

if executable 'gh' then
    --- @param opts Command.Opts
    nvim.command.set('PRCreate', function(opts)
        if #opts.fargs > 0 then
            opts.fargs = vim.list_extend({ '--reviewer' }, { table.concat(opts.fargs, ',') })
        end
        if not opts.bang then
            table.insert(opts.fargs, '--draft')
        end
        opts.args = table.concat(opts.fargs, ' ')
        RELOAD('utils.gh').create_pr({ args = opts.fargs }, function(_)
            vim.notify('PR created! ', vim.log.levels.INFO, { title = 'GH' })
        end)
    end, {
        nargs = '*',
        complete = completions.reviewers,
        bang = true,
        desc = 'Open PR with the given reviewers defined in reviewers.json',
    })

    --- @param opts Command.Opts
    nvim.command.set('PrOpen', function(opts)
        local gh = RELOAD 'utils.gh'

        local pr
        if opts.args ~= '' then
            pr = tonumber(opts.args)
        elseif not opts.bang then
            gh.list_repo_pr({}, function(list_pr)
                local titles = vim.tbl_map(function(pull_request)
                    return pull_request.title
                end, vim.deepcopy(list_pr))
                vim.ui.select(
                    titles,
                    { prompt = 'Select PR: ' },
                    vim.schedule_wrap(function(choice)
                        if choice ~= '' then
                            local pr_id = vim.tbl_filter(function(pull_request)
                                return pull_request.title == choice
                            end, list_pr)[1].number
                            gh.open_pr(pr_id)
                        end
                    end)
                )
            end)
            return
        end

        gh.open_pr(pr)
    end, {
        nargs = 0,
        bang = true,
        desc = 'Open PR in the browser',
    })

    --- @param opts Command.Opts
    nvim.command.set('PrReady', function(opts)
        local is_ready = true
        if opts.args == 'draft' then
            is_ready = false
        end
        RELOAD('utils.gh').pr_ready(is_ready, function(_)
            local msg = ('PR move to %s'):format(opts.args == '' and 'ready' or opts.args)
            vim.notify(msg, vim.log.levels.INFO, { title = 'GH' })
        end)
    end, {
        nargs = '?',
        complete = completions.gh_pr_ready,
        desc = 'Set PR to ready or to draft',
    })

    --- @param opts Command.Opts
    nvim.command.set('EditReviewers', function(opts)
        local reviewers = { table.concat(opts.fargs, ',') }
        local action = opts.fargs[1]:gsub('^%-+', '')
        local command = action == 'add' and '--add-reviewer' or '--remove-reviewer'
        opts.fargs = vim.list_extend({ command }, reviewers)
        opts.args = table.concat(opts.fargs, ' ')
        RELOAD('utils.gh').edit_pr({ args = opts.fargs }, function(_)
            local msg = ('Reviewers %s were %s'):format(action .. 'ed', table.concat(reviewers, ''))
            vim.notify(msg, vim.log.levels.INFO, { title = 'GH' })
        end)
    end, {
        nargs = '+',
        complete = completions.gh_edit_reviewers,
        bang = true,
        desc = 'Add/Remove reviewers defined in reviewers.json',
    })
end

--- @param opts Command.Opts
nvim.command.set('Argdo', function(opts)
    RELOAD('utils.arglist').exec(opts.args)
end, { nargs = '+', desc = 'argdo but without the final Press enter message', complete = 'command' })

--- @param opts Command.Opts
nvim.command.set('Qf2Arglist', function(opts)
    RELOAD('utils.qf').qf_to_arglist { clear = opts.bang }
end, { bang = true, desc = 'Dump qf files to the arglist' })

--- @param opts Command.Opts
nvim.command.set('Loc2Arglist', function(opts)
    RELOAD('utils.qf').qf_to_arglist { loc = true, clear = opts.bang }
end, { bang = true, desc = 'Dump loclist files to the arglist' })

nvim.command.set('Arglist2Qf', function()
    RELOAD('utils.qf').dump_files(vim.fn.argv())
end, { desc = 'Dump loclist files to the arglist' })

nvim.command.set('Arglist2Loc', function()
    RELOAD('utils.qf').dump_files(vim.fn.argv(), { win = 0 })
end, { desc = 'Dump loclist files to the arglist' })

nvim.command.set('ArgEdit', function(opts)
    RELOAD('utils.arglist').edit(opts.args)
end, {
    nargs = '?',
    complete = comp_utils.get_completion(function()
        return vim.iter(vim.fn.argv()):map(vim.fs.basename):totable()
    end),
    desc = 'Edit a file in the arglist',
})

nvim.command.set('ArgClear', function(opts)
    RELOAD('utils.arglist').clear(opts.bang)
end, { nargs = 0, bang = true, desc = 'Delete all or invalid arguments' })

--- @param opts Command.Opts
nvim.command.set('ArgAddBuf', function(opts)
    local argadd = RELOAD('utils.arglist').add
    local args = opts.fargs
    if #args == 0 then
        table.insert(args, '%')
    elseif #args == 1 and args[1]:match '%*' then
        local pattern = vim.glob.to_lpeg(args[1])
        local cwd = vim.pesc(vim.uv.cwd() .. '/')
        local buffers = vim.iter(vim.api.nvim_list_bufs())
            :map(function(buf)
                return (vim.api.nvim_buf_get_name(buf):gsub(cwd, ''))
            end)
            :filter(function(bufname)
                return bufname ~= ''
                    and not bufname:match '^%w+://'
                    and not bufname:match '^Mini%w+:.*'
                    and vim.re.match(bufname, pattern)
            end)
        args = buffers:totable()
    end
    argadd(args, opts.bang)
end, { bang = true, nargs = '*', complete = completions.buflist, desc = 'Add buffers to the arglist' })

--- @param opts Command.Opts
nvim.command.set('Marks2Arglist', function(opts)
    RELOAD('utils.marks').marks_to_arglist { clear = opts.bang }
end, { bang = true, desc = 'Dump global marks files to the arglist' })

nvim.command.set('Marks2Quickfix', function(_)
    RELOAD('utils.marks').marks_to_quickfix()
end, { bang = true, desc = 'Dump global marks files to the quickfix' })

nvim.command.set('Marks2LocList', function(_)
    RELOAD('utils.marks').marks_to_quickfix { win = 0 }
end, { bang = true, desc = 'Dump global marks files to the loclist' })

--- @param opts Command.Opts
nvim.command.set('ClearMarks', function(opts)
    RELOAD('utils.marks').clear { force = opts.bang }
    if not opts.bang then
        vim.notify('Ghost marks removed', vim.log.levels.INFO, { title = 'ClearMarks' })
    elseif opts.bang then
        vim.notify('All global marks cleared', vim.log.levels.INFO, { title = 'ClearMarks' })
    end
end, { bang = true, desc = 'Remove global marks of inexistent files' })

--- @param opts Command.Opts
nvim.command.set('DumpMarks', function(opts)
    if RELOAD('utils.marks').dump_marks { file = opts.args } then
        vim.notify('Marks dumped to marks.json', vim.log.levels.INFO, { title = 'Marks' })
    end
end, { nargs = '?', complete = 'file', desc = 'Dump global marks in a local json file' })

--- @param opts Command.Opts
nvim.command.set('LoadMarks', function(opts)
    if RELOAD('utils.marks').load_marks { file = opts.args } then
        vim.notify('Marks Loaded', vim.log.levels.INFO, { title = 'Marks' })
    end
end, { nargs = '?', complete = 'file', desc = 'Load global marks from json file' })

nvim.command.set('RemoveForeignMarks', function()
    local utils = require 'utils.files'
    local deleted_marks = 0
    local marks = RELOAD('utils.marks').get_global_marks()
    if next(marks) ~= nil then
        local cwd = vim.pesc(vim.uv.cwd() or '.')
        for letter, mark in pairs(marks) do
            local filename = (mark.filename:gsub(cwd, ''))
            if utils.is_file(filename) then
                filename = utils.realpath(filename)
            end
            if not utils.is_file(filename) or not filename:match('^' .. cwd) then
                vim.api.nvim_del_mark(letter)
                deleted_marks = deleted_marks + 1
            end
        end
    end
    if deleted_marks > 0 then
        vim.notify('Deleted marks not in the CWD: ' .. deleted_marks, vim.log.levels.INFO, { title = 'RemoveMarks' })
    end
end, { desc = 'Remove all global marks that are outside of the CWD' })

nvim.command.set('Oldfiles', function()
    vim.ui.select(
        vim.v.oldfiles,
        { prompt = 'Select file: ' },
        vim.schedule_wrap(function(choice)
            if choice then
                vim.cmd.edit(choice)
            end
        end)
    )
end, { nargs = 0, desc = 'Edit a file from oldfiles' })

if not vim.g.bare then
    nvim.command.set('SetupNeovim', function()
        nvim.setup(true)
    end, { nargs = 0, desc = 'Initial Neovim setup' })
end

--- @param opts Command.Opts
nvim.command.set('RemoteTermdebug', function(opts)
    RELOAD('utils.debug').remote_attach_debugger { hostname = opts.args }
end, {
    nargs = 1,
    desc = 'Start a Termdebug remote session using gdbserver',
    complete = completions.ssh_hosts_completion,
})

nvim.command.set('ClearBufNS', function(opts)
    local ns = vim.api.nvim_create_namespace(opts.args)
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
end, {
    nargs = 1,
    desc = 'Clear buffer namespace',
    complete = completions.namespaces,
})

nvim.command.set('SetupMake', function()
    RELOAD('filetypes.make.utils').copy_template()
    RELOAD 'filetypes.make.mappings'
end, { nargs = 0, desc = 'Copy Makefile template into cwd' })

-- TODO: Support make and cmake
nvim.command.set('InitCppProject', function()
    local utils = require 'utils.files'

    for _, dir in ipairs { 'src', 'include' } do
        utils.mkdir(dir)
    end

    local config_path = vim.fn.stdpath('config'):gsub('\\', '/')
    local templates = {
        ['main.cpp'] = './src/main.cpp',
        ['compile_flags.txt'] = 'compile_flags.txt',
        ['clang-tidy'] = '.clang-tidy',
        ['clang-format'] = '.clang-format',
    }

    for src, dest in pairs(templates) do
        local template = string.format('%s/skeletons/%s', config_path, src)
        utils.copy(template, dest)
    end

    RELOAD 'filetypes.cpp.mappings'

    require('utils.git').exec.init()

    if executable 'make' then
        RELOAD('filetypes.make.utils').copy_template()
        RELOAD 'filetypes.make.mappings'
    end

    vim.cmd.edit 'src/main.cpp'
end, { force = true, desc = 'Initialize a C/C++ project' })

if
    executable 'plantuml'
    or (executable 'java' and require('utils.files').is_file(vim.fn.stdpath 'state' .. '/utils/plantuml.jar'))
then
    nvim.command.set('ToggleAutoUMLRender', function()
        if vim.b.auto_render_uml == nil then
            vim.b.auto_render_uml = true
        end
        vim.b.auto_render_uml = not vim.b.auto_render_uml
        vim.notify(
            'PlantUML Render ' .. (vim.b.auto_render_uml and 'Enabled' or 'Disabled'),
            vim.log.levels.INFO,
            { title = 'AutoRenderUML' }
        )
    end, { desc = 'Disable/Enable Auto PlantUML render' })
end

--- @param opts Command.Opts
nvim.command.set('EditPathScript', function(opts)
    local cmd_str = opts.args
    local cmd = vim.fn.exepath(cmd_str)
    if cmd == '' then
        vim.notify(('Cannot find: %s in PATH'):format(cmd_str), vim.log.levels.ERROR, { title = 'EditPathScript' })
        return
    end
    vim.cmd.edit(cmd)
end, { nargs = 1, complete = 'shellcmd', desc = 'Open a script located somewhere in path' })

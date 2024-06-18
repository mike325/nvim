local M = {}

function M.get_remote_processes(opts, cb)
    vim.validate {
        opts = { opts, 'table', true },
        cb = { cb, 'function', true },
    }
    opts = opts or {}

    local filter = opts.filter or ''
    local host = opts.hostname

    local function parse_output(output)
        local processes = {}
        for _, process_str in ipairs(output) do
            local process = {}
            for s in string.gmatch(process_str, '([^%s]+)') do
                table.insert(process, s)
            end

            if #process >= 11 then
                local args = {}
                if #process > 11 then
                    args = vim.list_slice(process, 12, #process)
                end
                local skip = false
                local awk_filter = vim.pesc(filter)
                for _, arg in ipairs(args) do
                    if arg:match(awk_filter) then
                        skip = true
                        break
                    end
                end

                if not skip then
                    table.insert(processes, {
                        user = process[1],
                        pid = process[2],
                        process = process[11],
                        args = args,
                    })
                end
            end
        end

        return processes
    end

    host = RELOAD('utils.network').get_ssh_host(host)
    if not host then
        return
    end
    local remote_cmd = {
        'ssh',
        host,
        string.format("ps aux | awk '/%s/{ print $0}'", filter),
    }

    if cb then
        RELOAD('utils.functions').async_execute {
            cmd = remote_cmd,
            progress = false,
            auto_close = true,
            silent = true,
            title = 'GetRemoteProcess',
            callbacks_on_success = function(job)
                if cb then
                    cb(parse_output(job:output()))
                end
            end,
        }
        return
    end
    return parse_output(vim.fn.systemlist(remote_cmd))
end

function M.remote_attach_debugger(opts)
    vim.validate {
        opts = { opts, 'table', true },
    }
    opts = opts or {}

    local host = RELOAD('utils.network').get_ssh_host(opts.hostname)
    if not host then
        return
    end

    M.get_remote_processes({ hostname = host, filter = opts.filter }, function(processes)
        local process_lst = vim.tbl_map(function(p)
            return string.format('%s %s', p.process, table.concat(p.args, ' '))
        end, processes)
        vim.ui.select(
            process_lst,
            { prompt = 'Select a process > ' },
            vim.schedule_wrap(function(choice, idx)
                if choice and choice ~= '' then
                    local process = processes[idx]
                    local remote_gdb = ('target remote | ssh -T %s gdbserver - --attach %s'):format(host, process.pid)
                    -- TODO: Load local binary ?
                    vim.cmd.Termdebug()
                    vim.fn.chansend(vim.b.terminal_job_id, { remote_gdb, '\n' })
                    vim.cmd.startinsert()
                end
            end)
        )
    end)
end

function M.remote_dap_attach(host, pid, filemap, env)
    vim.validate {
        host = { host, 'string', true },
        pid = { pid, 'string', true },
        filemap = { filemap, 'table', true },
        env = { env, 'table', true },
    }
    local dap = vim.F.npcall(require, 'dap')
    if not dap then
        return false
    end

    host = RELOAD('utils.network').get_ssh_host(host)
    if not host then
        return
    end

    local function attach_dap(process_id)
        dap.run {
            name = 'Remote GDB attach',
            type = 'cppdbg',
            request = 'attach',
            program = string.format('/proc/%s/exe', process_id),
            processId = process_id,
            debuggerPath = vim.fn.exepath 'gdb',
            cwd = '${workspaceFolder}',
            pipeTransport = {
                debuggerPath = '/usr/bin/gdb',
                pipeProgram = '/usr/bin/ssh',
                pipeArgs = {
                    '-q',
                    '-o StrictHostKeyChecking=no',
                    host,
                },
                pipeCwd = '',
            },
            environment = env,
            sourceFileMap = filemap,
            MIMode = 'gdb',
            customLaunchSetupCommands = {
                {
                    description = 'Enable pretty-printing for gdb',
                    text = '-enable-pretty-printing',
                    ignoreFailures = true,
                },
                {
                    description = 'Set Disassembly Flavor to Intel',
                    text = '-gdb-set disassembly-flavor intel',
                    ignoreFailures = true,
                },
                {
                    description = 'Source code location',
                    text = 'source .gdbinit',
                    ignoreFailures = true,
                },
            },
        }
    end

    if not pid then
        M.get_remote_processes({ hostname = host }, function(processes)
            local process_lst = vim.tbl_map(function(p)
                return string.format('%s %s', p.process, table.concat(p.args, ' '))
            end, processes)
            vim.ui.select(
                process_lst,
                { prompt = 'Select a process > ' },
                vim.schedule_wrap(function(choice, idx)
                    if choice and choice ~= '' then
                        local process = processes[idx]
                        attach_dap(process.pid)
                    end
                end)
            )
        end)
    else
        attach_dap(pid)
    end
end

function M.local_launch_dap(program, args, env, stopAtEntry)
    vim.validate {
        program = { program, { 'string', 'function' }, true },
        args = { args, 'table', true },
        env = { env, 'table', true },
        stopAtEntry = { stopAtEntry, 'boolean', true },
    }

    local dap = vim.F.npcall(require, 'dap')
    if not dap or not require('utils.files').executable('gdb') then
        return false
    end

    if env and not vim.islist(env) then
        local tmp = {}
        for var, val in pairs(env) do
            table.insert(tmp, {name = var, value = val})
        end
        env = tmp
    end

    if stopAtEntry == nil then
        stopAtEntry = true
    end

    dap.run {
        name = 'Local launch GDB',
        type = 'cppdbg',
        request = 'launch',
        stopAtEntry = stopAtEntry,
        program = program,
        args = args,
        environment = env,
        debuggerPath = vim.fn.exepath 'gdb',
        cwd = '${workspaceFolder}',
        MIMode = 'gdb',
    }
end

return M

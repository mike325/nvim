local M = {}

function M.ssh_hosts(opts)
    local parsers = RELOAD 'threads.parsers'
    RELOAD('threads').queue_thread(parsers.sshconfig, function(hosts)
        for host, attrs in pairs(hosts) do
            STORAGE.hosts[host] = attrs
        end
    end, opts or {})
end

function M.compile_flags(opts)
    vim.validate {
        opts = { opts, 'table' },
        flags_file = { opts.flags_file, 'string' },
    }

    local parsers = RELOAD 'threads.parsers'
    local parse_func = {
        ['compile_commands.json'] = parsers.compiledb,
        ['compile_flags.txt'] = parsers.compile_flags,
    }

    local flags_type = vim.fs.basename(opts.flags_file)
    -- opts.flags = flags_type == 'compile_flags.txt' and STORAGE.compile_flags or STORAGE.databases

    local thread_func = parse_func[flags_type]

    RELOAD('threads').queue_thread(thread_func, function(results)
        local ftype = vim.fs.basename(results.flags_file)
        if ftype == 'compile_flags.txt' then
            local flags_file = require('utils.files').realpath(results.flags_file)
            STORAGE.compile_flags[flags_file] = results.flags
        else
            for source_name, flags in pairs(results.flags) do
                STORAGE.databases[source_name] = flags
            end
        end
        local parsed = vim.g.parsed or {}
        parsed[vim.fs.dirname(results.flags_file)] = true
        vim.g.parsed = parsed
        vim.cmd.doautocmd { args = { 'User', 'FlagsParsed' } }
    end, opts or {})
end

return M

local M = {}

function M.ssh_hosts(opts)
    local parsers = RELOAD 'threads.parsers'
    local ssh_config = string.format('%s/.ssh/config', (vim.uv.os_homedir():gsub('\\', '/')))
    if require('utils.files').is_file(ssh_config) then
        RELOAD('threads').queue_thread(parsers.sshconfig, function(hosts)
            for host, attrs in pairs(hosts) do
                STORAGE.hosts[host] = attrs
            end
        end, opts or {})
    end
end

function M.compile_flags(opts)
    vim.validate('opts', opts, 'table')
    vim.validate('flags_file', opts.flags_file, 'string')

    local parsers = RELOAD 'threads.parsers'
    local parse_func = {
        ['compile_commands.json'] = parsers.compiledb,
        ['compile_flags.txt'] = parsers.compile_flags,
    }

    local flags_type = vim.fs.basename(opts.flags_file)
    -- opts.flags = flags_type == 'compile_flags.txt' and STORAGE.compile_flags or STORAGE.compile_commands_dbs

    local thread_func = parse_func[flags_type]
    RELOAD('threads').queue_thread(thread_func, function(results)
        local ftype = vim.fs.basename(results.flags_file)
        if ftype == 'compile_flags.txt' then
            local flags_file = require('utils.files').realpath(results.flags_file)
            STORAGE.compile_flags[flags_file] = results.flags
        else
            for source_name, flags in pairs(results.flags) do
                STORAGE.compile_commands_dbs[source_name] = flags
            end
        end

        local parsed_files = vim.g.parsed_flags or {}
        parsed_files[results.flags_file] = true
        vim.g.parsed_flags = parsed_files

        vim.api.nvim_exec_autocmds('User', {
            pattern = 'FlagsParsed',
            group = vim.api.nvim_create_augroup('ParseCompileFlags', { clear = false }),
            data = {
                flags_file = results.flags_file,
            },
        })
    end, opts or {})
end

return M

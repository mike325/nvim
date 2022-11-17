local M = {}

function M.ssh_hosts(opts)
    local parsers = require 'threads.parsers'
    local work = vim.loop.new_work(parsers.sshconfig, function(hosts)
        if hosts and hosts ~= '' then
            hosts = vim.json.decode(hosts)
            for host, addr in pairs(hosts) do
                STORAGE.hosts[host] = addr
            end
        end
    end)
    work:queue(vim.json.encode(opts))
end

function M.compile_flags(opts)
    local parsers = require 'threads.parsers'
    local parse_func = {
        ['compile_commands.json'] = parsers.compiledb,
        ['compile_flags.txt'] = parsers.compile_flags,
    }
    opts.compile_flags = STORAGE.compile_flags
    opts.databases = STORAGE.databases

    opts.include_parser = string.dump(parsers.includes)
    local work = vim.loop.new_work(parse_func[vim.fs.basename(opts.flags_file)], function(results)
        if type(results) == type '' and results ~= '' then
            local parsed = vim.g.parsed or {}
            results = vim.json.decode(results)
            parsed[vim.fs.dirname(results.flags_file)] = true
            vim.g.parsed = parsed
            vim.list_extend(STORAGE.compile_flags, results.compile_flags)
            for source_name, flags in pairs(results.databases) do
                STORAGE.databases[source_name] = flags
            end
        end
    end)
    work:queue(vim.json.encode(opts))
end

return M

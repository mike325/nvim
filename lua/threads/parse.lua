local M = {}

function M.parse_includes(args)
    local includes = {}
    local include = false
    for _, arg in pairs(args) do
        if arg == '-isystem' or arg == '-I' or arg == '/I' then
            include = true
        elseif include then
            table.insert(includes, arg)
            include = false
        elseif arg:match '^[-/]I' then
            table.insert(includes, vim.trim(arg:gsub('^[-/]I', '')))
        elseif arg:match '^%-isystem' then
            table.insert(includes, vim.trim(arg:gsub('^%-isystem', '')))
        end
    end
    return includes
end

-- local has_cjson = STORAGE.has_cjson
-- TODO: Add support to inherit c/cpp source paths
function M.parse_compile_flags(opts)
    local utils = require 'utils.files'

    opts = vim.json.decode(opts)
    local data = utils.readfile(opts.flags_file, true)
    local inc_parser = loadstring(opts.parse_includes)

    opts.flags_file = utils.realpath(opts.flags_file)
    local compile_flags = {
        [opts.flags_file] = {
            flags = {},
            includes = {},
        },
    }
    for _, line in pairs(data) do
        if line:sub(1, 1) == '-' or line:sub(1, 1) == '/' then
            table.insert(compile_flags[opts.flags_file].flags, line)
        end
    end
    compile_flags[opts.flags_file].includes = inc_parser(compile_flags[opts.flags_file].flags)
    -- NOTE: No longer needed
    opts.parse_includes = nil
    opts.compile_flags = compile_flags
    return vim.json.encode(opts)
end

function M.parse_compiledb(opts)
    local utils = require 'utils.files'

    opts = vim.json.decode(opts)
    local data = utils.readfile(opts.flags_file, false)
    local json = vim.json.decode(data)
    local inc_parser = loadstring(opts.parse_includes)

    local databases = {}

    for _, source in pairs(json) do
        local source_name
        if not source.file:match '/' then
            source_name = source.directory .. '/' .. source.file
        else
            source_name = source.file
        end
        local args
        if source.arguments then
            args = source.arguments
        elseif source.command then
            args = vim.split(source.command, ' ')
        end
        databases[source_name] = {}
        databases[source_name].filename = source_name
        databases[source_name].compiler = args[1]
        databases[source_name].flags = vim.list_slice(args, 2, #args)
        databases[source_name].includes = inc_parser(databases[source_name].flags)
    end
    opts.parse_includes = nil
    opts.databases = databases
    return vim.json.encode(opts)
end

function M.parse_ssh_config(opts)
    local utils = require 'utils.files'
    -- opts = vim.json.decode(opts)
    local ssh_config = vim.loop.os_homedir() .. '/.ssh/config'

    if utils.is_file(ssh_config) then
        local host = ''
        local hosts = {}
        local data = utils.readfile(ssh_config, true)
        for _, line in pairs(data) do
            if line and line ~= '' and line:match '[hH]ost%s+[a-zA-Z0-9_-%.]+' then
                host = vim.split(line, '%s+')[2]
            elseif line:match '%s+[hH]ostname%s+[a-zA-Z0-9_-%.]+' and host ~= '' then
                local addr = vim.split(line, '%s+')[2]
                hosts[host] = addr
                host = ''
            end
        end
        return vim.json.encode(hosts)
    end
end

function M.ssh_hosts(opts)
    local work = vim.loop.new_work(M.parse_ssh_config, function(hosts)
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
    local parse_func = {
        ['compile_commands.json'] = M.parse_compiledb,
        ['compile_flags.txt'] = M.parse_compile_flags,
    }
    opts.compile_flags = STORAGE.compile_flags
    opts.databases = STORAGE.databases

    opts.parse_includes = string.dump(M.parse_includes)
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

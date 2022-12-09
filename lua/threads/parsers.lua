-- NOTE: Parsers should be available in non main threads

local M = {}

function M.includes(args)
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
function M.compile_flags(thread_args)
    thread_args = require('threads').init(thread_args)
    local utils = require 'utils.files'

    local flags_file = thread_args.args.flags_file
    local data = utils.readfile(flags_file, true)
    local inc_parser = require('threads.parsers').includes

    flags_file = utils.realpath(flags_file)
    local compile_flags = {
        [flags_file] = {
            flags = {},
            includes = {},
        },
    }

    for _, line in pairs(data) do
        if line:sub(1, 1) == '-' or line:sub(1, 1) == '/' then
            table.insert(compile_flags[flags_file].flags, line)
        end
    end

    compile_flags[flags_file].includes = inc_parser(compile_flags[flags_file].flags)

    local results = {
        flags_file = flags_file,
        flags = compile_flags,
    }
    return vim.is_thread() and vim.json.encode(results) or results
end

function M.compiledb(thread_args)
    thread_args = require('threads').init(thread_args)
    local utils = require 'utils.files'

    local flags_file = thread_args.args.flags_file

    local data = utils.readfile(flags_file, false)
    local json = vim.json.decode(data)
    local inc_parser = require('threads.parsers').includes

    local databases = {}

    for _, source in pairs(json) do
        local source_name
        if not source.file:match '[/\\]' then
            source_name = source.directory:gsub('\\', '/') .. '/' .. source.file
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

    local results = {
        flags_file = flags_file,
        flags = databases,
    }
    return vim.is_thread() and vim.json.encode(results) or results
end

function M.sshconfig()
    require('threads').init()

    local utils = require 'utils.files'
    local ssh_config = vim.loop.os_homedir() .. '/.ssh/config'

    local hosts = {}
    if utils.is_file(ssh_config) then
        local host = ''
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
    end
    return vim.is_thread() and vim.json.encode(hosts) or hosts
end

function M.yaml(thread_args)
    thread_args = require('threads').init(thread_args)

    local filename = thread_args.args.filename
    vim.validate {
        filename = { filename, 'string' },
    }

    local utils = require 'utils.files'
    local ok, parser = pcall(require, 'yaml')
    local data = utils.readfile(filename, not ok)

    local yaml_dict = {}
    if ok then
        yaml_dict = parser.eval(data)
        return vim.is_thread() and vim.json.encode(yaml_dict) or yaml_dict
    end

    -- local multiline = false
    -- TODO: Missing support for:
    -- - Multi line strings
    -- - Dict attributes
    -- - List attributes
    for _, line in ipairs(data) do
        if line:match '^%w+' then
            -- if not line:match '^%s*$' and not line:match '^%s*#' then
            local attr = vim.split(line, ':')
            local attr_name = vim.trim(attr[1])
            local value = attr[2] and vim.trim(table.concat(vim.list_slice(attr, 2, #attr))) or ''

            if value:match '#.+$' then
                value = value:gsub('#.+$', '')
            end

            if value:match '^-?%d+$' then
                value = tonumber(value)
            elseif value:match '^[tT][rR][uU][eE]$' then
                value = true
            elseif value:match '^[fF][aA][lL][sS][eE]$' then
                value = false
            elseif value:match [[^'.+'$]] then
                value = value:match [[^'(.+)'$]]
            elseif value:match [[^".+"$]] then
                value = value:match [[^"(.+)"$]]
            elseif value:match '^%[' then
                local lst = {}
                for i in value:gmatch '[^%[%], ]+' do
                    -- if i:match [=[^['"]]=] then
                    --     i = i:match [[^['"](.+)['"]$]]
                    -- end
                    table.insert(lst, i)
                end
                value = lst
            end

            yaml_dict[attr_name] = value
        end
    end

    return vim.is_thread() and vim.json.encode(yaml_dict) or yaml_dict
end

return M

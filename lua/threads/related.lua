local M = {}

-- NOTE: May save this to disk in a json cache file
function M.gather_srcs_headers(thread_args)
    thread_args = require('threads').init(thread_args)

    local basename = require('utils.files').basename
    local extension = require('utils.files').extension
    -- local dirname = require('utils.files').dirname

    local extensions = {
        c = { 'h' },
        h = { 'c' },
        cc = { 'hpp', 'hxx' },
        cpp = { 'hpp', 'hxx' },
        cxx = { 'hpp', 'hxx' },
        hpp = { 'cpp', 'cxx', 'cc' },
        hxx = { 'cpp', 'cxx', 'cc' },
    }

    local args = thread_args.args
    local alternates = {}
    local path = args.path or '.'

    local filter_func = function(filename)
        local ext = extension(filename)
        return extensions[ext] ~= nil
    end
    local candidates = vim.fs.find(filter_func, { type = 'file', limit = math.huge, path = path })

    local tmp = {}
    local idxs = {}
    for _, filename in ipairs(candidates) do
        local realfile = vim.loop.fs_realpath(filename)
        tmp[realfile] = {}
        local basename_file = basename(filename)
        if basename_file then
            if not idxs[basename_file] then
                idxs[basename_file] = {}
            end
            table.insert(idxs[basename_file], realfile)
        end
    end

    for _, filename in ipairs(candidates) do
        filename = vim.loop.fs_realpath(filename)
        local file_name = basename(filename)
        local file_ext = extension(file_name)
        local file_name_no_ext = filename
        if file_ext and file_ext ~= '' then
            file_name_no_ext = filename:gsub('%.' .. file_ext .. '$', '')
        end

        for _, alt_ext in pairs(extensions[file_ext]) do
            local alt_candidate = basename(file_name_no_ext .. '.' .. alt_ext)
            if idxs[alt_candidate] then
                if not tmp[filename] then
                    tmp[filename] = {}
                end
                vim.list_extend(tmp[filename], idxs[alt_candidate])
            end
        end
    end

    for filename, alternate_files in pairs(tmp) do
        if #alternate_files > 0 then
            alternates[filename] = alternate_files
        end
    end

    return vim.is_thread() and vim.json.encode(alternates) or alternates
end

function M.gather_tests(thread_args)
    -- local encode = type(thread_args) == type ''
    thread_args = require('threads').init(thread_args)

    local basename = require('utils.files').basename
    local extension = require('utils.files').extension

    local extensions = {
        c = true,
        cc = true,
        cpp = true,
        cxx = true,
        lua = true,
        py = true,
        go = true,
        rust = true,
        java = true,
    }

    local args = thread_args.args

    local tests = {}
    local path = args.path or '.'

    local filter_func = function(filename)
        local ext = extension(filename)
        return extensions[ext] ~= nil
    end

    local candidates = vim.fs.find(filter_func, { type = 'file', limit = math.huge, path = path })

    local tmp = {}
    local idxs = {}
    for _, filename in ipairs(candidates) do
        local realfile = vim.loop.fs_realpath(filename)
        tmp[realfile] = {}
        -- NOTE: Hope to not find repeated files
        idxs[basename(filename)] = realfile
    end

    for _, filename in ipairs(candidates) do
        filename = vim.loop.fs_realpath(filename)
        local file_name = basename(filename)
        local file_ext = extension(file_name)
        local file_name_no_ext = filename
        if file_ext and file_ext ~= '' then
            file_name_no_ext = filename:gsub('%.' .. file_ext .. '$', '')
        end

        -- TODO: look into tst/test directory for the same name
        local test_patterns = {
            '([_.]spec)%.' .. file_ext,
            '^([tT][eE][sS][tT][_.])' .. file_name,
            file_name_no_ext .. '([._][tT][eE][sS][tT])%.' .. file_ext,
        }

        local is_test = false
        for _, pattern in ipairs(test_patterns) do
            if file_name:match(pattern) then
                is_test = true
                break
            end
        end

        if not is_test then
            local test_names = {
                'test',
                'spec',
            }
            local separators = { '_', '.' }
            local test_candidates = {}

            local fmt_str = '%s%s%s.%s'
            for _, test in ipairs(test_names) do
                for _, sep in ipairs(separators) do
                    table.insert(test_candidates, fmt_str:format(test:lower(), sep, file_name_no_ext, file_ext))
                    table.insert(test_candidates, fmt_str:format(test:upper(), sep, file_name_no_ext, file_ext))
                    table.insert(test_candidates, fmt_str:format(file_name_no_ext, sep, test:lower(), file_ext))
                    table.insert(test_candidates, fmt_str:format(file_name_no_ext, sep, test:upper(), file_ext))
                end
            end

            for _, candidate in pairs(test_candidates) do
                if idxs[candidate] then
                    table.insert(tmp[filename], idxs[candidate])
                end
            end
        else
            for _, pattern in pairs(test_patterns) do
                if file_name:match(pattern) then
                    local src = file_name:gsub((file_name:match(pattern)), '')
                    if idxs[src] then
                        table.insert(tmp[filename], idxs[src])
                    end
                end
            end
        end
    end

    for filename, tests_files in pairs(tmp) do
        if #tests_files > 0 then
            tests[filename] = tests_files
        end
    end

    return vim.is_thread() and vim.json.encode(tests) or tests
end

function M.alternate_src_header(thread_args)
    thread_args = require('threads').init(thread_args)

    local basename = require('utils.files').basename
    local extension = require('utils.files').extension

    local extensions = {
        c = { 'h' },
        h = { 'c' },
        cc = { 'hpp', 'hxx' },
        cpp = { 'hpp', 'hxx' },
        cxx = { 'hpp', 'hxx' },
        hpp = { 'cpp', 'cxx', 'cc' },
        hxx = { 'cpp', 'cxx', 'cc' },
    }

    local candidates = {}
    local buf = thread_args.context.bufname
    local buf_name = basename(buf)
    local buf_ext = extension(buf_name)
    local buf_name_no_ext = buf_name
    if buf_ext and buf_ext ~= '' then
        buf_name_no_ext = buf_name:gsub('%.' .. buf_ext .. '$', '')
    end

    if extensions[buf_ext] then
        local filter_func = function(filename)
            local name = filename
            local ext = extension(name)
            if ext and ext ~= '' then
                name = filename:gsub('%.' .. ext .. '$', '')
            end

            return buf_name_no_ext == name and vim.list_contains(extensions[buf_ext], ext)
        end

        candidates = vim.fs.find(filter_func, { type = 'file' })
    end

    local results = {
        candidates = candidates,
        key = buf,
        varname = 'alternates',
    }

    return vim.is_thread() and vim.json.encode(results) or results
end

function M.alternate_test(thread_args)
    thread_args = require('threads').init(thread_args)

    local basename = require('utils.files').basename
    local extension = require('utils.files').extension

    local extensions = {
        c = true,
        cc = true,
        cpp = true,
        cxx = true,
        lua = true,
        py = true,
        go = true,
        rust = true,
        java = true,
    }

    local candidates = {}
    local bufname = thread_args.context.bufname
    local base_bufname = basename(bufname)
    local buf_ext = extension(base_bufname)

    -- TODO: look into tst/test directory for the same name
    local test_patterns = {
        '[_%.]spec%.' .. buf_ext .. '$',
        '^[tT][eE][sS][tT][_%.]' .. base_bufname,
        '[%._][tT][eE][sS][tT]%.' .. buf_ext .. '$',
    }

    local function is_test(filename)
        for _, pattern in ipairs(test_patterns) do
            if filename:match(pattern) then
                return true
            end
        end
        return false
    end

    if extensions[buf_ext] then
        local function find_test(filename)
            for _, pattern in ipairs(test_patterns) do
                if filename:match(pattern) then
                    return true
                end
            end
            return false
        end

        local src_name
        if is_test(base_bufname) then
            src_name = basename(bufname)
            for _, pattern in ipairs(test_patterns) do
                src_name = src_name:gsub(pattern, '')
            end
            src_name = src_name .. '.' .. buf_ext
        else
            for idx, pattern in ipairs(test_patterns) do
                if pattern:sub(1, 1) ~= '^' then
                    test_patterns[idx] = base_bufname:gsub('%.' .. buf_ext .. '$', '') .. pattern
                end
            end
        end

        local function find_src(filename)
            return filename == src_name
        end

        local filter_func = is_test(base_bufname) and find_src or find_test

        candidates = vim.fs.find(filter_func, { type = 'file' })
    end

    local results = {
        candidates = candidates,
        key = bufname,
        varname = 'tests',
    }

    return vim.is_thread() and vim.json.encode(results) or results
end

-- NOTE: This does not work yet since find in nvim-0.8 can not search upward in different threads
function M.related_makefiles(thread_args)
    thread_args = require('threads').init(thread_args)

    -- NOTE: current buffer's directory
    local dirname = thread_args.context.dirname

    local candidates = vim.fs.find(function(filename)
        return filename:match '^[Mm]akefile' ~= nil or filename:match '.+%.mk$' ~= nil
    end, { type = 'file', limit = math.huge, upward = true, path = dirname })

    local results = {
        candidates = candidates,
        key = dirname,
        varname = 'makefiles',
    }

    return vim.is_thread() and vim.json.encode(results) or results
end

function M.update_var_cb(opts)
    local key = opts.key
    local varname = opts.varname
    local candidates = opts.candidates

    if #candidates > 0 then
        local update_val = vim.g[varname] or {}
        update_val[key] = candidates
        vim.g[varname] = update_val
    end
end

function M.tests_cb(tests)
    vim.g.tests = vim.tbl_extend('force', vim.deepcopy(vim.g.tests or {}), tests or {})
end

function M.alternate_cb(alternates)
    vim.g.alternates = vim.tbl_extend('force', vim.deepcopy(vim.g.alternates or {}), alternates or {})
end

function M.async_lookup_alternate(opts)
    opts = opts or {}
    require('threads').queue_thread(M.alternate_src_header, M.update_var_cb, opts)
end

function M.async_lookup_tests(opts)
    opts = opts or {}
    require('threads').queue_thread(M.alternate_test, M.update_var_cb, opts)
end

function M.async_lookup_makefiles(opts)
    opts = opts or {}
    require('threads').queue_thread(M.related_makefiles, M.update_var_cb, opts)
end

function M.async_gather_alternates(opts)
    opts = opts or {}
    require('threads').queue_thread(M.gather_srcs_headers, M.alternate_cb, opts)
end

function M.async_gather_tests(opts)
    opts = opts or {}
    require('threads').queue_thread(M.gather_tests, M.tests_cb, opts)
end

return M

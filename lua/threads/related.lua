local M = {}

-- NOTE: May save this to disk in a json cache file
-- TODO: simplify and unify threads initialization
function M.gather_srcs_headers(opts)
    if not vim.env then
        vim.env = setmetatable({}, {
            __index = function(_, k)
                local v = vim.loop.os_getenv(k)
                if v == nil then
                    return nil
                end
                return v
            end,
            __newindex = function(_, k, v)
                vim.loop.os_setenv(k, v)
            end,
        })
    end

    if not vim.fs then
        vim.fs = require 'vim.fs'
    end

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

    opts = vim.json.decode(opts)
    opts.alternates = opts.alternates or {}
    local path = opts.path or '.'

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

        for _, alt_ext in pairs(extensions[file_ext]) do
            local alt_candidate = basename(file_name_no_ext .. '.' .. alt_ext)
            if idxs[alt_candidate] then
                table.insert(tmp[filename], idxs[alt_candidate])
            end
        end
    end

    for filename, alternates in pairs(tmp) do
        if #alternates > 0 then
            opts.alternates[filename] = alternates
        end
    end

    return vim.json.encode(opts)
end

function M.gather_tests(opts)
    if not vim.env then
        vim.env = setmetatable({}, {
            __index = function(_, k)
                local v = vim.loop.os_getenv(k)
                if v == nil then
                    return nil
                end
                return v
            end,
            __newindex = function(_, k, v)
                vim.loop.os_setenv(k, v)
            end,
        })
    end

    if not vim.fs then
        vim.fs = require 'vim.fs'
    end

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

    opts = vim.json.decode(opts)
    opts.tests = opts.tests or {}
    local path = opts.path or '.'

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

    for filename, tests in pairs(tmp) do
        if #tests > 0 then
            opts.tests[filename] = tests
        end
    end

    return vim.json.encode(opts)
end

function M.alternate_src_header(opts)
    if not vim.env then
        vim.env = setmetatable({}, {
            __index = function(_, k)
                local v = vim.loop.os_getenv(k)
                if v == nil then
                    return nil
                end
                return v
            end,
            __newindex = function(_, k, v)
                vim.loop.os_setenv(k, v)
            end,
        })
    end

    if not vim.fs then
        vim.fs = require 'vim.fs'
    end

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

    opts = vim.json.decode(opts)

    local prefix = opts.buf:match '^%w+://'
    if prefix then
        opts.buf = opts.buf:gsub('^%w+://', '')
        if prefix == 'fugitive://' then
            opts.buf = opts.buf:gsub('%.git//?[%w%d]+//?', '')
        end
    end

    local candidates = {}
    local buf = opts.buf
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

            return buf_name_no_ext == name and vim.tbl_contains(extensions[buf_ext], ext)
        end

        candidates = vim.fs.find(filter_func, { type = 'file' })
    end

    return vim.json.encode(opts), vim.json.encode(candidates), opts.buf, 'alternates'
end

function M.alternate_test(opts)
    if not vim.env then
        vim.env = setmetatable({}, {
            __index = function(_, k)
                local v = vim.loop.os_getenv(k)
                if v == nil then
                    return nil
                end
                return v
            end,
            __newindex = function(_, k, v)
                vim.loop.os_setenv(k, v)
            end,
        })
    end

    if not vim.fs then
        vim.fs = require 'vim.fs'
    end

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

    opts = vim.json.decode(opts)

    local prefix = opts.buf:match '^%w+://'
    if prefix then
        opts.buf = opts.buf:gsub('^%w+://', '')
        if prefix == 'fugitive://' then
            opts.buf = opts.buf:gsub('%.git//?[%w%d]+//?', '')
        end
    end

    local candidates = {}
    local buf = opts.buf
    local buf_name = basename(buf)
    local buf_ext = extension(buf_name)
    -- local buf_name_no_ext = buf_name
    -- if buf_ext and buf_ext ~= '' then
    --     buf_name_no_ext = buf_name:gsub('%.' .. buf_ext .. '$', '')
    -- end

    -- TODO: look into tst/test directory for the same name
    local test_patterns = {
        '([_.]spec)%.' .. buf_ext,
        '^([tT][eE][sS][tT][_.])',
        '([._][tT][eE][sS][tT])%.' .. buf_ext,
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
            for _, pattern in pairs(test_patterns) do
                if filename:match(pattern) then
                    return true
                end
            end
            return false
        end

        local function find_src(filename)
            for _, pattern in pairs(test_patterns) do
                local sub = (filename:match(pattern))
                if sub and filename:gsub(sub, '') == buf_name then
                    return true
                end
            end
            return false
        end

        local filter_func = is_test(buf_name) and find_test or find_src

        candidates = vim.fs.find(filter_func, { type = 'file' })
    end

    return vim.json.encode(opts), vim.json.encode(candidates), opts.buf, 'tests'
end

-- NOTE: This does not work yet since find in nvim-0.8 can not search upward in different threads
function M.related_makefiles(opts)
    if not vim.env then
        vim.env = setmetatable({}, {
            __index = function(_, k)
                local v = vim.loop.os_getenv(k)
                if v == nil then
                    return nil
                end
                return v
            end,
            __newindex = function(_, k, v)
                vim.loop.os_setenv(k, v)
            end,
        })
    end

    if not vim.fs then
        vim.fs = require 'vim.fs'
    end

    opts = vim.json.decode(opts)

    local candidates = vim.fs.find(function(filename)
        return filename:match '^[Mm]akefile' ~= nil or filename:match '.+%.mk$' ~= nil
    end, { type = 'file', limit = math.huge, upward = true, path = opts.basedir })

    return vim.json.encode(opts), vim.json.encode(candidates), opts.basedir, 'makefiles'
end

function M.update_var_cb(opts, results, key, varname)
    if type(results) == type '' then
        local candidates = vim.json.decode(results)
        -- opts = vim.json.decode(opts)

        if #candidates > 0 then
            local udpate_val = vim.g[varname] or {}
            udpate_val[key] = candidates
            vim.g[varname] = udpate_val
        end
    else
        vim.notify(
            'Something when wrong, got an empty string from another thread',
            'ERROR',
            { title = 'Alternate lookup Thread' }
        )
    end
end

function M.tests_cb(opts)
    if type(opts) == type '' then
        opts = vim.json.decode(opts)
        vim.g.tests = vim.tbl_extend('force', vim.g.tests or {}, opts.tests or {})
    else
        vim.notify(
            'Something when wrong, got an empty string from another thread',
            'ERROR',
            { title = 'Alternate lookup Thread' }
        )
    end
end

function M.alternate_cb(opts)
    if type(opts) == type '' then
        opts = vim.json.decode(opts)
        vim.g.alternates = vim.tbl_extend('force', vim.g.alternates or {}, opts.alternates or {})
    else
        vim.notify(
            'Something when wrong, got an empty string from another thread',
            'ERROR',
            { title = 'Alternate lookup Thread' }
        )
    end
end

function M.async_lookup_alternate(opts)
    opts = opts or {}
    opts.buf = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
    local work = vim.loop.new_work(M.alternate_src_header, M.update_var_cb)
    work:queue(vim.json.encode(opts))
end

function M.async_lookup_tests(opts)
    opts = opts or {}
    opts.buf = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
    local work = vim.loop.new_work(M.alternate_test, M.update_var_cb)
    work:queue(vim.json.encode(opts))
end

function M.async_lookup_makefiles(opts)
    opts = opts or {}
    opts.buf = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())

    local prefix = opts.buf:match '^%w+://'
    if prefix then
        opts.buf = opts.buf:gsub('^%w+://', '')
        if prefix == 'fugitive://' then
            opts.buf = opts.buf:gsub('%.git//?[%w%d]+//?', '')
        end
    end

    opts.basedir = vim.fs.dirname(opts.buf)
    local work = vim.loop.new_work(M.related_makefiles, M.update_var_cb)
    work:queue(vim.json.encode(opts))
end

function M.async_gather_alternates(opts)
    opts = opts or {}
    opts.alternates = vim.g.alternates or {}
    opts.path = opts.path or vim.loop.cwd()
    local work = vim.loop.new_work(M.gather_srcs_headers, M.alternate_cb)
    work:queue(vim.json.encode(opts))
end

function M.async_gather_tests(opts)
    opts = opts or {}
    opts.tests = vim.g.tests or {}
    opts.path = opts.path or vim.loop.cwd()
    local work = vim.loop.new_work(M.gather_tests, M.tests_cb)
    work:queue(vim.json.encode(opts))
end

return M

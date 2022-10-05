local M = {}

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

    local extentions = {
        c = { 'h' },
        h = { 'c' },
        cc = { 'hpp', 'hxx' },
        cpp = { 'hpp', 'hxx' },
        cxx = { 'hpp', 'hxx' },
        hpp = { 'cpp', 'cxx', 'cc' },
        hxx = { 'cpp', 'cxx', 'cc' },
    }

    opts = vim.json.decode(opts)

    local candidates = {}
    local buf = opts.buf
    local buf_name = buf:match '[^/]+$'
    local buf_ext = buf_name:match '^.+%.(.+)$' or ''

    if extentions[buf_ext] then
        local filter_func = function(filename)
            local ext = filename:match '^.+%.(.+)$' or ''
            local name = filename:gsub('%.' .. ext .. '$', '')

            return buf_name:gsub('%.' .. buf_ext .. '$', '') == name and vim.tbl_contains(extentions[buf_ext], ext)
        end

        candidates = vim.fs.find(filter_func, { type = 'file' })
    end

    return vim.json.encode(opts), vim.json.encode(candidates), opts.buf, 'alternates'
end

function M.alternate_cb(opts, results, key, varname)
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

function M.async_lookup_alternate()
    local opts = {}
    opts.buf = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
    local work = vim.loop.new_work(M.alternate_src_header, M.alternate_cb)
    work:queue(vim.json.encode(opts))
end

return M

local executable = require('utils.files').executable

if not executable 'git' then
    return false
end

local M = {}

local function rm_colors(cmd)
    -- stylua: ignore
    return vim.list_extend(cmd or {}, {
        '-c', 'color.ui=off',
        '-c', 'color.branch=off',
        '-c', 'color.interactive=off',
        '-c', 'color.grep=off',
        '-c', 'color.log=off',
        '-c', 'color.diff=off',
        '-c', 'color.status=off',
    })
end

local function rm_pager(cmd)
    return vim.list_extend(cmd or {}, {
        '--no-pager',
    })
end

local function get_git_dir(cmd)
    if vim.b.project_root and vim.b.project_root.is_git then
        return vim.list_extend(cmd or {}, { '--git-dir', vim.b.project_root.git_dir })
    end
    return {}
end

local function filter_empty(tbl)
    return vim.tbl_filter(function(v)
        return v ~= ''
    end, tbl)
end

local function exec_sync_gitcmd(cmd, gitcmd)
    local ok, output = pcall(vim.fn.system, cmd)
    return ok and output or error(debug.traceback('Failed to execute: ' .. gitcmd .. ', ' .. output))
end

function M.get_git_cmd(gitcmd, args)
    local cmd = { 'git' }
    rm_colors(cmd)
    get_git_dir(cmd)
    rm_pager(cmd)
    table.insert(cmd, gitcmd)
    if vim.tbl_islist(args) then
        vim.list_extend(cmd, args)
    else
        table.insert(cmd, args)
    end
    return cmd
end

local function parse_status(status)
    vim.validate {
        status = {
            status,
            function(s)
                return type(s) == type '' or vim.tbl_islist(s)
            end,
            'valid git status format',
        },
    }

    if type(status) == 'string' then
        status = vim.split(status, '[\n\r]+')
    end

    local parsed = {
        branch = '',
        upstream = '',
        stage = {},
        workspace = {},
        untracked = {},
    }

    for _, gitfile in ipairs(status) do
        if gitfile:match '^#%s+branch%.head' then
            parsed.branch = vim.split(gitfile, '%s+')[3]
        elseif gitfile:match '^#%s+branch%.upstream' then
            parsed.upstream = vim.split(gitfile, '%s+')[3]
        else
            local file_status = gitfile:sub(1, 1)
            if file_status ~= '#' then
                -- parsed.files = parsed.files or {}
                -- local line = vim.split(gitfile, '%s+')
                if file_status == '1' or file_status == '2' then
                    local stage_status = gitfile:sub(3, 3)
                    local wt_status = gitfile:sub(4, 4)
                    local renamed = false
                    local filename = gitfile:sub(114, #gitfile)
                    if stage_status:match '[AMD]' then
                        if stage_status == 'M' then
                            stage_status = 'modified'
                        else
                            stage_status = stage_status == 'A' and 'added' or 'deleted'
                        end
                        parsed.stage[filename] = { status = stage_status }
                        -- parsed.files[filename] = 'staged'
                    elseif stage_status == 'R' then
                        renamed = true
                        local files = vim.split(filename:gsub('^R%d+%s+', ''), '%s+')
                        local moved_file = files[1]
                        parsed.stage[moved_file] = {
                            status = 'moved',
                            original = files[2],
                        }
                        -- parsed.files[filename] = 'staged'
                    end
                    if wt_status == 'M' then
                        if renamed then
                            filename = vim.split(filename:gsub('^R%d+%s+', ''), '%s+')[2]
                        end
                        parsed.workspace[filename] = {
                            status = 'modified',
                        }
                        -- parsed.files[filename] = 'workspace'
                    end
                elseif file_status == '?' then
                    parsed.untracked = parsed.untracked or {}
                    local filename = gitfile:sub(3, #gitfile)
                    parsed.untracked[#parsed.untracked + 1] = filename
                    -- parsed.files[filename] = 'untracked'
                    -- elseif gitfile:sub(1, 1) == 'u' then  -- TODO
                    --     parsed.unmerge = parsed.unmerge or {}
                end
            end
        end
    end
    return parsed
end

local function exec_gitcmd(gitcmd, args, callbacks)
    vim.validate {
        gitcmd = { gitcmd, 'string' },
        args = { args, { 'string', 'table' } },
        callbacks = { callbacks, 'function', true },
    }

    local cmd = M.get_git_cmd(gitcmd, args)
    if not callbacks then
        return filter_empty(vim.split(exec_sync_gitcmd(cmd, gitcmd), '\n'))
    end

    local git = RELOAD('jobs'):new {
        cmd = cmd,
        silent = true,
        callbacks_on_success = function(job)
            callbacks(filter_empty(job:output()))
        end,
        callbacks_on_failure = function(job)
            local title = 'Git' .. gitcmd:sub(1, 1):upper() .. gitcmd:sub(2, #gitcmd)
            vim.notify('Failed to execute git ' .. gitcmd, 'ERROR', { title = title })
        end,
    }
    git:start()
end

function M.status(callback)
    vim.validate { callback = { callback, 'function', true } }

    local gitcmd = 'status'
    local args = {
        '--branch',
        '--porcelain=2',
    }
    if not callback then
        return parse_status(exec_gitcmd(gitcmd, args))
    end

    exec_gitcmd(gitcmd, args, function(status)
        callback(parse_status(status))
    end)
end

function M.branch(callback)
    vim.validate { callback = { callback, 'function', true } }

    local gitcmd = 'rev-parse'
    local args = {
        '--abbrev-ref',
        'HEAD',
    }
    if not callback then
        return exec_gitcmd(gitcmd, args)[1] or ''
    end
    exec_gitcmd(gitcmd, args, function(branch)
        callback(branch[1] or '')
    end)
end

function M.base_branch(base, callback)
    vim.validate {
        base = { base, { 'string', 'function' }, true },
        callback = { callback, 'function', true },
    }

    if type(base) == type(callback) and base ~= nil then
        error(debug.traceback 'base and callback cannot be the same type')
    end

    if type(base) == 'function' then
        callback = base
        base = nil
    end

    local gitcmd = 'merge-base'
    local args = {
        '--fork-point',
        'HEAD',
        -- 'main', -- 'master',
    }
    if base then
        table.insert(args, base)
    end
    if not callback then
        return exec_gitcmd(gitcmd, args)[1] or ''
    end
    exec_gitcmd(gitcmd, args, function(branch)
        callback(branch[1] or '')
    end)
end

function M.modified_files(base, callback)
    vim.validate {
        base = { base, { 'string', 'function' }, true },
        callback = { callback, 'function', true },
    }

    if type(base) == type(callback) and base ~= nil then
        error(debug.traceback 'base and callback cannot be the same type')
    end

    if type(base) == 'function' then
        callback = base
        base = ''
    end

    local function get_files(status)
        if base == 'stage' or base == 'staged' then
            return vim.tbl_keys(status.stage)
        elseif base == 'workspace' then
            return vim.tbl_keys(status.workspace)
        elseif base == 'untrack' or base == 'untracked' then
            return vim.tbl_keys(status.untracked)
        end
        local files = vim.tbl_keys(status.stage)
        vim.list_extend(files, vim.tbl_keys(status.workspace))
        vim.list_extend(files, vim.tbl_keys(status.untracked))
        return RELOAD('utils.tables').uniq_unorder(files)
    end

    if not callback then
        return get_files(M.status())
    end
    M.status(function(status)
        callback(get_files(status))
    end)
end

function M.modified_files_from_base(base, callback)
    vim.validate {
        base = { base, { 'string', 'function' }, true },
        callback = { callback, 'function', true },
    }

    if type(base) == type(callback) and base ~= nil then
        error(debug.traceback 'base and callback cannot be the same type')
    end

    if type(base) == 'function' then
        callback = base
        base = nil
    end

    local gitcmd = 'diff'
    local args = {
        '--name-only',
        'HEAD',
        -- base branch/commit
    }
    if not callback then
        table.insert(args, base or M.base_branch())
        return exec_gitcmd(gitcmd, args) or {}
    end
    if base then
        table.insert(args, base)
        exec_gitcmd(gitcmd, args, function(files)
            callback(files)
        end)
    else
        M.base_branch(function(branch)
            table.insert(args, branch)
            exec_gitcmd(gitcmd, args, function(files)
                callback(files)
            end)
        end)
    end
end

return M

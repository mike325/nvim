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
    if vim.b.project_root and vim.b.project_root.git_dir then
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
    local ok, output = pcall(vim.fn.systemlist, cmd)
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
        conflict = {},
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
                elseif file_status == 'u' then
                    local info = vim.split(gitfile, '%s+', { trimempty = true })
                    local filename = table.concat(vim.list_slice(info, 11, #info), ' ')
                    parsed.conflict[filename] = { status = 'conflict' }
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
        return filter_empty(exec_sync_gitcmd(cmd, gitcmd))
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

function M.modified_files(location, callback)
    vim.validate {
        location = { location, { 'string', 'function' }, true },
        callback = { callback, 'function', true },
    }

    if type(location) == type(callback) and location ~= nil then
        error(debug.traceback 'location and callback cannot be the same type')
    end

    if type(location) == 'function' then
        callback = location
        location = ''
    end

    local function get_files(status)
        if location == 'stage' or location == 'staged' then
            return vim.tbl_keys(status.stage)
        elseif location == 'workspace' then
            return vim.tbl_keys(status.workspace)
        elseif location == 'conflict' then
            return vim.tbl_keys(status.conflict)
        elseif location == 'untrack' or location == 'untracked' then
            return status.untracked
        end
        local files = {}
        for _, git_files in pairs(status) do
            if vim.tbl_islist(git_files) then
                vim.list_extend(files, git_files)
            elseif type(git_files) == type {} then
                vim.list_extend(files, vim.tbl_keys(git_files))
            end
        end
        return RELOAD('utils.tables').uniq_unorder(files)
    end

    if not callback then
        return get_files(M.status())
    end
    M.status(function(status)
        callback(get_files(status))
    end)
end

function M.modified_files_from_base(revision, callback)
    vim.validate {
        revision = { revision, { 'string', 'function' }, true },
        callback = { callback, 'function', true },
    }

    if type(revision) == type(callback) and revision ~= nil then
        error(debug.traceback 'revision and callback cannot be the same type')
    end

    if type(revision) == 'function' then
        callback = revision
        revision = nil
    end

    local gitcmd = 'diff'
    local args = {
        '--diff-algorithm=patience',
        '-M',
        '-B',
        '-C',
        '--find-copies-harder',
        '--name-only',
        -- 'HEAD',
        -- revision branch/commit
    }
    if not callback then
        table.insert(args, (revision or M.base_branch()) .. '...')
        return exec_gitcmd(gitcmd, args) or {}
    end
    if revision then
        table.insert(args, revision .. '...')
        exec_gitcmd(gitcmd, args, function(files)
            callback(files)
        end)
    else
        M.base_branch(function(branch)
            table.insert(args, branch .. '...')
            exec_gitcmd(gitcmd, args, function(files)
                callback(files)
            end)
        end)
    end
end

function M.is_git_repo(root)
    vim.validate {
        root = { root, 'string' },
    }

    local is_file = require('utils.files').is_file
    local is_dir = require('utils.files').is_dir

    if not executable 'git' then
        return false
    end

    root = vim.fs.normalize(root)

    local git = root .. '/.git'

    if is_dir(git) or is_file(git) then
        return git
    end
    local results = vim.fs.find('.git', { path = root, upward = true })
    return #results > 0 and results[1] or false
end

function M.get_git_dir(path, callback)
    vim.validate {
        path = { path, 'string', true },
        callback = { callback, 'function', true },
    }

    local gitcmd = 'rev-parse'
    local args = {
        '--git-dir',
    }

    local cmd = { 'git' }
    rm_colors(cmd)
    rm_pager(cmd)
    table.insert(cmd, gitcmd)
    vim.list_extend(cmd, args)

    path = path or require('utils.files').getcwd()

    if not callback then
        local git = RELOAD('jobs'):new {
            cmd = cmd,
            opts = {
                cwd = path,
            },
            silent = true,
            callbacks_on_failure = function(job)
                local title = 'Git' .. gitcmd:sub(1, 1):upper() .. gitcmd:sub(2, #gitcmd)
                vim.notify('Failed to execute git ' .. gitcmd, 'ERROR', { title = title })
            end,
        }
        git:start()
        git:wait()
        if git.rc == 0 then
            local git_dir = table.concat(filter_empty(git:output()))
            if git_dir == '.git' then
                return (('%s/%s'):format(path, git_dir):gsub('/+', '/'))
            end
            return git_dir
        end
        return false
    end

    local git = RELOAD('jobs'):new {
        cmd = cmd,
        opts = {
            cwd = path,
        },
        silent = true,
        callbacks_on_success = function(job)
            local git_dir = table.concat(filter_empty(job:output()))
            if git_dir == '.git' then
                git_dir = (('%s/%s'):format(path, git_dir):gsub('/+', '/'))
            end
            callback(git_dir)
        end,
        callbacks_on_failure = function(job)
            local title = 'Git' .. gitcmd:sub(1, 1):upper() .. gitcmd:sub(2, #gitcmd)
            vim.notify('Failed to execute git ' .. gitcmd, 'ERROR', { title = title })
        end,
    }
    git:start()
end

M.exec = setmetatable({}, {
    __index = function(_, k)
        vim.validate {
            gitcmd = { k, 'string' },
        }

        local gitcmd = k
        local supported_cmds = {
            'mv',
        }

        if not vim.tbl_contains(supported_cmds, gitcmd) then
            error(debug.traceback('Unsupported cmd: ' .. gitcmd .. ', ' .. vim.inspect(supported_cmds)))
        end

        return function(args, callback)
            if not callback then
                return exec_gitcmd(gitcmd, args)[1] or ''
            end
            exec_gitcmd(gitcmd, args, function(branch)
                callback(branch[1] or '')
            end)
        end
    end,
    __newindex = function(_, _, _)
        error(debug.traceback 'Cannot set values to exec table')
    end,
})

return M

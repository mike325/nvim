if not vim.is_thread() then
    local executable = require('utils.files').executable
    if not executable 'git' then
        return false
    end
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
    if not vim.is_thread() and vim.t.git_info then
        return vim.list_extend(cmd or {}, { '--git-dir', vim.t.git_info.git_dir })
    end
    return {}
end

local function filter_empty(tbl)
    return vim.tbl_filter(function(v)
        return v ~= ''
    end, tbl)
end

local function normalize_args(args)
    if vim.is_thread() then
        return args
    end

    local function normalize(arg)
        local normalize_arg = arg
        if arg == '%' or arg == '#' or arg == '$' then
            normalize_arg = vim.fn.bufname(arg)
        elseif arg == '##' then
            normalize_arg = vim.fn.argv()
        end
        return normalize_arg
    end

    if type(args) == type '' then
        return normalize(args)
    end

    local tmp = {}
    for _, arg in ipairs(args) do
        local normalize_arg = normalize(arg)
        if type(normalize_arg) == type {} then
            vim.list_extend(tmp, normalize_arg)
        else
            table.insert(tmp, normalize_arg)
        end
    end
    return tmp
end

local function notify_error(gitcmd, output, rc)
    local title = 'Git' .. gitcmd:sub(1, 1):upper() .. gitcmd:sub(2, #gitcmd)
    if type(output) == type {} then
        output = table.concat(output, '\n')
    end
    vim.notify(
        'Failed to execute gitcmd: ' .. gitcmd .. ' exited with ' .. rc .. '\n' .. output,
        vim.log.levels.ERROR,
        { title = title }
    )
end

-- NOTE: Should change this to return the error status and the full output
local function exec_sync_gitcmd(cmd, gitcmd)
    -- TODO: This is not a direct replacement, may need to use vim.system but need a cleanup first
    if vim.is_thread() then
        local git = io.popen(table.concat(cmd, ' '), 'r')
        if not git then
            return {}
        end
        local output = git:read '*a'
        return vim.split(output, '\n', { trimempty = true })
    else
        local ok, output = pcall(vim.fn.systemlist, cmd)
        if not ok or vim.v.shell_error ~= 0 then
            if type(output) == type {} then
                output = table.concat(output, '\n')
            end
            error(
                debug.traceback(
                    ('Failed to execute gitcmd: %s, exited with %d\n%s'):format(gitcmd, vim.v.shell_error, output)
                )
            )
        end
        return output
    end
end

function M.get_git_cmd(gitcmd, args)
    local cmd = { 'git' }
    rm_colors(cmd)
    get_git_dir(cmd)
    rm_pager(cmd)
    table.insert(cmd, gitcmd)
    if vim.islist(args) then
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
                return type(s) == type '' or vim.islist(s)
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
                    -- NOTE: Should this be a dict to facilitate lookups ?
                    table.insert(parsed.untracked, filename)
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

    local cmd = M.get_git_cmd(gitcmd, normalize_args(args))
    if not callbacks then
        return filter_empty(exec_sync_gitcmd(cmd, gitcmd))
    end

    local git = RELOAD('jobs'):new {
        cmd = cmd,
        silent = true,
        callbacks_on_success = function(job)
            callbacks(filter_empty(job:output()))
        end,
        callbacks_on_failure = function(job, _)
            notify_error(gitcmd, job:output(), job.rc)
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
            if vim.islist(git_files) then
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
        table.insert(args, string.format('%s...', (revision or M.base_branch())))
        return exec_gitcmd(gitcmd, args) or {}
    end
    if revision then
        table.insert(args, string.format('%s...', revision))
        exec_gitcmd(gitcmd, args, function(files)
            callback(files)
        end)
    else
        M.base_branch(function(branch)
            table.insert(args, string.format('%s...', branch))
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

    root = vim.fs.normalize(root)
    local git = root .. '/.git'

    if is_dir(git) or is_file(git) then
        return git
    end
    local results = vim.fs.find('.git', { path = root, upward = true })
    return #results > 0 and results[1] or false
end

function M.get_git_info(path, callback)
    vim.validate {
        path = { path, 'string', true },
        callback = { callback, 'function', true },
    }

    path = path or require('utils.files').getcwd()

    local gitcmd = 'rev-parse'
    local args = {
        '--git-dir',
        '--show-toplevel',
        '--is-inside-git-dir',
        '--is-bare-repository',
        '--is-inside-work-tree',
    }

    local cmd = { 'git' }
    rm_colors(cmd)
    rm_pager(cmd)
    table.insert(cmd, gitcmd)
    vim.list_extend(cmd, args)

    local function parse_output(output)
        local info_values = filter_empty(output)
        local git_dir = info_values[1]
        if git_dir == '.git' then
            git_dir = (('%s/%s'):format(path, git_dir):gsub('/+', '/'))
        end

        return {
            git_dir = (git_dir:gsub('\\', '/')),
            root = info_values[2],
            inside_git = info_values[3],
            is_bare = info_values[4],
            inside_worktree = info_values[5],
        }
    end

    local git = RELOAD('jobs'):new {
        cmd = cmd,
        opts = {
            cwd = path,
        },
        silent = true,
        callbacks_on_success = function(job)
            if callback then
                callback(parse_output(job:output()))
            end
        end,
        callbacks_on_failure = function(job)
            notify_error(gitcmd, job:output(), job.rc)
        end,
    }

    git:start()
    if not callback then
        git:wait()
        if git.rc == 0 then
            return parse_output(git:output())
        end
        return false
    end
end

function M.get_git_dir(path, callback)
    vim.validate {
        path = { path, 'string', true },
        callback = { callback, 'function', true },
    }

    path = path or require('utils.files').getcwd()

    local gitcmd = 'rev-parse'
    local args = {
        '--git-dir',
    }

    local cmd = { 'git' }
    rm_colors(cmd)
    rm_pager(cmd)
    table.insert(cmd, gitcmd)
    vim.list_extend(cmd, args)

    local function parse_output(output)
        local git_dir = table.concat(filter_empty(output))
        if git_dir == '.git' then
            return (('%s/%s'):format(path, git_dir):gsub('/+', '/'))
        end
        return (git_dir:gsub('\\', '/'))
    end

    local git = RELOAD('jobs'):new {
        cmd = cmd,
        opts = {
            cwd = path,
        },
        silent = true,
        callbacks_on_success = function(job)
            if callback then
                callback(parse_output(job:output()))
            end
        end,
        callbacks_on_failure = function(job)
            notify_error(gitcmd, job:output(), job.rc)
        end,
    }

    git:start()
    if not callback then
        git:wait()
        if git.rc == 0 then
            return parse_output(git:output())
        end
        return false
    end
end

function M.get_branch(callback)
    vim.validate { callback = { callback, 'function', true } }

    local gitcmd = 'branch'
    local args = {
        '--show-current',
    }
    if not callback then
        return exec_gitcmd(gitcmd, args)[1]
    end

    exec_gitcmd(gitcmd, args, function(branch)
        callback(branch[1])
    end)
end

function M.get_remote(branch, callback)
    vim.validate {
        branch = { branch, { 'string', 'function' }, true },
        callback = { callback, 'function', true },
    }

    if branch ~= nil and type(branch) == type(callback) then
        error(debug.traceback 'Branch need to either be nil or a string')
    end

    if type(branch) == 'function' then
        callback = branch
        branch = nil
    end

    local remote_cmd = 'rev-parse'
    local remote_args = {
        '--abbrev-ref',
        '%s@{upstream}',
    }

    local url_cmd = 'remote'
    local url_args = {
        'get-url',
    }

    local remote_data = {
        remote = '',
        url = '',
        hostname = '',
    }

    local function get_sync_remote(git_branch)
        remote_args[#remote_args] = remote_args[#remote_args]:format(git_branch)
        remote_data.remote = exec_gitcmd(remote_cmd, remote_args)[1]

        table.insert(url_args, (remote_data.remote:gsub('/.*$', '')))
        remote_data.url = exec_gitcmd(url_cmd, url_args)[1]

        -- test http/ssh
        local hostname = (remote_data.url:match 'https?://([%w%d_-%.]+)')
        if not hostname then
            hostname = (remote_data.url:match '%w+@([%w%d_-%.]+):')
        end
        remote_data.hostname = hostname

        return remote_data
    end

    local function get_async_remote(upstream)
        remote_data.remote = upstream[1]
        table.insert(url_args, (upstream[1]:gsub('/.*$', '')))
        remote_data.url = exec_gitcmd(url_cmd, url_args, function(url)
            remote_data.url = url[1]
            -- test http/ssh
            local hostname = (remote_data.url:match 'https?://([%w%d_-%.]+)')
            if not hostname then
                hostname = (remote_data.url:match '%w+@([%w%d_-%.]+):')
            end
            remote_data.hostname = hostname
            callback(remote_data)
        end)
    end

    if not branch or branch == '' then
        if not callback then
            return get_sync_remote(M.get_branch())
        end

        M.get_branch(function(current_branch)
            remote_args[#remote_args] = remote_args[#remote_args]:format(current_branch)
            exec_gitcmd(remote_cmd, remote_args, get_async_remote)
        end)
    else
        if not callback then
            return get_sync_remote(branch)
        end

        remote_args[#remote_args] = remote_args[#remote_args]:format(branch)
        exec_gitcmd(remote_cmd, remote_args, get_async_remote)
    end
end

function M.get_remotes(callback)
    vim.validate {
        callback = { callback, 'function', true },
    }

    local gitcmd = 'remote'
    local remotes = {}

    if not callback then
        for _, remote in ipairs(exec_gitcmd(gitcmd, {})) do
            remotes[remote] = exec_gitcmd(gitcmd, { 'get-url', remote })[1]
        end
        return remotes
    end

    -- TODO: Add true async for all get-url calls
    exec_gitcmd(gitcmd, {}, function(repo_remotes)
        for _, remote in ipairs(repo_remotes) do
            remotes[remote] = exec_gitcmd(gitcmd, { 'get-url', remote })[1]
        end
        callback(remotes)
    end)
end

function M.get_filecontent(filename, revision, callback)
    vim.validate {
        filename = { filename, 'string' },
        revision = { revision, { 'string', 'function' }, true },
        callback = { callback, 'function', true },
    }

    if callback and type(revision) == type(callback) then
        error(debug.traceback 'Revision should be a string, cannot provide 2 callbacks')
    elseif type(revision) == 'function' then
        callback = revision
        revision = nil
    end

    local file_rev = '%s:%s'

    local gitcmd = 'show'
    local args = { file_rev:format(revision or '', filename) }
    if not callback then
        return exec_gitcmd(gitcmd, args)
    end

    exec_gitcmd(gitcmd, args, function(content)
        callback(content)
    end)
end

M.exec = setmetatable({}, {
    __index = function(_, k)
        vim.validate {
            gitcmd = { k, 'string' },
        }

        local gitcmd = k

        local function return_first_line(args, callback)
            vim.validate {
                args = { args, { 'string', 'table' }, true },
                callback = { callback, 'function', true },
            }
            if not callback then
                return exec_gitcmd(gitcmd, args)[1] or ''
            end
            exec_gitcmd(gitcmd, args, function(output)
                callback(output[1] or '')
            end)
        end

        local supported_cmds = {
            mv = return_first_line,
            add = return_first_line,
            restore = return_first_line,
            rm = function(args, callback)
                vim.validate {
                    args = { args, { 'string', 'table' }, true },
                    callback = { callback, 'function', true },
                }
                if not callback then
                    exec_gitcmd(gitcmd, args)
                    return ''
                end
                exec_gitcmd(gitcmd, args, function(_)
                    callback()
                end)
            end,
            init = function(args, callback)
                vim.validate {
                    args = { args, { 'string', 'table' }, true },
                    callback = { callback, 'function', true },
                }
                if not args or #args == 0 then
                    args = { '--initial-branch=main' }
                end
                if not callback then
                    return exec_gitcmd(gitcmd, args)
                end
                exec_gitcmd(gitcmd, args, function(_)
                    callback()
                end)
            end,
        }

        if supported_cmds[gitcmd] == nil then
            error(debug.traceback('Unsupported cmd: ' .. gitcmd .. ', ' .. vim.inspect(supported_cmds)))
        end

        return supported_cmds[gitcmd]
    end,
    __newindex = function(_, _, _)
        error(debug.traceback 'Cannot set values to exec table')
    end,
})

return M

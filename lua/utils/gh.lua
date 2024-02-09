local M = {}

local function filter_empty(tbl)
    return vim.tbl_filter(function(v)
        return v ~= ''
    end, tbl)
end

local function exec_sync_ghcmd(cmd, ghcmd)
    -- TODO: This is not a direct replacement, may need to use vim.system but need a cleanup first
    if vim.is_thread() then
        local gh = io.popen(table.concat(cmd, ' '), 'r')
        local output = gh:read '*a'
        return vim.split(output, '\n', { trimempty = true })
    else
        local ok, output = pcall(vim.fn.systemlist, cmd)
        return ok and output or error(debug.traceback('Failed to execute: ' .. ghcmd .. ', ' .. output))
    end
end

local function exec_ghcmd(ghcmd, args, callbacks)
    vim.validate {
        ghcmd = { ghcmd, 'string' },
        args = { args, { 'string', 'table' } },
        callbacks = { callbacks, 'function', true },
    }

    local cmd = { 'gh', ghcmd }
    if type(args) == 'string' then
        table.insert(args)
    else
        cmd = vim.list_extend(cmd, args)
    end

    if not callbacks then
        return filter_empty(exec_sync_ghcmd(cmd, ghcmd))
    end

    local gh = RELOAD('jobs'):new {
        cmd = cmd,
        silent = true,
        callbacks_on_success = function(job)
            callbacks(filter_empty(job:output()))
        end,
        callbacks_on_failure = function(job)
            local title = 'GH' .. ghcmd:sub(1, 1):upper() .. ghcmd:sub(2, #ghcmd)
            vim.notify('Failed to execute gh ' .. ghcmd, vim.log.levels.ERROR, { title = title })
        end,
    }
    gh:start()
end

function M.get_pr_changes(opts, callback)
    vim.validate {
        opts = { opts, 'table', true },
        callback = { callback, 'function', true },
    }
    -- opts = opts or {}

    local ghcmd = 'pr'
    local args = { 'view', '--json', 'files,baseRefName' }

    local function format_output(output)
        local json = vim.json.decode(table.concat(output, '\n'))
        local data = {
            revision = json.baseRefName,
            files = {},
        }
        for _, file in ipairs(json.files) do
            table.insert(data.files, file.path)
        end
        return data
    end

    if not callback then
        return format_output(exec_ghcmd(ghcmd, args))
    end

    exec_ghcmd(ghcmd, args, function(output)
        local files = format_output(output)
        callback(files)
    end)
end

function M.open_pr(pr)
    vim.validate {
        pr = { pr, 'number', true },
    }

    local ghcmd = 'pr'
    local args = { 'view' }

    if pr then
        table.insert(args, pr)
    end

    vim.list_extend(args, {'--json', 'url' })

    local function open_url(output)
        local json = vim.json.decode(table.concat(output, '\n'))
        vim.ui.open(json.url)
    end
    open_url(exec_ghcmd(ghcmd, args))
end

function M.list_repo_pr(opts, callback)
    vim.validate {
        opts = { opts, 'table', true },
        callback = { callback, 'function', true },
    }
    opts = opts or {}

    local ghcmd = 'pr'
    local args = { 'list' }

    local json_fields = { '--json' }
    if opts.fields then
        local fields = opts.fields
        if type(fields) == type {} then
            fields = table.concat(fields, ',')
        end
        table.insert(json_fields, fields)
    else
        table.insert(json_fields, 'author,state,isDraft,number,title,url')
    end
    args = vim.list_extend(args, json_fields)

    local filters = {}
    opts.filters = opts.filters or opts.filter
    if opts.filters and type(opts.filters) == type {} then
        local filter_args = {
            assignee = true,
            author = true,
            base = true,
            draft = true,
            head = true,
            label = true,
            limit = true,
            search = true,
            state = true,
        }

        for filter, value in pairs(opts.filters) do
            vim.validate {
                filter = { filter, 'string' },
                value = { value, { 'string', 'number', 'bool' } },
            }
            if filter_args[filter] then
                table.insert(filters, '--' .. filter)
                if filter ~= 'draft' then
                    table.insert(filters, value)
                end
            end
        end
    end
    args = vim.list_extend(args, filters)

    local function format_output(output)
        return vim.json.decode(table.concat(output, '\n'))
    end

    if not callback then
        return format_output(exec_ghcmd(ghcmd, args))
    end

    exec_ghcmd(ghcmd, args, function(output)
        callback(format_output(output))
    end)
end

function M.get_pr_checks(opts, callback)
    vim.validate {
        opts = { opts, 'table', true },
        callback = { callback, 'function', true },
    }
    opts = opts or {}

    local ghcmd = 'pr'
    local args = { 'view', '--json', 'statusCheckRollup' }

    if opts.number or opts.url or opts.branch then
        table.insert(args, 2, opts.number or opts.url or opts.branch)
    end

    local function format_output(output)
        local json = vim.json.decode(table.concat(output, '\n'))
        local checks = {}
        for _, check in ipairs(json.statusCheckRollup) do
            local name = check.name or check.context
            checks[name] = {
                pass = (check.state or check.conclusion) == 'SUCCESS',
                running = check.state == 'PENDING',
                url = check.detailsUrl or check.targetUrl,
            }
        end
        return checks
    end

    if not callback then
        return format_output(exec_ghcmd(ghcmd, args))
    end

    exec_ghcmd(ghcmd, args, function(output)
        callback(format_output(output))
    end)
end

function M.create_pr(opts, callback)
    vim.validate {
        opts = { opts, 'table', true },
        callback = { callback, 'function', true },
    }
    opts = opts or {}

    local ghcmd = 'pr'
    local args = { 'create', '--assignee', '@me', '--fill' }
    vim.list_extend(args, opts.args or {})

    if not callback then
        return exec_ghcmd(ghcmd, args)
    end

    exec_ghcmd(ghcmd, args, function(output)
        callback(output)
    end)
end

-- TODO: Add an auto create option ?
function M.edit_pr(opts, callback)
    vim.validate {
        opts = { opts, 'table', true },
        callback = { callback, 'function', true },
    }
    opts = opts or {}

    local ghcmd = 'pr'
    local args = { 'edit', require('utils.git').get_branch() }
    vim.list_extend(args, opts.args or {})

    if not callback then
        return exec_ghcmd(ghcmd, args)
    end

    exec_ghcmd(ghcmd, args, function(output)
        callback(output)
    end)
end

-- TODO: Add an auto create option ?
function M.pr_ready(is_ready, callback)
    vim.validate {
        is_ready = { is_ready, 'boolean', true },
        callback = { callback, 'function', true },
    }

    local ghcmd = 'pr'
    local args = { 'ready' }

    if is_ready == false then
        table.insert(args, '--undo')
    end

    if not callback then
        return exec_ghcmd(ghcmd, args)
    end

    exec_ghcmd(ghcmd, args, function(output)
        callback(output)
    end)
end

function M.get_repo_reviewers(callback)
    vim.validate {
        callback = { callback, 'function', true },
    }

    local ghcmd = 'api'
    local args = {
        '--hostname',
        'HOSTNAME',
        '-H',
        'Accept: application/vnd.github+json',
        '-H',
        'X-GitHub-Api-Version: 2022-11-28',
        '/repos/%s/collaborators',
    }

    local reviewers = {}

    local function get_approvers(info)
        for _, user in ipairs(info) do
            if user.role_name == 'write' or user.role_name == 'admin' then
                reviewers[user.login] = user
            end
        end
        return reviewers
    end

    local function parse_api_collaborators(url, cb)
        local repo
        local hostname = (url:match 'https?://([%w%d_%-%.]+)')
        if hostname then
            repo = url:match 'https?://[%w%d_%-%.]+/(.+)'
        else
            hostname = (url:match '%w+@([%w%d_%-%.]+):')
            repo = url:match '%w+@[%w%d_%-%.]+:(.+)'
        end

        args[2] = (hostname:gsub('%.git$', ''))
        args[#args] = args[#args]:format((repo:gsub('%.git$', '')))
        if not cb then
            local json = table.concat(exec_ghcmd(ghcmd, args), '\n')
            return get_approvers(vim.json.decode(json))
        end
        exec_ghcmd(ghcmd, args, function(output)
            local info = vim.json.decode(table.concat(output, ''))
            callback(get_approvers(info))
        end)
    end

    if not callback then
        local url
        local ok, remote = pcall(require('utils.git').get_remote)
        if ok then
            url = remote.url
        else
            local remotes = require('utils.git').get_remotes()
            url = remotes.origin or next(remotes)
        end
        return parse_api_collaborators(url)
    end

    require('utils.git').get_remotes(function(remotes)
        local url = remotes.origin or next(remotes)
        parse_api_collaborators(url, callback)
    end)
end

return M

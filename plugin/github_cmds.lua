local executable = require('utils.files').executable

if executable 'gh' then
    local completions = require 'completions'
    local comp_utils = require 'completions.utils'

    local function pr_create(args, ready)
        if #args > 0 then
            args = vim.list_extend({ '--reviewer' }, { table.concat(args, ',') })
        end
        if not ready then
            table.insert(args, '--draft')
        end
        require('utils.gh').create_pr({ args = args }, function(_)
            vim.notify('PR created! ', vim.log.levels.INFO, { title = 'GH' })
        end)
    end

    local function select_pr(callback)
        local gh = require 'utils.gh'
        gh.list_repo_pr({}, function(list_pr)
            local titles = vim.tbl_map(function(pull_request)
                return string.format(
                    '[%s] %d: %s',
                    pull_request.isDraft and 'Draft' or 'Ready',
                    pull_request.number,
                    pull_request.title
                )
            end, vim.deepcopy(list_pr))
            vim.ui.select(
                titles,
                { prompt = 'Select PR: ' },
                vim.schedule_wrap(function(choice)
                    if choice ~= '' then
                        local pr_id = vim.tbl_filter(function(pull_request)
                            return string.format(
                                '[%s] %d: %s',
                                pull_request.isDraft and 'Draft' or 'Ready',
                                pull_request.number,
                                pull_request.title
                            ) == choice
                        end, list_pr)[1]
                        if pr_id then
                            callback(pr_id.number)
                        end
                    end
                end)
            )
        end)
    end

    local function pr_view(args, current)
        local gh = require 'utils.gh'
        local pr
        if tonumber(args) then
            pr = tonumber(args)
        elseif not current and args ~= 'current' then
            select_pr(gh.open_pr)
            return
        end

        gh.open_pr(pr)
    end

    local function pr_checkout(pr)
        local gh = require 'utils.gh'
        if not pr then
            select_pr(gh.pr_checkout)
            return
        end

        gh.list_repo_pr({}, function(list_pr)
            local pr_id = vim.tbl_filter(function(pull_request)
                return pull_request.number == tonumber(pr) or pull_request.title == pr
            end, list_pr)[1]

            if not pr_id then
                vim.notify('PR not found: ' .. pr, vim.log.levels.ERROR, { title = 'GH' })
                return
            end

            gh.pr_checkout(pr_id.number)
        end)
    end

    local function pr_approve(is_approved, comment)
        local msg = 'PR ' .. (is_approved and 'approved' or 'disapproved')
        if comment and comment ~= '' then
            msg = msg .. ' with comment: ' .. comment
        end
        require('utils.gh').pr_review(is_approved, nil, comment, function()
            vim.notify(msg, vim.log.levels.INFO, { title = 'GH' })
        end)
    end

    --- @param opts Command.Opts
    vim.api.nvim_create_user_command('PR', function(opts)
        local args = opts.fargs
        local subcmd = args[1]
        local gh = require 'utils.gh'

        if subcmd == 'create' or subcmd == 'open' then
            pr_create(vim.list_slice(args, 2), opts.bang)
        elseif subcmd == 'ready' or subcmd == 'draft' then
            local is_ready = subcmd == 'ready'
            gh.pr_ready(is_ready, function(_)
                local msg = ('PR move to %s'):format(subcmd)
                vim.notify(msg, vim.log.levels.INFO, { title = 'GH' })
            end)
        elseif subcmd == 'view' then
            pr_view(args[2], opts.bang)
        elseif subcmd == 'checkout' then
            pr_checkout(args[2])
        elseif subcmd == 'review' then
            local function start_review()
                require('utils.git').get_remote(function(info)
                    gh.get_pr_base_branch(nil, function(base)
                        local remote = (info.remote:gsub('/.*', ''))
                        vim.g.pr_base_branch = string.format('%s/%s', remote, base)
                        vim.cmd.DiffviewOpen { args = { vim.g.pr_base_branch .. '...HEAD' } }
                    end)
                end)
            end
            if opts.bang then
                select_pr(function(pr_id)
                    gh.pr_checkout(pr_id, function()
                        start_review()
                    end)
                end)
            else
                start_review()
            end
        elseif subcmd == 'approve' or subcmd == 'disapprove' then
            if opts.bang then
                pr_approve(subcmd == 'approve', nil)
                return
            end
            vim.ui.input({ prompt = 'Add comment: ' }, function(input)
                if input and input ~= '' then
                    pr_approve(subcmd == 'approve', input)
                end
            end)
        elseif subcmd == 'markview' or subcmd == 'unmarkview' then
            local filename = vim.api.nvim_buf_get_name(0)
            filename = require('utils.files').remove_cwd_from_filepath(
                require('utils.buffers').convert_virtual_fname(filename)
            )
            gh.pr_mark_view({
                filename = filename,
                view = subcmd == 'markview',
            }, function(_)
                vim.print(
                    string.format('File marked as %s: %s', (subcmd == 'markview' and 'viewed' or 'unviewed'), filename)
                )
            end)
        end
    end, {
        nargs = '+',
        bang = true,
        complete = comp_utils.get_completion({
            'checkout',
            'review',
            'create',
            'ready',
            'draft',
            'approve',
            'disapprove',
            'markview',
            'unmarkview',
            -- 'getchanges',
        }, {
            ['view'] = function(_)
                return { 'current' }
            end,
        }, true),
        desc = 'Administer GitHub PRs',
    })

    --- @param opts Command.Opts
    vim.api.nvim_create_user_command('Comment', function(opts)
        local filename = vim.api.nvim_buf_get_name(0)
        filename = require('utils.buffers').convert_virtual_fname(filename)
        filename = require('utils.files').remove_cwd_from_filepath(filename)

        local range
        if opts.range > 0 then
            range = { opts.line1, opts.line2 }
        end

        local comment = vim.fn.input 'Add comment: '
        if not comment or comment == '' then
            return
        end

        require('utils.gh').add_file_comment(filename, comment, range, nil, function(_)
            vim.notify(string.format('Comment added to %s', filename), vim.log.levels.INFO, { title = 'GH' })
        end)
    end, {
        range = true,
        desc = 'Add a PR review comment to the current file (optionally on a visual/line range)',
    })

    --- @param opts Command.Opts
    vim.api.nvim_create_user_command('ReviewerEdit', function(opts)
        local reviewers = { table.concat(opts.fargs, ',') }
        local action = opts.fargs[1]:gsub('^%-+', '')
        local command = action == 'add' and '--add-reviewer' or '--remove-reviewer'
        opts.fargs = vim.list_extend({ command }, reviewers)
        opts.args = table.concat(opts.fargs, ' ')
        require('utils.gh').edit_pr({ args = opts.fargs }, function(_)
            local msg = ('Reviewers %s were %s'):format(action .. 'ed', table.concat(reviewers, ''))
            vim.notify(msg, vim.log.levels.INFO, { title = 'GH' })
        end)
    end, {
        nargs = '+',
        complete = completions.gh_edit_reviewers,
        bang = true,
        desc = 'Add/Remove reviewers defined in reviewers.json or .github/teams.yml or .github/CODEOWNERS',
    })
end

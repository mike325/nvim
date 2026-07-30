local executable = require('utils.files').executable

if executable 'gh' then
    local nvim = require 'nvim'
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

    local function pr_view(args, current)
        local gh = require 'utils.gh'
        local pr
        if tonumber(args) then
            pr = tonumber(args)
        elseif not current and args ~= 'current' then
            gh.list_repo_pr({}, function(list_pr)
                local titles = vim.tbl_map(function(pull_request)
                    return pull_request.title
                end, vim.deepcopy(list_pr))
                vim.ui.select(
                    titles,
                    { prompt = 'Select PR: ' },
                    vim.schedule_wrap(function(choice)
                        if choice ~= '' then
                            local pr_id = vim.tbl_filter(function(pull_request)
                                return pull_request.title == choice
                            end, list_pr)[1]
                            if pr_id then
                                gh.open_pr(pr_id.number)
                            end
                        end
                    end)
                )
            end)
            return
        end

        gh.open_pr(pr)
    end

    local function pr_approve(is_approved, comment)
        local msg = 'PR ' .. (is_approved and 'approved' or 'disapproved')
        if comment and comment ~= '' then
            msg = msg .. ' with comment: ' .. comment
        end
        require('utils.gh').pr_review(is_approved, nil, comment, function()
            vim.print(msg)
        end)
    end

    --- @param opts Command.Opts
    nvim.command.set('PR', function(opts)
        local args = opts.fargs
        local subcmd = args[1]

        if subcmd == 'create' or subcmd == 'open' then
            pr_create(vim.list_slice(args, 2), opts.bang)
        elseif subcmd == 'ready' or subcmd == 'draft' then
            local is_ready = subcmd == 'ready'
            require('utils.gh').pr_ready(is_ready, function(_)
                local msg = ('PR move to %s'):format(subcmd)
                vim.notify(msg, vim.log.levels.INFO, { title = 'GH' })
            end)
        elseif subcmd == 'view' then
            pr_view(args[2], opts.bang)
        elseif subcmd == 'review' then
            require('utils.git').get_remote(function(info)
                require('utils.gh').get_pr_base_branch(nil, function(base)
                    local remote = (info.remote:gsub('/.*', ''))
                    vim.cmd.DiffviewOpen { args = { string.format('%s/%s...', remote, base) } }
                end)
            end)
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
            require('utils.gh').pr_mark_view({
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
    nvim.command.set('EditReviewers', function(opts)
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

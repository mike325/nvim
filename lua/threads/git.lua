local M = {}

function M.get_hunks(thread_args, async)
    thread_args = require('threads').init(thread_args)

    local utils = require 'utils.files'
    local args = thread_args.args

    local git_cmd = {
        'git',
        'show',
        (args.revision or 'HEAD') .. ':',
    }

    local hunks = {
        items = {},
        diffs = {},
    }
    local diff_opts = { result_type = 'indices', algorithm = 'minimal' }
    local version = vim.is_thread() and thread_args.version or vim.version()
    if version.major > 0 or version.minor == 0 and version.minor >= 9 then
        diff_opts.linematch = true
    end
    local files = args.files
    if not files and args.revision then
        files = require('utils.git').modified_files_from_base(args.revision)
    elseif not files then
        files = require('utils.git').modified_files()
    end

    local status = require('utils.git').status()
    for _, f in ipairs(files) do
        if utils.is_file(f) then
            local is_untrack = vim.list_contains(status.untracked, f)
            if not is_untrack then
                local revision_content = io.popen(table.concat(git_cmd, ' ') .. f):read '*a'
                revision_content = (revision_content:gsub('\n$', ''))
                local workspace_content = utils.readfile(f, true)
                local diffs = vim.diff(table.concat(workspace_content, '\n'), revision_content, diff_opts)
                hunks.diffs[f] = diffs
                for _, diff in ipairs(diffs) do
                    table.insert(
                        hunks.items,
                        { filename = f, lnum = diff[1], text = workspace_content[diff[1]], valid = true }
                    )
                end
            else
                hunks.diffs[f] = {}
                local workspace_content = utils.readfile(f, true)
                table.insert(hunks.items, { filename = f, lnum = 1, text = workspace_content[1], valid = true })
            end
        end
    end

    local rt = vim.is_thread() and vim.json.encode(hunks) or hunks
    if async then
        vim.uv.async_send(async, rt)
        return
    end
    return rt
end

return M

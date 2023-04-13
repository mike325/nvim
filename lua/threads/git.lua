local M = {}

function M.get_hunks(thread_args)
    thread_args = require('threads').init(thread_args)

    local utils = require 'utils.files'
    local args = thread_args.args

    local git_cmd = {
        'git',
        'show',
        (args.revision or 'HEAD') .. ':',
    }

    local hunks = {}
    local diff_opts = { result_type = 'indices', algorithm = 'minimal' }
    local version = thread_args.version
    if version.major > 0 or version.minor == 0 and version.minor >= 9 then
        diff_opts.linematch = true
    end
    for _, f in ipairs(args.files) do
        if utils.is_file(f) then
            local revision_content = io.popen(table.concat(git_cmd, ' ') .. f):read '*a'
            revision_content = (revision_content:gsub('\n$', ''))
            local workspace_content = utils.readfile(f, true)
            local diffs = vim.diff(table.concat(workspace_content, '\n'), revision_content, diff_opts)
            for _, diff in ipairs(diffs) do
                table.insert(hunks, { filename = f, lnum = diff[1], text = workspace_content[diff[1]], valid = true })
            end
        end
    end

    return vim.is_thread() and vim.json.encode(hunks) or hunks
end

return M

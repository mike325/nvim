local M = {}

function M.get_pr_changes(opts)
    local action = opts.args:gsub('%-', '')
    RELOAD('utils.functions').async_execute {
        cmd = { 'gh', 'pr', 'view', '--json', 'files,baseRefName' },
        progress = false,
        context = 'GitHub',
        title = 'GitHub',
        callbacks_on_success = function(job)
            local json = vim.json.decode(table.concat(job:output(), '\n'))
            local files = {}
            for _, file in ipairs(json.files) do
                table.insert(files, file.path)
            end
            if #files > 0 then
                local cwd = vim.pesc(require('utils.files').getcwd()) .. '/'
                for _, f in ipairs(files) do
                    -- NOTE: using badd since `:edit` load every buffer and `bufadd()` set buffers as hidden
                    vim.cmd.badd((f:gsub('^' .. cwd, '')))
                end
                local qfutils = RELOAD 'utils.qf'
                if action == 'qf' then
                    qfutils.dump_files(files, { open = true })
                elseif action == 'hunks' then
                    local revision = json.baseRefName
                    RELOAD('threads').queue_thread(RELOAD('threads.git').get_hunks, function(hunks)
                        if #hunks > 0 then
                            qfutils.set_list { items = hunks, open = not qfutils.is_open() }
                        end
                    end, { revision = revision, files = files })
                elseif action == 'open' or action == '' then
                    vim.api.nvim_win_set_buf(0, vim.fn.bufadd(files[1]))
                end
            end
        end,
    }
end

return M

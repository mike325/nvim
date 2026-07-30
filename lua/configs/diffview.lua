local diffview = vim.F.npcall(require, 'diffview')

if not diffview then
    return false
end

diffview.setup {
    diff_binaries = false, -- Show diffs for binaries
    use_icons = true,
    file_panel = {
        win_config = {
            width = 35,
        },
    },
    hooks = {
        view_closed = function(_)
            for buf in vim.iter(vim.g.diffview_bufs or {}) do
                if vim.api.nvim_buf_is_valid(buf) and vim.b.buf_view_status then
                    vim.b.buf_view_status = nil
                end
            end
            vim.g.diffview_bufs = nil
        end,
        view_opened = function(_)
            require('utils.gh').get_view_files(nil, function(files)
                vim.t.files_status = files
            end)
        end,
        diff_buf_win_enter = function(bufnr, _, _)
            vim.t.files_status = vim.t.files_status or {}
            local filename = vim.api.nvim_buf_get_name(bufnr)
            filename = require('utils.files').remove_cwd_from_filepath(
                require('utils.buffers').convert_virtual_fname(filename)
            )
            vim.b.buf_view_status = vim.t.files_status[filename] or 'UNVIEWED'
        end,
        diff_buf_read = function(bufnr, _)
            local diffview_bufs = vim.g.diffview_bufs or {}
            diffview_bufs[bufnr] = true
            vim.g.diffview_bufs = diffview_bufs
        end,
    },
    keymaps = {
        view = {
            ['<leader>q'] = function()
                require('diffview.config').actions.close(true)
            end,
            -- TODO: Add statusline indicator
            ['<leader>v'] = function()
                local filename = vim.api.nvim_buf_get_name(0)
                filename = require('utils.files').remove_cwd_from_filepath(
                    require('utils.buffers').convert_virtual_fname(filename)
                )
                require('utils.gh').pr_mark_view({
                    filename = filename,
                }, function(_)
                    local files = vim.t.files_status or {}
                    files[filename] = 'VIEWED'
                    vim.t.files_status = files
                    require('diffview.config').actions.select_next_entry()
                end)
            end,
            ['<leader>u'] = function()
                local filename = vim.api.nvim_buf_get_name(0)
                filename = require('utils.files').remove_cwd_from_filepath(
                    require('utils.buffers').convert_virtual_fname(filename)
                )
                require('utils.gh').pr_mark_view({
                    filename = filename,
                    view = false,
                }, function(_)
                    local files = vim.t.files_status or {}
                    files[filename] = 'UNVIEWED'
                    vim.t.files_status = files
                    vim.print(string.format('File marked as unviewed: %s', filename))
                end)
            end,
            ['<leader>a'] = function()
                vim.ui.input({ prompt = 'Add comment: ' }, function(input)
                    local msg = 'PR Approved'
                    if input and input ~= '' then
                        msg = msg .. ' with comment: ' .. input
                    end

                    require('utils.gh').pr_review(true, nil, input, function()
                        vim.print(msg)
                    end)
                end)
            end,
            ['<leader>d'] = function()
                vim.ui.input({ prompt = 'Add comment: ' }, function(input)
                    local msg = 'PR Disapproved'
                    if input and input ~= '' then
                        msg = msg .. ' with comment: ' .. input
                    end

                    require('utils.gh').pr_review(false, nil, input, function()
                        vim.print(msg)
                    end)
                end)
            end,
        },
    },
}

return true

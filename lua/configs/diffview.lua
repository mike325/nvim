local diffview = vim.F.npcall(require, 'diffview')

if not diffview then
    return false
end

local function set_buf_comments(bufnr, filename)
    local io_utils = require 'utils.files'
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if
        vim.t.pr_inline_comments
        and vim.t.pr_inline_comments[filename]
        and (filename == io_utils.remove_cwd_from_filepath(bufname) or bufname:match(vim.t.git_info.sha))
    then
        require('utils.gh').set_comment_diagnostics(bufnr, vim.t.pr_inline_comments[filename], true)
        vim.b[bufnr].comments_set = true
    end
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
            for buf, _ in pairs(vim.g.diffview_bufs or {}) do
                if vim.api.nvim_buf_is_valid(buf) and vim.b.buf_view_status then
                    vim.b.buf_view_status = nil
                end
            end
            vim.g.diffview_bufs = nil
            if vim.g.pr_base_branch then
                vim.g.pr_base_branch = nil
            end
        end,
        view_opened = function(_)
            vim.t.files_status = {}
            if vim.g.pr_base_branch then
                local gh = require 'utils.gh'
                gh.get_view_files(nil, function(files)
                    vim.t.files_status = files
                end)

                gh.get_pr_inline_comments(nil, {}, function(pr_comments)
                    vim.t.pr_inline_comments = pr_comments
                    local diagnostics = {}
                    for path, comments in pairs(pr_comments) do
                        local bufnr = vim.fn.bufadd(path)
                        if not vim.api.nvim_buf_is_loaded(bufnr) then
                            vim.fn.bufload(bufnr)
                        end
                        vim.list_extend(diagnostics, gh.set_comment_diagnostics(bufnr, comments))
                    end

                    if next(diagnostics) ~= nil then
                        require('utils.qf').diagnostics_to_qf(diagnostics, {
                            title = 'GithubComments',
                            open = false,
                            jump = false,
                        })
                    end

                    if vim.t.missing_buffers then
                        for path, _ in pairs(pr_comments) do
                            if vim.t.missing_buffers[path] then
                                set_buf_comments(vim.t.missing_buffers[path], path)
                            end
                        end
                        vim.t.missing_buffers = nil
                    end
                end)
            end
        end,
        diff_buf_win_enter = function(bufnr, _, _)
            vim.t.files_status = vim.t.files_status or {}
            local io_utils = require 'utils.files'
            local bufname = vim.api.nvim_buf_get_name(bufnr)
            local filename = io_utils.remove_cwd_from_filepath(require('utils.buffers').convert_virtual_fname(bufname))
            vim.b.buf_view_status = vim.t.files_status[filename] or 'UNVIEWED'
        end,
        diff_buf_read = function(bufnr, _)
            local diffview_bufs = vim.g.diffview_bufs or {}
            diffview_bufs[bufnr] = true
            vim.g.diffview_bufs = diffview_bufs

            local io_utils = require 'utils.files'
            local bufname = vim.api.nvim_buf_get_name(bufnr)
            local filename = io_utils.remove_cwd_from_filepath(require('utils.buffers').convert_virtual_fname(bufname))
            if vim.t.pr_inline_comments and vim.t.git_info and not vim.b.comments_set then
                set_buf_comments(bufnr, filename)
            elseif not vim.t.pr_inline_comments and (vim.t.git_info and not vim.b.comments_set) then
                local missing_buffers = vim.t.missing_buffers or {}
                missing_buffers[filename] = bufnr
                vim.t.missing_buffers = missing_buffers
            end
        end,
    },
    keymaps = {
        view = {
            ['<leader>q'] = function()
                require('diffview.config').actions.close(true)
            end,
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

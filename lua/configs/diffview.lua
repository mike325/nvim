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
                    local msg = 'PR Disaapproved'
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

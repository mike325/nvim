local diffview = vim.F.npcall(require, 'diffview')

if diffview == nil then
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
        },
    },
}

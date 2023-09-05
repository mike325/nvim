local diffview = vim.F.npcall(require, 'diffview')

if diffview == nil then
    return false
end

local has_devicons = vim.F.npcall(require, 'nvim-web-devicons')
diffview.setup {
    diff_binaries = false, -- Show diffs for binaries
    use_icons = has_devicons ~= nil, -- Requires nvim-web-devicons
    file_panel = {
        win_config = {
            width = 35,
        },
    },
}

-- TODO: Use Gum when running in cli/nvim -l mode
local mini_pick = vim.F.npcall(require, 'mini.pick')

if mini_pick then
    vim.ui.select = mini_pick.ui_select
end

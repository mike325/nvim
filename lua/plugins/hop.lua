local hop = vim.F.npcall(require, 'hop')

if not hop then
    return false
end

hop.setup {}

vim.keymap.set('n', [[\]], "<cmd>lua require'hop'.hint_char1()<CR>", { noremap = true })

return true

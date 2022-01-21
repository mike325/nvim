local load_module = require('utils.helpers').load_module

local hop = load_module 'hop'

if not hop then
    return false
end

hop.setup {}

vim.keymap.set('n', 'f', "<cmd>lua require'hop'.hint_char1()<CR>", { noremap = true })
vim.keymap.set('n', 'F', "<cmd>lua require'hop'.hint_char1()<CR>", { noremap = true })
vim.keymap.set('n', 't', "<cmd>lua require'hop'.hint_char1()<CR>", { noremap = true })
vim.keymap.set('n', 'T', "<cmd>lua require'hop'.hint_char1()<CR>", { noremap = true })

return true

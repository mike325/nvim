vim.keymap.set('n', 'q', '<cmd>q!<CR>', { noremap = true, silent = true, nowait = true, buffer = true })

if not vim.g.loaded_cfilter then
    vim.cmd.packadd { args = { 'cfilter' }, bang = false }
    vim.g.loaded_cfilter = true
end

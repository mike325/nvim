vim.g.signify_cursorhold_insert = 1
vim.g.signify_cursorhold_normal = 1
vim.g.signify_update_on_focusgained = 1
vim.g.signify_update_on_bufenter = 0

vim.g.signify_skip_filetype = {
    log = 1,
}

vim.g.signify_skip_filename_pattern = {
    '*.log',
}

vim.keymap.set('n', ']h', '<plug>(signify-next-hunk)')
vim.keymap.set('n', '[h', '<plug>(signify-prev-hunk)')
vim.keymap.set('o', 'ih', '<plug>(signify-motion-inner-pending)')
vim.keymap.set('x', 'ih', '<plug>(signify-motion-inner-visual)')
vim.keymap.set('o', 'ah', '<plug>(signify-motion-outer-pending)')
vim.keymap.set('x', 'ah', '<plug>(signify-motion-outer-visual)')
vim.keymap.set('n', '=f', '<cmd>SignifyHunkDiff<CR>', { silent = true, noremap = true })
vim.keymap.set('n', '=u', '<cmd>SignifyHunkUndo<CR>', { silent = true, noremap = true })

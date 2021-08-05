
vim.g.signify_cursorhold_insert     = 1
vim.g.signify_cursorhold_normal     = 1
vim.g.signify_update_on_focusgained = 1
vim.g.signify_update_on_bufenter    = 0

vim.g.signify_skip_filetype = {
    log = 1,
}

vim.g.signify_skip_filename_pattern = {
    '*.log',
}

vim.api.nvim_set_keymap('n', ']h', '<plug>(signify-next-hunk)', {})
vim.api.nvim_set_keymap('n', '[h', '<plug>(signify-prev-hunk)', {})

vim.api.nvim_set_keymap('o', 'ih', '<plug>(signify-motion-inner-pending)', {})
vim.api.nvim_set_keymap('x', 'ih', '<plug>(signify-motion-inner-visual)', {})
vim.api.nvim_set_keymap('o', 'ah', '<plug>(signify-motion-outer-pending)', {})
vim.api.nvim_set_keymap('x', 'ah', '<plug>(signify-motion-outer-visual)', {})

vim.api.nvim_set_keymap('n', '=f', '<cmd>SignifyHunkDiff<CR>', {silent = true, noremap = true})
vim.api.nvim_set_keymap('n', '=u', '<cmd>SignifyHunkUndo<CR>', {silent = true, noremap = true})

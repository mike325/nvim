-- local sys = require'sys'
local get_icon = require('utils.helpers').get_icon

-- vim.g.neomake_ft_maker_remove_invalid_entries = 1

vim.g.neomake_error_sign = {
    text = get_icon 'error',
    texthl = 'NeomakeErrorSign',
}
vim.g.neomake_warning_sign = {
    text = get_icon 'warn',
    texthl = 'NeomakeWarningSign',
}
vim.g.neomake_info_sign = {
    text = get_icon 'info',
    texthl = 'NeomakeInfoSign',
}
vim.g.neomake_message_sign = {
    text = get_icon 'message',
    texthl = 'NeomakeMessageSign',
}

-- Don't show the location list, silently run Neomake
vim.g.neomake_open_list = 0

vim.g.neomake_echo_current_error = 0
vim.g.neomake_virtualtext_current_error = 1
vim.g.neomake_virtualtext_prefix = get_icon 'virtual_text' .. ' '

-- function! plugins#neomake#makeprg() abort
--     if empty(&makeprg)
--         return
--     endif
--     local ft = &filetype
--     local makeprg = map(split(&makeprg, ' '), {key, val -> substitute(val, '^%$', '%t', 'g') })
--     local executable = l:makeprg[0]
--     local args = l:makeprg[1:]
--     local name = plugins#convert_name(l:executable)

--     let b:neomake_{l:ft}_enabled_makers = [l:name]
--     let b:neomake_{l:ft}_{l:name}_maker = {
--         \   'exe': l:executable,
--         \   'args': l:args,
--         \   'errorformat': !empty(&l:errorformat) ? &l:errorformat : &errorformat,
--         \}
-- endfunction

-- augroup NeomakeConfig
--     autocmd!
--     autocmd OptionSet makeprg call plugins#neomake#makeprg()
-- augroup end

-- local triggers = {'nrw', 200}
-- if sys.name == 'windows' then
--     triggers = {
--         {
--             InsertLeave = {},
--             BufWinEnter = {},
--             BufWritePost = {delay = 0},
--         },
--         500
--     }
-- end

-- if vim.v.vim_did_enter == 1 then
--     -- silent! call neomake#configure#automake(s:triggers[0], s:triggers[1])
-- else
--     -- augroup NeomakeConfig
--     --     autocmd VimEnter * silent! call neomake#configure#automake(s:triggers[0], s:triggers[1])
--     -- augroup end
-- end

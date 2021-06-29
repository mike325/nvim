local get_icon = require'utils.helpers'.get_icon
local get_separators = require'utils.helpers'.get_separators

if not vim.g.started_by_firenvim then
    vim.g['airline#extensions#tabline#enabled']           = 1
    vim.g['airline#extensions#tabline#fnamemod']          = ':t'
    vim.g['airline#extensions#tabline#close_symbol']      = '×'
    vim.g['airline#extensions#tabline#show_tabs']         = 1
    vim.g['airline#extensions#tabline#show_buffers']      = 1
    vim.g['airline#extensions#tabline#show_close_button'] = 0
    vim.g['airline#extensions#tabline#show_splits']       = 0
end

vim.g.airline_highlighting_cache = 1

vim.g.airline_mode_map = {
    ['__']     = '-',
    ['c']      = 'C',
    ['i']      = 'I',
    ['ic']     = 'I',
    ['ix']     = 'I',
    ['n']      = 'N',
    ['multi']  = 'M',
    ['ni']     = 'N',
    ['no']     = 'N',
    ['R']      = 'R',
    ['Rv']     = 'R',
    ['s']      = 'S',
    ['S']      = 'SL',
    ['']     = 'SB',
    ['t']      = 'T',
    ['v']      = 'V',
    ['V']      = 'VL',
    ['']     = 'VB',
}

vim.g.airline_powerline_fonts = 1
vim.g.airline_symbols_ascii = 0

local plugins = {
    'nvimlsp',
    'neomake',
    'languageclient',
    'lsp',
    'ycm',
}

for _, i in pairs(plugins) do
    vim.g['airline#extensions#'..i..'#error_symbol'] = get_icon('error')
    vim.g['airline#extensions#'..i..'#warning_symbol'] = get_icon('warn')
end

-- vim.g['airline#extensions#hunks#hunk_symbols'] = {
--     get_icon('diff_add')..' ',
--     get_icon('diff_modified')..' ',
--     get_icon('diff_remove')..' ',
-- }

vim.g.airline_left_sep = get_separators('arrow')['left']
vim.g.airline_right_sep = get_separators('arrow')['right']

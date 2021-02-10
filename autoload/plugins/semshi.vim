scriptencoding 'utf-8'
" Semshi Setttings
" github.com/mike325/.vim

if !has#plugin('semshi') || exists('g:config_semshi')
    finish
endif

let g:config_semshi = 1

function! plugins#semshi#colorfix() abort
    hi semshiLocal           ctermfg=209 guifg=#ff875f
    hi semshiGlobal          ctermfg=214 guifg=#ffaf00
    hi semshiImported        ctermfg=214 guifg=#ffaf00 cterm=bold gui=bold
    hi semshiParameter       ctermfg=75  guifg=#5fafff
    hi semshiParameterUnused ctermfg=117 guifg=#87d7ff cterm=underline gui=underline
    hi semshiFree            ctermfg=218 guifg=#ffafd7
    hi semshiBuiltin         ctermfg=207 guifg=#ff5fff
    hi semshiAttribute       ctermfg=49  guifg=#00ffaf
    hi semshiSelf            ctermfg=249 guifg=#b2b2b2
    hi semshiUnresolved      ctermfg=226 guifg=#ffff00 cterm=underline gui=underline
    hi semshiSelected        ctermfg=231 guifg=#ffffff ctermbg=161 guibg=#d7005f

    hi semshiErrorSign       ctermfg=231 guifg=#ffffff ctermbg=160 guibg=#d70000
    hi semshiErrorChar       ctermfg=231 guifg=#ffffff ctermbg=160 guibg=#d70000

    execute 'sign define semshiError text='.tools#get_icon('error').' texthl=semshiErrorSign'
endfunction

" let $SEMSHI_LOG_FILE  = os#tmp('semshi.log')
" let $SEMSHI_LOG_LEVEL = 'DEBUG'

let g:semshi#active                       = 1
let g:semshi#simplify_markup              = 1
let g:semshi#no_default_builtin_highlight = 1

augroup SemshiColorFix
    autocmd!
    autocmd ColorScheme * call plugins#semshi#colorfix()
augroup end

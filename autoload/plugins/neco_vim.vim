" ############################################################################
"
"                               neco Setttings
"
"                                     -`
"                     ...            .o+`
"                  .+++s+   .h`.    `ooo/
"                 `+++%++  .h+++   `+oooo:
"                 +++o+++ .hhs++. `+oooooo:
"                 +s%%so%.hohhoo'  'oooooo+:
"                 `+ooohs+h+sh++`/:  ++oooo+:
"                  hh+o+hoso+h+`/++++.+++++++:
"                   `+h+++h.+ `/++++++++++++++:
"                            `/+++ooooooooooooo/`
"                           ./ooosssso++osssssso+`
"                          .oossssso-````/osssss::`
"                         -osssssso.      :ssss``to.
"                        :osssssss/  Mike  osssl   +
"                       /ossssssss/   8a   +sssslb
"                     `/ossssso+/:-        -:/+ossss'.-
"                    `+sso+:-`                 `.-/+oso:
"                   `++:.  github.com/mike325/.vim  `-/+/
"                   .`                                 `/
"
" ############################################################################

" Stole and adapted from tracyone/t-vim
function! s:get_input() abort
    let col = col( '.' )
    let line = getline( '.' )
    if col - 1 < len( line )
        return matchstr( line, '^.*\%' . col . 'c' )
    endif
    return line
endfunction

function! plugins#neco_vim#complete( findstart, base ) abort
    if !exists('g:plugs["neco-vim"]') || exists('g:plugs["deoplete.nvim"]')
        return -1
    endif

    let line_prefix = s:get_input()
    if a:findstart
        let ret = necovim#get_complete_position(line_prefix)
        if ret < 0
            return col( '.' ) " default to current
        endif
        return ret
    else
        let candidates = necovim#gather_candidates(line_prefix . a:base, a:base)
        let filtered_candidates = []
        for candidate in candidates
            if candidate.word =~? '^' . a:base
                call add(filtered_candidates, candidate)
            endif
        endfor
        return filtered_candidates
    endif
endfunction

function! plugins#neco_vim#init(data) abort
    if !exists('g:plugs["neco-vim"]') || exists('g:plugs["deoplete.nvim"]')
        return -1
    endif

    augroup Neco
        autocmd!
        autocmd FileType vim setlocal omnifunc=plugins#neco_vim#complete
    augroup end
endfunction
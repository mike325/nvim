" ############################################################################
"
"                               vim Setttings
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

function! vim#init() abort

    if has('nvim')
        return -1
    endif

    set nocompatible
    set ttyfast
    set t_Co=255
    set t_vb= " ...disable the visual effect

    set autoindent
    set autoread
    set background=dark
    set backspace=indent,eol,start
    set cscopeverbose
    set encoding=utf-8     " The encoding displayed.
    set fillchars=vert:│,fold:·
    set nofsync
    set hlsearch
    set incsearch
    set history=10000
    set langnoremap
    set laststatus=2
    set nrformats=bin,hex
    set ruler
    set shortmess=filnxtToOF
    set showcmd
    set sidescroll=1
    set smarttab
    set tabpagemax=50
    set tags=./tags;,tags
    set ttimeoutlen=50

    if exists('+display')
        set display=lastline
    endif

    if v:version >= 704
        set formatoptions=tcqj
    endif

    if exists('+belloff')
        set belloff=all " Bells are annoying
    endif

    " TODO: Something it's changing the settings in vim so recall this
    call set#initconfigs()

endfunction

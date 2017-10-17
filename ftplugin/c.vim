" HEADER {{{
"
"                                  C settings
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
" }}} END HEADER


if exists('g:plugs["YouCompleteMe"]') && exists('g:plugs["vim-fugitive"]')
    try
        function! SetExtraConf()
            let g:ycm_global_ycm_extra_conf =  fugitive#extract_git_dir(expand('%:p'))

            if g:ycm_global_ycm_extra_conf ==# ''
                let g:ycm_global_ycm_extra_conf = fnameescape(g:base_path . "ycm_extra_conf.py")
            else
                let g:ycm_global_ycm_extra_conf .=  "/ycm_extra_conf.py"
            endif
        endfunction

        call SetExtraConf()

        command! -buffer UpdateYCMConf call SetExtraConf()
    catch E117
        echomsg "Fugitive is not install, Please run :PlugInstall to get Fugitive plugin"
    endtry
endif

setlocal cindent
setlocal foldmethod=syntax

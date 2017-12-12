" ############################################################################
"
"                               YCM extra settings
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

" TODO: put all git dependent file configs here

try
    " Set project specific config
    function! s:SetProjectConfigs()
        let g:project_config =  fugitive#extract_git_dir(expand('%:p'))

        if g:project_config !=# '' && filereadable(g:project_config . "/project.vim")
            execute 'source '. g:project_config . '/project.vim'
        endif
    endfunction

    function! s:FindProjectConfig()
        if g:project_config !=# '' && filereadable(g:project_config . "/project.vim")
            execute "find " . g:project_config . '/project.vim'
        endif
    endfunction

    call s:SetProjectConfigs()

    command! UpdateProjectConfig call s:SetProjectConfigs()
    command! OpenProjectConfig call s:FindProjectConfig()
catch E117
    " TODO: Display errors/status in the start screen
    " Just a placeholder
endtry

if exists('g:plugs["YouCompleteMe"]')
    try
        function! s:SetExtraConf()
            let g:ycm_global_ycm_extra_conf =  fugitive#extract_git_dir(expand('%:p:h'))

            if g:ycm_global_ycm_extra_conf !=# '' && filereadable(g:ycm_global_ycm_extra_conf . "/ycm_extra_conf.py")
                let g:ycm_global_ycm_extra_conf .=  "/ycm_extra_conf.py"

            else
                let g:ycm_global_ycm_extra_conf = fnameescape(g:base_path . "ycm_extra_conf.py")
            endif
        endfunction

        function! s:FindExtraConfig()
            if g:ycm_global_ycm_extra_conf !=# '' && filereadable(g:ycm_global_ycm_extra_conf . "/project.vim")
                execute "find " . g:ycm_global_ycm_extra_conf
            endif
        endfunction

        call s:SetExtraConf()

        command! UpdateYCMConf call s:SetExtraConf()
        command! OpenYCMConf call s:FindExtraConfig()
    catch E117
        " TODO: Display errors/status in the start screen
        " Just a placeholder
    endtry
endif

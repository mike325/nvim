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
    function! s:GetProjectConfigs()
        let g:project_config =  fugitive#extract_git_dir(expand('%:p'))

        if g:project_config !=# '' && filereadable(g:project_config . "/project.vim")
            execute 'source '. g:project_config . '/project.vim'
        else
            echomsg "There's no project file"
        endif
    endfunction

    function! s:FindProjectConfig()
        if g:project_config !=# '' && filereadable(g:project_config . "/project.vim")
            execute "find " . g:project_config . '/project.vim'
        else
            echomsg "There's no project file"
        endif
    endfunction

    command! UpdateProjectConfig call s:GetProjectConfigs()
    command! OpenProjectConfig call s:FindProjectConfig()
catch E117
    echomsg "Fugitive is not install, Please run :PlugInstall to get Fugitive plugin"
endtry

if exists('g:plugs["YouCompleteMe"]')
    try
        function! SetExtraConf()
            let g:ycm_global_ycm_extra_conf =  fugitive#extract_git_dir(expand('%:p:h'))

            if g:ycm_global_ycm_extra_conf !=# '' && filereadable(g:ycm_global_ycm_extra_conf . "/ycm_extra_conf.py")
                let g:ycm_global_ycm_extra_conf .=  "/ycm_extra_conf.py"

                if has('nvim') && exists('g:GuiLoaded')
                    echomsg "Updated ycm extra config to " . g:ycm_global_ycm_extra_conf
                endif
            else
                let g:ycm_global_ycm_extra_conf = fnameescape(g:base_path . "ycm_extra_conf.py")
                if has('nvim') && exists('g:GuiLoaded')
                    echomsg "Using default ycm extra config"
                endif
            endif
        endfunction

        call SetExtraConf()

        command! UpdateYCMConf call SetExtraConf()
        command! OpenYCMConf execute "find " . g:ycm_global_ycm_extra_conf
    catch E117
        echomsg "Fugitive is not install, Please run :PlugInstall to get Fugitive plugin"
    endtry
endif

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
        elseif has('nvim') && exists('g:GuiLoaded')
            echomsg "There's no project file"
        endif
    endfunction

    function! s:FindProjectConfig()
        if g:project_config !=# '' && filereadable(g:project_config . "/project.vim")
            execute "find " . g:project_config . '/project.vim'
        elseif has('nvim') && exists('g:GuiLoaded')
            echomsg "There's no project file"
        endif
    endfunction

    call s:SetProjectConfigs()

    command! UpdateProjectConfig call s:SetProjectConfigs()
    command! OpenProjectConfig call s:FindProjectConfig()
catch E117
    echomsg "Fugitive is not install, Please run :PlugInstall to get Fugitive plugin"
endtry

if exists('g:plugs["YouCompleteMe"]')
    try
        function! s:SetExtraConf()
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

        function! s:FindExtraConfig()
            if g:ycm_global_ycm_extra_conf !=# '' && filereadable(g:ycm_global_ycm_extra_conf . "/project.vim")
                execute "find " . g:ycm_global_ycm_extra_conf
            elseif has('nvim') && exists('g:GuiLoaded')
                echomsg "Can't find the ycm extra config file"
            endif
        endfunction

        call s:SetExtraConf()

        command! UpdateYCMConf call s:SetExtraConf()
        command! OpenYCMConf call s:FindExtraConfig()
    catch E117
        echomsg "Fugitive is not install, Please run :PlugInstall to get Fugitive plugin"
    endtry
endif

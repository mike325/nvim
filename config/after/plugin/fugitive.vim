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

if !exists('g:plugs["vim-fugitive"]') || !exists('fugitive#extract_git_dir')
    finish
endif


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

    augroup ProjectConfig
        autocmd!
        if has("nvim")
            autocmd DirChanged * call s:SetProjectConfigs()
        endif
        autocmd VimEnter,SessionLoadPost * call s:SetProjectConfigs()
    augroup end

    if exists('g:plugs["ctrlp.vim"]')
        augroup CtrlPCache
            autocmd!
            if has("nvim")
                autocmd DirChanged * let g:ctrlp_clear_cache_on_exit = (!empty(fugitive#extract_git_dir(expand('%:p:h')))) ?  1 : (g:ctrlp_user_command.fallback =~# "^ag ")
            endif
            autocmd VimEnter,SessionLoadPost * let g:ctrlp_clear_cache_on_exit = (!empty(fugitive#extract_git_dir(expand('%:p:h')))) ?  1 : (g:ctrlp_user_command.fallback =~# "^ag ")
        augroup end
    endif

    command! UpdateProjectConfig call s:SetProjectConfigs()
    command! OpenProjectConfig call s:FindProjectConfig()

catch E117
    " TODO: Display errors/status in the start screen for GUI clients
    if !GUI()
        echoerr "We could't set extra project configs, may be because fuigitive is not ready"
    endif
endtry

" if exists('g:plugs["YouCompleteMe"]')
"     try
"         function! s:SetExtraConf()
"             let g:ycm_global_ycm_extra_conf =  fugitive#extract_git_dir(expand('%:p:h'))
"
"             if g:ycm_global_ycm_extra_conf !=# '' && filereadable(g:ycm_global_ycm_extra_conf . "/ycm_extra_conf.py")
"                 let g:ycm_global_ycm_extra_conf .=  "/ycm_extra_conf.py"
"
"             else
"                 let g:ycm_global_ycm_extra_conf = fnameescape(g:base_path . "ycm_extra_conf.py")
"             endif
"         endfunction
"
"         function! s:FindExtraConfig()
"             if g:ycm_global_ycm_extra_conf !=# '' && filereadable(g:ycm_global_ycm_extra_conf . "/project.vim")
"                 execute "find " . g:ycm_global_ycm_extra_conf
"             endif
"         endfunction
"
"         call s:SetExtraConf()
"
"         command! UpdateYCMConf call s:SetExtraConf()
"         command! OpenYCMConf call s:FindExtraConfig()
"     catch E117
"         " TODO: Display errors/status in the start screen for GUI clients
"         if !GUI()
"             echoerr "We could't set extra project configs, may be because fuigitive is not ready"
"         endif
"     endtry
" endif


function! plugins#vim_clap#init(data) abort
    if !exists('g:plugs["vim-clap"]')
        return -1
    endif

    nnoremap <C-p> :Clap files<cr>
    nnoremap <C-b> :Clap buffers<cr>
    command! Oldfiles Clap history

    " let g:clap_cache_directory = os#cache() . '/clap'
    let g:clap_layout = {
        \ 'relative': 'editor',
        \ 'width': '80%',
        \ 'height': '80%',
        \ 'row': '10%',
        \ 'col': '10%'
        \}

    let g:clap_project_root_markers = [
        \ '.projections.json',
        \ '.git',
        \ '.git/',
        \ '.svn',
        \ '.svn/',
        \ '.hg',
        \ '.hg/',
        \ 'compile_commands.json',
        \]

    " let g:clap_provider_grep_executable = tools#select_filelist(0)
    " let g:clap_provider_grep_opts = tools#select_grep(0)

endfunction

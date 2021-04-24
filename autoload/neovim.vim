" neovim Settings
" github.com/mike325/.vim

" This Autocmd file is wrapper around lua functions
" since we cannot pass lua funcref to neovim's internal options like opfunc

if !has('nvim')
    finish
endif

function! neovim#grep(type, ...) abort
    let l:visual = a:0 ? v:true : v:false
    call luaeval('require"settings.functions".opfun_grep(_A[1], _A[2])', [a:type, l:visual])
endfunction

function! neovim#gitfiles_status(gittype) abort
    let l:files = luaeval('require"git.utils".status()')
    let l:list = []
    if type(l:files) == type({})
        if type(a:gittype) == type([])
            for l:type in a:gittype
                let l:list += keys(get(l:files, l:type, {}))
            endfor
        elseif type(a:gittype) == type('')
            let l:list = keys(get(l:files, a:gittype, {}))
        endif
    endif
    return l:list
endfunction

function! neovim#gitfiles_stage(arglead, cmdline, cursorpos) abort
    return mappings#general_completion(a:arglead, a:cmdline, a:cursorpos, neovim#gitfiles_status('stage'))
endfunction

function! neovim#gitfiles_workspace(arglead, cmdline, cursorpos) abort
    let l:files = neovim#gitfiles_status(['workspace', 'untracked'])
    return mappings#general_completion(a:arglead, a:cmdline, a:cursorpos, l:files)
endfunction


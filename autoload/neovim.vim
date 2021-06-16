" neovim Settings
" github.com/mike325/.vim

" This Autocmd file is wrapper around lua functions
" since we cannot pass lua funcref to neovim's internal options like opfunc

if !has('nvim')
    finish
endif

function! neovim#general_completion(arglead, cmdline, cursorpos, options) abort
    return filter(a:options, "v:val =~? join(split(a:arglead, '\zs'), '.*')")
endfunction

function! neovim#vim_oscyank(args, _, __) abort
    return filter(['tmux', 'kitty', 'default'], "v:val =~? join(split(a:args, 'zs'), '.*')")
endfunction

function! neovim#ssh_hosts_completion(arglead, cmdline, cursorpos) abort
    let l:hosts = luaeval("vim.tbl_keys(require'utils'.system.hosts)")
    return neovim#general_completion(a:arglead, a:cmdline, a:cursorpos, l:hosts)
endfunction

function! neovim#grep(type, ...) abort
    let l:visual = a:0 ? v:true : v:false
    call luaeval('require"utils".functions.opfun_grep(_A[1], _A[2])', [a:type, l:visual])
endfunction

function! neovim#lsp_format(type, ...) abort
    " let l:visual = a:0 ? v:true : v:false
    call luaeval('require"utils".functions.opfun_lsp_format()')
endfunction

function! neovim#comment(type, ...) abort
    let l:visual = a:0 ? v:true : v:false
    call luaeval('require"utils".functions.opfun_comment(_A[1], _A[2])', [a:type, l:visual])
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
    return neovim#general_completion(a:arglead, a:cmdline, a:cursorpos, neovim#gitfiles_status('stage'))
endfunction

function! neovim#gitfiles_workspace(arglead, cmdline, cursorpos) abort
    let l:files = neovim#gitfiles_status(['workspace', 'untracked'])
    return neovim#general_completion(a:arglead, a:cmdline, a:cursorpos, l:files)
endfunction

function! neovim#inside_empty_pairs() abort
    let l:rsp = v:false
    let l:pairs = {
        \ '"': '"',
        \ "'": "'",
        \ ')': '(',
        \ '}': '{',
        \ ']': '[',
        \ '>': '<',
        \}
        " \ '(': ')',
        " \ '{': '}',
        " \ '[': ']',
        " \ '<': '>',

    let l:line = nvim_get_current_line()
    let [l:ln, l:col] = nvim_win_get_cursor(0)

    if l:col > 0
        let l:close = l:line[l:col]
        let l:open = l:line[l:col - 1]
        if get(l:pairs, l:close, -1) != -1
            let l:rsp = l:pairs[l:close] == l:open
        endif
    endif

    return l:rsp
endfunction

function! neovim#enter() abort
    let l:snippet = 0

    if has#plugin('snippets.nvim')
        let l:snippet = luaeval("require'snippets'.expand_or_advance(1)")
    elseif has#plugin('ultisnips')
        let l:snippet = UltiSnips#ExpandSnippet()
    endif

    if get(g:,'ulti_expand_res', 0) > 0
        return l:snippet
    elseif has#plugin('snippets.nvim') && l:snippet
        return ''
    elseif pumvisible()
        let l:selected = complete_info()['selected'] !=# '-1'
        if has#plugin('YouCompleteMe')
            call feedkeys("\<C-y>")
            return ''
        elseif has#plugin('nvim-compe')
            return l:selected ? compe#confirm('<CR>') : compe#close('<C-e>')
        elseif has#plugin('completion-nvim')
            if ! l:selected
                call nvim_select_popupmenu_item(-1 , v:false , v:true ,{})
            endif
            call luaeval("require'completion'.confirmCompletion()")
            return l:selected ? "\<C-y>" : ''
        endif

        return "\<C-y>"
    elseif has#plugin('nvim-autopairs')
        return luaeval('require"nvim-autopairs".autopairs_cr()')
    elseif has#plugin('pears.nvim')
        if neovim#inside_empty_pairs()
            call luaeval('require"pears".handle_return(_A)', nvim_get_current_buf())
            return ''
        endif
    elseif has#plugin('delimitMate') && delimitMate#WithinEmptyPair()
        return delimitMate#ExpandReturn()
    elseif has#plugin('ultisnips')
        call UltiSnips#JumpForwards()
        if get(g:, 'ulti_jump_forwards_res', 0) > 0
            return ''
        endif
    endif

    return "\<CR>"
endfunction

function! neovim#tab() abort
    if pumvisible()
        return "\<C-n>"
    endif
    if has#plugin('snippets.nvim')
        let l:snippet = luaeval("require'snippets'.expand_or_advance(1)")
        return ''
    elseif has#plugin('ultisnips')
        call UltiSnips#JumpForwards()
        if get(g:, 'ulti_jump_forwards_res', 0) > 0
            return ''
        endif
    endif
    return "\<TAB>"
endfunction

function! neovim#shifttab() abort
    if pumvisible()
        return "\<C-p>"
    endif
    if has#plugin('ultisnips')
        call UltiSnips#JumpBackwards()
        if get(g:, 'ulti_jump_backwards_res', 0) > 0
            return ''
        endif
    endif
    " TODO
    return ''
endfunction

function! neovim#bs() abort
    try
        execute 'pop'
    catch /E\(55\(5\|6\)\|73\|92\)/
        execute "normal! \<C-o>"
    endtry
endfunction

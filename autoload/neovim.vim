" neovim Settings
" github.com/mike325/.vim

" This Autocmd file is wrapper around lua functions
" since we cannot pass lua funcref to neovim's internal options like opfunc

if !has('nvim')
    finish
endif

function! neovim#grep(type, ...) abort
    let l:visual = a:0 ? v:true : v:false
    call luaeval('RELOAD"utils.functions".opfun_grep(_A[1], _A[2])', [a:type, l:visual])
endfunction

function! neovim#comment(type, ...) abort
    let l:visual = a:0 ? v:true : v:false
    call luaeval('RELOAD"utils.functions".opfun_comment(_A[1], _A[2])', [a:type, l:visual])
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

    if has#plugin('LuaSnip') && luasnip#expandable()
        let l:snippet = luaeval("require'luasnip'.expand()")
        return ''
    elseif get(g:,'ulti_expand_res', 0) > 0
        return l:snippet
    elseif pumvisible()
        let l:selected = complete_info()['selected'] !=# -1
        if has#plugin('YouCompleteMe')
            call feedkeys("\<C-y>")
            return ''
        elseif has#plugin('nvim-cmp')
            if l:selected
                call luaeval('require"cmp".mapping.confirm({ select = true })()')
            else
                call luaeval('require"cmp".mapping.close()()')
            endif
            return ''
        elseif has#plugin('nvim-compe')
            if l:selected
                call compe#confirm('<C-y>')
            else
                call compe#close('<C-e>')
            endif
            return ''
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

    if has#plugin('LuaSnip') && luasnip#jumpable(1)
        lua require'luasnip'.jump(1)
        return ''
    elseif has#plugin('snippets.nvim')
        let l:snippet = luaeval("require'snippets'.expand_or_advance(1)")
        return ''
    elseif has#plugin('ultisnips')
        call UltiSnips#JumpForwards()
        if get(g:, 'ulti_jump_forwards_res', 0) > 0
            return ''
        endif
    elseif has#plugin('nvim-cmp')
        call v:lua.cmp.utils.keymap.listen.run('i', '<Tab>')
        return ''
    endif
    return "\<TAB>"
endfunction

function! neovim#shifttab() abort
    if pumvisible()
        return "\<C-p>"
    endif

    if has#plugin('LuaSnip') && luasnip#jumpable(-1)
        lua require'luasnip'.jump(-1)
        return ''
    elseif has#plugin('ultisnips')
        call UltiSnips#JumpBackwards()
        if get(g:, 'ulti_jump_backwards_res', 0) > 0
            return ''
        endif
    endif
    " TODO
    return ''
endfunction

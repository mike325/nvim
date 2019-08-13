" Cpp highlight enhance settings
" github.com/mike325/.vim

function! plugins#vim_cpp_enhanced_highlight#init(data) abort
    if !exists('g:plugs["vim-cpp-enhanced-highlight"]')
        return -1
    endif

    let g:cpp_class_scope_highlight                  = 1
    let g:cpp_member_variable_highlight              = 1
    let g:cpp_class_decl_highlight                   = 1
    let g:cpp_concepts_highlight                     = 1
    let g:cpp_experimental_template_highlight        = 1
    " let g:cpp_experimental_simple_template_highlight = 1
endfunction

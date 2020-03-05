" Cpp highlight enhance settings
" github.com/mike325/.vim

if !exists('g:plugs["vim-cpp-enhanced-highlight"]') || exists('g:config_cpp_enhanced')
    finish
endif

let g:config_cpp_enhanced = 1

let g:cpp_class_scope_highlight                  = 1
let g:cpp_member_variable_highlight              = 1
let g:cpp_class_decl_highlight                   = 1
let g:cpp_concepts_highlight                     = 1
let g:cpp_experimental_template_highlight        = 1
" let g:cpp_experimental_simple_template_highlight = 1

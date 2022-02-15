require('utils.buffers').setup('cpp', {
    define = [[^\(#\s*define\|[a-z]*\s*const\(expr\)\?\s*[a-z]*\)]],
    includeexpr = [[substitute(v:fname,'\.','/','g')]],
    commentstring = '// %s',
})

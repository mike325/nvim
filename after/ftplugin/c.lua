require('utils.buffers').setup('cpp', {
    define = [[^\(#\s*define\|[a-z]*\s*const\(expr\)\?\s*[a-z]*\)]],
    commentstring = '// %s',
})

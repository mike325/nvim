local executable = require'utils.files'.executable

-- vim.opt_local.foldenable = true
-- vim.opt_local.foldmethod = 'syntax'

vim.opt_local.expandtab = true
-- vim.opt_local.shiftround = true
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 0
vim.opt_local.softtabstop = -1

vim.opt_local.define = [[^\\s*\\(def\\\|class\\)\\s\\+]]
vim.opt_local.suffixesadd:prepend('.py')
vim.opt_local.suffixesadd:prepend('__init__.py')

-- nnoremap <silent><buffer> <CR> :call mappings#cr()<CR>

vim.opt_local.formatexpr = [[luaeval('require\"format.python\".format()')]]

if executable('flake8') then
    -- let s:cmd = ['flake8']
    -- let s:path = expand(os#name('windows') ? '~/.flake8' : '~/.config/flake8')
    -- if !filereadable(s:path) && !filereadable('./tox.ini') && !filereadable('./.flake8') && !filereadable('./setup.cfg')
    --     let s:cmd += ['--max-line-length=120', '--ignore=E203,E226,E231,E261,E262,E265,E302,W391']
    -- endif
    -- let s:cmd += ['%']
    -- let &l:makeprg = join(s:cmd, ' ')
    -- vim.opt_local.makeprg = ''
    vim.opt_local.errorformat = '%f:%l:%c: %t%n %m'
elseif executable('pycodestyle') then
    vim.opt_local.makeprg = 'pycodestyle --max-line-length=120 --ignore=E121,E123,E126,E226,E24,E704,W503,W504,H233,E228,E701,E226,E251,E501,E221,E203,E27 %'
    vim.opt_local.errorformat = '%f:%l:%c: %t%n %m'
else
    vim.opt_local.makeprg = [[python3 -c "import py_compile,sys; sys.stderr=sys.stdout; py_compile.compile(r'%')"]]
    vim.opt_local.errorformat = '%C %.%#,%A  File "%f", line %l%.%#,%Z%[%^ ]%@=%m'
end

-- if has#plugin('neomake')
--     call plugins#neomake#makeprg()
-- endif

-- if !has#plugin('vim-apathy')
--     if !exists('b:python_path')
--         if !exists('g:python_path')
--             let g:python_path = split(system(get(g:, 'python3_host_prog', 'python') . ' -c "import sys; print(''\n''.join(sys.path))"')[0:-2], "\n", 1)
--             if v:shell_error
--                 let g:python_path = []
--             endif
--         endif
--         let b:python_path = g:python_path
--     end
--     let s:path = split(copy(&l:path), ',')
--     if !empty(b:python_path)
--         for s:i in b:python_path
--             if !empty(s:i) && index(s:path, s:i) == -1
--                 execute 'vim.opt_local.path+='.s:i
--             endif
--         endfor
--     endif
-- endif

-- if !exists('*s:PythonFix')
--     if !exists('*s:PythonReplace')
--         function! s:PythonReplace(pattern) abort
--             execute a:pattern
--             call histdel('search', -1)
--         endfunction
--     endif
--     function! s:PythonFix()
--         normal! m`
--         execute 'retab'
--         let l:scout = "'"
--         let l:dcout = '"'
--         let l:patterns = [
--         \   '%s/\s\zs==\ze\(\s\+\)\(None\|True\|False\)/is/g',
--         \   '%s/\s\zs!=\ze\(\s\+\)\(None\|True\|False\)/is not/g',
--         \   '%s/==\ze\(\s\+\)\(None\|True\|False\)/ is/g',
--         \   '%s/!=\ze\(\s\+\)\(None\|True\|False\)/ is not/g',
--         \   '%s/^\(\s\+\)\?\zs#\ze\([^ #!]\)/# /e',
--         \   '%s/\(except\):/\1 Exception:/e',
--         \   '%s/re\.compile(\zs\('.l:scout.'|"\)/r\1/g',
--         \]
--         for l:pattern in l:patterns
--             silent! call s:PythonReplace(l:pattern)
--         endfor
--         normal! ``
--     endfunction
-- endif
-- command! -buffer PythonFix call s:PythonFix()

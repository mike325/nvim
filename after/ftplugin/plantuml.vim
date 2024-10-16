" Plantuml Settings
" github.com/mike325/.vim

let b:plantuml_autobuild = 0

command! -buffer OpenPlantUML call system('xdg-open ' . fnamemodify(bufname('%'), ':r') . '.png')
command! -buffer AutoBuild let b:plantuml_autobuild = !b:plantuml_autobuild | echomsg (b:plantuml_autobuild ? 'AutoBuild plantuml is On!' : 'AutoBuild plantuml is Off!')

setlocal makeprg=plantuml\ %

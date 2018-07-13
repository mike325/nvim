" ############################################################################
"
"                               python Setttings
"
"                                     -`
"                     ...            .o+`
"                  .+++s+   .h`.    `ooo/
"                 `+++%++  .h+++   `+oooo:
"                 +++o+++ .hhs++. `+oooooo:
"                 +s%%so%.hohhoo'  'oooooo+:
"                 `+ooohs+h+sh++`/:  ++oooo+:
"                  hh+o+hoso+h+`/++++.+++++++:
"                   `+h+++h.+ `/++++++++++++++:
"                            `/+++ooooooooooooo/`
"                           ./ooosssso++osssssso+`
"                          .oossssso-````/osssss::`
"                         -osssssso.      :ssss``to.
"                        :osssssss/  Mike  osssl   +
"                       /ossssssss/   8a   +sssslb
"                     `/ossssso+/:-        -:/+ossss'.-
"                    `+sso+:-`                 `.-/+oso:
"                   `++:.  github.com/mike325/.vim  `-/+/
"                   .`                                 `/
"
" ############################################################################


if exists("+formatprg")
    if executable("yapf")
        setlocal formatprg=yapf\ --style\ pep8
    elseif executable("autopep8")
        setlocal formatprg=autopep8\ --experimental\ --aggressive\ --max-line-length\ 100
    endif
endif

if executable("flake8")
    setlocal makeprg=flake8\ --max-line-length=100\ --ignore=E501\ %
    let &efm='%f:%l:%c: %t%n %m'
elseif executable("pycodestyle")
    setlocal makeprg=pycodestyle\ --max-line-length=100\ --ignore=E501\ %
    let &efm='%f:%l:%c: %t%n %m'
else
    setlocal makeprg=python\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"
    setlocal efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m
endif

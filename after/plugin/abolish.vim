" ############################################################################
"
"                              Abolish extra settings
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

if !exists('g:plugs["vim-abolish"]')
    finish
endif

try
    Abolish avalib{ility,le} availab{ility, le}
    Abolish seting{s}        setting{s}
    Abolish settign{s}       setting{s}
    Abolish gti              git
    Abolish subtitution{s}   substitution{s}
    Abolish flase            false
    Abolish enviroment{s}    environment{s}
    Abolish syntaxis         syntax
    Abolish developement     development
    Abolish sustition{s}     substitution{s}
    Abolish sustitution{s}   substitution{s}
    Abolish aibbreviation{s} abbreviation{s}
    Abolish identation       indentation
    Abolish aligment         aliment
    Abolish posible          possible
    Abolish imr{pov,pvo}e    improve
    Abolish abbrevations     abbreviations
    Abolish reproducable     reproducible
    Abolish retreive         retrieve
    Abolish compeletly       completely
    Abolish abbrevation{s}   abbreviations

    Abolish {despa,sepe}rat{e,es,ed,ing,ely,ion,ions,or} {despe,sepa}rat{}
    Abolish {,in}consistant{,ly}                         {}consistent{}
    Abolish lan{gauge,gue,guege,guegae,ague,agueg}       language
    Abolish delimeter{,s}                                delimiter{}
    Abolish {,non}existan{ce,t}                          {}existen{}
    Abolish d{e,i}screp{e,a}nc{y,ies}                    d{i}screp{a}nc{}
    Abolish {,un}nec{ce,ces,e}sar{y,ily}                 {}nec{es}sar{}
    Abolish persistan{ce,t,tly}                          persisten{}
    Abolish {,ir}releven{ce,cy,t,tly}                    {}relevan{}
    Abolish cal{a,e}nder{,s}                             cal{e}ndar{}
catch E492
    if !GUI()
        augroup InitErrors
            autocmd VimEnter * echoerr 'Abolish is not install, please run :Pluginstall'
        augroup end
    endif
endtry

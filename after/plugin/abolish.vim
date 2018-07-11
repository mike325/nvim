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
    Abolish imrpove          improve
    Abolish abbrevations     abbreviations

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
    Abolish reproducable                                 reproducible
    Abolish retreive                                     retrieve
    Abolish compeletly                                   completely

catch E492

    " TODO: Improve crap fallback
    " Since we don't have Abolish, we fallback to correct simple typos

    iabbrev avalible      available
    iabbrev abbrevations  abbreviations
    iabbrev avalibility   availability
    iabbrev seting        setting
    iabbrev setings       settings
    iabbrev settign       setting
    iabbrev settigns      settings
    iabbrev gti           git
    iabbrev subtitution   substitution
    iabbrev subtitution   substitutions
    iabbrev flase         false
    iabbrev enviroment    environment
    iabbrev enviroment    environments
    iabbrev syntaxis      syntax
    iabbrev developement  development
    iabbrev sustition     substitution
    iabbrev sustition     substitutions
    iabbrev sustitution   substitution
    iabbrev sustitution   substitutions
    iabbrev aibbreviation abbreviation
    iabbrev aibbreviation abbreviations
    iabbrev identation    indentation
    iabbrev aligment      aliment
    iabbrev posible       possible
    iabbrev imrpove       improve
    iabbrev reproducable  reproducible
    iabbrev retreive      retrieve
    iabbrev compeletly    completely

    iabbrev Avalible      Available
    iabbrev Avalibility   Availability
    iabbrev Abbrevations  Abbreviations
    iabbrev Seting        Setting
    iabbrev Setings       Settings
    iabbrev Settign       Setting
    iabbrev Settigns      Settings
    iabbrev Gti           Git
    iabbrev Subtitution   Substitution
    iabbrev Subtitution   Substitutions
    iabbrev Flase         False
    iabbrev Enviroment    Environment
    iabbrev Enviroment    Environments
    iabbrev Syntaxis      Syntax
    iabbrev Developement  Development
    iabbrev Sustition     Substitution
    iabbrev Sustition     Substitutions
    iabbrev Sustitution   Substitution
    iabbrev Sustitution   Substitutions
    iabbrev Aibbreviation Abbreviation
    iabbrev Aibbreviation Abbreviations
    iabbrev Identation    Indentation
    iabbrev Aligment      Aliment
    iabbrev Posible       Possible
    iabbrev Imrpove       Improve
    iabbrev Reproducable  Reproducible
    iabbrev Retreive      Retrieve
    iabbrev Compeletly    Completely

    iabbrev AVALIBLE      AVAILABLE
    iabbrev AVALIBILITY   AVAILABILITY
    iabbrev AVALIBILITY   AVAILABILITY
    iabbrev SETING        SETTING
    iabbrev SETINGS       SETTINGS
    iabbrev SETTIGN       SETTING
    iabbrev SETTIGNS      SETTINGS
    iabbrev GTI           GIT
    iabbrev SUBTITUTION   SUBSTITUTION
    iabbrev SUBTITUTION   SUBSTITUTIONS
    iabbrev FLASE         FALSE
    iabbrev ENVIROMENT    ENVIRONMENT
    iabbrev ENVIROMENT    ENVIRONMENTS
    iabbrev SYNTAXIS      SYNTAX
    iabbrev DEVELOPEMENT  DEVELOPMENT
    iabbrev SUSTITION     SUBSTITUTION
    iabbrev SUSTITION     SUBSTITUTIONS
    iabbrev SUSTITUTION   SUBSTITUTION
    iabbrev SUSTITUTION   SUBSTITUTIONS
    iabbrev AIBBREVIATION ABBREVIATION
    iabbrev AIBBREVIATION ABBREVIATIONS
    iabbrev IDENTATION    INDENTATION
    iabbrev ALIGMENT      ALIMENT
    iabbrev POSIBLE       POSSIBLE
    iabbrev IMRPOVE       IMPROVE
    iabbrev REPRODUCABLE  REPRODUCIBLE
    iabbrev RETREIVE      RETRIEVE
    iabbrev COMPELETLY    COMPLETELY
endtry

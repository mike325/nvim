-- luacheck: globals unpack vim

local inspect = vim.inspect

local nvim       = require('nvim')
local line       = require('nvim').fn.line
local system     = require('nvim').fn.system
local executable = require('nvim').fn.executable

local sys = require('sys')
local cache = require('sys').cache

local git_version = ''
local modern_git = -1

local langservers = {
    python = {'pyls'},
    c      = {'ccls', 'clangd', 'cquery'},
    cpp    = {'ccls', 'clangd', 'cquery'},
    cuda   = {'ccls'},
    objc   = {'ccls'},
    sh     = {'bash-language-server'},
    bash   = {'bash-language-server'},
    docker = {'docker-language-server'},
    go     = {'gopls'},
    latex  = {'texlab'},
    tex    = {'texlab'},
}

-- global helpers
tools = {}

function tools.split_components(str, pattern)
     local t = {}
    for v in string.gmatch(str, pattern) do
        t[#t + 1] = v
    end
    return t
end

function tools.last_position()
    local sc_mark = nvim.buf.get_mark(0, "'")
    local dc_mark = nvim.buf.get_mark(0, '"')
    local last_line = line('$')
    local filetype = nvim.bo.filetype

    local black_list = {
        git = 1,
        gitcommit = 1,
        fugitive = 1,
        qf = 1,
    }

    if sc_mark[1] >= 1 and dc_mark[1] <= last_line and black_list[filetype] == nil then
        nvim.win_set_cursor(0, dc_mark)
    end
end

function tools.check_version(sys_version, version_target)
    for i,val in pairs(version_target) do
        if version_target[i] > sys_version[i] then
            return 0
        elseif version_target[i] < sys_version[i] then
            return 1
        elseif #version_target == i and version_target[i] == sys_version[i] then
            return 1
        end
    end
    return 0
end

function tools.has_git_version(...)
    if executable('git') == 0 then
        return 0
    end

    local args
    if ... == nil or type(...) ~= 'table' then
        args = {...}
    else
        args = ...
    end

    if #git_version == 0 then
        git_version = string.match(require'nvim'.fn.system('git --version'), '%d+%p%d+%p%d+')
    end

    if #args == 0 then
        return git_version
    end

    local components = tools.split_components(git_version, '%d+')

    return tools.check_version(components, args)
end

function tools.ignores(tool)
    local excludes = vim.split(nvim.o.backupskip, ',')

    local ignores = {
        fd = ' -E ' .. table.concat(excludes, ' -E ') .. ' ',
        find = '',
        rg = '',
        ag = ' --ignore ' .. table.concat(excludes, ' --ignore ') .. ' ',
        grep = '--exclude='.. table.concat(excludes, ' --exclude=') .. ' ',
        findstr = '',
    }

    return ignores[tool] ~= nil and ignores[tool] or ''
end

function tools.grep(tool, ...)
    local opts

    if ... == nil or type(...) ~= 'table' then
        opts = ... == nil and {} or {...}
    else
        opts = ...
    end

    local properity = #opts > 0 and opts[1] or 'grepprg'

    if modern_git == -1 then
        modern_git = tools.has_git_version('2', '19')
    end

    local greplist = {
        git = {
            grepprg = 'git --no-pager grep '.. (modern_git == 1 and '--column' or '') ..' --no-color -Iin ',
            grepformat = modern_git == 1 and '%f:%l:%c:%m,%f:%l:%m' or '%f:%l:%m',
        },
        rg = {
            grepprg = 'rg -S -n --color never -H --no-search-zip --trim --vimgrep ',
            grepformat = '%f:%l:%c:%m,%f:%l:%m'
        },
        ag = {
            grepprg = 'ag -S --follow --nogroup --nocolor --hidden --vimgrep '..tools.ignores('ag'),
            grepformat = '%f:%l:%c:%m,%f:%l:%m'
        },
        grep = {
            grepprg = 'grep -RHiIn --color=never ',
            grepformat = '%f:%l:%m'
        },
        findstr = {
            grepprg = 'findstr -rspn ',
            grepformat = '%f:%l:%m',
        },
    }

    return greplist[tool] ~= nil and greplist[tool][properity] or nil
end

function tools.filelist(tool)
    local filelist = {
        git = 'git --no-pager ls-files -co --exclude-standard',
        fd = 'fd ' .. tools.ignores('fd') .. ' --type f --hidden --follow --color never . .',
        rg = 'rg --line-number --column --with-filename --color never --no-search-zip --hidden --trim --files',
        ag = 'ag -l --follow --nocolor --nogroup --hidden '..tools.ignores('ag')..'-g ""',
        find = "find . -iname '*'",
    }

    return filelist[tool]
end

function tools.select_filelist(is_git)
    local filelist = ''

    if is_git == 0 or is_git == nil then
        is_git = false
    end

    if executable('git') and is_git then
        filelist = tools.filelist('git')
    elseif executable('fd') then
        filelist = tools.filelist('fd')
    elseif executable('rg') then
        filelist = tools.filelist('rg')
    elseif executable('ag') then
        filelist = tools.filelist('ag')
    elseif sys.name ~= 'windows' then
        filelist = tools.filelist('find')
    end

    return filelist
end

function tools.select_grep(is_git, ...)
    local opts

    if ... == nil or type(...) ~= 'table' then
        opts = ... == nil and {} or {...}
    else
        opts = ...
    end

    local properity = #opts > 0 and opts[1] or 'grepprg'

    if is_git == 0 or is_git == nil then
        is_git = false
    end

    local grep = ''

    if executable('git') and is_git then
        grep = tools.grep('git', properity)
    elseif executable('rg') then
        grep = tools.grep('rg', properity)
    elseif executable('ag') then
        grep = tools.grep('ag', properity)
    elseif executable('grep') then
        grep = tools.grep('grep', properity)
    elseif sys.name == 'windows' then
        grep = tools.grep('findstr', properity)
    end

    return grep
end

local function check_lsp(servers)
    for _, server in pairs(servers) do
        if executable(server) == 1 then
            return 1
        end
    end

    return 0
end

function tools.check_language_server(...)
    local language

    if ... == nil then
        language = nil
    elseif type(...) == 'table' then
        local tmp = ...
        language = vim.tbl_isempty(tmp) and nil or tmp[1]
    else
        language = ...
    end

    if language == nil then
        for _, servers in pairs(langservers) do
            if check_lsp(servers) == 1 then
                return 1
            end
        end
    elseif langservers[language] ~= nil then
        return check_lsp(langservers[language])
    end

    return 0
end

function tools.get_language_server(language)

    if tools.check_language_server(language) == 0 then
        return {}
    end

    local cmds = {
        ['pyls']   = { 'pyls', '--check-parent-process', '--log-file=' .. sys.tmp('pyls.log') },
        ['ccls']   = {
            'ccls',
            '--log-file=' .. sys.tmp('ccls.log'),
            '--init={"cacheDirectory":"' .. sys.cache .. '/ccls", "completion": {"filterAndSort": false}}'
        },
        ['cquery'] = {
            'cquery',
            '--log-file=' .. sys.tmp('cquery.log'),
            '--init={"cacheDirectory":"' .. sys.cache .. '/cquery", "completion": {"filterAndSort": false}}'
        },
        ['clangd'] = {'clangd', '--background-index'},
        ['gopls']  = {'gopls' },
        ['texlab'] = {'texlab' },
        ['bash-language-server'] = {'bash-language-server', 'start'},
    }

    local cmd = {}

    for _,server in pairs(langservers[language]) do
        if executable(server) then
            cmd = cmds[server]
            break
        end
    end

    return cmd
end

function tools.abolish(language)

    local abolish = {}
    local current = nvim.o.spelllang

    abolish['en'] = {
        ['flase']                                        = 'false',
        ['syntaxis']                                     = 'syntax',
        ['developement']                                 = 'development',
        ['identation']                                   = 'indentation',
        ['aligment']                                     = 'aliment',
        ['posible']                                      = 'possible',
        ['abbrevations']                                 = 'abbreviations',
        ['reproducable']                                 = 'reproducible',
        ['retreive']                                     = 'retrieve',
        ['compeletly']                                   = 'completely',
        ['movil']                                        = 'mobil',
        ['pro{j,y}ect{o}']                               = 'project',
        ['imr{pov,pvo}e']                                = 'improve',
        ['enviroment{s}']                                = 'environment{s}',
        ['sustition{s}']                                 = 'substitution{s}',
        ['sustitution{s}']                               = 'substitution{s}',
        ['aibbreviation{s}']                             = 'abbreviation{s}',
        ['abbrevation{s}']                               = 'abbreviations',
        ['avalib{ility,le}']                             = 'availab{ility,le}',
        ['seting{s}']                                    = 'setting{s}',
        ['settign{s}']                                   = 'setting{s}',
        ['subtitution{s}']                               = 'substitution{s}',
        ['{despa,sepe}rat{e,es,ed,ing,ely,ion,ions,or}'] = '{despe,sepa}rat{}',
        ['{,in}consistant{,ly}']                         = '{}consistent{}',
        ['lan{gauge,gue,guege,guegae,ague,agueg}']       = 'language',
        ['delimeter{,s}']                                = 'delimiter{}',
        ['{,non}existan{ce,t}']                          = '{}existen{}',
        ['d{e,i}screp{e,a}nc{y,ies}']                    = 'd{i}screp{a}nc{}',
        ['{,un}nec{ce,ces,e}sar{y,ily}']                 = '{}nec{es}sar{}',
        ['persistan{ce,t,tly}']                          = 'persisten{}',
        ['{,ir}releven{ce,cy,t,tly}']                    = '{}relevan{}',
        ['cal{a,e}nder{,s}']                             = 'cal{e}ndar{}'
    }

    abolish['es'] = {
        ['analisis']                                                            = 'análisis',
        ['artifial']                                                            = 'artificial',
        ['conexion']                                                            = 'conexión',
        ['autonomo']                                                            = 'autónomo',
        ['codigo']                                                              = 'código',
        ['teoricas']                                                            = 'teóricas',
        ['disminicion']                                                         = 'disminución',
        ['adminstracion']                                                       = 'administración',
        ['relacion']                                                            = 'relación',
        ['minimo']                                                              = 'mínimo',
        ['area']                                                                = 'área',
        ['imagenes']                                                            = 'imágenes',
        ['arificiales']                                                         = 'artificiales',
        ['actuan']                                                              = 'actúan',
        ['basicamente']                                                         = 'básicamente',
        ['acuardo']                                                             = 'acuerdo',
        ['carateristicas']                                                      = 'características',
        ['ademas']                                                              = 'además',
        ['asi']                                                                 = 'así',
        ['siguente']                                                            = 'siguiente',
        ['automatico']                                                          = 'automático',
        ['algun']                                                               = 'algún',
        ['dia{s}']                                                              = 'día{}',
        ['pre{sici,cisi}on']                                                    = 'precisión',
        ['pro{j,y}ect{o}']                                                      = 'proyecto',
        ['logic{as,o,os}']                                                      = 'lógic{}',
        ['{h,f}ernandez']                                                       = '{}ernández',
        ['electronico{s}']                                                      = 'electrónico{}',
        ['algorimo{s}']                                                         = 'algoritmo{}',
        ['podria{n}']                                                           = 'podría{}',
        ['metodologia{s}']                                                      = 'metodología{}',
        ['{bibliogra}fia']                                                      = '{}fía',
        ['{reflexi}on']                                                         = '{}ón',
        ['mo{b,v}il']                                                           = 'móvil',
        ['{televi,explo}sion']                                                  = '{}sión',
        ['{reac,disminu,interac,clasifica,crea,notifica,introduc,justifi}cion'] = '{}ción',
        ['{obten,ora,emo,valora,utilizap,modifica,sec,delimita,informa}cion']   = '{}ción',
        ['{fun,administra,aplica,rala,aproxima,programa}cion']                  = '{}ción',
    }

    if nvim.fn.exists(':Abolish') == 2 then
        if abolish[current] ~= nil then
            for base,replace in pairs(abolish[current]) do
                nvim.command('Abolish -delete '..base)
            end
        end
        if abolish[language] ~= nil then
            for base,replace in pairs(abolish[language]) do
                nvim.command('Abolish '..base..' '..replace)
            end
        end
    elseif current ~= language then
        if abolish[current] ~= nil then
            for base,replace in pairs(abolish[current]) do
                if not string.match(base, '{.+}') then
                    nvim.nvim_set_abbr('i', base, nil)
                end
            end
        end
        if abolish[language] ~= nil then
            for base,replace in pairs(abolish[language]) do
                if not string.match(base, '{.+}') then
                    nvim.nvim_set_abbr('i', base, replace)
                end
            end
        end
    end

end

function tools.spelllangs(lang)
    tools.abolish(lang)
    nvim.o.spelllang = lang
    print(nvim.bo.spelllang)
end

return tools

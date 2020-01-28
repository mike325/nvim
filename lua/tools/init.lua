-- luacheck: globals unpack vim

local inspect = vim.inspect

local nvim         = require('nvim')
local line         = require('nvim').fn.line
local system       = require('nvim').fn.system
local executable   = require('nvim').fn.executable
local isdirectory  = require('nvim').fn.isdirectory
local filereadable = require('nvim').fn.filereadable

local sys   = require('sys')
local cache = require('sys').cache

local plugs = nvim.plugs

local git_version = ''
local modern_git = -1

local langservers = {
    python     = {'pyls'},
    c          = {'clangd', 'ccls', 'cquery'},
    cpp        = {'clangd', 'ccls', 'cquery'},
    cuda       = {'clangd', 'ccls'},
    objc       = {'clangd', 'ccls'},
    objcpp     = {'clangd', 'ccls'},
    sh         = {'bash-language-server'},
    bash       = {'bash-language-server'},
    go         = {'gopls'},
    latex      = {'texlab'},
    tex        = {'texlab'},
    bib        = {'texlab'},
    vim        = {'vim-language-server'},
    lua        = {'sumneko_lua'},
    dockerfile = {'docker-langserver'},
    Dockerfile = {'docker-langserver'},
}

local abolish = {}
abolish['en'] = {
    ['flase']                                        = 'false',
    ['syntaxis']                                     = 'syntax',
    ['developement']                                 = 'development',
    ['identation']                                   = 'indentation',
    ['aligment']                                     = 'aliment',
    ['posible']                                      = 'possible',
    ['reproducable']                                 = 'reproducible',
    ['retreive']                                     = 'retrieve',
    ['compeletly']                                   = 'completely',
    ['movil']                                        = 'mobil',
    ['pro{j,y}ect{o}']                               = 'project',
    ['imr{pov,pvo}e']                                = 'improve',
    ['enviroment{,s}']                               = 'environment{}',
    ['sustition{,s}']                                = 'substitution{}',
    ['sustitution{,s}']                              = 'substitution{}',
    ['aibbreviation{,s}']                            = 'abbreviation{}',
    ['abbrevation{,s}']                              = 'abbreviation{}',
    ['avalib{ility,le}']                             = 'availab{ility,le}',
    ['seting{,s}']                                   = 'setting{}',
    ['settign{,s}']                                  = 'setting{}',
    ['subtitution{,s}']                              = 'substitution{}',
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
    ['dia{,s}']                                                             = 'día{}',
    ['pre{sici,cisi}on']                                                    = 'precisión',
    ['pro{j,y}ect{o}']                                                      = 'proyecto',
    ['logic{as,o,os}']                                                      = 'lógic{}',
    ['{h,f}ernandez']                                                       = '{}ernández',
    ['electronico{,s}']                                                     = 'electrónico{}',
    ['algorimo{,s}']                                                        = 'algoritmo{}',
    ['podria{,n,s}']                                                        = 'podría{}',
    ['metodologia{,s}']                                                     = 'metodología{}',
    ['{bibliogra}fia']                                                      = '{}fía',
    ['{reflexi}on']                                                         = '{}ón',
    ['mo{b,v}il']                                                           = 'móvil',
    ['{televi,explo}sion']                                                  = '{}sión',
    ['{reac,disminu,interac,clasifica,crea,notifica,introduc,justifi}cion'] = '{}ción',
    ['{obten,ora,emo,valora,utilizap,modifica,sec,delimita,informa}cion']   = '{}ción',
    ['{fun,administra,aplica,rala,aproxima,programa}cion']                  = '{}ción',
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

        if type(version_target[i]) == 'string' then
            version_target[i] = tonumber(version_target[i])
        end

        if type(sys_version[i]) == 'string' then
            sys_version[i] = tonumber(sys_version[i])
        end

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
            grepformat = '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m',
        },
        rg = {
            grepprg = 'rg -S -n --color never -H --no-search-zip --trim --vimgrep ',
            grepformat = '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m'
        },
        ag = {
            grepprg = 'ag -S --follow --nogroup --nocolor --hidden --vimgrep '..tools.ignores('ag'),
            grepformat = '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m'
        },
        grep = {
            grepprg = 'grep -RHiIn --color=never ',
            grepformat = '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m'
        },
        findstr = {
            grepprg = 'findstr -rspn ',
            grepformat = '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m',
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

    if executable('git') and is_git == true or is_git == 1 then
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

    local grep = ''

    if executable('git') and is_git == true or is_git == 1 then
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
        ['vim-language-server']  = {'vim-language-server', '--stdio'},
        ['docker-langserver']    = {'docker-langserver', '--stdio'},
    }

    local cmd = {}

    for _,server in pairs(langservers[language]) do
        if executable(server) == 1 then
            cmd = cmds[server]
            break
        end
    end

    return cmd
end

function tools.get_abbrs(language)
    return abolish[language]
end

function tools.abolish(language)

    local current = nvim.bo.spelllang

    if nvim.fn.exists(':Abolish') == 2 then
        if abolish[current] ~= nil then
            for base,replace in pairs(abolish[current]) do
                nvim.command('Abolish -delete -buffer '..base)
            end
        end
        if abolish[language] ~= nil then
            for base,replace in pairs(abolish[language]) do
                nvim.command('Abolish -buffer '..base..' '..replace)
            end
        end
    else
        local function remove_abbr(base)
            nvim.nvim_set_abbr('i', base, nil, {silent = true, buffer = true})
            nvim.nvim_set_abbr('i', base:upper(), nil, {silent = true, buffer = true})
            nvim.nvim_set_abbr('i', base:gsub('%a', string.upper, 1), nil, {silent = true, buffer = true})
        end

        local function set_abbr(base, replace)
            nvim.nvim_set_abbr('i', base, replace, {buffer = true})
            nvim.nvim_set_abbr('i', base:upper(), replace:upper(), {buffer = true})
            nvim.nvim_set_abbr('i', base:gsub('%a', string.upper, 1), replace:gsub('%a', string.upper, 1), {buffer = true})
        end

        if abolish[current] ~= nil then
            for base,replace in pairs(abolish[current]) do
                if not string.match(base, '{.+}') then
                    remove_abbr(base)
                end
            end
        end
        if abolish[language] ~= nil then
            for base,replace in pairs(abolish[language]) do
                if not string.match(base, '{.+}') then
                    set_abbr(base, replace)
                end
            end
        end
    end

end

function tools.spelllangs(lang)
    tools.abolish(lang)
    nvim.bo.spelllang = lang
    print(nvim.bo.spelllang)
end

function tools.clean_file()
    local buftypes = {
        nofile = 1,
        help = 1,
        quickfix = 1,
        terminal = 1,
    }

    local filetypes = {
        bin = 1,
        log = 1,
        git = 1,
        man = 1,
        terminal = 1,
    }

    local buftype = nvim.bo.buftype
    local filetype = nvim.bo.filetype

    if nvim.b.trim ~= 1 or buftypes[buftype] ~= nil or filetypes[filetype] ~= nil or filetype == '' then
        return 1
    end

    local position = nvim.win_get_cursor(0)
    local search_reg = nvim.fn.getreg('/')

    nvim.command('%s/\\s\\+$//e')
    nvim.fn.histdel('search', -1)

    nvim.command('%s/\\(\\s\\+\\)┊/\\1 /ge')
    nvim.fn.histdel('search', -1)

    if sys.name ~= 'windows' then
        nvim.command('%s/\\r$//ge')
        nvim.fn.histdel('search', -1)
    end

    nvim.win_set_cursor(0, position)
    nvim.fn.setreg('/', search_reg)
end

function tools.file_name(...)
    local opts

    if ... == nil or type(...) ~= 'table' then
        opts = ... == nil and {} or {...}
    else
        opts = ...
    end

    local filename = nvim.fn.expand('%:t:r')
    local extension = nvim.fn.expand('%:e')
    local skeleton = ''

    -- print('File: '..filename)
    -- print('Extention: '..extension)

    local template = #opts > 0 and opts[1] or ''

    local skeletons_path = sys.base..'/skeletons/'

    local known_names = {
        py = {'ycm_extra_conf'},
        json = {'projections'},
        c = {'main'},
        cpp = {'main'},
    }

    if #template == 0 then
        skeleton = nvim.fn.fnameescape(skeletons_path .. template)
    else
        if known_names[extension] ~= nil then
            local names = known_names[extension]
            for _,name in pairs(names) do
                if string.find(filename, name) ~= nil and filereadable(skeletons_path..name..'.'..extension) == 1 then
                    skeleton = nvim.fn.fnameescape(skeletons_path..name..'.'..extension)
                    break
                end
            end
        end

        if #skeleton == 0 then
            skeleton = nvim.fn.fnameescape(skeletons_path..'/skeleton.'..extension)
        end

    end

    -- print('Skeleton: '..skeleton)

    if filereadable(skeleton) == 1 then
        nvim.ex.keepalt('read '..skeleton)
        nvim.command('%s/\\<NAME\\>/'..filename..'/e')
        nvim.fn.histdel('search', -1)
        nvim.command('%s/\\<NAME\\ze_H\\(PP\\)\\?\\>/\\U'..filename..'/g')
        nvim.fn.histdel('search', -1)
        nvim.ex['bwipeout!'](skeleton)
        nvim.command('1delete_')
    end
end

local function find_project_root(path)
    local project_root
    local vcs_markers = {'.git', '.svn', '.hg',}
    local dir = nvim.fn.fnamemodify(path, ':p')

    for _,marker in pairs(vcs_markers) do
        project_root = nvim.fn.finddir(marker, dir..';')

        if #project_root == 0 and marker == '.git' then
            project_root = nvim.fn.findfile(marker, dir..';')
            project_root = #project_root > 0 and project_root..'/' or project_root
        end

        if #project_root > 0 then
            project_root = nvim.fn.fnamemodify(project_root, ':p:h:h')
            break
        end

    end

    return project_root
end

local function is_git_repo(root)
    local git = root .. '/.git'
    return (isdirectory(git) == 1 or filereadable(git) == 1) and true or false
end

function tools.project_config(event)
    -- print(inspect(event))

    local cwd = event.cwd or nvim.fn.getcwd()

    local root = find_project_root(cwd)

    if #root == 0 then
        root = nvim.fn.fnamemodify(cwd, ':p')
    end

    if root == nvim.b.project_root then
        return root
    end

    nvim.b.project_root = root

    local is_git = is_git_repo(nvim.b.project_root)
    local filetype = nvim.bo.filetype
    local buftype = nvim.bo.buftype

    nvim.bo.grepprg = tools.select_grep(is_git)

    local project = nvim.fn.findfile('.project.vim', cwd..';')
    if #project > 0 then
        nvim.command('source '..project)
    end

    if plugs['ultisnips'] ~= nil then
        nvim.g.UltiSnipsSnippetDirectories = {
            sys.base .. '/config/UltiSnips',
            'UltiSnips'
        }
        if isdirectory(root..'/UltiSnips') == 1 then
            nvim.g.UltiSnipsSnippetsDir = root .. '/config/UltiSnips'
            table.insert(nvim.g.UltiSnipsSnippetDirectories, 1, root..'/UltiSnips')
        else
            nvim.g.UltiSnipsSnippetsDir = sys.base .. '/config/UltiSnips'
        end
    end

    if plugs['ctrlp'] ~= nil then
        local fast_look_up = {
            ag = 1,
            fd = 1,
            rg = 1,
        }
        local fallback = nvim.g.ctrlp_user_command.fallback
        local clear_cache = is_git and 1 or (fast_look_up[fallback] ~= nil and 1 or 0)

        nvim.g.ctrlp_clear_cache_on_exit = clear_cache
    end

    if plugs['deoplete.nvim'] ~= nil and (plugs['deoplete-clang'] ~= nil or plugs['deoplete-clang2'] ~= nil) then
        nvim.g['deoplete#sources#clang#clang_complete_database'] = nil
        if filereadable(root..'/compile_commands.json') == 1 then
            nvim.g['deoplete#sources#clang#clang_complete_database'] = root
        end
    end

    if plugs['vim-grepper'] ~= nil then

        local operator = {}
        local tools = {}

        if executable('git') == 1 and is_git then
            tools[#tools + 1] = 'git'
            operator[#operator + 1] = 'git'
        end

        if executable('rg') == 1 then
            tools[#tools + 1] = 'rg'
            operator[#operator + 1] = 'rg'
        end

        if executable('ag') == 1 then
            tools[#tools + 1] = 'ag'
            operator[#operator + 1] = 'ag'
        end

        if executable('grep') == 1 then
            tools[#tools + 1] = 'grep'
            operator[#operator + 1] = 'grep'
        end

        if executable('findstr') == 1 then
            tools[#tools + 1] = 'findstr'
            operator[#operator + 1] = 'findstr'
        end

        nvim.g.grepper = {
            tools = tools,
            operator = {
                tools = operator
            },
        }

    end

    if plugs['gonvim-fuzzy'] ~= nil then
        nvim.g.gonvim_fuzzy_ag_cmd = tools.select_grep(is_git)
    end

end

return tools

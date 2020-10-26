-- luacheck: globals unpack vim

-- local inspect = vim.inspect

local sys  = require('sys')
local nvim = require('nvim')

local line         = nvim.fn.line
local system       = nvim.fn.system
local executable   = nvim.executable
local isdirectory  = nvim.isdirectory
local filereadable = nvim.filereadable

local git_version = ''
local modern_git = -1

local langservers = {
    python     = {'pyls'},
    c          = {'clangd', 'ccls', 'cquery'},
    cpp        = {'clangd', 'ccls', 'cquery'},
    cuda       = {'clangd', 'ccls', 'cquery'},
    objc       = {'clangd', 'ccls', 'cquery'},
    objcpp     = {'clangd', 'ccls', 'cquery'},
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

local split = function(str, delimiter)
    local results = {}
    for match in str:gmatch("([^"..delimiter.."]+)") do
        results[#results + 1] = match
    end
    return results
end

-- Global helpers
if tools == nil then
    tools = {}
end

function tools.load_module(name)
    local ok, M = pcall(require, name)
    if not ok then
        return nil
    end
    return M
end


function tools.check_property(tbl, prop)
   if type(tbl) == 'table' and tbl[prop] ~= nil then
       return true
   end
   return false
end


function tools.normalize_path(path)
    if path:sub(1, 1) == '~' then
        path = nvim.fn.expand(path)
    end

    return path:gsub('\\','/')
end

function tools.echoerr(msg)
    nvim.echoerr(msg)
end

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
    for i,_ in pairs(version_target) do

        if type(version_target[i]) == 'string' then
            version_target[i] = tonumber(version_target[i])
        end

        if type(sys_version[i]) == 'string' then
            sys_version[i] = tonumber(sys_version[i])
        end

        if version_target[i] > sys_version[i] then
            return false
        elseif version_target[i] < sys_version[i] then
            return true
        elseif #version_target == i and version_target[i] == sys_version[i] then
            return true
        end
    end
    return false
end

function tools.has_git_version(...)
    if not executable('git') then
        return false
    end

    local args
    if ... == nil or type(...) ~= 'table' then
        args = {...}
    else
        args = ...
    end

    if #git_version == 0 then
        git_version = string.match(system('git --version'), '%d+%p%d+%p%d+')
    end

    if #args == 0 then
        return git_version
    end

    local components = tools.split_components(git_version, '%d+')

    return tools.check_version(components, args)
end

function tools.ignores(tool)
    local excludes = split(nvim.o.backupskip, ',')

    local ignores = {
        fd = ' -E ' .. table.concat(excludes, ' -E ') .. ' ',
        find = '', -- TODO
        rg = '',
        ag = ' --ignore ' .. table.concat(excludes, ' --ignore ') .. ' ',
        grep = '--exclude='.. table.concat(excludes, ' --exclude=') .. ' ',
        findstr = '', -- TODO
    }

    return ignores[tool] ~= nil and ignores[tool] or ''
end

function tools.grep(tool, opts)

    if type(opts) ~= 'table' then
        opts = {opts}
    end

    local property = #opts > 0 and opts[1] or 'grepprg'

    if modern_git == -1 then
        modern_git = tools.has_git_version('2', '19')
    end

    local greplist = {
        git = {
            grepprg = 'git --no-pager grep '.. (modern_git and '--column' or '') ..' --no-color -Iin ',
            grepformat = '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m',
        },
        rg = {
            grepprg = 'rg -S --hidden --color never --no-search-zip --trim --vimgrep ',
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

    return greplist[tool] ~= nil and greplist[tool][property] or nil
end

function tools.filelist(tool)
    local filelist = {
        git = 'git --no-pager ls-files -co --exclude-standard',
        fd = 'fd ' .. tools.ignores('fd') .. ' --type f --hidden --follow --color never . .',
        rg = 'rg --color never --no-search-zip --hidden --trim --files',
        ag = 'ag -l --follow --nocolor --nogroup --hidden '..tools.ignores('ag')..'-g ""',
        find = "find . -iname '*'",
    }

    return filelist[tool]
end

function tools.select_filelist(is_git)
    local filelist = ''

    if executable('git') and is_git == true or is_git then
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

function tools.select_grep(is_git, opts)

    if type(opts) ~= 'table' then
        opts = {opts}
    end

    local property = #opts > 0 and opts[1] or 'grepprg'

    local grep = ''

    if executable('git') and (is_git or is_git == 1) then
        grep = tools.grep('git', property)
    elseif executable('rg') then
        grep = tools.grep('rg', property)
    elseif executable('ag') then
        grep = tools.grep('ag', property)
    elseif executable('grep') then
        grep = tools.grep('grep', property)
    elseif sys.name == 'windows' then
        grep = tools.grep('findstr', property)
    end

    return grep
end

local check_lsp = function(servers)
    for _, server in pairs(servers) do
        if executable(server) then
            return true
        end
    end

    return false
end

function tools.check_language_server(languages)

    if languages == nil or #languages > 0 then
        for _, servers in pairs(langservers) do
            if check_lsp(servers) then
                return true
            end
        end
    elseif type(languages) == 'table' then
        for _, servers in pairs(languages) do
            if check_lsp(langservers[languages]) then
                return true
            end
        end
    elseif langservers[languages] ~= nil then
        return check_lsp(langservers[languages])
    end

    return false
end

function tools.get_language_server(language)

    if tools.check_language_server(language) then
        return {}
    end

    local cmds = {
        ['pyls']   = { 'pyls', '--check-parent-process', '--log-file=' .. sys.tmp('pyls.log') },
        ['clangd'] = {
            'clangd',
            '--index',
            '--background-index',
            '--suggest-missing-includes',
            '--clang-tidy',
            '--header-insertion=iwyu',
            '--function-arg-placeholders',
            '--log=verbose',
        },
        ['ccls']   = {
            'ccls',
            '--log-file=' .. sys.tmp('ccls.log'),
            '--init={'..
                '"cache": {"directory": "' .. sys.cache .. '/ccls"},'..
                '"completion": {"filterAndSort": false},'..
                '"highlight": {"lsRanges" : true }'..
            '}'
        },
        ['cquery'] = {
            'cquery',
            '--log-file=' .. sys.tmp('cquery.log'),
            '--init={'..
                '"cache": {"directory": "' .. sys.cache .. '/cquery"},'..
                '"completion": {"filterAndSort": false},'..
                '"highlight": { "enabled" : true },'..
                '"emitInactiveRegions" : true'..
            '}'
        },
        ['gopls']  = {'gopls' },
        ['texlab'] = {'texlab' },
        ['bash-language-server'] = {'bash-language-server', 'start'},
        ['vim-language-server']  = {'vim-language-server', '--stdio'},
        ['docker-langserver']    = {'docker-langserver', '--stdio'},
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

function tools.get_abbrs(language)
    return abolish[language]
end

function tools.abolish(language)

    local current = nvim.bo.spelllang

    if nvim.has.cmd('Abolish') == 2 then
        if abolish[current] ~= nil then
            for base,_ in pairs(abolish[current]) do
                nvim.command('Abolish -delete -buffer '..base)
            end
        end
        if abolish[language] ~= nil then
            for base,replace in pairs(abolish[language]) do
                nvim.command('Abolish -buffer '..base..' '..replace)
            end
        end
    else
        local remove_abbr = function(base)
            nvim.nvim_set_abbr('i', base, nil, {silent = true, buffer = true})
            nvim.nvim_set_abbr('i', base:upper(), nil, {silent = true, buffer = true})
            nvim.nvim_set_abbr('i', base:gsub('%a', string.upper, 1), nil, {silent = true, buffer = true})
        end

        local set_abbr = function(base, replace)
            nvim.nvim_set_abbr('i', base, replace, {buffer = true})
            nvim.nvim_set_abbr('i', base:upper(), replace:upper(), {buffer = true})
            nvim.nvim_set_abbr(
                'i',
                base:gsub('%a', string.upper, 1),
                replace:gsub('%a', string.upper, 1),
                {buffer = true}
            )
        end

        if abolish[current] ~= nil then
            for base, _ in pairs(abolish[current]) do
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

    if not nvim.b.trim or buftypes[buftype] ~= nil or filetypes[filetype] ~= nil or filetype == '' then
        return false
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

function tools.file_name(opts)

    if type(opts) ~= 'table' then
        opts = {opts}
    end

    local filename = nvim.fn.expand('%:t:r')
    local extension = nvim.fn.expand('%:e') ~= '' and nvim.fn.expand('%:e') or '*'
    local skeleton = ''

    local template = #opts > 0 and opts[1] or ''

    local skeletons_path = sys.base..'/skeletons/'

    local known_names = {
        ['*'] = { 'clang-format', 'clang-tidy' },
        py    = {'ycm_extra_conf'},
        json  = {'projections'},
        c     = {'main'},
        cpp   = {'main'},
    }

    if #template ~= 0 then
        skeleton = nvim.fn.fnameescape(skeletons_path .. template)
    else

        if known_names[extension] ~= nil then
            local names = known_names[extension]
            for _, name in pairs(names) do

                if string.find(filename, name, 1, true) ~= nil then

                    local template_file = skeletons_path..name

                    if filereadable(template_file) then
                        skeleton = nvim.fn.fnameescape(template_file)
                        break
                    elseif filereadable(template_file..'.'..extension) then
                        skeleton = nvim.fn.fnameescape(template_file..'.'..extension)
                        break
                    end

                end
            end
        end

        if #skeleton == 0 then
            skeleton = nvim.fn.fnameescape(skeletons_path..'/skeleton.'..extension)
        end

    end

    if filereadable(skeleton) then
        nvim.ex.keepalt('read '..skeleton)
        nvim.command('silent! %s/\\C%\\<NAME\\>/'..filename..'/e')
        nvim.fn.histdel('search', -1)
        nvim.command('silent! %s/\\C%\\<NAME\\ze_H\\(PP\\)\\?\\>/\\U'..filename..'/g')
        nvim.fn.histdel('search', -1)
        nvim.ex['bwipeout!']('skeleton')
        nvim.command('1delete_')
    end

end

function tools.dprint(...)
    print(vim.inspect(...))
end

function tools.find_project_root(path)
    local root
    local vcs_markers = {'.git', '.svn', '.hg',}
    local dir = nvim.fn.fnamemodify(path, ':p')

    for _,marker in pairs(vcs_markers) do
        root = nvim.fn.finddir(marker, dir..';')

        if #root == 0 and marker == '.git' then
            root = nvim.fn.findfile(marker, dir..';')
            root = #root > 0 and root..'/' or root
        end

        if #root > 0 then
            root = nvim.fn.fnamemodify(root, ':p:h:h')
            break
        end

    end

    root = tools.normalize_path(root)

    return root
end

function tools.is_git_repo(root)
    if not executable('git') then
        return false
    end

    root = tools.normalize_path(root)

    local git = root .. '/.git'

    if isdirectory(git) or filereadable(git) then
        return true
    end
    return nvim.fn.findfile('.git', root..';') ~= ''
end

function tools.to_clean_tbl(cmd_string)
    return nvim.clear_lst(vim.split(vim.trim(cmd_string), ' ', true))
end

function tools.regex(str, regex)
    return nvim.eval(string.format([[ '%s'  =~# '%s' ]], str, regex)) == 1
end

function tools.iregex(str, regex)
    return nvim.eval(string.format([[ '%s'  =~? '%s' ]], str, regex)) == 1
end

function tools.ls(expr)
    expr = expr == nil and {} or expr

    local search
    local path = expr.path
    local glob = expr.glob
    local filter = expr.type

    if glob == nil and path == nil then
        path = path == nil and '.' or path
        glob = glob == nil and '*' or glob
    end

    if path ~= nil and glob ~= nil then
        search = path..'/'..glob
    else
        search = path == nil and glob or path
    end

    local results = nvim.fn.glob(search, false, true, false)

    local filter_func = {
        file = filereadable,
        dir  = isdirectory,
    }

    filter_func.files = filter_func.file
    filter_func.dirs = filter_func.dir

    if filter_func[filter] ~= nil then
        local filtered = {}

        for _,element in pairs(results) do
            if filter_func[filter](element) then
                filtered[#filtered + 1] = element
            end
        end

        results = filtered
    end

    return results
end

function tools.get_files(expr)
    expr = expr == nil and {} or expr
    expr.type = 'file'
    return tools.ls(expr)
end

function tools.get_dirs(expr)
    expr = expr == nil and {} or expr
    expr.type = 'dirs'
    return tools.ls(expr)
end

function tools.read_json(filename)
    if not filereadable(filename) then
        return false
    end

    return nvim.fn.json_decode(nvim.fn.readfile(filename))
end

return tools

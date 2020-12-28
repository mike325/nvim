local sys = require'sys'
local nvim = require'nvim'
local plugins = require'nvim'.plugins

local rename       = nvim.fn.rename
local bufloaded    = nvim.bufloaded
local executable   = nvim.executable
local isdirectory  = nvim.isdirectory
local filereadable = nvim.filereadable

local normalize_path   = require'tools.files'.normalize_path
local split_components = require'tools.strings'.split_components

local system = nvim.fn.system
local getcwd = nvim.fn.getcwd

local M = {}

local git_version = ''
local modern_git = -1
local abolish = {}

local langservers = {
    python     = {'pyls', 'jedi-language-server'},
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

abolish['en'] = {
    ['flase']                                = 'false',
    ['syntaxis']                             = 'syntax',
    ['developement']                         = 'development',
    ['identation']                           = 'indentation',
    ['aligment']                             = 'aliment',
    ['posible']                              = 'possible',
    ['reproducable']                         = 'reproducible',
    ['retreive']                             = 'retrieve',
    ['compeletly']                           = 'completely',
    ['movil']                                = 'mobil',
    ['pro{j,y}ect{o}']                       = 'project',
    ['imr{pov,pvo}e']                        = 'improve',
    ['enviroment{,s}']                       = 'environment{}',
    ['sustition{,s}']                        = 'substitution{}',
    ['sustitution{,s}']                      = 'substitution{}',
    ['aibbreviation{,s}']                    = 'abbreviation{}',
    ['abbrevation{,s}']                      = 'abbreviation{}',
    ['avalib{ility,le}']                     = 'availab{ility,le}',
    ['seting{,s}']                           = 'setting{}',
    ['settign{,s}']                          = 'setting{}',
    ['subtitution{,s}']                      = 'substitution{}',
    ['{despa,sepe}rat{e,es,ed}']             = '{despe,sepa}rat{}',
    ['{despa,sepe}rat{ing,ely,ion,ions,or}'] = '{despe,sepa}rat{}',
    ['{,in}consistant{,ly}']                 = '{}consistent{}',
    ['lan{gauge,gue,guege}']                 = 'language',
    ['lan{guegae,ague,agueg}']               = 'language',
    ['delimeter{,s}']                        = 'delimiter{}',
    ['{,non}existan{ce,t}']                  = '{}existen{}',
    ['d{e,i}screp{e,a}nc{y,ies}']            = 'd{i}screp{a}nc{}',
    ['{,un}nec{ce,ces,e}sar{y,ily}']         = '{}nec{es}sar{}',
    ['persistan{ce,t,tly}']                  = 'persisten{}',
    ['{,ir}releven{ce,cy,t,tly}']            = '{}relevan{}',
    ['cal{a,e}nder{,s}']                     = 'cal{e}ndar{}'
}

abolish['es'] = {
    ['analisis']                      = 'análisis',
    ['artifial']                      = 'artificial',
    ['conexion']                      = 'conexión',
    ['autonomo']                      = 'autónomo',
    ['codigo']                        = 'código',
    ['teoricas']                      = 'teóricas',
    ['disminicion']                   = 'disminución',
    ['adminstracion']                 = 'administración',
    ['relacion']                      = 'relación',
    ['minimo']                        = 'mínimo',
    ['area']                          = 'área',
    ['imagenes']                      = 'imágenes',
    ['arificiales']                   = 'artificiales',
    ['actuan']                        = 'actúan',
    ['basicamente']                   = 'básicamente',
    ['acuardo']                       = 'acuerdo',
    ['carateristicas']                = 'características',
    ['ademas']                        = 'además',
    ['asi']                           = 'así',
    ['siguente']                      = 'siguiente',
    ['automatico']                    = 'automático',
    ['algun']                         = 'algún',
    ['dia{,s}']                       = 'día{}',
    ['pre{sici,cisi}on']              = 'precisión',
    ['pro{j,y}ect{o}']                = 'proyecto',
    ['logic{as,o,os}']                = 'lógic{}',
    ['{h,f}ernandez']                 = '{}ernández',
    ['electronico{,s}']               = 'electrónico{}',
    ['algorimo{,s}']                  = 'algoritmo{}',
    ['podria{,n,s}']                  = 'podría{}',
    ['metodologia{,s}']               = 'metodología{}',
    ['{bibliogra}fia']                = '{}fía',
    ['{reflexi}on']                   = '{}ón',
    ['mo{b,v}il']                     = 'móvil',
    ['{televi,explo}sion']            = '{}sión',
    ['{reac,disminu,interac}cion']    = '{}ción',
    ['{clasifica,crea,notifica}cion'] = '{}ción',
    ['{introduc,justifi}cion']        = '{}ción',
    ['{obten,ora,emo,valora}cion']    = '{}ción',
    ['{utilizap,modifica,sec}cion']   = '{}ción',
    ['{delimita,informa}cion']        = '{}ción',
    ['{fun,administra,aplica}cion']   = '{}ción',
    ['{rala,aproxima,programa}cion']  = '{}ción',
}

function M.load_module(name)
    local ok, module = pcall(require, name)
    if not ok then
        return nil
    end
    return module
end

function M.echoerr(msg)
    nvim.echoerr(msg)
end

function M.project_config(event)
    -- print(vim.inspect(event))

    local cwd = event.cwd or getcwd()
    cwd = cwd:gsub('\\', '/')

    if nvim.b.project_root and nvim.b.project_root['cwd'] == cwd then
        return nvim.b.project_root
    end

    local root = M.find_project_root(cwd)

    if #root == 0 then
        root = nvim.fn.fnamemodify(cwd, ':p')
    end

    root = normalize_path(root)

    if nvim.b.project_root and root == nvim.b.project_root['root'] then
        return nvim.b.project_root
    end

    local is_git = M.is_git_repo(root)
    -- local filetype = nvim.bo.filetype
    -- local buftype = nvim.bo.buftype

    nvim.b.project_root = {
        cwd = cwd,
        file_dir = nvim.fn.expand('%:p:h'),
        root = root,
        is_git = is_git,
    }

    nvim.bo.grepprg = M.select_grep(is_git)

    local project = nvim.fn.findfile('.project.vim', cwd..';')
    if #project > 0 then
        -- print('Sourcing Project ', project)
        nvim.ex.source(project)
    end

    -- local telescope = M.load_module'plugins/telescope'

    if plugins['ctrlp'] ~= nil then
        local fast_look_up = {
            ag = 1,
            fd = 1,
            rg = 1,
        }
        local fallback = nvim.g.ctrlp_user_command.fallback
        local clear_cache = is_git and true or (fast_look_up[fallback] ~= nil and true or false)

        nvim.g.ctrlp_clear_cache_on_exit = clear_cache
    end

    if plugins['vim-grepper'] ~= nil then

        local operator = {}
        local tools = {}

        if executable('git') and is_git then
            tools[#tools + 1] = 'git'
            operator[#operator + 1] = 'git'
        end

        if executable('rg') then
            tools[#tools + 1] = 'rg'
            operator[#operator + 1] = 'rg'
        end

        if executable('ag') then
            tools[#tools + 1] = 'ag'
            operator[#operator + 1] = 'ag'
        end

        if executable('grep') then
            tools[#tools + 1] = 'grep'
            operator[#operator + 1] = 'grep'
        end

        if executable('findstr') then
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

    if plugins['gonvim-fuzzy'] ~= nil then
        nvim.g.gonvim_fuzzy_ag_cmd = M.select_grep(is_git)
    end

end

function M.toggle_qf(qf_type)
    local close = false

    local funcs = {
        qf = {
            close = 'cclose',
            open = 'Qopen',
            get_list = 'getqflist',
        },
        loc = {
            close = 'lclose',
            open = 'lopen',
            get_list = 'getloclist',
        },
    }

    local qf = funcs[qf_type]

    local qf_winid

    if qf_type == 'qf' then
        qf_winid = nvim.fn.getqflist({winid = 0}).winid
    else
        qf_winid = nvim.fn.getloclist(0, {winid = 0}).winid
    end

    if qf_winid > 0 then
        for _, winid in pairs(nvim.tab.list_wins(0)) do
            if winid == qf_winid then
                close = true
                break
            end
        end
    end
    if close then
        nvim.ex[qf['close']]()
    else
        nvim.ex[qf['open']]()
        nvim.ex.wincmd('p')
    end
end

function M.add_nl(down)
    local cursor_pos = nvim.win.get_cursor(0)
    local lines = {''}
    local count = nvim.v['count1']
    if count > 1 then
        for _=2,count,1 do
            lines[#lines + 1] = ''
        end
    end

    local cmd
    if not down then
        cursor_pos[1] = cursor_pos[1] + count
        cmd = '[ '
    else
        cmd = '] '
    end

    nvim.put(lines, 'l', down, true)
    nvim.win.set_cursor(0, cursor_pos)
    nvim.command('silent! call repeat#set("'..cmd..'",'..count..')')

end

local function check_lsp(servers)
    for _, server in pairs(servers) do
        if executable(server) then
            return true
        end
    end

    return false
end

function M.check_language_server(languages)

    if languages == nil or #languages == 0 then
        for _, server in pairs(langservers) do
            if check_lsp(server) then
                return true
            end
        end
    elseif type(languages) == 'table' then
        for _, server in pairs(languages) do
            if check_lsp(langservers[server]) then
                return true
            end
        end
    elseif langservers[languages] ~= nil then
        return check_lsp(langservers[languages])
    end

    return false
end

function M.find_project_root(path)
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

    root = normalize_path(root)

    return root
end

function M.is_git_repo(root)
    if not executable('git') then
        return false
    end

    root = normalize_path(root)

    local git = root .. '/.git'

    if isdirectory(git) or filereadable(git) then
        return true
    end
    return nvim.fn.findfile('.git', root..';') ~= ''
end

function M.dprint(...)
    print(vim.inspect(...))
end

function M.check_version(sys_version, version_target)
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

function M.has_git_version(...)
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

    local components = split_components(git_version, '%d+')

    return M.check_version(components, args)
end

function M.ignores(tool)
    local excludes = nvim.fn.split(nvim.o.backupskip, ',')

    for idx,_ in pairs(excludes) do
        excludes[idx] = "'" .. excludes[idx] .. "'"
    end

    local ignores = {
        fd = ' -E ' .. table.concat(excludes, ' -E ') .. ' ',
        find = [[ -regextype egrep ! \( -iwholename ]] .. table.concat(excludes, ' -or -iwholename ') .. [[ \) ]],
        rg = '',
        ag = ' --ignore ' .. table.concat(excludes, ' --ignore ') .. ' ',
        grep = '--exclude='.. table.concat(excludes, ' --exclude=') .. ' ',
        findstr = '', -- TODO
    }

    if filereadable(sys.home .. '/.config/git/ignore') then
        -- ignores.rg = ' --ignore-file '.. sys.home .. '/.config/git/ignore '
        ignores.fd = ' --ignore-file '.. sys.home .. '/.config/git/ignore '
    end

    return ignores[tool] ~= nil and ignores[tool] or ''
end

function M.grep(tool, opts)

    if type(opts) ~= 'table' then
        opts = {opts}
    end

    local property = #opts > 0 and opts[1] or 'grepprg'

    if modern_git == -1 then
        modern_git = M.has_git_version('2', '19')
    end

    local greplist = {
        git = {
            grepprg = 'git --no-pager grep '.. (modern_git and '--column' or '') ..' --no-color -Iin ',
            grepformat = '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m',
        },
        rg = {
            grepprg = 'rg -S --color=never --trim --vimgrep '..M.ignores('rg')..' ',
            grepformat = '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m'
        },
        ag = {
            grepprg = 'ag -S --follow --nogroup --nocolor --hidden --vimgrep '..M.ignores('ag')..' ',
            grepformat = '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m'
        },
        grep = {
            grepprg = 'grep -RHiIn --color=never '..M.ignores('grep')..' ',
            grepformat = '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m'
        },
        findstr = {
            grepprg = 'findstr -rspn ',
            grepformat = '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m',
        },
    }

    return greplist[tool] ~= nil and greplist[tool][property] or nil
end

function M.filelist(tool)
    local filelist = {
        git  = 'git --no-pager ls-files -co --exclude-standard',
        fd   = 'fd ' .. M.ignores('fd') .. ' --type f --hidden --follow --color never . .',
        rg   = 'rg --color=never --no-search-zip --hidden --trim --files '.. M.ignores('rg'),
        ag   = 'ag -l --follow --nocolor --nogroup --hidden '..M.ignores('ag')..'-g ""',
        find = "find . -type f -iname '*' "..M.ignores('find') .. ' ',
    }

    return filelist[tool]
end

function M.select_filelist(is_git)
    local filelist = ''

    if executable('git') and is_git == true or is_git then
        filelist = M.filelist('git')
    elseif executable('fd') then
        filelist = M.filelist('fd')
    elseif executable('rg') then
        filelist = M.filelist('rg')
    elseif executable('ag') then
        filelist = M.filelist('ag')
    elseif sys.name ~= 'windows' then
        filelist = M.filelist('find')
    end

    return filelist
end

function M.select_grep(is_git, opts)

    if type(opts) ~= 'table' then
        opts = {opts}
    end

    local property = #opts > 0 and opts[1] or 'grepprg'

    local grep = ''

    if executable('rg') then
        grep = M.grep('rg', property)
    elseif executable('git') and (is_git or is_git == 1) then
        grep = M.grep('git', property)
    elseif executable('ag') then
        grep = M.grep('ag', property)
    elseif executable('grep') then
        grep = M.grep('grep', property)
    elseif sys.name == 'windows' then
        grep = M.grep('findstr', property)
    end

    return grep
end

function M.spelllangs(lang)
    M.abolish(lang)
    nvim.bo.spelllang = lang
    print(nvim.bo.spelllang)
end

function M.get_abbrs(language)
    return abolish[language]
end

function M.abolish(language)

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
        local function remove_abbr(base)
            nvim.nvim_set_abbr{
                mode = 'i',
                lhs = base,
                args = {silent = true, buffer = true},
            }

            nvim.nvim_set_abbr{
                mode = 'i',
                lhs = base:upper(),
                args = {silent = true, buffer = true},
            }

            nvim.nvim_set_abbr{
                mode = 'i',
                lhs = base:gsub('%a',  string.upper, 1),
                args = {silent = true, buffer = true}
            }

        end

        local function set_abbr(base, replace)
            nvim.nvim_set_abbr{
                mode = 'i',
                lhs = base,
                rhs = replace,
                args = {buffer = true},
            }

            nvim.nvim_set_abbr{
                mode = 'i',
                lhs = base:upper(),
                rhs = replace:upper(),
                args = {buffer = true},
            }

            nvim.nvim_set_abbr{
                mode = 'i',
                lhs = base:gsub('%a', string.upper, 1),
                rhs = replace:gsub('%a', string.upper, 1),
                args = {buffer = true},
            }
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

function M.get_language_server(language)

    if M.check_language_server(language) then
        return {}
    end

    local cmds = {
        ['pyls']   = {
            'pyls',
            '--check-parent-process',
            '--log-file=' .. sys.tmp('pyls.log'),
        },
        ['jedi-language-server']   = { 'jedi-language-server' },
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

_G['tools'].helpers = M

return M

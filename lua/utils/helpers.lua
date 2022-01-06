-- local sys = require 'sys'
local nvim = require 'neovim'
-- local plugins = require'neovim'.plugins

local executable = require('utils.files').executable
local normalize_path = require('utils.files').normalize_path
local getcwd = require('utils.files').getcwd
local split = require('utils.strings').split

local line = vim.fn.line

local M = {}

local abolish = {}

-- stylua: ignore
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

-- stylua: ignore
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

local qf_funcs = {
    first = function(win)
        if win then
            nvim.ex.lfirst()
        else
            nvim.ex.cfirst()
        end
    end,
    last = function(win)
        if win then
            nvim.ex.llast()
        else
            nvim.ex.clast()
        end
    end,
    open = function(win)
        local cmd = vim.o.splitbelow and 'botright' or 'topleft'
        if win then
            vim.cmd(cmd .. ' lopen')
        else
            vim.cmd(cmd .. ' copen')
        end
    end,
    close = function(win)
        if win then
            nvim.ex.lclose()
        else
            nvim.ex.cclose()
        end
    end,
    set_list = function(items, action, what, win)
        if win then
            -- BUG: For some reason we cannot send what as nil, so it needs to be ommited
            if not what then
                vim.fn.setloclist(win, items, action)
            else
                vim.fn.setloclist(win, items, action, what)
            end
        else
            if not what then
                vim.fn.setqflist(items, action)
            else
                vim.fn.setqflist(items, action, what)
            end
        end
    end,
    get_list = function(what, win)
        if win then
            return vim.fn.getloclist(win, what)
        end
        return vim.fn.getqflist(what)
    end,
}

local icons

-- Separators
-- 
-- 
-- ▶
-- ◀
-- »
-- «
-- ❯
-- ➤
-- 
-- ☰
-- 

if not vim.env['NO_COOL_FONTS'] then
    icons = {
        error = '✗', -- ✗ -- 🞮 --  -- ❌
        warn = '',
        info = '',
        hint = '',
        bug = '',
        wait = '☕',
        build = '⛭',
        success = '✔',
        virtual_text = '❯',
        diff_add = '',
        diff_modified = '',
        diff_remove = '',
        git_branch = '',
        readonly = '🔒',
        bar = '▋',
        sep_triangle_left = '',
        sep_triangle_right = '',
        sep_circle_right = '',
        sep_circle_left = '',
        sep_arrow_left = '',
        sep_arrow_right = '',
    }
else
    icons = {
        error = '×',
        warn = '!',
        info = 'I',
        hint = 'H',
        bug = 'B',
        build = 'W',
        wait = '...',
        success = ':)',
        virtual_text = '➤',
        diff_add = '+',
        diff_modified = '~',
        diff_remove = '-',
        git_branch = '',
        readonly = '',
        bar = '|',
        sep_triangle_left = '>',
        sep_triangle_right = '<',
        sep_circle_right = '(',
        sep_circle_left = ')',
        sep_arrow_left = '>',
        sep_arrow_right = '<',
    }
end

icons.err = icons.error
icons.msg = icons.hint
icons.message = icons.hint
icons.warning = icons.warn
icons.information = icons.info

local git_dirs = {}

function M.load_module(name)
    local ok, module = pcall(require, name)
    if not ok then
        return nil
    end
    return module
end

function M.get_separators(sep_type)
    local separators = {
        circle = {
            left = icons.sep_circle_left,
            right = icons.sep_circle_right,
        },
        triangle = {
            left = icons.sep_triangle_left,
            right = icons.sep_triangle_right,
        },
        arrow = {
            left = icons.sep_arrow_left,
            right = icons.sep_arrow_right,
        },
    }

    return separators[sep_type]
end

function M.get_icon(icon)
    return icons[icon]
end

function M.project_config(event)
    local cwd = event.cwd or getcwd()
    cwd = cwd:gsub('\\', '/')

    if vim.b.project_root and vim.b.project_root['cwd'] == cwd then
        return vim.b.project_root
    end

    local root = M.find_project_root(cwd)

    if #root == 0 then
        root = vim.fn.fnamemodify(cwd, ':p')
    end

    root = normalize_path(root)

    if vim.b.project_root and root == vim.b.project_root['root'] then
        return vim.b.project_root
    end

    local is_git = M.is_git_repo(root)
    local git_dir = is_git and git_dirs[cwd] or nil
    -- local filetype = vim.bo.filetype
    -- local buftype = vim.bo.buftype

    vim.b.project_root = {
        cwd = cwd,
        root = root,
        is_git = is_git,
        git_dir = git_dir,
    }

    if is_git and not git_dir and nvim.has 'nvim-0.5' then
        require('utils.functions').get_git_dir(function(dir)
            local project = vim.b.project_root
            project.git_dir = dir
            git_dirs[cwd] = dir
            vim.b.project_root = project
        end)
    end

    if is_git then
        pcall(require('git.commands').set_commands)
    else
        pcall(require('git.commands').rm_commands)
    end

    M.set_grep(is_git, true)

    local project = vim.fn.findfile('.project.vim', cwd .. ';')
    if #project > 0 then
        -- print('Sourcing Project ', project)
        nvim.ex.source(project)
    end
end

function M.add_nl(down)
    local cursor_pos = nvim.win.get_cursor(0)
    local lines = { '' }
    local count = vim.v['count1']
    if count > 1 then
        for _ = 2, count, 1 do
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
    vim.cmd('silent! call repeat#set("' .. cmd .. '",' .. count .. ')')
end

function M.move_line(down)
    -- local cmd
    local lines = { '' }
    local count = vim.v.count1

    if count > 1 then
        for _ = 2, count, 1 do
            lines[#lines + 1] = ''
        end
    end

    if down then
        -- cmd = ']e'
        count = line '$' < line '.' + count and line '$' or line '.' + count
    else
        -- cmd = '[e'
        count = line '.' - count - 1 < 1 and 1 or line '.' - count - 1
    end

    vim.cmd(string.format([[move %s | normal! ==]], count))
    -- TODO: Make repeat work
    -- vim.cmd('silent! call repeat#set("'..cmd..'",'..count..')')
end

function M.find_project_root(path)
    assert(type(path) == 'string' and path ~= '', ([[Not a path: "%s"]]):format(path))
    local root
    local vcs_markers = { '.git', '.svn', '.hg' }
    local dir = vim.fn.fnamemodify(path, ':p')

    for _, marker in pairs(vcs_markers) do
        root = vim.fn.finddir(marker, dir .. ';')

        if #root == 0 and marker == '.git' then
            root = vim.fn.findfile(marker, dir .. ';')
            root = #root > 0 and root .. '/' or root
        end

        if root ~= '' then
            root = vim.fn.fnamemodify(root, ':p:h:h')
            break
        end
    end

    root = (not root or root == '') and getcwd() or root
    return normalize_path(root)
end

function M.is_git_repo(root)
    assert(type(root) == type '' and root ~= '', debug.traceback(([[Not a path: "%s"]]):format(root)))
    if not executable 'git' then
        return false
    end

    root = normalize_path(root)

    local git = root .. '/.git'

    if require('utils.files').is_dir(git) or require('utils.files').is_file(git) then
        return true
    end
    return vim.fn.findfile('.git', root .. ';') ~= ''
end

function M.ignores(tool)
    local excludes = split(vim.o.backupskip, ',')

    local ignores = {
        fd = {},
        find = { '-regextype', 'egrep', '!', [[\(]] },
        -- rg = {},
        ag = {},
        grep = {},
        -- findstr = {},
    }

    if #excludes == 0 or not ignores[tool] then
        return ''
    end

    for i = 1, #excludes do
        -- excludes[i] = "'" .. excludes[i] .. "'"

        ignores.fd[#ignores.fd + 1] = '--exclude=' .. excludes[i]
        ignores.find[#ignores.find + 1] = '-iwholename ' .. excludes[i]
        if i < #excludes then
            ignores.find[#ignores.find + 1] = '-or'
        end
        ignores.ag[#ignores.ag + 1] = ' --ignore ' .. excludes[i]
        ignores.grep[#ignores.grep + 1] = '--exclude=' .. excludes[i]
    end

    ignores.find[#ignores.find + 1] = [[\)]]

    -- if is_file(sys.home .. '/.config/git/ignore') then
    --     -- ignores.rg = ' --ignore-file '.. sys.home .. '/.config/git/ignore '
    --     ignores.fd = ' --ignore-file '.. sys.home .. '/.config/git/ignore '
    -- end

    return table.concat(ignores[tool], ' ')
end

function M.grep(tool, attr, lst)
    local property = (attr and attr ~= '') and attr or 'grepprg'

    local modern_git = STORAGE.modern_git

    local greplist = {
        git = {
            grepprg = 'git --no-pager grep ' .. (modern_git and '--column' or '') .. ' --no-color -Iin ',
            grepformat = '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m',
        },
        rg = {
            grepprg = 'rg -SHn --trim --color=never --no-heading --column ',
            grepformat = '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m',
        },
        ag = {
            grepprg = 'ag -S --follow --nogroup --nocolor --hidden --vimgrep ' .. M.ignores 'ag' .. ' ',
            grepformat = '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m',
        },
        grep = {
            grepprg = 'grep -RHiIn --color=never ' .. M.ignores 'grep' .. ' ',
            grepformat = '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m',
        },
        findstr = {
            grepprg = 'findstr -rspn ',
            grepformat = '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m',
        },
    }

    local grep = lst and {} or ''
    if executable(tool) and greplist[tool] ~= nil then
        grep = greplist[tool][property]
        grep = lst and split(grep, ' ') or grep
    end

    return grep
end

function M.filelist(tool, lst)
    local filetool = {
        git = 'git --no-pager ls-files -c --exclude-standard',
        fd = 'fd --type=file --hidden --follow --color=never',
        rg = 'rg --color=never --no-search-zip --hidden --trim --files ',
        ag = 'ag -l --follow --nocolor --nogroup --hidden ' .. M.ignores 'ag' .. '-g ""',
        find = 'find . -type f ' .. M.ignores 'find' .. " -iname '*' ",
    }

    filetool.fdfind = string.gsub(filetool.fd, '^fd', 'fdfind')

    local filelist = lst and {} or ''
    if executable(tool) and filetool[tool] ~= nil then
        filelist = filetool[tool]
    elseif tool == 'fd' and not executable 'fd' and executable 'fdfind' then
        filelist = filetool.fdfind
    end

    if #filelist > 0 then
        filelist = lst and split(filelist, ' ') or filelist
    end
    return filelist
end

function M.select_filelist(is_git, lst)
    local filelist = ''

    local utils = {
        'fd',
        'rg',
        'ag',
        'find',
    }

    if executable 'git' and is_git then
        filelist = M.filelist('git', lst)
    else
        for _, lister in pairs(utils) do
            filelist = M.filelist(lister, lst)
            if #filelist > 0 then
                break
            end
        end
    end

    return filelist
end

function M.select_grep(is_git, attr, lst)
    local property = (attr and attr ~= '') and attr or 'grepprg'

    local grepprg = ''

    local utils = {
        'rg',
        'ag',
        'grep',
        'findstr',
    }

    if executable 'git' and is_git then
        grepprg = M.grep('git', property, lst)
    else
        for _, grep in pairs(utils) do
            grepprg = M.grep(grep, property, lst)
            if #grepprg > 0 then
                break
            end
        end
    end

    return grepprg
end

function M.set_grep(is_git, is_local)
    if is_local then
        vim.bo.grepprg = M.select_grep(is_git)
    else
        vim.o.grepprg = M.select_grep(is_git)
    end
    vim.o.grepformat = M.select_grep(is_git, 'grepformat')
end

function M.spelllangs(lang)
    M.abolish(lang)
    vim.wo.spelllang = lang
    print(vim.wo.spelllang)
end

function M.get_abbrs(language)
    return abolish[language]
end

function M.abolish(language)
    local current = vim.bo.spelllang
    local set_abbr = require('neovim.abbrs').set_abbr

    if nvim.has.cmd 'Abolish' == 2 then
        if abolish[current] ~= nil then
            for base, _ in pairs(abolish[current]) do
                vim.cmd('Abolish -delete -buffer ' .. base)
            end
        end
        if abolish[language] ~= nil then
            for base, replace in pairs(abolish[language]) do
                vim.cmd('Abolish -buffer ' .. base .. ' ' .. replace)
            end
        end
    else
        local function remove_abbr(base)
            set_abbr {
                mode = 'i',
                lhs = base,
                args = { silent = true, buffer = true },
            }

            set_abbr {
                mode = 'i',
                lhs = base:upper(),
                args = { silent = true, buffer = true },
            }

            set_abbr {
                mode = 'i',
                lhs = base:gsub('%a', string.upper, 1),
                args = { silent = true, buffer = true },
            }
        end

        local function change_abbr(base, replace)
            set_abbr {
                mode = 'i',
                lhs = base,
                rhs = replace,
                args = { buffer = true },
            }

            set_abbr {
                mode = 'i',
                lhs = base:upper(),
                rhs = replace:upper(),
                args = { buffer = true },
            }

            set_abbr {
                mode = 'i',
                lhs = base:gsub('%a', string.upper, 1),
                rhs = replace:gsub('%a', string.upper, 1),
                args = { buffer = true },
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
            for base, replace in pairs(abolish[language]) do
                if not string.match(base, '{.+}') then
                    change_abbr(base, replace)
                end
            end
        end
    end
end

function M.python(version, args)
    local py2 = vim.g.python_host_prog
    local py3 = vim.g.python3_host_prog

    local pyversion = version == 3 and py3 or py2

    if pyversion == nil or pyversion == '' then
        vim.notify('Python' .. pyversion .. ' is not available in the system', 'ERROR', { title = 'Python' })
        return -1
    end

    local split_type = vim.o.splitbelow and 'botright' or 'topleft'
    vim.cmd(split_type .. ' split term://' .. pyversion .. ' ' .. args)
end

function M.toggle_qf(win)
    local qf_winid = qf_funcs.get_list({ winid = 0 }, win).winid
    local action = qf_winid > 0 and 'close' or 'open'
    qf_funcs[action](win)
end

function M.dump_to_qf(opts)
    vim.validate {
        opts = { opts, 'table' },
        lines = { opts.lines, 'table' },
        context = { opts.context, 'string', true },
        title = { opts.title, 'string', true },
        efm = {
            opts.efm,
            function(e)
                return not e or type(e) == type '' or type(e) == type {}
            end,
            'error format must be a string or a table',
        },
    }

    opts.context = opts.context or 'GenericQfData'
    opts.title = opts.title or 'Generic Qf data'
    opts.efm = opts.efm or vim.opt_local.efm:get() or vim.opt_global.efm:get()

    if type(opts.efm) == type {} then
        opts.efm = table.concat(opts.efm, ',')
    end
    -- opts.efm = opts.efm:gsub(' ', '\\ ')

    local qf_type = opts.loc and 'loc' or 'qf'
    local qf_open = opts.open or false
    local qf_jump = opts.jump or false

    opts.loc = nil
    opts.open = nil
    opts.jump = nil
    opts.cmdname = nil
    opts.lines = require('utils.tables').clear_lst(opts.lines)

    local win
    if qf_type ~= 'qf' then
        win = opts.win or vim.api.nvim_get_current_win()
    end
    opts.win = nil
    qf_funcs.set_list({}, 'r', opts, win)

    local info_tab = opts.tab
    if info_tab and info_tab ~= nvim.get_current_tabpage() then
        vim.notify(
            ('%s Updated! with %s info'):format(qf_type == 'qf' and 'Qf' or 'Loc', opts.context),
            'INFO',
            { title = qf_type == 'qf' and 'QuickFix' or 'LocationList' }
        )
        return
    elseif #opts.lines > 0 then
        if qf_open then
            qf_funcs.open(win)
        end

        if qf_jump then
            qf_funcs.first(win)
        end
    end
end

function M.clear_qf(win)
    qf_funcs.set_list({}, 'r', nil, win)
    qf_funcs.close(win)
end

if STORAGE.modern_git == -1 then
    STORAGE.modern_git = require('storage').has_version('git', { '2', '19' })
end

return M

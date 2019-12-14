-- luacheck: globals unpack vim

local inspect = vim.inspect

local nvim       = require('nvim')
local line       = require('nvim').fn.line
local system     = require('nvim').fn.system
local executable = require('nvim').fn.executable

local sys = require('sys')

local helpers = {}

local git_version = ''
local modern_git = -1

local function split_components(str, pattern)
     local t = {}
    for v in string.gmatch(str, pattern) do
        t[#t + 1] = v
    end
    return t
end

local function split(str, pattern)
     local t = {}
    for v in string.gmatch(str, '([^'..pattern..']+)') do
        t[#t + 1] = v
    end
    return t
end

function helpers.LastPosition()
    local sc_mark = nvim.buf.get_mark(0, "'")[1]
    local dc_mark = nvim.buf.get_mark(0, '"')[1]
    local last_line = line('$')
    local filetype = nvim.bo.filetype

    local black_list = {
        git = 1,
        gitcommit = 1,
        fugitive = 1,
        qf = 1,
    }

    if sc_mark >= 1 and dc_mark <= last_line and black_list[filetype] == nil then
        nvim.command([[normal! g'"]])
    end
end

function helpers.has_git_version(...)
    if executable('git') == 0 then
        return 0
    end

    local args = ... ~= nil and {...} or {}

    if #git_version == 0 then
        git_version = string.match(require'nvim'.fn.system('git --version'), '%d+%p%d+%p%d+')
    end

    local components = split_components(git_version, '%d+')

    for i,val in pairs(args) do
        if args[i] > components[i] then
            return 0
        elseif args[i] < components[i] then
            return 1
        elseif #args == i and args[i] == components[i] then
            return 1
        end
    end
    return 0
end

function helpers.ignores(tool)
    local excludes = split(nvim.o.backupskip, ',')

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

function helpers.grep(tool, ...)
    local opts = ... ~= nil and {...} or {}
    local properity = #opts > 0 and opts[1] or 'grepprg'

    if modern_git == -1 then
        modern_git = helpers.has_git_version('2', '19')
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
            grepprg = 'ag -S --follow --nogroup --nocolor --hidden --vimgrep '..helpers.ignores('ag'),
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

    return greplist[tool][properity]
end

function helpers.filelist(tool)
    local filelist = {
        git = 'git --no-pager ls-files -co --exclude-standard',
        fd = 'fd ' .. helpers.ignores('fd') .. ' --type f --hidden --follow --color never . .',
        rg = 'rg --line-number --column --with-filename --color never --no-search-zip --hidden --trim --files',
        ag = 'ag -l --follow --nocolor --nogroup --hidden '..helpers.ignores('ag')..'-g ""',
        find = "find . -iname '*'",
    }

    return filelist[tool]
end

function helpers.select_filelist(is_git)
    local filelist = ''

    if is_git == 0 or is_git == nil then
        is_git = false
    end

    if executable('git') and is_git then
        filelist = helpers.filelist('git')
    elseif executable('fd') then
        filelist = helpers.filelist('fd')
    elseif executable('rg') then
        filelist = helpers.filelist('rg')
    elseif executable('ag') then
        filelist = helpers.filelist('ag')
    elseif sys.name ~= 'windows' then
        filelist = helpers.filelist('find')
    end

    return filelist
end

function helpers.select_grep(is_git, ...)
    local opts = ... ~= nil and {...} or {}
    local properity = #opts > 0 and opts[1] or 'grepprg'

    if is_git == 0 or is_git == nil then
        is_git = false
    end

    local grep = ''

    if executable('git') and is_git then
        grep = helpers.grep('git', properity)
    elseif executable('rg') then
        grep = helpers.grep('rg', properity)
    elseif executable('ag') then
        grep = helpers.grep('ag', properity)
    elseif executable('grep') then
        grep = helpers.grep('grep', properity)
    elseif sys.name == 'windows' then
        grep = helpers.grep('findstr', properity)
    end

    return grep
end

function helpers.spelllangs(lang)
    nvim.bo.spelllang = lang
    print(nvim.bo.spelllang)
end

return helpers

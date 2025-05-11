local nvim = require 'nvim'

local replace_indent = require('utils.buffers').replace_indent
local executable = require('utils.files').executable
local is_file = require('utils.files').is_file
local getcwd = require('utils.files').getcwd

local M = {}

-- TODO: Improve python folding text
function M.foldtext()
    local lines = vim.api.nvim_buf_get_lines(0, vim.v.foldstart, vim.v.foldend, false)
    local indent_level = require('utils.buffers').get_indent_block(lines)
    local indent_string = require('utils.buffers').get_indent_string(indent_level)
    local foldtext = '%s %s %s %s'
    return foldtext:format(
        indent_string .. '+-',
        vim.trim(vim.fn.getline(vim.v.foldstart)),
        ('-- %s lines folded --'):format(vim.v.foldend - vim.v.foldstart),
        vim.trim(vim.fn.getline(vim.v.foldend))
    )
end

function M.set_compiler(compiler, opts)
    vim.validate {
        compiler = { compiler, 'string' },
        opts = { opts, 'table', true },
    }

    opts = opts or {}

    local language = opts.language or vim.bo.filetype
    local option = opts.option or 'makeprg'

    local function get_args(configs, configflag, fallback_args)
        if configs and configflag then
            local config_files = vim.fs.find(configs, { upward = true, type = 'file' })
            if config_files[1] then
                return { configflag, config_files[1] }
            end
        elseif opts.global_config and is_file(opts.global_config) then
            return { configflag, opts.global_config }
        end

        return fallback_args
    end

    local cmd = { compiler }
    if opts.subcmd or opts.subcommand then
        table.insert(cmd, opts.subcmd or opts.subcommand)
    end

    local efm = opts.efm or opts.errorformat
    if not efm then
        efm = vim.go.efm
    end

    local args
    local ft_compilers = vim.F.npcall(RELOAD, 'filetypes.' .. language)
    if ft_compilers and ft_compilers[option] then
        local compiler_data = ft_compilers[option][compiler]
        if compiler_data then
            args = compiler_data
            efm = opts.efm or opts.errorformat or compiler_data.efm or compiler_data.errorformat or efm
        end
    end

    if opts.args then
        args = type(opts.args) == type {} and opts.args or { opts.args }
    end

    local extra_args = get_args(opts.configs, opts.config_flag, args or {})
    vim.list_extend(cmd, extra_args)

    local has_cmd = nvim.has.command 'CompilerSet'
    if not has_cmd then
        nvim.command.set('CompilerSet', function(command)
            -- TODO: Migrate this into opt_local API
            vim.cmd(('setlocal %s'):format(command.args))
        end, { nargs = 1, buffer = true })
    end

    vim.cmd.CompilerSet('makeprg=' .. table.concat(replace_indent(cmd), '\\ '))

    if efm then
        efm = type(efm) == type {} and table.concat(efm, ',') or efm
        -- TODO: fix this with non local options
        vim.bo.efm = efm
    end

    vim.b.current_compiler = compiler

    if not has_cmd then
        nvim.command.del('CompilerSet', true)
    end
end

function M.load_module(name)
    return vim.F.npcall(require, name)
end

function M.find_project_root(path)
    assert(type(path) == 'string' and path ~= '', ([[Not a path: "%s"]]):format(path))
    local root
    local vcs_markers = { '.git', '.svn', '.hg' }
    local dir = vim.fn.fnamemodify(path, ':p')

    for _, marker in pairs(vcs_markers) do
        root = vim.fs.find(marker, { path = dir, upward = true })[1]
        if root then
            break
        end
    end

    return not root and getcwd() or vim.fs.dirname(root)
end

function M.ignores(tool, excludes, lst)
    vim.validate {
        tool = { tool, 'string' },
        excludes = { excludes, { 'string', 'table' } },
        lst = { lst, 'boolean', true },
    }

    if lst == nil then
        lst = false
    end

    if not vim.islist(excludes) then
        excludes = { excludes }
    end

    local ignores = {
        fd = {},
        find = { '-regextype', 'egrep', '!', [[\(]] },
        rg = {},
        ag = {},
        grep = {},
        -- findstr = {},
    }

    if #excludes == 0 or not ignores[tool] then
        return lst and {} or ''
    end

    for i = 1, #excludes do
        if excludes[i] ~= '' then
            table.insert(ignores.fd, '--exclude=' .. excludes[i])
            table.insert(ignores.find, '-iwholename ' .. excludes[i])
            if i < #excludes then
                table.insert(ignores.find, '-or')
            end
            table.insert(ignores.ag, ' --ignore ' .. excludes[i])
            table.insert(ignores.grep, '--exclude=' .. excludes[i])
            table.insert(ignores.rg, ' --iglob=!' .. excludes[i])
        end
    end

    table.insert(ignores.find, [[\)]])

    -- if is_file(sys.home .. '/.config/git/ignore') then
    --     ignores.rg = ' --ignore-file '.. sys.home .. '/.config/git/ignore '
    --     ignores.fd = ' --ignore-file '.. sys.home .. '/.config/git/ignore '
    -- end

    return lst and ignores[tool] or table.concat(ignores[tool], ' ')
end

function M.grep(tool, attr, lst)
    local property = (attr and attr ~= '') and attr or 'grepprg'
    local excludes = vim.split(vim.o.backupskip, ',+')

    -- local modern_git = STORAGE.modern_git

    local greplist = {
        git = {
            grepprg = 'git --no-pager grep --column --no-color -Iin ',
            grepformat = '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m',
        },
        rg = {
            grepprg = 'rg -SHn --no-binary --trim --color=never --no-heading --column --no-search-zip --hidden '
                .. M.ignores('rg', excludes)
                .. ' ',
            grepformat = '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m',
        },
        ag = {
            grepprg = 'ag -S --follow --nogroup --nocolor --hidden --vimgrep ' .. M.ignores('ag', excludes) .. ' ',
            grepformat = '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m',
        },
        grep = {
            grepprg = 'grep -RHiIn --color=never ' .. M.ignores('grep', excludes) .. ' ',
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
        grep = lst and vim.split(grep, '%s+') or grep
    end

    if vim.islist(grep) then
        grep = vim.tbl_filter(function(k)
            return not k:match '^%s*$'
        end, grep)
    end

    return grep
end

function M.filelist(tool, lst)
    local excludes = vim.split(vim.o.backupskip, ',+')

    -- TODO: find in windows works different
    local filetool = {
        git = 'git --no-pager ls-files -c --exclude-standard',
        fd = 'fd --type=file --hidden --color=never ' .. M.ignores('fd', excludes) .. ' ',
        rg = 'rg --no-binary --color=never --no-search-zip --hidden --trim --files '
            .. M.ignores('rg', excludes)
            .. ' ',
        ag = 'ag -l --follow --nocolor --nogroup --hidden ' .. M.ignores('ag', excludes) .. '-g ""',
        find = 'find . -type f ' .. M.ignores('find', excludes) .. " -iname '*' ",
    }

    filetool.fdfind = string.gsub(filetool.fd, '^fd', 'fdfind')

    local filelist = lst and {} or ''
    if executable(tool) and filetool[tool] ~= nil then
        filelist = filetool[tool]
    elseif tool == 'fd' and not executable 'fd' and executable 'fdfind' then
        filelist = filetool.fdfind
    end

    if #filelist > 0 then
        filelist = lst and vim.split(filelist, '%s+') or filelist
    end

    if vim.islist(filelist) then
        filelist = vim.tbl_filter(function(k)
            return not k:match '^%s*$'
        end, filelist)
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
    if lang and lang ~= '' then
        vim.bo.spelllang = lang
    end
    vim.print(vim.bo.spelllang)
end

function M.set_abbrs(old_lang, new_lang)
    if old_lang == new_lang or vim.bo.spelllang ~= new_lang then
        return
    end
    local abolish = RELOAD('configs.abolish').abolish
    local capitalize = require('utils.strings').capitalize

    if nvim.has.cmd 'Abolish' then
        if abolish[old_lang] ~= nil then
            for base, _ in pairs(abolish[old_lang]) do
                vim.cmd.Abolish { args = { '-delete', '-buffer', base } }
            end
        end
        if abolish[new_lang] ~= nil then
            for base, replace in pairs(abolish[new_lang]) do
                vim.cmd.Abolish { args = { '-buffer', base, replace } }
            end
        end
    else
        if abolish[old_lang] ~= nil then
            for base, _ in pairs(abolish[old_lang]) do
                -- TODO: Use abolish transformations
                if not base:match '%{' then
                    pcall(vim.keymap.del, 'ia', base, { buffer = true })
                    pcall(vim.keymap.del, 'ia', base:upper(), { buffer = true })
                    pcall(vim.keymap.del, 'ia', capitalize(base), { buffer = true })
                end
            end
        end
        if abolish[new_lang] ~= nil then
            for base, replace in pairs(abolish[new_lang]) do
                if not base:match '%{' and not replace:match '%{' then
                    vim.keymap.set('ia', base, replace, { buffer = true })
                    vim.keymap.set('ia', base:upper(), replace:upper(), { buffer = true })
                    vim.keymap.set('ia', capitalize(base), capitalize(replace), { buffer = true })
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
        vim.notify(
            'Python' .. pyversion .. ' is not available in the system',
            vim.log.levels.ERROR,
            { title = 'Python' }
        )
        return -1
    end

    local split_type = vim.o.splitbelow and 'botright' or 'topleft'
    vim.cmd { cmd = 'split', args = { 'term://' .. pyversion .. ' ' .. args }, mods = { split = split_type } }
end

function M.scp_edit(opts)
    opts = opts or {}
    local host = opts.host
    local filename = opts.filename
    local path = opts.path
    local port = opts.port

    local function get_remote_file(hostname, remote_file, remote_path, host_port)
        vim.validate {
            hostname = { hostname, 'string' },
            remote_file = { remote_file, 'string' },
            remote_path = { remote_path, 'string', true },
            host_port = { host_port, { 'string', 'number' }, true },
        }

        if STORAGE.hosts[hostname] then
            host_port = STORAGE.hosts[hostname].port or host_port
            hostname = RELOAD('utils.network').get_ssh_host(hostname)
        end

        if remote_path and remote_path ~= '' then
            remote_file = remote_path .. '/' .. remote_file
        end

        local virtual_filename = ('scp://%s:%s/%s'):format(hostname, host_port or '22', remote_file)
        vim.cmd.edit(virtual_filename)
    end

    local function filename_input(hostname, remote_path, host_port)
        vim.validate {
            hostname = { hostname, 'string' },
            remote_path = { remote_path, 'string', true },
            host_port = { host_port, { 'string', 'number' }, true },
        }

        if not filename or filename == '' then
            if STORAGE.hosts[hostname] then
                host_port = STORAGE.hosts[hostname].port or host_port
                hostname = RELOAD('utils.network').get_ssh_host(hostname)
            end

            local ssh_cmd = {
                'ssh',
                '-p',
                host_port or '22',
                hostname,
                'ls',
                remote_path or '.',
            }
            vim.ui.select(
                vim.split(vim.system(ssh_cmd, { text = true }):wait().stdout, '\n', { trimempty = true }),
                { prompt = 'Select File/Buffer attribute: ' },
                vim.schedule_wrap(function(choice)
                    if not choice then
                        vim.notify('Missing filename!', vim.log.levels.ERROR, { title = 'SCPEdit' })
                        return
                    end
                    filename = choice
                    get_remote_file(host, filename, path, port)
                end)
            )
        else
            get_remote_file(host, filename, path, port)
        end
    end

    if not host or host == '' then
        vim.ui.input({
            prompt = 'Enter hostname > ',
            completion = "customlist,v:lua.require'completions'.ssh_hosts_completion",
        }, function(input)
            if not input then
                vim.notify('Missing hostname!', vim.log.levels.ERROR, { title = 'SCPEdit' })
                return
            end
            host = input
            filename_input(host, path, port)
        end)
    elseif not filename or filename == '' then
        filename_input(host, path, port)
    else
        get_remote_file(host, filename, path, port)
    end
end

function M.typos_check(buf)
    buf = buf or vim.api.nvim_get_current_buf()
    local bufname = vim.api.nvim_buf_get_name(buf)

    local cmd = {
        'typos',
        '--format',
        'brief',
        bufname,
    }

    require('utils.async').makeprg {
        makeprg = cmd,
        notify = false,
        silent = true,
        dump = false,
    }
end

return M

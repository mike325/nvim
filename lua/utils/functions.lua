local nvim = require 'nvim'

local replace_indent = require('utils.buffers').replace_indent
local executable = require('utils.files').executable
local is_file = require('utils.files').is_file
local getcwd = require('utils.files').getcwd

local M = {}

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

local icons
if not vim.env.NO_COOL_FONTS then
    icons = {
        error = '×', -- ✗ -- 🞮  -- × --  -- ❌
        warn = ' ', -- 
        info = ' ',
        hint = '',
        wait = '☕',
        build = '⛭',
        success = '✓', -- ✓ -- ✔ -- 
        fail = '✗',
        bug = '',
        breakpoint = '●',
        todo = '',
        hack = ' ',
        perf = ' ',
        note = ' ',
        test = '⏲ ',
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
        wait = '☕', -- W
        build = '⛭', -- b
        success = '✓', -- ✓ -- ✔ -- 
        fail = '✗',
        breakpoint = '⦿',
        bug = 'B', -- 🐛' -- B
        todo = '⦿',
        hack = '☠',
        perf = '✈', -- 🚀
        note = '🗈',
        test = '⏲',
        virtual_text = '❯', -- '❯', -- '➤',
        diff_add = '+',
        diff_modified = '~',
        diff_remove = '-',
        git_branch = '', -- TODO add an universal branch
        readonly = '🔒', -- '',
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

function M.send_osc1337(name, val)
    local b64 = vim.base64.encode(val)
    local seq = vim.env.TMUX and '\x1bPtmux;\x1b\x1b]1337;SetUserVar=%s=%s\b\x1b\\' or '\x1b]1337;SetUserVar=%s=%s\b'
    local stdout = vim.loop.new_tty(1, false)
    stdout:write(seq:format(name, b64))
end

function M.send_osc52(lines)
    local b64 = vim.base64.encode(table.concat(lines, '\n'))
    local seq = vim.env.TMUX and '\x1bPtmux;\x1b\x1b]52;;%s\b\x1b\\' or '\x1b]52;;%s\x1b\\'
    local stdout = vim.loop.new_tty(1, false)
    stdout:write(seq:format(b64))
end

function M.get_icon(icon)
    return icons[icon]
end

function M.send_grep_job(opts)
    vim.validate {
        opts = { opts, 'table', true },
    }

    opts = opts or {}

    local grepprg = vim.bo.grepprg ~= '' and vim.bo.grepprg or vim.o.grepprg
    grepprg = vim.split(grepprg, '%s+', { trimempty = true })

    local cmd = opts.cmd or grepprg[1]
    local args = opts.args or {}
    local search = opts.search or vim.fn.expand '<cword>'
    -- NOTE: Save the search in / for future reference,
    nvim.reg['/'] = search
    local use_loc = opts.loc

    vim.validate {
        cmd = { cmd, 'string' },
        args = { args, 'table' },
        search = { search, 'string' },
        use_loc = { use_loc, 'boolean', true },
    }

    if cmd == grepprg[1] and #args == 0 then
        vim.list_extend(args, vim.list_slice(grepprg, 2, #grepprg))
    end

    local win
    if use_loc then
        win = opts.win or vim.api.nvim_get_current_win()
    end

    cmd = { cmd }
    args = vim.tbl_filter(function(k)
        return not k:match '^%s*$'
    end, args)

    vim.list_extend(cmd, args)
    table.insert(cmd, search)

    local grep = RELOAD('jobs'):new {
        cmd = cmd,
        silent = true,
        opts = {
            cwd = require('utils.files').getcwd(),
            stdin = 'null',
        },
        qf = {
            on_fail = {
                open = true,
                jump = false,
            },
            loc = use_loc,
            win = win,
            jump = true,
            title = 'AsyncGrep',
            efm = vim.opt.grepformat:get(),
        },
    }

    grep:add_callbacks(function(job, rc)
        if rc == 0 and job:is_empty() then
            vim.notify('No matching results ' .. search, vim.log.levels.WARN, { title = 'Grep' })
        elseif rc ~= 0 then
            if job:is_empty() then
                vim.notify('No matching results ' .. search, vim.log.levels.WARN, { title = 'Grep' })
            else
                vim.notify(('%s exited with code %s'):format(cmd[1], rc), vim.log.levels.ERROR, { title = 'Grep' })
            end
        end
    end)
    grep:start()
end

-- TODO: call opfun functions directly instead of using a viml wrapper
function M.opfun_grep(_, visual)
    local select_save = vim.o.selection
    vim.o.selection = 'inclusive'

    local search, s_row, s_col, e_row, e_col
    if visual then
        local startpos = nvim.fn.getpos "'<"
        local endpos = nvim.fn.getpos "'>"
        s_row, s_col, e_row, e_col = startpos[2] - 1, startpos[3] - 1, endpos[2] - 1, endpos[3]
    else
        local startpos = nvim.buf.get_mark(0, '[')
        local endpos = nvim.buf.get_mark(0, ']')
        s_row, s_col, e_row, e_col = startpos[1] - 1, startpos[2], endpos[1] - 1, endpos[2] + 1
    end

    search = nvim.buf.get_text(0, s_row, s_col, e_row, e_col, {})[1]
    M.send_grep_job { search = search }

    vim.o.selection = select_save
end

function M.toggle_comments(first, last)
    local cursor = nvim.win.get_cursor(0)
    local lines = nvim.buf.get_lines(0, first, last, false)

    local commentstring = vim.bo.commentstring:gsub('%s+', '')
    local indent_level
    local comment = false
    local allempty = true

    local comment_match = '^%s*' .. commentstring:format('.*'):gsub('%-', '%%-'):gsub('/%*', '/%%*'):gsub('%*/', '%%*/')

    for _, line in pairs(lines) do
        if #line > 0 then
            allempty = false
            if not comment and not line:match(comment_match) then
                comment = true
                break
            end
        end
    end

    if allempty then
        -- indent_level = 0
        comment = true
    end

    indent_level = require('utils.buffers').get_indent_block(lines) + 1

    local spaces = ''
    if comment then
        for _ = 1, indent_level - 1 do
            spaces = spaces .. ' '
        end
    end

    for i = 1, #lines do
        if comment then
            local tocomment = lines[i]:sub(indent_level, #lines[i])
            local uncomment = (#lines[i] == 0 and indent_level > 1) and spaces or lines[i]:sub(1, indent_level - 1)
            local format = #lines[i] == 0 and tocomment or ' ' .. tocomment
            lines[i] = uncomment .. commentstring:format(format)
        else
            local indent_match = '^%s+'
            local uncomment_match = '^%s*'
                .. commentstring:format('%s?(.*)'):gsub('%-', '%%-'):gsub('/%*', '/%%*'):gsub('%*/', '%%*/')
            local indent = lines[i]:match(indent_match) or ''
            local data = lines[i]:match(uncomment_match)
            lines[i] = #data > 0 and indent .. data or ''
        end
    end

    nvim.buf.set_lines(0, first, last, false, lines)
    nvim.win.set_cursor(0, cursor)
end

function M.opfun_comment(_, visual)
    local select_save = vim.o.selection
    vim.o.selection = 'inclusive'

    local s_row, e_row
    if visual then
        local startpos = nvim.fn.getpos "'<"
        local endpos = nvim.fn.getpos "'>"
        s_row, e_row = startpos[2] - 1, endpos[2]
    else
        local startpos = nvim.buf.get_mark(0, '[')
        local endpos = nvim.buf.get_mark(0, ']')
        s_row, e_row = startpos[1] - 1, endpos[1]
    end

    M.toggle_comments(s_row, e_row)

    vim.o.selection = select_save
end

function M.external_formatprg(args)
    vim.validate {
        args = { args, 'table' },
        cmd = { args.cmd, 'table' },
    }

    local cmd = args.cmd
    local buf = args.buffer or vim.api.nvim_get_current_buf()

    local buf_utils = RELOAD 'utils.buffers'

    local first = args.first or (vim.v.lnum - 1)
    local last = args.last or (first + vim.v.count)

    local lines = vim.api.nvim_buf_get_lines(buf, first, last, false)
    local indent_level = buf_utils.get_indent_block_level(lines)
    local tmpfile = vim.fn.tempname()

    require('utils.files').writefile(tmpfile, buf_utils.indent(lines, -indent_level))

    table.insert(cmd, tmpfile)

    local view = vim.fn.winsaveview()

    local formatprg = RELOAD('jobs'):new {
        cmd = cmd,
        silent = true,
        qf = {
            dump = false,
            on_fail = {
                open = true,
                jump = false,
                dump = true,
            },
            loc = true,
            win = vim.api.nvim_get_current_win(),
            title = 'Format',
            efm = args.efm,
        },
        callbacks_on_success = function(_)
            local fmt_lines = require('utils.files').readfile(tmpfile)
            fmt_lines = buf_utils.indent(fmt_lines, indent_level)
            vim.api.nvim_buf_set_lines(buf, first, last, false, fmt_lines)
            vim.fn.winrestview(view)
        end,
    }

    formatprg:start()
end

function M.async_execute(opts)
    vim.validate {
        opts = { opts, 'table' },
        cmd = { opts.cmd, { 'table', 'string' } },
    }

    local cmd = opts.cmd
    local args = opts.args

    if opts.progress == nil then
        opts.progress = true
    end

    local dump = opts.dump
    if dump == nil then
        dump = false
    end

    local script = RELOAD('jobs'):new {
        cmd = cmd,
        args = args,
        silent = opts.silent,
        progress = opts.progress,
        verify_exec = opts.verify_exec,
        parse_errors = opts.parse_errors,
        opts = {
            cwd = opts.cwd or require('utils.files').getcwd(),
            on_stdout = opts.on_stdout,
            on_stderr = opts.on_stderr,
            on_exit = opts.on_exit,
            pty = opts.pty,
        },
        qf = {
            dump = dump,
            open = dump,
            on_fail = {
                jump = true,
                open = true,
                dump = true,
            },
            efm = opts.efm,
            title = opts.title or 'AsyncExecute',
        },
        callbacks = opts.callbacks,
        callbacks_on_failure = opts.callbacks_on_failure,
        callbacks_on_success = opts.callbacks_on_success,
    }

    if opts.auto_close or opts.autoclose then
        script:callbacks_on_success(function(_)
            if vim.t.progress_win and not vim.g.active_job then
                nvim.win.close(vim.t.progress_win, true)
            end
        end)
    end

    if opts.pre_execute then
        opts.pre_execute = vim.islist(opts.pre_execute) and opts.pre_execute or { opts.pre_execute }
        for _, func in ipairs(opts.pre_execute) do
            func()
        end
    end

    script:start()
    if opts.progress then
        script:progress()
    end
end

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

    local cmd = { compiler }
    local ok, ft_compilers = pcall(RELOAD, 'filetypes.' .. language)
    local efm
    if ok then
        local compiler_data = ft_compilers[option][compiler] or {}

        local has_config = false
        if opts.configs then
            local config_files = vim.fs.find(opts.configs, { upward = true, type = 'file' })
            has_config = #config_files > 0
        end

        if not has_config and opts.global_config and is_file(opts.global_config) then
            has_config = true
        end

        -- TODO: Add option to pass config path as compiler arg
        if not has_config and compiler_data then
            vim.list_extend(cmd, compiler_data)
        elseif opts.subcmd or opts.subcommand then
            table.insert(cmd, opts.subcmd or opts.subcommand)
        end

        efm = compiler_data.efm or compiler_data.errorformat or opts.efm or opts.errorformat
    elseif opts.args then
        vim.list_extend(cmd, type(opts.args) == type {} and opts.args or { opts.args })
        efm = opts.efm or opts.errorformat
    else
        error(debug.traceback(string.format('Invalid compiler: %s', compiler)))
    end

    -- table.insert(cmd, '%')

    local has_cmd = nvim.has.command 'CompilerSet'
    if not has_cmd then
        nvim.command.set('CompilerSet', function(command)
            -- TODO: Migrate this into opt_local API
            vim.cmd(('setlocal %s'):format(command.args))
        end, { nargs = 1, buffer = true })
    end

    vim.cmd.CompilerSet('makeprg=' .. table.concat(replace_indent(cmd), '\\ '))

    if efm then
        vim.cmd.CompilerSet('errorformat=' .. table.concat(efm, ','):gsub(' ', '\\ '))
    end

    vim.b.current_compiler = compiler

    if not has_cmd then
        nvim.command.del('CompilerSet', true)
    end
end

function M.load_module(name)
    return vim.F.npcall(require, name)
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
        tag = {
            left = '',
            right = '',
        },
        slash = {
            left = '/',
            right = '\\',
        },
        parenthesis = {
            left = ')',
            right = '(',
        },
    }

    return separators[sep_type]
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

    local modern_git = STORAGE.modern_git

    local greplist = {
        git = {
            grepprg = 'git --no-pager grep ' .. (modern_git and '--column' or '') .. ' --no-color -Iin ',
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
        M.abolish(lang)
        vim.bo.spelllang = lang
    end
    vim.print(vim.bo.spelllang)
end

function M.get_abbrs(language)
    return require('configs.abolish').abolish[language]
end

function M.abolish(language)
    local current = vim.bo.spelllang
    local set_abbr = require('nvim.abbrs').set_abbr
    local abolish = require('configs.abolish').abolish

    if nvim.has.cmd 'Abolish' then
        if abolish[current] ~= nil then
            for base, _ in pairs(abolish[current]) do
                vim.cmd.Abolish { args = { '-delete', '-buffer', base } }
            end
        end
        if abolish[language] ~= nil then
            for base, replace in pairs(abolish[language]) do
                vim.cmd.Abolish { args = { '-buffer', base, replace } }
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

if STORAGE.modern_git == -1 then
    STORAGE.modern_git = require('storage').has_version('git', { '2', '19' })
end

function M.autoformat(cmd, args)
    if vim.b.autoformat == false or vim.t.autoformat == false or vim.g.autoformat == false then
        return
    end

    local view = vim.fn.winsaveview()
    local formatter = RELOAD('jobs'):new {
        cmd = cmd,
        args = args,
        silent = true,
        callbacks_on_success = function()
            vim.cmd.checktime()
            vim.fn.winrestview(view)
            -- vim.cmd.edit()
        end,
    }
    formatter:start()
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

            vim.ui.select(
                vim.split(
                    vim.system({ 'ssh', '-p', host_port or '22', hostname, 'ls', remote_path or '.' }, { text = true })
                        :wait().stdout,
                    '\n',
                    { trimempty = true }
                ),
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

    local title = 'Typos'
    local typos = RELOAD('jobs'):new {
        cmd = cmd,
        silent = true,
        callbacks = function(job, _)
            local qf_utils = RELOAD 'utils.qf'
            local output = RELOAD('utils.tables').remove_empty(job:output())
            local diagnostic_ns_name = title:lower()
            if #output > 0 then
                qf_utils.set_list {
                    title = diagnostic_ns_name,
                    items = output,
                    jump = false,
                    open = false,
                    win = 0,
                }
                qf_utils.qf_to_diagnostic(diagnostic_ns_name, 0)
            elseif diagnostic_ns_name == vim.fn.getloclist(0, { title = 1 }).title then
                qf_utils.clear(0)
                vim.diagnostic.reset(vim.api.nvim_create_namespace(diagnostic_ns_name))
            end
        end,
    }
    typos:start()
end

function M.watch_config_file(fname)
    vim.validate {
        fname = { fname, 'string' },
    }

    if require('utils.files').is_file(fname) then
        local real_fname = require('utils.files').realpath(fname)
        require('watcher.file'):new(real_fname, 'ConfigReloader'):start()
    end
end

return M

local nvim = require 'neovim'
local sys = require 'sys'

local replace_indent = require('utils.buffers').replace_indent
local executable = require('utils.files').executable
local is_file = require('utils.files').is_file
local getcwd = require('utils.files').getcwd

local M = {}

local git_dirs = {}
local qf_funcs = {
    first = function(win)
        vim.validate {
            win = { win, 'number', true },
        }
        if win then
            vim.cmd.lfirst()
        else
            vim.cmd.cfirst()
        end
    end,
    last = function(win)
        vim.validate {
            win = { win, 'number', true },
        }
        if win then
            vim.cmd.llast()
        else
            vim.cmd.clast()
        end
    end,
    open = function(win, size)
        vim.validate {
            win = { win, 'number', true },
            size = { size, 'number', true },
        }
        local direction = vim.o.splitbelow and 'botright' or 'topleft'
        local cmd = win and 'lopen' or 'copen'
        -- TODO: botright and topleft does not seem to work with vim.cmd, need some digging
        vim.cmd(('%s %s %s'):format(direction, cmd, size or ''))
    end,
    close = function(win)
        vim.validate {
            win = { win, 'number', true },
        }
        if win then
            vim.cmd.lclose()
        else
            vim.cmd.cclose()
        end
    end,
    set_list = function(items, action, what, win)
        vim.validate {
            win = { win, 'number', true },
        }
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
        vim.validate {
            what = { what, 'table', true },
            win = { win, 'number', true },
        }
        if win then
            if what then
                return vim.fn.getloclist(win, what)
            end
            return vim.fn.getloclist(win)
        end
        if what then
            return vim.fn.getqflist(what)
        end
        return vim.fn.getqflist()
    end,
}

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

function M.get_icon(icon)
    return icons[icon]
end

function M.make_executable()
    if sys.name == 'windows' then
        return
    end

    local shebang = nvim.buf.get_lines(0, 0, 1, true)[1]
    if not shebang or not shebang:match '^#!.+' then
        nvim.autocmd.add('BufWritePre', {
            group = 'MakeExecutable',
            buffer = nvim.win.get_buf(0),
            callback = function()
                M.make_executable()
            end,
            once = true,
        })
        return
    end

    local filename = vim.fn.expand '%'
    if is_file(filename) then
        local fileinfo = vim.loop.fs_stat(filename)
        local filemode = fileinfo.mode - 32768

        if fileinfo.uid ~= sys.user.uid or bit.band(filemode, 0x40) ~= 0 then
            return
        end
    end

    nvim.autocmd.add('BufWritePost', {
        group = 'MakeExecutable',
        buffer = nvim.win.get_buf(0),
        callback = function()
            M.chmod_exec()
        end,
        once = true,
    })
end

function M.chmod_exec()
    local filename = vim.fn.expand '%'

    if not is_file(filename) or sys.name == 'windows' then
        return
    end

    local fileinfo = vim.loop.fs_stat(filename)
    local filemode = fileinfo.mode - 32768
    require('utils.files').chmod(filename, bit.bor(filemode, 0x48), 10)
end

function M.send_grep_job(opts)
    vim.validate {
        opts = { opts, 'table', true },
    }

    opts = opts or {}

    local grepprg = vim.split(vim.bo.grepprg or vim.o.grepprg, '%s+')
    local cmd = opts.cmd or grepprg[1]
    local args = opts.args or {}
    local search = opts.search or vim.fn.expand '<cword>'
    local use_loc = opts.loc

    vim.validate {
        cmd = { cmd, 'string' },
        args = { args, 'table' },
        search = { search, 'string' },
        use_loc = { use_loc, 'boolean', true },
    }

    if cmd == grepprg[1] then
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

    local grep = require('jobs'):new {
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
            context = 'AsyncGrep',
            title = 'AsyncGrep',
            efm = vim.opt.grepformat:get(),
        },
    }

    grep:add_callback(function(job, rc)
        if rc == 0 and job:is_empty() then
            vim.notify('No matching results ' .. search, 'WARN', { title = 'Grep' })
        elseif rc ~= 0 then
            if job:is_empty() then
                vim.notify('No matching results ' .. search, 'WARN', { title = 'Grep' })
            else
                vim.notify(('%s exited with code %s'):format(cmd[1], rc), 'ERROR', { title = 'Grep' })
            end
        end
    end)
    grep:start()
end

-- TODO: call opfun functions directly instead of using a viml wrapper
function M.opfun_grep(select, visual)
    local select_save = vim.o.selection
    vim.o.selection = 'inclusive'

    local startpos = nvim.buf.get_mark(0, '[')
    local endpos = nvim.buf.get_mark(0, ']')
    local selection = nvim.buf.get_text(0, startpos[1] - 1, startpos[2], endpos[1] - 1, endpos[2] + 1, {})[1]

    M.send_grep_job { search = selection }

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

    local startpos = nvim.buf.get_mark(0, '[')
    local endpos = nvim.buf.get_mark(0, ']')

    M.toggle_comments(startpos[1] - 1, endpos[1])

    vim.o.selection = select_save
end

function M.get_git_dir(callback)
    vim.validate { callback = { callback, 'function' } }
    assert(executable 'git', 'Missing git')

    local j = require('jobs'):new {
        cmd = { 'git', 'rev-parse', '--git-dir' },
        silent = true,
    }
    j:callback_on_success(function(job)
        local dir = table.concat(job:output(), '')
        pcall(callback, require('utils.files').realpath(dir))
    end)
    j:start()
end

function M.external_formatprg(args)
    assert(type(args) == type {} and args.cmd, debug.traceback 'Missing command')

    local cmd = args.cmd
    local buf = args.buffer or vim.api.nvim_get_current_buf()

    local indent = require('utils.buffers').indent

    local first = args.first or (vim.v.lnum - 1)
    local last = args.last or (first + vim.v.count)

    local lines = vim.api.nvim_buf_get_lines(buf, first, last, false)
    local indent_level = require('utils.buffers').get_indent_block_level(lines)
    local tmpfile = vim.fn.tempname()

    require('utils.files').writefile(tmpfile, indent(lines, -indent_level))

    table.insert(cmd, tmpfile)

    local formatprg = require('jobs'):new {
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
            context = 'Format',
            title = 'Format',
            efm = args.efm,
        },
    }

    local view = vim.fn.winsaveview()

    formatprg:callback_on_success(function(_)
        local fmt_lines = require('utils.files').readfile(tmpfile)
        fmt_lines = indent(fmt_lines, indent_level)
        vim.api.nvim_buf_set_lines(buf, first, last, false, fmt_lines)
        vim.fn.winrestview(view)
    end)

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
            dump = false,
            on_fail = {
                jump = true,
                open = true,
                dump = true,
            },
            efm = opts.efm,
            context = opts.context or opts.title or 'AsyncExecute',
            title = opts.title or opts.context or 'AsyncExecute',
        },
    }

    if opts.auto_close then
        script:callback_on_success(function(_)
            if vim.t.progress_win then
                nvim.win.close(vim.t.progress_win, true)
            end
        end)
    end

    if opts.callbacks then
        script:add_callback(opts.callbacks)
    end

    if opts.callback_on_failure then
        script:callback_on_failure(opts.callback_on_failure)
    end

    if opts.callback_on_success then
        script:callback_on_success(opts.callback_on_success)
    end

    if opts.pre_execute then
        opts.pre_execute = vim.tbl_islist(opts.pre_execute) and opts.pre_execute or { opts.pre_execute }
        for _, func in ipairs(opts.pre_execute) do
            func()
        end
    end

    script:start()
    if opts.progress then
        script:progress()
    end
end

function M.open(uri)
    vim.validate {
        uri = { uri, 'string' },
    }

    local cmd
    local args = {}
    if sys.name == 'windows' then
        cmd = 'powershell'
        vim.list_extend(args, { '-noexit', '-executionpolicy', 'bypass', 'Start-Process' })
    elseif sys.name == 'linux' then
        cmd = 'xdg-open'
    else
        -- Problably macos
        cmd = 'open'
    end

    table.insert(args, uri)

    local open = require('jobs'):new {
        cmd = cmd,
        args = args,
        qf = {
            dump = false,
            on_fail = {
                dump = true,
                jump = false,
                open = true,
            },
            context = 'Open',
            title = 'Open',
        },
    }
    open:start()
end

-- TODO: Improve python folding text
function M.foldtext()
    local indent_level =
        require('utils.buffers').get_indent_block(vim.api.nvim_buf_get_lines(0, vim.v.foldstart, vim.v.foldend, false))
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

    local language = opts.language or vim.opt_local.filetype:get()
    local option = opts.option or 'makeprg'

    local cmd = { compiler }
    local compiler_data = RELOAD('filetypes.' .. language)[option][compiler] or {}

    local has_config = false
    if opts.configs then
        for _, config in ipairs(opts.configs) do
            if is_file(config) then
                has_config = true
                break
            end
        end
    end

    -- TODO: Add option to pass config path as compiler arg
    if not has_config and compiler_data then
        vim.list_extend(cmd, compiler_data)
    end

    table.insert(cmd, '%')

    local has_cmd = nvim.has.command 'CompilerSet'

    if not has_cmd then
        nvim.command.set('CompilerSet', function(command)
            -- TODO: Migrate this into opt_local API
            vim.cmd(('setlocal %s'):format(command.args))
        end, { nargs = 1, buffer = true })
    end

    vim.cmd.CompilerSet('makeprg=' .. table.concat(replace_indent(cmd), '\\ '))

    local efm = compiler_data.efm
    if efm then
        vim.cmd.CompilerSet('errorformat=' .. table.concat(efm, ','):gsub(' ', '\\ '))
    end

    vim.b.current_compiler = compiler

    if not has_cmd then
        nvim.command.del('CompilerSet', true)
    end
end

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

    root = vim.fs.normalize(root)

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

    if is_git and not git_dir then
        -- TODO: This should trigger an autocmd to update alternates, tests and everything else with the correct root
        M.get_git_dir(function(dir)
            local project = vim.b.project_root
            project.git_dir = dir
            git_dirs[cwd] = dir
            vim.b.project_root = project
        end)
    end

    if not vim.t.lock_grep then
        M.set_grep(is_git, true)
    else
        M.set_grep(false, true)
    end

    if nvim.has { 0, 8 } then
        -- NOTE: this could be also search in another thread, we may have too many search in bufenter/filetype events

        -- RELOAD('threads.related').async_gather_tests()

        local is_c_project = vim.fs.find(
            { 'CMakeLists.txt', 'compile_flags.txt', 'compile_commands.json', '.clang-format', '.clang-tidy' },
            { upward = true, type = 'file' }
        )

        if #is_c_project > 0 then
            RELOAD('threads.related').async_gather_alternates { path = vim.fs.dirname(is_c_project[1]) }

            local compile_flags = vim.fs.find(
                { 'compile_flags.txt', 'compile_commands.json' },
                { upward = true, type = 'file' }
            )

            local flags_root = vim.fs.dirname(compile_flags[1])
            vim.g.parsed = vim.g.parsed or {}
            if #compile_flags > 0 and not vim.g.parsed[flags_root] then
                RELOAD('threads.parse').compile_flags {
                    root = flags_root,
                    flags_file = compile_flags[1],
                }
            end
        end
    end

    local project = vim.fs.find('.project.lua', { upward = true, type = 'file' })
    if #project > 0 then
        vim.cmd.source(project[1])
    end
end

function M.add_nl(down)
    local cursor_pos = nvim.win.get_cursor(0)
    local lines = { '' }
    local count = vim.v['count1']
    if count > 1 then
        for _ = 2, count, 1 do
            table.insert(lines, '')
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
    -- TODO: Investigate how to add silent
    vim.cmd('silent! call repeat#set("' .. cmd .. '",' .. count .. ')')
end

function M.move_line(down)
    -- local cmd
    local lines = { '' }
    local count = vim.v.count1

    if count > 1 then
        for _ = 2, count, 1 do
            table.insert(lines, '')
        end
    end

    if down then
        -- cmd = ']e'
        count = vim.fn.line '$' < vim.fn.line '.' + count and vim.fn.line '$' or vim.fn.line '.' + count
    else
        -- cmd = '[e'
        count = vim.fn.line '.' - count - 1 < 1 and 1 or vim.fn.line '.' - count - 1
    end

    vim.cmd.move(count)
    vim.cmd.normal { bang = true, args = { '==' } }
    -- TODO: Make repeat work
    -- vim.cmd('silent! call repeat#set("'..cmd..'",'..count..')')
end

function M.find_project_root(path)
    assert(type(path) == 'string' and path ~= '', ([[Not a path: "%s"]]):format(path))
    local root
    local vcs_markers = { '.git', '.svn', '.hg' }
    local dir = vim.fn.fnamemodify(path, ':p')

    for _, marker in pairs(vcs_markers) do
        local results = vim.fs.find(marker, { path = dir, upward = true })
        if #results > 0 then
            root = results[1]
            break
        end
    end

    return not root and getcwd() or vim.fs.dirname(root)
end

function M.is_git_repo(root)
    assert(type(root) == type '' and root ~= '', debug.traceback(([[Not a path: "%s"]]):format(root)))
    if not executable 'git' then
        return false
    end

    root = vim.fs.normalize(root)

    local git = root .. '/.git'

    if require('utils.files').is_dir(git) or require('utils.files').is_file(git) then
        return true
    end
    local results = vim.fs.find('.git', { path = root, upward = true })
    return #results > 0 and results[1] or false
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

    if not vim.tbl_islist(excludes) then
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

    if vim.tbl_islist(grep) then
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

    if vim.tbl_islist(filelist) then
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
        vim.opt_local.spelllang = lang
    end
    P(vim.opt_local.spelllang:get()[1])
end

function M.get_abbrs(language)
    return require('plugins.abolish').abolish[language]
end

function M.abolish(language)
    local current = vim.bo.spelllang
    local set_abbr = require('neovim.abbrs').set_abbr
    local abolish = require('plugins.abolish').abolish

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
        vim.notify('Python' .. pyversion .. ' is not available in the system', 'ERROR', { title = 'Python' })
        return -1
    end

    local split_type = vim.o.splitbelow and 'botright' or 'topleft'
    -- TODO: migrate this
    vim.cmd(split_type .. ' split term://' .. pyversion .. ' ' .. args)
end

function M.toggle_qf(opts)
    vim.validate {
        opts = { opts, 'table', true },
    }
    opts = opts or {}
    local win = opts.win
    if type(win) ~= type(1) then
        win = nil
    end

    local qf_winid = qf_funcs.get_list({ winid = 0 }, win).winid
    if qf_winid > 0 then
        qf_funcs.close(win)
    else
        local size
        local elements = #qf_funcs.get_list(nil, win) + 1
        if opts.size then
            size = opts.size
        else
            local lines = vim.opt_local.lines:get()
            size = math.min(math.floor(lines * 0.5), elements)
        end

        qf_funcs.open(win, size)
    end
end

-- TODO: Add support to dump to diagnostics ?
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

    opts.title = opts.title or opts.context or 'Generic Qf data'
    opts.context = opts.context or opts.title or 'GenericQfData'
    if not opts.efm or #opts.efm == 0 then
        local efm = vim.opt_local.efm:get()
        if #efm == 0 then
            efm = vim.opt_global.efm:get()
        end
        opts.efm = efm
    end

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
    opts.on_fail = nil
    opts.lines = require('utils.tables').clear_lst(opts.lines)

    for idx, line in ipairs(opts.lines) do
        opts.lines[idx] = vim.api.nvim_replace_termcodes(line, true, false, false)
    end

    local win
    if qf_type ~= 'qf' then
        win = opts.win or vim.api.nvim_get_current_win()
    end
    opts.win = nil
    qf_funcs.set_list({}, ' ', opts, win)

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
            local elements = #qf_funcs.get_list(nil, win) + 1
            local lines = vim.opt.lines:get()
            local size = math.min(math.floor(lines * 0.5), elements)
            qf_funcs.open(win, size)
        end

        if qf_jump then
            qf_funcs.first(win)
        end
    else
        vim.notify('No output to display', 'ERROR', { title = qf_type == 'qf' and 'QuickFix' or 'LocationList' })
    end
end

function M.clear_qf(win)
    qf_funcs.set_list({}, ' ', nil, win)
    qf_funcs.close(win)
end

if STORAGE.modern_git == -1 then
    STORAGE.modern_git = require('storage').has_version('git', { '2', '19' })
end

function M.autoformat(cmd, args)
    if vim.b.disable_autoformat or vim.t.disable_autoformat or vim.g.disable_autoformat then
        return
    end

    local view = vim.fn.winsaveview()
    local formatter = RELOAD('jobs'):new {
        cmd = cmd,
        args = args,
        silent = true,
    }
    formatter:callback_on_success(function()
        vim.cmd.checktime()
        vim.fn.winrestview(view)
        -- vim.cmd.edit()
    end)
    formatter:start()
end

return M

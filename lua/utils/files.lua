local sys = require 'sys'
local nvim = require 'neovim'
local bufloaded = require('utils.buffers').bufloaded

local uv = vim.loop

local has_cjson, _ = pcall(require, 'cjson')
STORAGE.has_cjson = vim.json ~= nil or has_cjson

local M = {}

M.getcwd = uv.cwd

local is_windows = sys.name == 'windows'

function M.forward_path(path)
    if is_windows then
        if vim.o.shellslash then
            path = path:gsub('\\', '/')
            return path
        end
        path = path:gsub('/', '\\')
        return path
    end
    return path
end

function M.separator()
    if is_windows and not vim.o.shellslash then
        return '\\'
    end
    return '/'
end

local function split_path(path)
    path = require('utils.strings').split(M.normalize_path(path), M.separator())
    return path
end

if vim.json then
    vim.json.encode_escape_forward_slash(false)
end

function M.exists(filename)
    vim.validate { filename = { filename, 'string' } }
    assert(filename ~= '', debug.traceback 'Empty filename')
    local stat = uv.fs_stat(M.normalize_path(filename))
    return stat and stat.type or false
end

function M.is_dir(filename)
    return M.exists(filename) == 'directory'
end

function M.is_file(filename)
    return M.exists(filename) == 'file'
end

function M.mkdir(dirname, recurive)
    vim.validate {
        dirname = { dirname, 'string' },
        recurive = { recurive, 'boolean', true },
    }
    assert(dirname ~= '', debug.traceback 'Empty dirname')
    if M.is_dir(dirname) then
        return true
    end
    dirname = M.normalize_path(dirname)
    local ok, msg, err = uv.fs_mkdir(dirname, 511)
    if err == 'ENOENT' and recurive then
        local dirs = vim.split(dirname, M.separator())
        local base = dirs[1] == '' and '/' or dirs[1]
        if dirs[1] == '' or M.is_root(dirs[1]) then
            table.remove(dirs, 1)
        end
        for _, dir in ipairs(dirs) do
            base = base .. M.separator() .. dir
            if not M.exists(base) then
                ok, msg, _ = uv.fs_mkdir(base, 511)
                if not ok then
                    vim.notify(msg, 'ERROR', { title = 'Mkdir' })
                    break
                end
            else
                ok = M.is_dir(base)
                if not ok then
                    break
                end
            end
        end
    elseif not ok then
        vim.notify(msg, 'ERROR', { title = 'Mkdir' })
    end
    return ok or false
end

function M.link(src, dest, sym, force)
    vim.validate {
        source = { src, 'string' },
        destination = { dest, 'string' },
        use_symbolic = { sym, 'boolean', true },
        force = { force, 'boolean', true },
    }
    assert(src ~= '', debug.traceback 'Empty source')
    assert(dest ~= '', debug.traceback 'Empty destination')
    assert(M.exists(src), debug.traceback('link source ' .. src .. ' does not exists'))

    if dest == '.' then
        dest = M.basename(src)
    end

    dest = M.normalize_path(dest)
    src = M.normalize_path(src)

    assert(src ~= dest, debug.traceback 'Cannot link src to itself')

    local status, msg

    if not sym and M.is_dir(src) then
        vim.notify('Cannot hard link a directory', 'ERROR', { title = 'Link' })
        return false
    end

    if not force and M.exists(dest) then
        vim.notify('Dest already exists in ' .. dest, 'ERROR', { title = 'Link' })
        return false
    elseif force and M.exists(dest) then
        status, msg, _ = uv.fs_unlink(dest)
        if not status then
            vim.notify(msg, 'ERROR', { title = 'Link' })
            return false
        end
    end

    if sym then
        status, msg = uv.fs_symlink(src, dest, 438)
    else
        status, msg = uv.fs_link(src, dest)
    end

    if not status then
        vim.notify(msg, 'ERROR', { title = 'Link' })
    end

    return status or false
end

function M.executable(exec)
    vim.validate { exec = { exec, 'string' } }
    assert(exec ~= '', debug.traceback 'Empty executable string')
    return vim.fn.executable(exec) == 1
end

function M.exepath(exec)
    vim.validate { exec = { exec, 'string' } }
    assert(exec ~= '', debug.traceback 'Empty executable string')
    local path = vim.fn.exepath(exec)
    return path ~= '' and path or false
end

function M.is_absolute(path)
    vim.validate { path = { path, 'string' } }
    assert(path ~= '', debug.traceback 'Empty path')
    if path:sub(1, 1) == '~' then
        path = path:gsub('~', sys.home)
    end

    local is_abs = false
    if is_windows and #path >= 2 then
        is_abs = string.match(path:sub(1, 2), '^%w:$') ~= nil
    elseif not is_windows then
        is_abs = path:sub(1, 1) == '/'
    end
    return is_abs
end

function M.is_root(path)
    vim.validate { path = { path, 'string' } }
    assert(path ~= '', debug.traceback 'Empty path')
    local root = false
    if is_windows and #path >= 2 then
        path = M.forward_path(path)
        root = string.match(path, '^%w:' .. M.separator() .. '?$') ~= nil
    elseif not is_windows then
        root = path == '/'
    end
    return root
end

function M.realpath(path)
    vim.validate { path = { path, 'string' } }
    assert(M.exists(path), debug.traceback(([[Path "%s" doesn't exists]]):format(path)))
    path = M.normalize_path(path)
    local rpath = uv.fs_realpath(path)
    return M.forward_path(rpath or path)
end

function M.normalize_path(path)
    vim.validate { path = { path, 'string' } }
    assert(path ~= '', debug.traceback 'Empty path')
    if path:sub(1, 1) == '~' then
        path = path:gsub('~', sys.home)
    elseif path == '%' then
        -- TODO: Replace this with a fast API
        path = vim.fn.expand(path)
    end
    return M.forward_path(path)
end

function M.basename(path)
    vim.validate { path = { path, 'string' } }
    if path == '.' then
        path = M.getcwd()
    end
    path = M.normalize_path(path)
    return path:match(('[^%s]+$'):format(M.separator()))
end

function M.extension(path)
    vim.validate { path = { path, 'string' } }
    assert(path ~= '', debug.traceback 'Empty path')
    local extension = ''
    path = M.normalize_path(path)
    if not M.is_dir(path) then
        local filename = split_path(path)
        filename = filename[#filename]
        extension = filename:match '^.+(%..+)$' or ''
    end
    return #extension >= 2 and extension:sub(2, #extension) or extension
end

function M.filename(path)
    vim.validate { path = { path, 'string' } }
    local name = M.basename(path)
    local extension = M.extension(name)
    return extension ~= '' and name:gsub('%.' .. extension .. '$', '') or name
end

function M.basedir(path)
    vim.validate { path = { path, 'string' } }
    path = M.normalize_path(path)
    local path_components = split_path(path)
    if #path_components > 1 then
        table.remove(path_components, #path_components)
        if M.is_absolute(path) and not is_windows then
            path = '/'
        else
            path = ''
        end
        path = path .. table.concat(path_components, M.separator())
    elseif M.is_absolute(path) then
        if is_windows then
            path = path:sub(1, #path > 2 and 3 or 2)
        else
            path = '/'
        end
    else
        path = '.'
    end
    return M.forward_path(path)
end

function M.is_parent(parent, child)
    vim.validate { parent = { parent, 'string' }, child = { child, 'string' } }
    assert(M.is_dir(parent), debug.traceback(('Parent path is not a directory "%s"'):format(parent)))
    assert(M.is_dir(child), debug.traceback(('Child path is not a directory "%s"'):format(child)))

    child = M.realpath(child)
    parent = M.realpath(parent)

    -- TODO: Check windows multi drive root
    local is_child = false
    if M.is_root(parent) or child:match('^' .. parent) then
        is_child = true
    end

    return is_child
end

function M.openfile(path, flags, callback)
    vim.validate {
        path = { path, 'string' },
        flags = { flags, 'string' },
        callback = { callback, 'function' },
    }
    assert(path ~= '', debug.traceback 'Empty path')

    local fd, msg, _ = uv.fs_open(path, flags, 438)
    if not fd then
        vim.notify(msg, 'ERROR', { title = 'OpenFile' })
        return false
    end
    local ok, rst = pcall(callback, fd)
    assert(uv.fs_close(fd))
    return rst or ok
end

local function fs_write(path, data, append, callback)
    vim.validate {
        path = { path, 'string' },
        data = {
            data,
            function(d)
                return type(d) == type '' or vim.tbl_islist(d)
            end,
            'a string or an array',
        },
        append = { append, 'boolean', true },
        callback = { callback, 'function', true },
    }

    data = type(data) ~= type '' and table.concat(data, '\n') or data
    local flags = append and 'a' or 'w'

    if not callback then
        return M.openfile(path, flags, function(fd)
            local stat = uv.fs_fstat(fd)
            local offset = append and stat.size or 0
            local ok, msg, _ = uv.fs_write(fd, data, offset)
            if not ok then
                vim.notify(msg, 'ERROR', { title = 'Write file' })
            end
        end)
    end

    uv.fs_open(path, 'r', 438, function(oerr, fd)
        assert(not oerr, oerr)
        uv.fs_fstat(fd, function(serr, stat)
            assert(not serr, serr)
            local offset = append and stat.size or 0
            uv.fs_write(fd, data, offset, function(rerr)
                assert(not rerr, rerr)
                uv.fs_close(fd, function(cerr)
                    assert(not cerr, cerr)
                    return callback()
                end)
            end)
        end)
    end)
end

function M.writefile(path, data, callback)
    return fs_write(path, data, false, callback)
end

function M.updatefile(path, data, callback)
    assert(M.is_file(path), debug.traceback('Not a file: ' .. path))
    return fs_write(path, data, true, callback)
end

function M.readfile(path, split, callback)
    vim.validate {
        path = { path, 'string' },
        callback = { callback, 'function', true },
        split = { split, 'boolean', true },
    }
    assert(M.is_file(path), debug.traceback('Not a file: ' .. path))
    if split == nil then
        split = true
    end
    if not callback then
        return M.openfile(path, 'r', function(fd)
            local stat = assert(uv.fs_fstat(fd))
            local data = assert(uv.fs_read(fd, stat.size, 0))
            if split then
                data = vim.split(data, '[\r]?\n')
                -- NOTE: This seems to always read an extra linefeed so we remove it if it's empty
                if data[#data] == '' then
                    data[#data] = nil
                end
            end
            return data
        end)
    end
    uv.fs_open(path, 'r', 438, function(oerr, fd)
        assert(not oerr, oerr)
        uv.fs_fstat(fd, function(serr, stat)
            assert(not serr, serr)
            uv.fs_read(fd, stat.size, 0, function(rerr, data)
                assert(not rerr, rerr)
                uv.fs_close(fd, function(cerr)
                    assert(not cerr, cerr)
                    if split then
                        data = vim.split(data, '[\r]?\n')
                        if data[#data] == '' then
                            data[#data] = nil
                        end
                    end
                    return callback(data)
                end)
            end)
        end)
    end)
end

function M.chmod(path, mode, base)
    if is_windows then
        return
    end

    vim.validate {
        path = { path, 'string' },
        mode = {
            mode,
            function(m)
                local isnumber = type(m) == type(1)
                -- TODO: check for hex and bin ?
                local isrepr = type(m) == type '' and m ~= ''
                return isnumber or isrepr
            end,
            'valid integer representation',
        },
    }
    assert(path ~= '', debug.traceback 'Empty path')
    base = base == nil and 8 or base
    local ok, msg, _ = uv.fs_chmod(path, tonumber(mode, base))
    if not ok then
        vim.notify(msg, 'ERROR', { title = 'Chmod' })
    end
    return ok or false
end

function M.ls(expr)
    vim.validate {
        expr = {
            expr,
            function(e)
                return type(e) == type '' or type(e) == type {}
            end,
            'Expresion must be a string or a table with path and globs',
        },
    }

    if not expr then
        expr = {}
    elseif type(expr) == type '' then
        expr = { path = M.normalize_path(expr) }
    end

    local path = expr.path
    local glob = expr.glob
    local filter = expr.type

    glob = glob or '*'
    path = path or '.'

    local filter_func = {
        file = M.is_file,
        directory = M.is_dir,
    }

    filter_func.files = filter_func.file
    filter_func.directorys = filter_func.directory
    filter_func.dir = filter_func.dir
    filter_func.dirs = filter_func.dir

    -- TODO: Replace this with a luv function
    local results = vim.fn.globpath(path, glob, false, true, false)

    if filter_func[filter] ~= nil then
        results = vim.tbl_filter(filter_func[filter], results)
    end

    if is_windows and vim.o.shellslash then
        vim.tbl_map(M.forward_path, results)
    end

    return results
end

function M.get_files(expr)
    assert(
        not expr or type(expr) == type {} or type(expr) == type '',
        debug.traceback('Invalid expression ' .. vim.inspect(expr))
    )
    if not expr then
        expr = {}
    elseif type(expr) == type '' then
        expr = { path = M.normalize_path(expr) }
    end
    expr.type = 'file'
    return M.ls(expr)
end

function M.get_dirs(expr)
    assert(
        not expr or type(expr) == type {} or type(expr) == type '',
        debug.traceback('Invalid expression ' .. vim.inspect(expr))
    )
    if not expr then
        expr = {}
    elseif type(expr) == type '' then
        expr = { path = M.normalize_path(expr) }
    end
    expr.type = 'directory'
    return M.ls(expr)
end

function M.find_files(path, globs, cb)
    vim.validate {
        path = { path, 'string' },
        globs = {
            globs,
            function(g)
                return type(g) == type '' or vim.tbl_islist(g)
            end,
            'string or array of globs',
        },
        cb = { cb, 'function', true },
    }

    local seeker = require('utils.helpers').select_filelist(false, true)
    local cmd = seeker[1]
    local args = vim.list_slice(seeker, 2, #seeker)

    if globs then
        globs = type(globs) == type '' and { globs } or globs
        if cmd == 'find' then
            args[#args] = nil -- removes '*'
            args[#args] = nil -- removes -iname
        end
        -- WARN: due to differences in file searchers, globs only work with extensions
        for i = 1, #globs do
            if cmd == 'fd' then
                local extension = globs[i]:gsub('*%.', '')
                vim.list_extend(args, { '-e', extension })
            elseif cmd == 'rg' then
                vim.list_extend(args, { '--glob', globs[i] })
            elseif cmd == 'find' then
                vim.list_extend(args, { '-iname', globs[i] })
                if i < #globs then
                    table.insert(args, '-or')
                end
            end
        end
    end

    local files = RELOAD('jobs'):new {
        cmd = cmd,
        args = args,
        opts = {
            cwd = path,
        },
        silent = true,
    }

    files:callback_on_success(function(job)
        job._output = require('utils.tables').clear_lst(job:output())
    end)

    if cb then
        files:callback_on_success(cb)
    end

    files:start()

    if not cb then
        local rc = files:wait()
        return rc == 0 and files:output() or {}
    end
end

function M.copy(src, dest, bang)
    src = M.normalize_path(src)
    dest = M.normalize_path(dest)
    dest = M.is_dir(dest) and dest .. '/' .. M.basename(src) or dest

    if not M.is_dir(src) and (not M.exists(dest) or bang) then
        if M.exists(dest) and bang then
            if not M.delete(dest, bang) then
                return false
            end
        end
        local status, msg = uv.fs_copyfile(src, dest)
        if status then
            return true
        end
        vim.notify('Failed to copy ' .. src .. ' to ' .. dest .. '\n' .. msg, 'ERROR', { title = 'Copy' })
    elseif M.is_dir(src) then
        vim.notify('Cannot recursively copy directories', 'ERROR', { title = 'Copy' })
    else
        vim.notify(dest .. ' exists, use force to override it', 'ERROR', { title = 'Copy' })
    end

    return false
end

function M.rename(old, new, bang)
    new = M.normalize_path(new)
    old = M.normalize_path(old)

    if not M.exists(new) or bang then
        local cursor_pos

        if not M.exists(old) and bufloaded(old) then
            nvim.ex.write(old)
            if M.realpath(nvim.buf.get_name(nvim.get_current_buf())) == M.realpath(old) then
                cursor_pos = nvim.win.get_cursor(nvim.get_current_buf())
            end
        end

        if bufloaded(new) then
            nvim.ex['bwipeout!'](new)
        end

        if uv.fs_rename(old, new) then
            if bufloaded(old) then
                nvim.ex['bwipeout!'](old)
            end

            if M.is_file(new) then
                nvim.ex.edit(new)
                if cursor_pos then
                    nvim.win.set_cursor(0, cursor_pos)
                end
            end

            return true
        else
            vim.notify('Failed to rename ' .. old, 'ERROR', { title = 'Rename' })
        end
    elseif M.exists(new) then
        vim.notify(new .. ' exists, use force to override it', 'ERROR', { title = 'Rename' })
    end

    return false
end

function M.delete(target, bang)
    vim.validate {
        target = { target, 'string' },
        bang = { bang, 'boolean', true },
    }

    if bang == nil then
        bang = false
    end

    target = M.normalize_path(target)

    if #target > 1 and target:sub(#target, #target) == '/' then
        target = target:sub(1, #target - 1)
    end

    if M.is_dir(target) then
        if target == sys.home then
            vim.notify('Cannot delete home directory', 'ERROR', { title = 'Delete File/Directory' })
            return false
        elseif M.is_root(target) then
            vim.notify('Cannot delete root directory', 'ERROR', { title = 'Delete File/Directory' })
            return false
        elseif target == '.' then
            vim.notify('Cannot delete cwd or parent directory', 'ERROR', { title = 'Delete File/Directory' })
            return false
        end
    end

    if M.is_file(target) or bufloaded(target) then
        if M.is_file(target) then
            if not uv.fs_unlink(target) then
                vim.notify('Failed to delete the file: ' .. target, 'ERROR', { title = 'Delete' })
                return false
            end
        end
        if bufloaded(target) then
            local command = bang and 'wipeout' or 'delete'
            local ok, error_code = pcall(vim.cmd, ([[b%s! %s]]):format(command, target))
            if not ok and error_code:match 'Vim(.%w+.)\\?:E94' then
                vim.notify('Failed to ' .. command .. ' buffer ' .. target, 'ERROR', { title = 'Delete' })
                return false
            end
        end
        return true
    elseif M.is_dir(target) then
        local flag = bang and 'rf' or 'd'
        if vim.fn.delete(target, flag) == -1 then
            vim.notify('Failed to remove the directory: ' .. target, 'ERROR', { title = 'Delete' })
            return false
        end
        return true
    end

    vim.notify('Non removable target: ' .. target, 'ERROR', { title = 'Delete' })
    return false
end

function M.skeleton_filename(opts)
    if type(opts) ~= 'table' then
        opts = { opts }
    end

    local buf = vim.fn.expand '%'
    if buf == '' or M.is_file(buf) then
        return
    end

    local buf_lines = nvim.buf.line_count(0)
    if buf_lines > 1 or (buf_lines == 1 and nvim.buf.get_lines(0, 0, 1, true)[1] ~= '') then
        return
    end

    local skeleton
    local filename = M.basename '%'
    local extension = M.extension '%'
    local skeletons_path = sys.base .. '/skeletons/'
    local template = #opts > 0 and opts[1] or ''

    if extension == '' then
        extension = '*'
    else
        filename = filename:gsub('%.' .. extension .. '$', '')
    end

    -- stylua: ignore
    local known_names = {
        ['*'] = { 'clang-format', 'clang-tidy', 'flake8' },
        py    = { 'ycm_extra_conf' },
        json  = { 'projections' },
        c     = { 'main' },
        cpp   = { 'main' },
        go    = { 'main' },
        yaml  = { 'pre-commit-config' },
        toml  = { 'pyproject', 'stylua' },
    }

    if #template ~= 0 then
        skeleton = skeletons_path .. template
    elseif known_names[extension] then
        local names = known_names[extension]

        for _, name in ipairs(names) do
            if filename:match('^%.?' .. name:gsub('%-', '%%-') .. '$') then
                local template_file = skeletons_path .. name
                if M.is_file(template_file) then
                    skeleton = template_file
                elseif M.is_file(template_file .. '.' .. extension) then
                    skeleton = template_file .. '.' .. extension
                end
                if skeleton then
                    break
                end
            end
        end
    end

    if not skeleton and extension ~= '' then
        skeleton = skeletons_path .. '/skeleton.' .. extension
    end

    if skeleton and M.is_file(skeleton) then
        local lines = M.readfile(skeleton)
        for i = 1, #lines do
            local line = lines[i]
            if line ~= '' then
                local macro = filename:upper()
                line = line:gsub('%%NAME_H', macro .. '_H')
                line = line:gsub('%%NAME', filename)
                lines[i] = line
            end
        end
        nvim.put(lines, 'c', false, true)
    end
end

function M.clean_file()
    local exc_buftypes = {
        nofile = 1,
        help = 1,
        quickfix = 1,
        terminal = 1,
    }

    local exc_filetypes = {
        bin = 1,
        log = 1,
        git = 1,
        man = 1,
        terminal = 1,
    }

    local buftype = vim.bo.buftype
    local filetype = vim.bo.filetype

    if
        not vim.b.trim
        or exc_buftypes[buftype]
        or exc_filetypes[filetype]
        or filetype == ''
    then
        return false
    end

    local lines = nvim.buf.get_lines(0, 0, -1, true)
    local expandtab = vim.bo.expandtab
    local retab = false

    for i = 1, #lines do
        local line = lines[i]
        if line ~= '' then
            local s_row = i - 1
            local e_row = i - 1

            if line:find '%s+$' then
                local s_col = line:find '%s+$' - 1
                local e_col = #line
                nvim.buf.set_text(0, s_row, s_col, e_row, e_col, { '' })
            end

            -- NOTE: Retab seems to be faster that set_(text/lines) API
            if expandtab and line:match '^\t+' then
                retab = true
            elseif not expandtab and line:match '^ +' then
                retab = true
            end
        end
    end
    if retab then
        nvim.ex['retab!']()
    end
    return true
end

function M.decode_json(data)
    assert(type(data) == type '' or type(data) == type {}, debug.traceback('Invalid Json data: ' .. vim.inspect(data)))
    if type(data) == type {} then
        data = table.concat(data, '\n')
    end
    if vim.json then
        return vim.json.decode(data)
    elseif has_cjson then
        return require('cjson').decode(data)
    elseif vim.in_fast_event() then
        error 'Decode json in fast event is not yet supported!!'
        -- return vim.fn.json_decode(data)
    end
    return vim.fn.json_decode(data)
end

function M.encode_json(data)
    vim.validate {
        data = { data, 'table' },
    }
    if vim.json then
        return vim.json.encode(data)
    elseif has_cjson then
        return require('cjson').encode(data)
    elseif vim.in_fast_event() then
        error(debug.traceback 'Encode json in fast event is not yet supported!!')
        -- return vim.fn.json_encode(data)
    end
    return vim.fn.json_encode(data)
end

function M.read_json(filename)
    vim.validate {
        filename = { filename, 'string' },
    }
    assert(filename ~= '', debug.traceback 'Empty filename')
    if filename:sub(1, 1) == '~' then
        filename = filename:gsub('~', sys.home)
    end
    assert(M.is_file(filename), debug.traceback('Not a file: ' .. filename))
    return M.decode_json(M.readfile(filename, false))
end

function M.dump_json(filename, data)
    vim.validate { filename = { filename, 'string' }, data = { data, 'table' } }
    assert(filename ~= '', debug.traceback 'Empty filename')
    if filename:sub(1, 1) == '~' then
        filename = filename:gsub('~', sys.home)
    end
    return M.writefile(filename, M.encode_json(data))
end

function M.find_parent(filename, basedir)
    vim.validate { filename = { filename, 'string' }, basedir = { basedir, 'string', true } }
    basedir = basedir or M.getcwd()
    assert(M.is_dir(basedir), debug.traceback('Invalid dirname: ' .. basedir))

    basedir = M.realpath(basedir)
    local dir = uv.fs_scandir(basedir)
    while true do
        local scanned, _ = uv.fs_scandir_next(dir)
        if not scanned then
            break
        end
        if scanned == filename then
            return M.normalize_path(basedir .. M.separator() .. scanned)
        end
    end

    if not M.is_root(basedir) then
        return M.find_parent(filename, M.basedir(basedir))
    end
    return false
end

return M

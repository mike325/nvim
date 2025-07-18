local nvim = require 'nvim'

local M = {
    getcwd = vim.uv.cwd,
}

local is_windows = jit.os == 'Windows'

-- TODO: Replace some of these functions with vim.fs counterparts

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

function M.exists(filename)
    vim.validate { filename = { filename, 'string' } }
    if filename == '' then
        return false
    end
    local stat = vim.uv.fs_stat(vim.fs.normalize(filename))
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
    dirname = vim.fs.normalize(dirname)
    local ok, msg, err = vim.uv.fs_mkdir(dirname, tonumber('775', 8))
    if err == 'ENOENT' and recurive then
        local parent = M.mkdir(vim.fs.dirname(dirname), recurive)
        return parent and M.mkdir(dirname, recurive)
    elseif not ok then
        vim.notify(msg, vim.log.levels.ERROR, { title = 'Mkdir' })
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
        dest = vim.fs.basename(src)
    end

    dest = vim.fs.normalize(dest)
    src = vim.fs.normalize(src)

    assert(src ~= dest, debug.traceback 'Cannot link src to itself')

    local status, msg, _

    if not sym and M.is_dir(src) then
        vim.notify('Cannot hard link a directory', vim.log.levels.ERROR, { title = 'Link' })
        return false
    end

    if not force and M.exists(dest) then
        vim.notify('Dest already exists in ' .. dest, vim.log.levels.ERROR, { title = 'Link' })
        return false
    elseif force and M.exists(dest) then
        status, msg, _ = vim.uv.fs_unlink(dest)
        if not status then
            vim.notify(msg, vim.log.levels.ERROR, { title = 'Link' })
            return false
        end
    end

    if sym then
        status, msg = vim.uv.fs_symlink(src, dest, { junction = true })
    else
        status, msg = vim.uv.fs_link(src, dest)
    end

    if not status then
        vim.notify(msg, vim.log.levels.ERROR, { title = 'Link' })
    end

    return status or false
end

--- Check if exec is executable
---@param exec string
---@return boolean
function M.executable(exec)
    vim.validate { exec = { exec, 'string' } }
    assert(exec ~= '', debug.traceback 'Empty executable string')
    return vim.fn.executable(exec) == 1
end

--- Return the executable's path
---@param exec string
---@return string|boolean
function M.exepath(exec)
    vim.validate { exec = { exec, 'string' } }
    assert(exec ~= '', debug.traceback 'Empty executable string')
    local path = vim.fn.exepath(exec)
    return path ~= '' and path or false
end

--- Check if path is absolute
---@param path string
---@return boolean
function M.is_absolute(path)
    vim.validate { path = { path, 'string' } }
    assert(path ~= '', debug.traceback 'Empty path')
    if path:sub(1, 1) == '~' then
        local home = vim.uv.os_homedir()
        ---@cast home string
        path = path:gsub('~', home)
    end

    local is_abs = false
    if is_windows and #path >= 2 then
        is_abs = string.match(path:sub(1, 2), '^%w:$') ~= nil
    elseif not is_windows then
        is_abs = path:sub(1, 1) == '/'
    end
    return is_abs
end

--- Check if path is root, / in unix and [a-zA-Z]:[/\\] on windows
---@param path string
---@return boolean
function M.is_root(path)
    vim.validate { path = { path, 'string' } }
    assert(path ~= '', debug.traceback 'Empty path')
    local root = false
    if is_windows and #path >= 2 then
        root = string.match(path, '^%w:[\\/]?$') ~= nil
    elseif not is_windows then
        root = path == '/'
    end
    return root
end

--- Return the real path
---@param path string
---@return string
function M.realpath(path)
    vim.validate { path = { path, 'string' } }
    assert(M.exists(path), debug.traceback(([[Path "%s" doesn't exists]]):format(path)))
    return (vim.uv.fs_realpath(vim.fs.normalize(path)):gsub('\\', '/'))
end

--- Get the file extension
---@param path string
---@return string
function M.extension(path)
    vim.validate { path = { path, 'string' } }
    assert(path ~= '', debug.traceback 'Empty path')
    local extension = ''
    path = vim.fs.normalize(path)
    if not M.is_dir(path) then
        local filename = vim.fs.basename(path)
        extension = filename and filename:match '^.+(%..+)$' or ''
    end
    return #extension >= 2 and extension:sub(2, #extension) or extension
end

--- Get the file name without the extension
---@param path string
---@return string
function M.filename(path)
    vim.validate { path = { path, 'string' } }
    local name = vim.fs.basename(path)
    local extension = M.extension(name)
    return extension ~= '' and (name:gsub('%.' .. extension .. '$', '')) or name
end

--- Check if one path is located inside another
---@param parent string
---@param child string
---@return boolean
function M.is_parent(parent, child)
    vim.validate { parent = { parent, 'string' }, child = { child, 'string' } }

    child = M.exists(child) and M.realpath(child) or child
    parent = M.exists(parent) and M.realpath(parent) or parent

    local is_child = false
    if child:match('^' .. vim.pesc(parent)) then
        is_child = true
    elseif is_windows then
        -- NOTE: Make sure that both are located on the same drive
        is_child = M.is_root(parent) and parent:sub(1, 2) == child:sub(1, 2)
    end

    return is_child
end

--- Open file and operate on callback
---@param path string
---@param flags string
---@param callback fun(fd: integer)
---@return boolean
function M.openfile(path, flags, callback)
    vim.validate {
        path = { path, 'string' },
        flags = { flags, 'string' },
        callback = { callback, 'function' },
    }
    assert(path ~= '', debug.traceback 'Empty path')

    local fd, msg, _ = vim.uv.fs_open(path, flags, tonumber('666', 8))
    if not fd then
        vim.notify(msg, vim.log.levels.ERROR, { title = 'OpenFile' })
        return false
    end
    local ok, rst = pcall(callback, fd)
    assert(vim.uv.fs_close(fd))
    return rst or ok
end

--- Open file and operate on callback
---@param path string
---@param data string|string[]
---@param callback fun()?
---@return boolean?
local function fs_write(path, data, append, callback)
    vim.validate {
        path = { path, 'string' },
        data = {
            data,
            function(d)
                return type(d) == type '' or vim.islist(d)
            end,
            'a string or an array',
        },
        append = { append, 'boolean', true },
        callback = { callback, { 'function', 'boolean' }, true },
    }

    if type(data) ~= type '' then
        ---@cast data string[]
        data = table.concat(data, '\n')
    end

    local flags = append and 'a+' or 'w+'

    if not callback then
        return M.openfile(path, flags, function(fd)
            local stat = vim.uv.fs_fstat(fd)
            local offset = (append and stat) and stat.size or 0
            local ok, msg, _ = vim.uv.fs_write(fd, data, offset)
            if not ok then
                vim.notify(msg, vim.log.levels.ERROR, { title = 'Write file' })
            end
        end)
    end

    vim.uv.fs_open(path, 'w+', tonumber('666', 8), function(oerr, fd)
        assert(not oerr, oerr)
        vim.uv.fs_fstat(fd, function(serr, stat)
            assert(not serr, serr)
            local offset = (append and stat) and stat.size or 0
            vim.uv.fs_write(fd, data, offset, function(rerr)
                assert(not rerr, rerr)
                vim.uv.fs_close(fd, function(cerr)
                    assert(not cerr, cerr)
                    if type(callback) == 'function' then
                        return callback()
                    end
                end)
            end)
        end)
    end)
end

--- Write data to file, override/create file
---@param path string
---@param data string|string[]
---@param callback fun()?
---@return boolean?
function M.writefile(path, data, callback)
    return fs_write(path, data, false, callback)
end

--- Update file content, append data to the end
---@param path string
---@param data string|string[]
---@param callback fun()?
---@return boolean?
function M.updatefile(path, data, callback)
    assert(M.is_file(path), debug.traceback('Not a file: ' .. path))
    return fs_write(path, data, true, callback)
end

--- Read given file
---@param path string
---@param split boolean?
---@param callback fun(data: string[])?
---@return boolean|string|string[]|nil
function M.readfile(path, split, callback)
    vim.validate {
        path = { path, 'string' },
        split = { split, 'boolean', true },
        callback = { callback, { 'function', 'boolean' }, true },
    }
    assert(M.is_file(path), debug.traceback('Not a file: ' .. path))
    if split == nil then
        split = true
    end
    if not callback then
        return M.openfile(path, 'r', function(fd)
            local stat = assert(vim.uv.fs_fstat(fd))
            ---@type string|string[]
            local data = assert(vim.uv.fs_read(fd, stat.size, 0))
            if split then
                ---@cast data string
                data = vim.split(data, '[\r]?\n')
                -- NOTE: This seems to always read an extra linefeed so we remove it if it's empty
                if data[#data] == '' then
                    data[#data] = nil
                end
            end
            return data
        end)
    end
    vim.uv.fs_open(path, 'r', tonumber('666', 8), function(oerr, fd)
        assert(not oerr, oerr)
        vim.uv.fs_fstat(fd, function(serr, stat)
            assert(not serr, serr)
            vim.uv.fs_read(fd, stat and stat.size or 0, 0, function(rerr, data)
                assert(not rerr, rerr)
                vim.uv.fs_close(fd, function(cerr)
                    assert(not cerr, cerr)
                    if split then
                        data = vim.split(data, '[\r]?\n')
                        if data[#data] == '' then
                            data[#data] = nil
                        end
                    end
                    return type(callback) == 'function' and callback(data) or data
                end)
            end)
        end)
    end)
end

--- Change file permissions
---@param path string
---@param mode string|number
---@param base integer?
---@return boolean
function M.chmod(path, mode, base)
    if is_windows then
        return false
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
    base = base or 8

    ---@type number
    ---@cast mode string
    local flags = tonumber(mode, base)

    local ok, msg, _ = vim.uv.fs_chmod(path, flags)
    if not ok then
        vim.notify(msg, vim.log.levels.ERROR, { title = 'Chmod' })
    end
    return ok or false
end

--- Get files from the given path
---@param path string
---@param opts table
---@param filter fun(name: string, ftype: string):boolean
---@return string[]
local function dir(path, opts, filter)
    local iter = vim.iter(vim.fs.dir(path, opts))
    if filter then
        iter = iter:filter(filter)
    end

    return iter:map(function(f, _)
        return vim.fs.joinpath(path, f)
    end):totable()
end

--- Get files from the given path
---@param path string
---@param opts table
---@return string[]
function M.get_files(path, opts)
    return dir(path, opts, function(_, t)
        return t == 'file'
    end)
end

--- Get directories from the given path
---@param path string
---@param opts table
---@return string[]
function M.get_dirs(path, opts)
    return dir(path, opts, function(_, t)
        return t == 'directory'
    end)
end

local function copy_undofile(old_fname, new_fname)
    vim.validate {
        old_fname = { old_fname, 'string' },
        new_fname = { new_fname, 'string' },
    }

    ---@type boolean?
    local ok = false
    local old_undofile = vim.fn.undofile(old_fname)
    if M.is_file(old_undofile) then
        local new_undofile = vim.fn.undofile(new_fname)
        ok = vim.uv.fs_copyfile(old_undofile, new_undofile, { excl = false })
    end
    return ok
end

function M.copy(src, dest, force)
    vim.validate { force = { force, 'boolean', true } }
    src = vim.fs.normalize(src)
    dest = vim.fs.normalize(dest)
    dest = M.is_dir(dest) and dest .. '/' .. vim.fs.basename(src) or dest

    if not M.is_dir(src) and (not M.exists(dest) or force) then
        local status, msg = vim.uv.fs_copyfile(src, dest, { excl = not force })
        if status then
            copy_undofile(src, dest)
            return true
        end
        vim.notify('Failed to copy ' .. src .. ' to ' .. dest .. '\n' .. msg, vim.log.levels.ERROR, { title = 'Copy' })
    elseif M.is_dir(src) then
        vim.notify('Cannot recursively copy directories', vim.log.levels.ERROR, { title = 'Copy' })
    else
        vim.notify(dest .. ' exists, use force to override it', vim.log.levels.ERROR, { title = 'Copy' })
    end

    return false
end

function M.rename(old, new, bang)
    local bufloaded = require('utils.buffers').bufloaded
    new = vim.fs.normalize(new)
    old = vim.fs.normalize(old)

    if not M.exists(new) or bang then
        local cursor_pos

        if not M.exists(old) and bufloaded(old) then
            vim.cmd.write(old)
            if M.realpath(nvim.buf.get_name(nvim.get_current_buf())) == M.realpath(old) then
                cursor_pos = nvim.win.get_cursor(nvim.get_current_buf())
            end
        end

        if bufloaded(new) then
            vim.cmd.bwipeout { args = { new }, bang = true }
        end

        local git = RELOAD 'utils.git'
        local is_git = git.is_git_repo(vim.fs.dirname(old))
        local is_untracked = is_git and vim.list_contains(vim.tbl_map(M.realpath, git.status().untracked or {}), old)

        local move_with_git = false
        if is_git and not is_untracked then
            local cwd = vim.pesc(vim.uv.cwd() .. '/')
            local dest_in_git = new:match('^' .. cwd)
            if dest_in_git then
                move_with_git = true
                local result = git.exec.mv { '-f', old, new }
                if #result > 0 then
                    vim.notify(
                        'Failed to rename ' .. old .. ' with git.\n' .. result,
                        vim.log.levels.ERROR,
                        { title = 'Rename' }
                    )
                    return false
                end
            end
        end

        -- TODO: Support git-rm when the dest is outside of the git repo
        if not move_with_git then
            local success, msg, err = vim.uv.fs_rename(old, new)
            if not success then
                if err and err ~= 'EXDEV' then
                    vim.notify(msg, vim.log.levels.ERROR, { title = 'Rename' })
                    return false
                else
                    -- TODO: support directories
                    success, msg = vim.uv.fs_copyfile(old, new)
                    if success then
                        success, msg = vim.uv.fs_unlink(old)
                    end

                    if not success then
                        vim.notify(msg, vim.log.levels.ERROR, { title = 'Rename' })
                        return false
                    end
                end
            end
        end

        if bufloaded(old) and M.is_file(new) then
            local cwd = vim.uv.cwd()

            ---@cast cwd string
            vim.cmd.edit((new:gsub(vim.fs.normalize(cwd), '')))
            if cursor_pos then
                nvim.win.set_cursor(0, cursor_pos)
            end
        end

        if bufloaded(old) then
            vim.cmd.bwipeout { args = { old }, bang = true }
        end

        copy_undofile(old, new)
        return true
    elseif M.exists(new) then
        vim.notify(new .. ' exists, use force to override it', vim.log.levels.ERROR, { title = 'Rename' })
    end

    return false
end

function M.delete(target, bang)
    vim.validate {
        target = { target, 'string' },
        bang = { bang, 'boolean', true },
    }

    local bufloaded = require('utils.buffers').bufloaded

    if bang == nil then
        bang = false
    end

    target = vim.fs.normalize(target)

    if #target > 1 and target:sub(#target, #target) == '/' then
        target = target:sub(1, #target - 1)
    end

    if M.is_dir(target) then
        if target == vim.uv.os_homedir() then
            vim.notify('Cannot delete home directory', vim.log.levels.ERROR, { title = 'Delete File/Directory' })
            return false
        elseif M.is_root(target) then
            vim.notify('Cannot delete root directory', vim.log.levels.ERROR, { title = 'Delete File/Directory' })
            return false
        elseif target == '.' then
            vim.notify(
                'Cannot delete cwd or parent directory',
                vim.log.levels.ERROR,
                { title = 'Delete File/Directory' }
            )
            return false
        end
    end

    local git = RELOAD 'utils.git'
    local is_git = git.is_git_repo(vim.fs.dirname(target))
    local is_untracked = is_git and vim.list_contains(vim.tbl_map(M.realpath, git.status().untracked or {}), target)

    if M.is_file(target) or bufloaded(target) then
        if is_git and not is_untracked then
            local result = git.exec.rm { '-f', target }
            if #result > 0 then
                vim.notify(
                    'Failed to delete the file ' .. target .. '\n' .. result,
                    vim.log.levels.ERROR,
                    { title = 'Delete' }
                )
                return false
            end
        elseif M.is_file(target) then
            if not vim.uv.fs_unlink(target) then
                vim.notify('Failed to delete the file: ' .. target, vim.log.levels.ERROR, { title = 'Delete' })
                return false
            end
        end
        if bufloaded(target) then
            local command = bang and 'bwipeout' or 'bdelete'

            if vim.list_contains(vim.tbl_map(M.realpath, vim.fn.argv()), target) then
                vim.cmd.argdelete(target)
            end

            local ok, error_code = pcall(vim.cmd, { cmd = command, bang = true, args = { target } })
            if not ok and error_code:match 'Vim(.%w+.)\\?:E94' then
                vim.notify('Failed to ' .. command .. ' buffer ' .. target, vim.log.levels.ERROR, { title = 'Delete' })
                return false
            end
        end
        return true
    elseif M.is_dir(target) then
        if is_git and not is_untracked then
            local result = git.exec.rm { bang and '-rf' or '-r', target }
            if #result > 0 then
                vim.notify(
                    'Failed to remove the directory: ' .. target .. '\n' .. result,
                    vim.log.levels.ERROR,
                    { title = 'Delete' }
                )
                return false
            end
        elseif vim.fn.delete(target, bang and 'rf' or 'd') == -1 then
            vim.notify('Failed to remove the directory: ' .. target, vim.log.levels.ERROR, { title = 'Delete' })
            return false
        end
        return true
    end

    vim.notify('Non removable target: ' .. target, vim.log.levels.ERROR, { title = 'Delete' })
    return false
end

function M.skeleton_filename(opts)
    if type(opts) ~= 'table' then
        opts = { opts }
    end

    local buf = vim.api.nvim_buf_get_name(0)
    if buf == '' or M.is_file(buf) then
        return
    end

    local buf_lines = nvim.buf.line_count(0)
    if buf_lines > 1 or (buf_lines == 1 and nvim.buf.get_lines(0, 0, 1, true)[1] ~= '') then
        return
    end

    local skeleton
    local filename = vim.fs.basename '%'
    local extension = M.extension '%'
    local skeletons_path = require('sys').base .. '/skeletons/'
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
            if filename:match('^%.?' .. (name:gsub('%-', '%%-')) .. '$') then
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
        local lines = M.readfile(skeleton) or {}
        for i = 1, #lines do
            local line = lines[i] or ''
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

--- Trim trailing whites
--- @param buf integer
--- @param range integer[]
function M.trimwhites(buf, range)
    vim.validate {
        buf = { buf, 'number', true },
        range = { range, 'table', true },
    }
    assert(not range or #range == 2, debug.traceback 'range must be {start, end} format')
    range = range or { 0, -1 }
    buf = buf or nvim.get_current_buf()

    local start_line = range[1]
    local end_line = range[2]
    local lines = nvim.buf.get_lines(buf, start_line, end_line, true)

    for i = 1, #lines do
        local line = lines[i]
        if line ~= '' then
            local s_row = (start_line + i) - 1
            local e_row = (start_line + i) - 1

            if line:find '%s+$' then
                local s_col, e_col = line:find '%s+$'
                s_col = s_col - 1
                nvim.buf.set_text(buf, s_row, s_col, e_row, e_col, { '' })
            end
        end
    end
end

--- Remove garbage from buffer
---  - trimwhites
---  - convert tab to spaces if `expand`, spaces to tabs otherwise
---  - exec retab
function M.clean_file()
    if vim.b.editorconfig and vim.b.editorconfig.trim_trailing_whitespace ~= nil then
        return
    end

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

    local excluded_buffer = exc_buftypes[buftype] or exc_filetypes[filetype] or filetype == ''
    local clean_buffer = vim.b.trim and not vim.g.disable_trim and not vim.t.disable_trim
    if not clean_buffer or excluded_buffer then
        return false
    end

    local range = { 0, -1 }
    local buf = nvim.get_current_buf()
    M.trimwhites(buf, range)

    local lines = nvim.buf.get_lines(buf, range[1], range[2], true)
    local expandtab = vim.bo.expandtab
    local retab = false
    for i = 1, #lines do
        local line = lines[i]
        if line ~= '' then
            -- NOTE: Retab seems to be faster that set_(text/lines) API
            if (expandtab and line:match '^\t+') or (not expandtab and line:match '^ +') then
                retab = true
                break
            end
        end
    end
    if retab then
        vim.cmd.retab { bang = true }
    end
    return true
end

--- Decode json data
---@param data string|string[]
---@return table
function M.decode_json(data)
    vim.validate {
        data = { data, { 'string', 'table' } },
    }
    if type(data) == type {} then
        ---@cast data string[]
        data = table.concat(data, '\n')
    end
    ---@cast data string
    return vim.json.decode(data)
end

--- Encode json data
---@param data table
---@return string
function M.encode_json(data)
    vim.validate {
        data = { data, 'table' },
    }
    local json = vim.json.encode(data)
    -- NOTE: Remove this once json:new works and expose the internals of cjson
    return (json:gsub('\\/', '/'))
end

--- Read json file
---@param filename string
---@return table
function M.read_json(filename)
    vim.validate {
        filename = { filename, 'string' },
    }
    assert(filename ~= '', debug.traceback 'Empty filename')
    if filename:sub(1, 1) == '~' then
        local home = vim.uv.os_homedir()
        ---@cast home string
        filename = filename:gsub('~', home)
    end
    assert(M.is_file(filename), debug.traceback('Not a file: ' .. filename))
    local data = M.readfile(filename, false)

    ---@cast data string
    return M.decode_json(data)
end

--- Dump obj into json data
---@param filename string
---@param data string[]
---@return boolean?
function M.dump_json(filename, data)
    vim.validate { filename = { filename, 'string' }, data = { data, 'table' } }
    assert(filename ~= '', debug.traceback 'Empty filename')
    if filename:sub(1, 1) == '~' then
        local home = vim.uv.os_homedir()
        ---@cast home string
        filename = filename:gsub('~', home)
    end

    local json = M.encode_json(data)
    if M.executable 'jq' then
        local job = vim.system({ 'jq', '.' }, { text = true, stdin = json }):wait()
        if job.code == 0 then
            return M.writefile(filename, job.stdout)
        end
    end

    return M.writefile(filename, json)
end

--- TODO
---@param dirname string
function M.parents(dirname)
    vim.validate { dirname = { dirname, 'string' } }
    dirname = M.realpath(dirname)
    return coroutine.wrap(function()
        local parent = vim.fs.dirname(dirname)
        while parent ~= dirname do
            coroutine.yield(parent)
            dirname = parent
            parent = vim.fs.dirname(dirname)
        end
    end)
end

--- TODO
---@param filename string|string[]|fun(name: string)
---@param opts table
function M.find(filename, opts)
    vim.validate {
        filename = { filename, { 'function', 'string', 'table' } },
        opts = { opts, 'table', true },
    }

    local blacklist = {
        ['.git'] = true,
        ['.svn'] = true,
        ['.cache'] = true,
        ['__pycache__'] = true,
        ['.vscode'] = true,
        ['.vscode_clangd_setup'] = true,
        ['node_modules'] = true,
    }

    local candidates = {}
    local path = '.'
    opts.path = opts.path or path
    for fname, ftype in vim.fs.dir(path) do
        if ftype == 'file' then
            if
                (type(filename) == type '' and filename == fname)
                ---@cast filename string[]
                or (type(filename) == type {} and vim.list_contains(filename, fname))
                or (type(filename) == 'function' and filename(fname))
            then
                table.insert(candidates, vim.fs.joinpath(path, fname))
            end
        elseif not blacklist[fname] then
            local results = vim.fs.find(filename, opts)
            if #results > 0 then
                candidates = vim.list_extend(candidates, results)
            end
        end
    end
    return candidates
end

--- Check if prog is executable
---@param filename string
function M.is_executable(filename)
    vim.validate {
        filename = { filename, 'string' },
    }
    return vim.uv.fs_access(vim.fs.normalize(filename), 'X')
end

--- Make given buffer file executable
---@param buf string|integer|nil
function M.chmod_exec(buf)
    vim.validate {
        buf = { buf, { 'number', 'string' }, true },
    }
    ---@type string
    local filename
    buf = buf or 0
    if type(buf) == type(0) then
        ---@cast buf number
        filename = vim.api.nvim_buf_get_name(buf)
    else
        ---@cast buf string
        filename = buf
    end
    if filename ~= '' and M.is_file(filename) and not M.is_executable(filename) then
        local fileinfo = vim.uv.fs_stat(filename)
        local filemode = fileinfo.mode - 32768
        M.chmod(filename, bit.bor(filemode, 0x48), 10)
    end
end

--- Make current buffer file executable if is a script like buffer
function M.make_executable()
    local sys = require 'sys'
    if sys.name == 'windows' then
        return
    end

    local filename = vim.api.nvim_buf_get_name(0)
    if M.is_executable(filename) then
        return
    end

    local shebang = nvim.buf.get_lines(0, 0, 1, true)[1]
    if not shebang or not shebang:match '^#!.+' then
        vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
            desc = 'Defer make executable until before save',
            group = vim.api.nvim_create_augroup('MakeExecutable', { clear = false }),
            buffer = nvim.win.get_buf(0),
            callback = function()
                M.make_executable()
            end,
            once = true,
        })
        return
    end

    if
        not M.is_executable(filename)
        or (not M.exists(filename) and filename ~= '' and not filename:match '^[%w%d_]+://')
    then
        -- TODO: Add support to pass buffer
        vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
            desc = 'Actually make the buffer/file executable after safe',
            group = vim.api.nvim_create_augroup('MakeExecutable', { clear = false }),
            buffer = nvim.win.get_buf(0),
            callback = function()
                M.chmod_exec()
            end,
            once = true,
        })
    end
end

function M.find_in_dir(args)
    args = args or {}
    vim.validate {
        pattern = { args.pattern, { 'function', 'table', 'string' } },
        dir = { args.dir, 'string', true },
        limit = { args.limit, 'number', true },
        callback = { args.callback, 'function', true },
    }

    local path
    if args.dir and args.dir ~= '' then
        path = M.realpath(args.dir)
    else
        path = vim.api.nvim_buf_get_name(0)
    end

    local cwd = vim.uv.cwd()
    if path ~= cwd then
        ---@cast cwd string
        path = path:gsub(vim.pesc(cwd) .. '/', ''):gsub('/.*', '')
    end

    local pattern = args.pattern
    local filter
    if type(pattern) == 'function' then
        filter = pattern
        pattern = nil
    end

    if args.callback then
        RELOAD('threads.functions').async_find {
            target = pattern,
            filter = filter,
            opts = {
                type = 'file',
                path = path,
                limit = args.limit,
            },
            cb = args.callback,
        }
        return
    end
    local results = RELOAD('threads.functions').find {
        args = {
            target = pattern,
            opts = {
                type = 'file',
                path = path,
            },
        },
        functions = {
            filter = filter,
        },
    }
    return results
end

function M.watch_config_file(fname)
    vim.validate { fname = { fname, 'string' } }
    if M.is_file(fname) then
        local real_fname = M.realpath(fname)
        require('watcher.file'):new(real_fname, 'ConfigReloader'):start()
    end
end

return M

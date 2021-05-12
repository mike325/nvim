local sys       = require'sys'
local nvim      = require'nvim'
local echoerr   = require'tools.messages'.echoerr
local bufloaded = require'tools.buffers'.bufloaded
-- local clear_lst = require'tools.tables'.clear_lst
local split     = require'tools.strings'.split

local uv = vim.loop

local M = {}

M.getcwd = uv.cwd

local is_windows = sys.name == 'windows'

local function split_path(path)
    path = M.normalize_path(path)
    return split(path, '/')
end

local function forward_path(path)
    if is_windows and nvim.o.shellslash then
        path:gsub('\\','/')
    end
    return path
end

local function separator()
    if is_windows and not nvim.o.shellslash then
        return '\\'
    end
    return '/'
end

function M.exists(filename)
    assert(type(filename) == 'string' and filename ~= '', ([[Not a filename: "%s"]]):format(filename))
    local stat = uv.fs_stat(filename)
    return stat and stat.type or false
end

function M.is_dir(filename)
    assert(type(filename) == 'string' and filename ~= '', ([[Not a filename: "%s"]]):format(filename))
    return M.exists(filename) == 'directory'
end

function M.is_file(filename)
    assert(type(filename) == 'string' and filename ~= '', ([[Not a filename: "%s"]]):format(filename))
    return M.exists(filename) == 'file'
end

function M.mkdir(dirname)
    assert(type(dirname) == 'string' and dirname ~= '', ([[Not a dirname: "%s"]]):format(dirname))
    nvim.fn.mkdir(dirname, 'p')
end

function M.executable(exec)
    return nvim.fn.executable(exec) == 1
end

function M.is_absolute(path)
    assert(type(path) == 'string' and path ~= '', ([[Not a path: "%s"]]):format(path))
    path = M.normalize_path(path)
    local is_abs = false
    if is_windows and #path >= 2 then
        is_abs = string.match(path:sub(1, 2), '^%w:$') ~= nil
    elseif not is_windows then
        is_abs = path:sub(1, 1) == '/'
    end
    return is_abs
end

function M.is_root(path)
    assert(type(path) == 'string' and path ~= '', ([[Not a path: "%s"]]):format(path))
    local root = false
    if is_windows and #path >= 2 then
        path = forward_path(path)
        root = string.match(path, '^%w:/?$') ~= nil
    elseif not is_windows then
        root = path == '/'
    end
    return root
end

function M.realpath(path)
    assert(M.exists(path), ([[Not a path: "%s"]]):format(path))
    local rpath = uv.fs_realpath(path)
    return forward_path(rpath or path)
end

function M.normalize_path(path)
    assert(type(path) == 'string' and path ~= '', ([[Not a path: "%s"]]):format(path))
    if path:sub(1, 1) == '~' or path == '%' then
        path = nvim.fn.expand(path)
    end
    return forward_path(path)
end

function M.basename(path)
    path = M.normalize_path(path)
    return path:match(('[^%s]+$'):format(separator()))
end

function M.extension(path)
    local extension = ''
    path = M.normalize_path(path)
    if not M.is_dir(path) then
        local filename = split_path(path)
        filename = filename[#filename]
        extension = filename:match'^.+(%..+)$' or ''
    end
    return extension
end

function M.basedir(path)
    path = M.normalize_path(path)
    if not M.is_dir(path) then
        local path_components = split_path(path)
        if #path_components > 1 then
            table.remove(path_components, #path_components)
            if M.is_absolute(path) and not is_windows then
                path = '/'
            else
                path = ''
            end
            path = path .. table.concat(path_components, '/')
        elseif M.is_absolute(path) then
            path = is_windows and path:match(path:sub(1, 2), '^%w:$') or '/'
        else
            path = '.'
        end
    end
    return path
end

function M.subpath_in_path(parent, child)
    assert(M.is_dir(parent), ('Parent path is not a directory "%s"'):format(parent) )
    assert(M.is_dir(child), ('Child path is not a directory "%s"'):format(child) )

    child = M.realpath(child)
    parent = M.realpath(parent)

    -- TODO: Check windows multi drive root
    local child_in_parent = false
    if M.is_root(parent) then
        child_in_parent = true
    elseif child:match('^'..parent) then
        child_in_parent = true
    end

    return child_in_parent
end

function M.openfile(path, flags, callback)
    assert(type(path) == 'string' and path ~= '', ([[Not a path: "%s"]]):format(path))
    assert(flags, 'Missing flags')
    assert(type(callback) == 'function', 'Missing valid callback')
    local fd = uv.fs_open(path, flags, 438)
    local ok, rst = pcall(callback, fd)
    assert(uv.fs_close(fd))
    return rst or ok
end

local function fs_write(path, data, append)
    assert(type(data) == type('') or type(data) == type({}), 'Invalid data type: '..type(data))
    data = type(data) == type('') and table.concat(data, '\n') or data
    assert(data and type(data) == 'string', 'Missing valid data buffer/string')
    local flags = append and 'a' or 'w'
    M.openfile(path, flags, function(fd)
        local stat = uv.fs_fstat(fd)
        local offset = append and stat.size or 0
        uv.fs_write(fd, data, offset)
    end)
end

function M.writefile(path, data) fs_write(path, data, false) end
function M.updatefile(path, data)
    assert(M.is_file(path), 'Not a file: '..path)
    fs_write(path, data, true)
end

function M.readfile(path, callback)
    assert(M.is_file(path), 'Not a file: '..path)
    assert(not callback or type(callback) == 'function', 'Missing valid callback')
    if not callback then
        return M.openfile(path, 'r', function(fd)
            local stat = uv.fs_fstat(fd)
            local data = uv.fs_read(fd, stat.size, 0)
            -- TODO: Support DOS format
            local split_func = vim.in_fast_event() and vim.split or nvim.fn.split
            data = split_func(data, '\n')
            return data
        end)
    end
    uv.fs_open(path, "r", 438, function(oerr, fd)
        assert(not oerr, oerr)
        uv.fs_fstat(fd, function(serr, stat)
            assert(not serr, serr)
            uv.fs_read(fd, stat.size, 0, function(rerr, data)
                assert(not rerr, rerr)
                uv.fs_close(fd, function(cerr)
                    assert(not cerr, cerr)
                    return callback(vim.split(data, '\n'))
                end)
            end)
        end)
    end)
end

function M.chmod(path, mode, base)
    if not is_windows then
        base = base == nil and 8 or base
        uv.fs_chmod(path, tonumber(mode, base))
    end
end

function M.ls(expr)
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
        file = M.is_file,
        dir  = M.is_dir,
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

    if is_windows and nvim.o.shellslash then
        for i=1,#results do
            results[i] = forward_path(results[i])
        end
    end

    return results
end

function M.get_files(expr)
    expr = expr == nil and {} or expr
    expr.type = 'file'
    return M.ls(expr)
end

function M.get_dirs(expr)
    expr = expr == nil and {} or expr
    expr.type = 'dirs'
    return M.ls(expr)
end

function M.read_json(filename)
    assert(M.is_file(filename), 'Not a file: '..filename)
    return nvim.fn.json_decode(M.readfile(filename))
end

function M.dump_json(filename, data)
    assert(type(data) == 'table', 'Not a json data: '..type(data))
    assert(type(filename) == 'string' and filename ~= '', ([[Not a filename: "%s"]]):format(filename))
    local json = nvim.fn.json_encode(data)
    M.writefile(filename, json)
end

function M.rename(old, new, bang)

    new = M.normalize_path(new)
    old = M.normalize_path(old)

    if not M.exists(new) or bang then

        if not M.exists(old) and bufloaded(old) then
            nvim.ex.write(old)
        end

        if bufloaded(new) then
            nvim.ex['bwipeout!'](new)
        end

        if uv.fs_rename(old, new) then
            local cursor_pos = nvim.win.get_cursor(0)

            if M.is_file(new) then
                nvim.ex.edit(new)
                nvim.win.set_cursor(0, cursor_pos)
            end

            if bufloaded(old) then
                nvim.ex['bwipeout!'](old)
            end

            return true
        else
            echoerr('Failed to rename '..old)
        end
    elseif M.exists(new) then
        echoerr(new..' exists, use ! to override, it')
    end

    return false
end

function M.delete(target, bang)
    target = M.normalize_path(target)
    if M.is_file(target) or bufloaded(target) then
        if M.is_file(target) then
            if nvim.fn.delete(target) == -1 then
                echoerr('Failed to delete the file: '..target)
            end
        end
        if bufloaded(target) then
            local command = bang and 'wipeout' or 'delete'
            local ok, error_code = pcall(nvim.command, ([[b%s! %s]]):format(command, target))
            if not ok and error_code:match('Vim(.%w+.)\\?:E94') then
                echoerr('Failed to '..command..' buffer '..target)
            end
        end
    elseif M.is_dir(target) then
        local flag = bang and 'rf' or 'd'
        if nvim.fn.delete(target, flag) == -1 then
            echoerr('Failed to remove the directory: '..target)
        end
    else
        echoerr('Non removable target: '..target)
   end
end

function M.skeleton_filename(opts)

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

                    if M.is_file(template_file) then
                        skeleton = nvim.fn.fnameescape(template_file)
                        break
                    elseif M.is_file(template_file..'.'..extension) then
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

    if M.is_file(skeleton) then
        local lines = M.readfile(skeleton)
        for i=1,#lines do
            local line = lines[i]
            if line ~= '' then
                local macro = filename:upper()
                line = line:gsub('%%NAME_H', macro..'_H')
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

    local buftype = nvim.bo.buftype
    local filetype = nvim.bo.filetype

    if not nvim.b.trim or exc_buftypes[buftype] or exc_filetypes[filetype] or filetype == '' then
        return false
    end

    local lines = nvim.buf.get_lines(0, 0, -1, true)
    local expandtab = nvim.bo.expandtab or nvim.o.expandtab

    -- local start = os.time()
    for i=1,#lines do
        local line = lines[i]
        if line ~= '' then
            local s_row = i - 1
            local e_row = i - 1

            if line:find('%s+$') then
                local s_col = line:find('%s+$') - 1
                local e_col = #line
                nvim.buf.set_text(0, s_row, s_col, e_row, e_col, {''})
            end

            if expandtab and line:match('^\t+') then
                local tabs = line:match('^\t+')
                local s_col = 0
                local e_col = #tabs
                if tabs then
                    local spaces = nvim.bo.softtabstop or nvim.o.softtabstop
                    if spaces < 0 then
                        spaces = nvim.bo.shiftwidth or nvim.o.shiftwidth
                        if spaces == 0 then
                            spaces = nvim.o.tabstop
                        end
                    end
                    local tab2space = ''
                    for _=1,spaces do
                        tab2space = tab2space .. ' '
                    end
                    spaces = ''
                    for _=1,#tabs do
                        spaces = spaces .. tab2space
                    end
                    nvim.buf.set_text(0, s_row, s_col, e_row, e_col, {spaces})
                end
            end
        end
    end
    -- local endt = os.time()
    -- print('Cleanning time: ', os.difftime(endt, start)..'s')
    return true
end

local function parser_config(data)
    data = type(data) ~= 'table' and split(data, '\n') or data
    local data_tbl = {}
    local section = nil
    local subsection = nil
    local subsections = {}
    for _,line in pairs(data) do
        if not line:match('^%s*;.*') and not line:match('^%s*#.*') and not line:match('^%s*$') then
            if line:match('^%s*%[%s*%a[%w_]*%s*]$') then
                section = line:match('%a[%w_]*')
                if not subsections[section] then
                    assert(not data_tbl[section], 'Repeated section: '..section)
                    data_tbl[section] = {}
                end
                subsection = nil
            elseif line:match('^%s*%[%s*%a[%w_]*%s+".+"%s*]$') then
                section = line:match('^%s*%[(%a[%w_]*)')
                if not data_tbl[section] then
                    data_tbl[section] = {}
                end
                subsection = line:match('"(.+)"%s*]$')
                assert(
                    not data_tbl[section][subsection],
                    'Repeated subsection: '..subsection..' in section: '..section..' '..vim.inspect(data_tbl)
                )
                data_tbl[section][subsection] = {}
                subsections[section] = subsection
            elseif section and line:match('^%s*%a[%w_%.-]*%s*=%s*.+$') then
                local clean_line = line:gsub('%s+;.+$', ''):gsub('%s+#.+$', '')
                local attr = clean_line:match('^%s*(%a[%w_%.-]*)%s*=')
                local val = clean_line:match('=%s*(.+)$')
                val = vim.trim(val)

                if val == 'true' or val == 'false' then
                    val = val == 'true'
                elseif val:match('^%d+$') then
                    val = tonumber(val)
                elseif val:match('^0[box][%da-fA-F]+$') then
                    if val:sub(2, 2) == 'x' and val:match('^0[xX][%da-fA-F]+$') then
                        val = tonumber(val, 16)
                    elseif val:sub(2, 2) == 'b' and val:match('^0b[01]+$') then
                        val = tonumber(val:match('^0b([01]+)$'), 2)
                    elseif val:sub(2, 2) == 'o' and val:match('^0o[0-7]+$') then
                        val = tonumber(val:match('^0o([0-7]+)$'), 8)
                    end
                elseif (val:sub(1,1) == '"' or val:sub(1,1) == "'") and val:sub(#val,#val) == val:sub(1, 1) then
                    local qtype = val:sub(1,1)
                    val = val:match(('^%s(.*)%s$'):format(qtype, qtype))
                end

                if not subsection then
                    data_tbl[section][attr] = val
                else
                    data_tbl[section][subsection][attr] = val
                end
            else
                print('Unmatched line: '..line)
                section = nil
                subsection = nil
            end
        end
    end
    return data_tbl
end

function M.read_config(config, callback)
    assert(not callback or type(callback) == 'function', 'Not a valid callback type: '..type(callback))

    config = M.normalize_path(config)
    assert(M.is_file(config), 'Not a valid file: '..config)
    if not callback then
        local data = M.readfile(config)
        return parser_config(data)
    end
    M.readfile(config, function(data)
        callback(parser_config(data))
    end)
end

return M

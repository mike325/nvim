local mini_test = require 'mini.test'
local is_windows = vim.fn.has 'win32' == 1

local function forward_path(path)
    if is_windows then
        return (path:gsub('\\', '/'))
    end
    return path
end

local dirname_basename_paths = {
    '~/repos/',
    '~/repos',
    '~/.bashrc',
    './.bashrc',
    '~/repos/foo.lua',
    'foo.lua',
    '.',
    '..',
    '../',
    '~',
    '/usr/bin',
    '/usr/bin/gcc',
    '/',
    '/usr/',
    '/usr',
    'c:/usr',
    'c:/',
    'c:/usr/bin',
    'c:/usr/bin/foo.lua',
    'c:/usr/bin/foo/../',
}

-- TODO: Missing function tests
-- copy
-- parents iterator
-- find_in_dir

describe('Check file and directories', function()
    local config_dir = vim.fn.stdpath 'config'
    local init_file = config_dir .. '/init.lua'

    it('exists', function()
        local exists = require('utils.files').exists
        mini_test.expect.equality('directory', exists(vim.loop.os_homedir()))
        mini_test.expect.equality('file', exists(init_file))
        mini_test.expect.equality(exists(vim.fn.tempname()), false)
    end)

    it('is_file', function()
        local is_file = require('utils.files').is_file
        mini_test.expect.equality(is_file(init_file), true)
        mini_test.expect.equality(is_file(config_dir), false)
        mini_test.expect.equality(is_file(vim.fn.tempname()), false)
    end)

    it('is_dir', function()
        local is_dir = require('utils.files').is_dir
        mini_test.expect.equality(is_dir(config_dir), true)
        mini_test.expect.equality(is_dir(vim.loop.os_homedir()), true)
        mini_test.expect.equality(is_dir(init_file), false)
        mini_test.expect.equality(is_dir(vim.fn.tempname()), false)
    end)
end)

describe('Mkdir', function()
    local mkdir = require('utils.files').mkdir

    it('Existing Directory', function()
        local homedir = vim.loop.os_homedir()
        mini_test.expect.equality(mkdir(homedir), true)
    end)

    it('New Directory', function()
        local tmp = vim.fn.tempname()
        local is_dir = require('utils.files').is_dir
        mini_test.expect.equality(is_dir(tmp), false)
        mini_test.expect.equality(mkdir(tmp), true)
        mini_test.expect.equality(is_dir(tmp), true)
    end)

    it('Existing file', function()
        local config_dir = vim.fn.stdpath 'config'
        local init_file = config_dir .. '/init.lua'
        mini_test.expect.equality(mkdir(init_file), false)
    end)

    it('Multiple directories', function()
        local tmp = vim.fn.tempname() .. '/test'
        local is_dir = require('utils.files').is_dir
        mini_test.expect.equality(is_dir(tmp), false)
        mini_test.expect.equality(mkdir(tmp), false)
        mini_test.expect.equality(mkdir(tmp, true), true)
        mini_test.expect.equality(is_dir(tmp), true)
    end)

    it('Recursive non existing', function()
        local is_dir = require('utils.files').is_dir
        local dirs = {
            vim.fn.tempname() .. '/this/is/a/deep/test/',
        }
        for _, dir in ipairs(dirs) do
            mini_test.expect.equality(is_dir(dir), false)
            mini_test.expect.equality(mkdir(dir, true), true)
            mini_test.expect.equality(is_dir(dir), true)
        end
    end)
end)

describe('Linking', function()
    local cached_files = {}

    teardown(function()
        for _, tmp in ipairs(cached_files) do
            os.remove(tmp)
        end
        cached_files = {}
    end)

    -- NOTE: sometimes /tmp is mount on a different drive and linking fail between different volumes
    local function get_cache_tmp()
        local cache_dir = vim.fn.stdpath('cache'):gsub('\\', '/')
        local fd, tmpname = vim.loop.fs_mkstemp(cache_dir .. '/test.XXXXXX')
        vim.loop.fs_close(fd)
        os.remove(tmpname) -- some functions check the file do not exist before writing to it
        table.insert(cached_files, tmpname)
        return tmpname
    end

    local function testlink(src, dest, sym, force)
        vim.validate {
            src = { src, 'string' },
            dest = { dest, 'string', true },
            force = { force, 'boolean', true },
            sym = { sym, 'boolean', true },
        }

        if sym == nil then
            sym = false
        end

        if force == nil then
            force = false
        end

        if dest == nil then
            dest = get_cache_tmp()
        end

        local link = require('utils.files').link
        local is_dir = require('utils.files').is_dir
        local is_file = require('utils.files').is_file

        local check = is_file(src) and is_file or is_dir

        if not force then
            mini_test.expect.equality(check(dest), false)
            mini_test.expect.equality(link(src, dest, sym), true)
            mini_test.expect.equality(check(dest), true)
        else
            mini_test.expect.equality(check(dest), true)
            mini_test.expect.equality(link(src, dest, sym, force), true)
            mini_test.expect.equality(check(dest), true)
        end
    end

    it('Symbolic link to Directory', function()
        testlink('~', nil, true)
    end)

    -- TODO: Add windows negative testing
    if not is_windows then
        it('Symbolic link to File', function()
            local config_dir = vim.fn.stdpath 'config'
            local init_file = config_dir .. '/init.lua'
            testlink(init_file, nil, true)
        end)
    end

    -- NOTE: Hardlinks fail in some systems
    it('Hard link File', function()
        local config_dir = vim.fn.stdpath 'config'
        local init_file = config_dir .. '/init.lua'
        testlink(init_file, nil, false)
    end)

    it('Hard link Directory', function()
        local link = require('utils.files').link
        local is_dir = require('utils.files').is_dir
        local dest = get_cache_tmp()
        mini_test.expect.equality(is_dir(dest), false)
        mini_test.expect.equality(link('~', dest), false)
        mini_test.expect.equality(is_dir(dest), false)
    end)

    it('Missing SRC file/dir', function()
        local src = get_cache_tmp()
        local dest = get_cache_tmp()
        local is_file = require('utils.files').is_file
        local is_dir = require('utils.files').is_dir
        local link = require('utils.files').link

        mini_test.expect.equality(is_file(dest), false)
        mini_test.expect.equality(is_dir(dest), false)
        mini_test.expect.error(function()
            link(src, dest)
        end)
        mini_test.expect.equality(is_file(dest), false)
        mini_test.expect.equality(is_dir(dest), false)
    end)

    describe('Force', function()
        it('Symbolic link to Directory', function()
            local dest = get_cache_tmp()
            testlink('~', dest, true, false)
            testlink('~', dest, true, true)
        end)

        if not is_windows then
            it('Symbolic link to File', function()
                local config_dir = vim.fn.stdpath 'config'
                local init_file = config_dir .. '/init.lua'
                local dest = get_cache_tmp()
                testlink(init_file, dest, true, false)
                testlink(init_file, dest, true, true)
            end)
        end

        it('Hard link File', function()
            local config_dir = vim.fn.stdpath 'config'
            local init_file = config_dir .. '/init.lua'
            local dest = get_cache_tmp()
            testlink(init_file, dest, false, false)
            testlink(init_file, dest, false, true)
        end)
    end)
end)

describe('Absolute path', function()
    local is_absolute = require('utils.files').is_absolute

    it('Unix/Windows', function()
        mini_test.expect.equality(is_absolute(vim.loop.os_homedir()), true)
        mini_test.expect.equality(is_absolute(vim.loop.cwd()), true)
        mini_test.expect.equality(is_absolute '.', false)
        mini_test.expect.equality(is_absolute '../', false)
        mini_test.expect.equality(is_absolute 'test', false)
        mini_test.expect.equality(is_absolute './home', false)

        if is_windows then
            mini_test.expect.equality(is_absolute 'c:/ProgramData', true)
            mini_test.expect.equality(is_absolute 'D:/data', true)
            mini_test.expect.equality(is_absolute [[..\\ProgramData]], false)
            mini_test.expect.equality(is_absolute [[c:\]], true)
            mini_test.expect.equality(is_absolute [[C:]], true)
        else
            mini_test.expect.equality(is_absolute '/', true)
            mini_test.expect.equality(is_absolute '/tmp/', true)
            mini_test.expect.equality(is_absolute 'home/', false)
            mini_test.expect.equality(is_absolute '/../', true)
        end
    end)
end)

describe('Root path', function()
    local is_root = require('utils.files').is_root

    if is_windows then
        it('Windows', function()
            mini_test.expect.equality(is_root [[c:\]], true)
            mini_test.expect.equality(is_root 'c:/', true)
            mini_test.expect.equality(is_root [[C:]], true)
            mini_test.expect.equality(is_root [[d:\]], true)
            mini_test.expect.equality(is_root 'D:/', true)
            mini_test.expect.equality(is_root [[D:]], true)
            mini_test.expect.equality(is_root 'D:/data', false)
            mini_test.expect.equality(is_root './home', false)
            mini_test.expect.equality(is_root [[c:\ProgramData]], false)
        end)
    else
        it('Unix', function()
            mini_test.expect.equality(is_root '/', true)
            mini_test.expect.equality(is_root '/home/', false)
            mini_test.expect.equality(is_root 'home/', false)
            mini_test.expect.equality(is_root '.', false)
            mini_test.expect.equality(is_root '../', false)
            mini_test.expect.equality(is_root 'test', false)
        end)
    end
end)

describe('Realpath', function()
    local realpath = require('utils.files').realpath

    it('HOME', function()
        local homedir = vim.loop.os_homedir()
        mini_test.expect.equality(realpath '~', forward_path(homedir))
    end)

    it('CWD', function()
        local cwd = vim.loop.cwd()
        mini_test.expect.equality(realpath '.', forward_path(cwd))
    end)

    it('parent', function()
        local cwd = vim.loop.cwd()
        mini_test.expect.equality(realpath '..', vim.fs.dirname(cwd))
    end)
end)

describe('Normalize', function()
    local normalize = require('utils.files').normalize

    it('HOME', function()
        local homedir = vim.loop.os_homedir()
        mini_test.expect.equality(normalize '~', forward_path(homedir))
    end)

    if is_windows then
        it('Windows Path', function()
            local windows_path = [[c:\Users]]

            vim.go.shellslash = false
            mini_test.expect.equality(normalize(windows_path), forward_path(windows_path))

            vim.go.shellslash = true
            mini_test.expect.equality(normalize(windows_path), forward_path(windows_path))
        end)
    end
end)

describe('Basename', function()
    local basename = require('utils.files').basename

    it('Default', function()
        for _, path in ipairs(dirname_basename_paths) do
            mini_test.expect.equality(basename(path), vim.fn.fnamemodify(path, ':t'))
        end
    end)

    it('Init file', function()
        local config_dir = vim.fn.stdpath 'config'
        local init_file = config_dir .. '/init.lua'
        mini_test.expect.equality('init.lua', basename(init_file))
    end)

    it('Filename', function()
        mini_test.expect.equality('init.lua', basename 'init.lua')
        mini_test.expect.equality('test', basename './test')
        mini_test.expect.equality('test', basename './test')
    end)
end)

describe('Extension', function()
    local extension = require('utils.files').extension

    it('Filename', function()
        local config_dir = vim.fn.stdpath 'config'
        local init_file = config_dir .. '/init.lua'
        mini_test.expect.equality('lua', extension(init_file))
        mini_test.expect.equality('lua', extension 'init.lua')
        mini_test.expect.equality('lua', extension '.././../init.test.lua')
        mini_test.expect.equality('cpp', extension './test.cpp')
        mini_test.expect.equality('c', extension './test.c')
        mini_test.expect.equality('sh', extension '.bashrc.sh')
        mini_test.expect.equality('', extension '.bashrc')
    end)
end)

describe('Filename', function()
    local filename = require('utils.files').filename

    it('without extension', function()
        local config_dir = vim.fn.stdpath 'config'
        local init_file = config_dir .. '/init.lua'
        mini_test.expect.equality('init', filename(init_file))
        mini_test.expect.equality('init', filename 'init.lua')
        mini_test.expect.equality('init.test', filename '.././../init.test.lua')
        mini_test.expect.equality('test', filename './test.cpp')
        mini_test.expect.equality('test', filename './test.c')
        mini_test.expect.equality('.bashrc', filename '.bashrc.sh')
        mini_test.expect.equality('.bashrc', filename '.bashrc')
    end)
end)

describe('Dirname', function()
    local dirname = require('utils.files').dirname

    it('Getting dirname from directories and files', function()
        for _, path in ipairs(dirname_basename_paths) do
            mini_test.expect.equality(dirname(path), vim.fn.fnamemodify(path, ':h'))
        end

        local config_dir = forward_path(vim.fn.stdpath 'config')
        local data_dir = forward_path(vim.fn.stdpath 'data')
        local cache_dir = forward_path(vim.fn.stdpath 'cache')

        local init_file = forward_path(config_dir .. '/init.lua')
        -- local homedir = forward_path(vim.loop.os_homedir())

        mini_test.expect.equality(config_dir, dirname(init_file))

        mini_test.expect.equality(config_dir:gsub([[[/\]nvim.*]], ''), dirname(config_dir))
        mini_test.expect.equality(data_dir:gsub([[[/\]nvim.*]], ''), dirname(data_dir))
        mini_test.expect.equality(cache_dir:gsub([[[/\]nvim.*]], ''), dirname(cache_dir))

        mini_test.expect.equality('~', dirname '~/.bashrc')
        if not is_windows then
            mini_test.expect.equality('/', dirname '/')
            mini_test.expect.equality('/tmp', dirname '/tmp/test')
        else
            mini_test.expect.equality(forward_path 'c:\\', dirname 'c:\\')
            mini_test.expect.equality(forward_path 'c:\\Temp', dirname 'c:\\Temp\\test')
        end
    end)
end)

describe('Read/Write', function()
    local writefile = require('utils.files').writefile
    local readfile = require('utils.files').readfile
    local tmp = vim.fn.tempname()
    local is_file = require('utils.files').is_file
    local config_dir = vim.fn.stdpath 'config'
    local init_file = config_dir .. '/init.lua'

    local function check_data(path, data)
        mini_test.expect.equality(is_file(path), true)
        local fd = assert(io.open(path))
        local rb_data = fd:read '*a'
        fd:close()
        if type(data) == type {} then
            rb_data = vim.split(rb_data, '[\r]?\n')
            -- Removing EOF jump
            if rb_data[#rb_data] == '' then
                rb_data[#rb_data] = nil
            end

            mini_test.expect.equality(rb_data, data)
        else
            -- BUG: Seems like IO does not read \r in windows but it does in unix
            if is_windows and data:match '\r' then
                rb_data = rb_data:gsub('\n', '\r\n')
            end
            mini_test.expect.equality(rb_data, data)
        end
    end

    local function write(path, data, cb)
        if not cb then
            mini_test.expect.equality(writefile(path, data), true)
            check_data(path, data)
        else
            writefile(path, data, function()
                check_data(path, data)
                mini_test.expect.equality(false, true)
            end)
        end
    end

    local function read(path, split, cb)
        if split == nil then
            split = true
        end
        if not cb then
            check_data(path, readfile(path, split))
        else
            mini_test.expect.equality(is_file(path), true)
            readfile(path, split, function(data)
                check_data(path, data)
            end)
        end
    end

    it('Creating new file', function()
        local msg = 'this is a test'
        mini_test.expect.equality(is_file(tmp), false)
        write(tmp, msg)
    end)

    it('Appending to exists file', function()
        local updatefile = require('utils.files').updatefile
        mini_test.expect.equality(is_file(tmp), true)

        local msg = table.concat(vim.fn.readfile(tmp), '\n')

        local append_data = '\nappending stuff'
        updatefile(tmp, append_data)

        local data = table.concat(vim.fn.readfile(tmp), '\n')
        mini_test.expect.equality(msg .. append_data, data)
    end)

    it('Overriding exists file', function()
        local msg = { 'This', 'Should', 'Override', 'the data' }
        mini_test.expect.equality(is_file(tmp), true)
        write(tmp, msg)
    end)

    it('Reading file as string', function()
        read(tmp, false)
        read(init_file, false)
    end)

    it('Reading file as table', function()
        read(tmp, true)
        read(init_file, true)
    end)
end)

if not is_windows then
    describe('Chmod', function()
        local chmod = require('utils.files').chmod

        it('Change file permissions', function()
            local writefile = require('utils.files').writefile
            local tmp = vim.fn.tempname()
            local is_file = require('utils.files').is_file

            local msg = 'this is a test'
            mini_test.expect.equality(is_file(tmp), false)
            mini_test.expect.equality(writefile(tmp, msg), true)
            mini_test.expect.equality(is_file(tmp), true)

            -- TODO: Need to check current permissions
            -- Removing write permissions
            mini_test.expect.equality(chmod(tmp, 400), true)
            mini_test.expect.equality(writefile(tmp, msg), false)
            mini_test.expect.equality(chmod(tmp, 600), true)
            mini_test.expect.equality(writefile(tmp, msg), true)
        end)
    end)
end

describe('ls', function()
    local homedir = vim.loop.os_homedir()

    it("List directory's files/dirs", function()
        local ls = require('utils.files').ls

        local dirs = {
            '.',
            homedir,
        }

        for _, dir in ipairs(dirs) do
            local files = {}
            for filename, _ in vim.fs.dir(dir) do
                table.insert(files, string.format('%s/%s', dir, filename))
            end
            mini_test.expect.equality(files, ls(dir))
        end
    end)

    it('Getting all files', function()
        local get_files = require('utils.files').get_files

        local dirs = {
            '.',
            homedir,
        }

        for _, dir in ipairs(dirs) do
            local files = {}
            for filename, fs_type in vim.fs.dir(dir) do
                if fs_type == 'file' then
                    table.insert(files, string.format('%s/%s', dir, filename))
                end
            end
            mini_test.expect.equality(files, get_files(dir))
        end
    end)

    it('Getting all directories', function()
        local get_dirs = require('utils.files').get_dirs

        local dirs = {
            '.',
            homedir,
        }

        for _, dir in ipairs(dirs) do
            local files = {}
            for filename, fs_type in vim.fs.dir(dir) do
                if fs_type == 'directory' then
                    table.insert(files, string.format('%s/%s', dir, filename))
                end
            end
            mini_test.expect.equality(files, get_dirs(dir))
        end
    end)
end)

describe('Rename', function()
    local rename = require('utils.files').rename

    it('file', function()
        local is_file = require('utils.files').is_file
        local writefile = require('utils.files').writefile
        local readfile = require('utils.files').readfile

        local tmpfile = vim.fn.tempname()
        local new_tmpfile = vim.fn.tempname()
        local msg = 'this is a test'

        mini_test.expect.equality(writefile(tmpfile, msg), true)

        mini_test.expect.equality(is_file(tmpfile), true)
        mini_test.expect.equality(is_file(new_tmpfile), false)

        mini_test.expect.equality(rename(tmpfile, new_tmpfile), true)

        mini_test.expect.equality(is_file(tmpfile), false)
        mini_test.expect.equality(is_file(new_tmpfile), true)

        mini_test.expect.equality(msg, readfile(new_tmpfile, false))
    end)

    it('file to existing file', function()
        local is_file = require('utils.files').is_file
        local writefile = require('utils.files').writefile
        local readfile = require('utils.files').readfile

        local tmpfile = vim.fn.tempname()
        local new_tmpfile = vim.fn.tempname()
        local msg = 'this is a test'

        mini_test.expect.equality(writefile(tmpfile, msg), true)
        mini_test.expect.equality(writefile(new_tmpfile, 'this should be just a tmp'), true)

        mini_test.expect.equality(is_file(tmpfile), true)
        mini_test.expect.equality(is_file(new_tmpfile), true)

        mini_test.expect.equality(rename(tmpfile, new_tmpfile), false)
        mini_test.expect.equality(rename(tmpfile, new_tmpfile, true), true)

        mini_test.expect.equality(is_file(tmpfile), false)
        mini_test.expect.equality(is_file(new_tmpfile), true)

        mini_test.expect.equality(msg, readfile(new_tmpfile, false))
    end)

    it('directory', function()
        local is_dir = require('utils.files').is_dir
        local mkdir = require('utils.files').mkdir

        local tmpfile = vim.fn.tempname()
        local new_tmpfile = vim.fn.tempname()

        mini_test.expect.equality(mkdir(tmpfile), true)
        mini_test.expect.equality(is_dir(tmpfile), true)
        mini_test.expect.equality(is_dir(new_tmpfile), false)

        mini_test.expect.equality(rename(tmpfile, new_tmpfile), true)

        mini_test.expect.equality(is_dir(tmpfile), false)
        mini_test.expect.equality(is_dir(new_tmpfile), true)
    end)

    -- it('file with buffer', function()
    -- end)
end)

describe('Delete', function()
    local delete = require('utils.files').delete

    it('file', function()
        local is_file = require('utils.files').is_file
        local writefile = require('utils.files').writefile

        local tmpfile = vim.fn.tempname()
        local msg = 'this is a test'
        mini_test.expect.equality(writefile(tmpfile, msg), true)

        mini_test.expect.equality(is_file(tmpfile), true)
        mini_test.expect.equality(delete(tmpfile), true)
        mini_test.expect.equality(is_file(tmpfile), false)
    end)

    it('empty directory', function()
        local is_dir = require('utils.files').is_dir
        local mkdir = require('utils.files').mkdir

        local tmpdir = vim.fn.tempname()
        mini_test.expect.equality(mkdir(tmpdir), true)

        mini_test.expect.equality(is_dir(tmpdir), true)
        mini_test.expect.equality(delete(tmpdir), true)
        mini_test.expect.equality(is_dir(tmpdir), false)
    end)

    -- BUG: This seems to fail in GH actions due to homedir having "~"
    --  Ex.  C:/Users/RUNNER~1/AppData/Local/Temp/nvimDm7s7v/16
    --  Temporally disabling for windows, may need to file a issue into Vim/Neovim
    if not is_windows then
        it('non empty directory', function()
            local is_dir = require('utils.files').is_dir
            local mkdir = require('utils.files').mkdir
            local is_file = require('utils.files').is_file
            local writefile = require('utils.files').writefile

            local tmpdir = vim.fn.tempname()
            mini_test.expect.equality(mkdir(tmpdir), true)
            mini_test.expect.equality(is_dir(tmpdir), true)

            local tmpfile = tmpdir .. '/test'
            local msg = 'this is a test'
            mini_test.expect.equality(writefile(tmpfile, msg), true)
            mini_test.expect.equality(is_file(tmpfile), true)

            mini_test.expect.equality(delete(tmpdir), false)
            mini_test.expect.equality(delete(tmpdir, true), true)
            mini_test.expect.equality(is_dir(tmpdir), false)
        end)
    end
end)

describe('JSON', function()
    local jsons = {
        { bool = true, num = 1, lst = { 1, 2, 3, 4 }, dict = { rec = false } },
        { 1, 2, 3, 4 },
        { true, 'tst', 2, false, { 1, 2, 3 } },
        { tst = 'tst', t2 = 'tst2/slash' },
    }

    local jsons_str = {
        '[1, 2, 3, 4]',
        '[1, false, "str", [1, 2, 3] ]',
        '{ "test": [1, 2], "rson": true, "data": "test" }',
        '{ "tst": "tst", "b": false, "num": 42, "foo": [ "test", 2, 1, true ] }',
    }

    it('Decode', function()
        local decode_json = require('utils.files').decode_json
        local readfile = require('utils.files').readfile

        local config_dir = vim.fn.stdpath 'config'
        local projections = config_dir .. '/.projections.json'

        local data = readfile(projections, false)

        for _, tst in ipairs(jsons_str) do
            mini_test.expect.equality(vim.fn.json_decode(tst), decode_json(tst))
        end
        mini_test.expect.equality(vim.fn.json_decode(data), decode_json(data))
    end)

    it('Encode', function()
        local encode_json = require('utils.files').encode_json
        local readfile = require('utils.files').readfile

        local config_dir = vim.fn.stdpath 'config'
        local projections = config_dir .. '/.projections.json'

        -- NOTE: This cannot be test 1:1 since both encodes generate different strings
        local internal
        local control
        for _, tst in ipairs(jsons) do
            internal = encode_json(tst)
            control = vim.fn.json_encode(tst)
            mini_test.expect.equality(vim.fn.json_decode(control), vim.fn.json_decode(internal))
        end

        local data = readfile(projections, false)
        internal = encode_json(vim.fn.json_decode(data))
        mini_test.expect.equality(vim.fn.json_decode(data), vim.fn.json_decode(internal))
    end)

    it('Read', function()
        local read_json = require('utils.files').read_json
        local readfile = require('utils.files').readfile
        local writefile = require('utils.files').writefile

        local config_dir = vim.fn.stdpath 'config'
        local projections = config_dir .. '/.projections.json'
        local tmp = vim.fn.tempname()

        for _, tst in ipairs(jsons_str) do
            mini_test.expect.equality(writefile(tmp, tst), true)
            mini_test.expect.equality(vim.fn.json_decode(tst), read_json(tmp))
        end
        mini_test.expect.equality(vim.fn.json_decode(readfile(projections, false)), read_json(projections))
    end)

    it('Dump', function()
        local dump_json = require('utils.files').dump_json
        local readfile = require('utils.files').readfile
        local writefile = require('utils.files').writefile

        local config_dir = vim.fn.stdpath 'config'
        local projections = config_dir .. '/.projections.json'
        local control = vim.fn.tempname()
        local tmp = vim.fn.tempname()

        for _, tst in ipairs(jsons) do
            mini_test.expect.equality(dump_json(tmp, tst), true)
            mini_test.expect.equality(writefile(control, vim.fn.json_encode(tst)), true)
            mini_test.expect.equality(vim.fn.json_decode(readfile(control, false)), vim.fn.json_decode(readfile(tmp)))
        end
        mini_test.expect.equality(dump_json(tmp, vim.fn.json_decode(readfile(projections))), true)
        mini_test.expect.equality(vim.fn.json_decode(readfile(projections, false)), vim.fn.json_decode(readfile(tmp)))
    end)
end)

describe('is_parent', function()
    local root = is_windows and 'C:/' or '/'
    local is_parent = require('utils.files').is_parent

    it('directory', function()
        mini_test.expect.equality(is_parent(root, vim.loop.os_homedir()), true)
        mini_test.expect.equality(is_parent(vim.loop.os_homedir(), vim.fn.stdpath 'data'), true)
        mini_test.expect.equality(is_parent(vim.loop.os_homedir(), vim.fn.stdpath 'cache'), true)
        mini_test.expect.equality(is_parent(vim.loop.os_tmpdir(), vim.loop.os_homedir()), false)
    end)

    it('root', function()
        mini_test.expect.equality(is_parent(root, root), true)
        if is_windows then
            mini_test.expect.equality(is_parent('C:', 'C:'), true)
            mini_test.expect.equality(is_parent('C:/', 'C:'), true)
            mini_test.expect.equality(is_parent('C:/', 'C:/'), true)
            mini_test.expect.equality(is_parent('C:/', 'D:/'), false)
            mini_test.expect.equality(is_parent('D:/', 'C:/users'), false)
        end
    end)
end)

describe('is_executable', function()
    local is_executable = require('utils.files').is_executable
    it('Check executable bit', function()
        mini_test.expect.equality(is_executable(vim.fn.tempname()), false)
        mini_test.expect.equality(is_executable(vim.fn.exepath(vim.o.shell)), true)
    end)
end)

if not is_windows then
    describe('chmod_exec', function()
        local chmod_exec = require('utils.files').chmod_exec

        it('file', function()
            local tmp = vim.fn.tempname()
            require('utils.files').writefile(tmp, 'test')

            mini_test.expect.equality(require('utils.files').is_executable(tmp), false)
            chmod_exec(tmp)
            mini_test.expect.equality(require('utils.files').is_executable(tmp), true)
        end)
    end)
end

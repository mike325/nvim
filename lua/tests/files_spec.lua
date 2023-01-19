require('plenary.async').tests.add_to_env()
local is_windows = vim.fn.has 'win32' == 1

-- local function separator()
--     if is_windows and not vim.o.shellslash then
--         return '\\'
--     end
--     return '/'
-- end

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
-- is_parent
-- find_files
-- skeleton_filename
-- clean_file

describe('Check file and direcotries', function()
    local config_dir, init_file, missing, homedir

    before_each(function()
        homedir = vim.loop.os_homedir()
        config_dir = vim.fn.stdpath 'config'
        init_file = config_dir .. '/init.lua'
        missing = vim.fn.tempname()
    end)

    it('exists', function()
        local exists = require('utils.files').exists
        assert.equals('directory', exists(config_dir))
        assert.equals('file', exists(init_file))
        assert.is_false(exists(missing))
    end)

    it('is_file', function()
        local is_file = require('utils.files').is_file
        assert.is_true(is_file(init_file))
        assert.is_false(is_file(config_dir))
        assert.is_false(is_file(missing))
    end)

    it('is_dir', function()
        local is_dir = require('utils.files').is_dir
        assert.is_true(is_dir(config_dir))
        assert.is_true(is_dir(homedir))
        assert.is_false(is_dir(init_file))
        assert.is_false(is_dir(missing))
    end)
end)

describe('Mkdir', function()
    local mkdir = require('utils.files').mkdir

    it('Existing Directory', function()
        local homedir = vim.loop.os_homedir()
        assert.is_true(mkdir(homedir))
    end)

    it('New Directory', function()
        local tmp = vim.fn.tempname()
        local is_dir = require('utils.files').is_dir
        assert.is_false(is_dir(tmp))
        assert.is_true(mkdir(tmp))
        assert.is_true(is_dir(tmp))
    end)

    it('Existing file', function()
        local config_dir = vim.fn.stdpath 'config'
        local init_file = config_dir .. '/init.lua'
        assert.is_false(mkdir(init_file))
    end)

    it('Multiple directories', function()
        local tmp = vim.fn.tempname() .. '/test'
        local is_dir = require('utils.files').is_dir
        assert.is_false(is_dir(tmp))
        assert.is_false(mkdir(tmp))
        assert.is_true(mkdir(tmp, true))
        assert.is_true(is_dir(tmp))
    end)
end)

describe('Linking', function()
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
            dest = vim.fn.tempname()
        end

        local link = require('utils.files').link
        local is_dir = require('utils.files').is_dir
        local is_file = require('utils.files').is_file

        local check = is_file(src) and is_file or is_dir

        if not force then
            assert.is_false(check(dest))
            assert.is_true(link(src, dest, sym))
            assert.is_true(check(dest))
        else
            assert.is_true(check(dest))
            assert.is_true(link(src, dest, sym, force))
            assert.is_true(check(dest))
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
        local dest = vim.fn.tempname()
        assert.is_false(is_dir(dest))
        assert.is_false(link('~', dest))
        assert.is_false(is_dir(dest))
    end)

    it('Missing SRC file/dir', function()
        local src = vim.fn.tempname()
        local dest = vim.fn.tempname()
        local is_file = require('utils.files').is_file
        local is_dir = require('utils.files').is_dir
        local link = require('utils.files').link

        assert.is_false(is_file(dest))
        assert.is_false(is_dir(dest))
        assert.has.error(function()
            link(src, dest)
        end)
        assert.is_false(is_file(dest))
        assert.is_false(is_dir(dest))
    end)

    describe('Force', function()
        it('Symbolic link to Directory', function()
            local dest = vim.fn.tempname()
            testlink('~', dest, true, false)
            testlink('~', dest, true, true)
        end)

        if not is_windows then
            it('Symbolic link to File', function()
                local config_dir = vim.fn.stdpath 'config'
                local init_file = config_dir .. '/init.lua'
                local dest = vim.fn.tempname()
                testlink(init_file, dest, true, false)
                testlink(init_file, dest, true, true)
            end)
        end

        it('Hard link File', function()
            local config_dir = vim.fn.stdpath 'config'
            local init_file = config_dir .. '/init.lua'
            local dest = vim.fn.tempname()
            testlink(init_file, dest, false, false)
            testlink(init_file, dest, false, true)
        end)
    end)
end)

describe('Absolute path', function()
    local is_absolute = require('utils.files').is_absolute

    it('Unix/Windows', function()
        assert.is_true(is_absolute(vim.loop.os_homedir()))
        assert.is_true(is_absolute(vim.loop.cwd()))
        assert.is_false(is_absolute '.')
        assert.is_false(is_absolute '../')
        assert.is_false(is_absolute 'test')
        assert.is_false(is_absolute './home')

        if is_windows then
            assert.is_true(is_absolute 'c:/ProgramData')
            assert.is_true(is_absolute 'D:/data')
            assert.is_false(is_absolute [[..\\ProgramData]])
            assert.is_true(is_absolute [[c:\]])
            assert.is_true(is_absolute [[C:]])
        else
            assert.is_true(is_absolute '/')
            assert.is_true(is_absolute '/tmp/')
            assert.is_false(is_absolute 'home/')
            assert.is_true(is_absolute '/../')
        end
    end)
end)

describe('Root path', function()
    local is_root = require('utils.files').is_root

    if is_windows then
        it('Windows', function()
            assert.is_true(is_root [[c:\]])
            assert.is_true(is_root 'c:/')
            assert.is_true(is_root [[C:]])
            assert.is_true(is_root [[d:\]])
            assert.is_true(is_root 'D:/')
            assert.is_true(is_root [[D:]])
            assert.is_false(is_root 'D:/data')
            assert.is_false(is_root './home')
            assert.is_false(is_root [[c:\ProgramData]])
        end)
    else
        it('Unix', function()
            assert.is_true(is_root '/')
            assert.is_false(is_root '/home/')
            assert.is_false(is_root 'home/')
            assert.is_false(is_root '.')
            assert.is_false(is_root '../')
            assert.is_false(is_root 'test')
        end)
    end
end)

describe('Realpath', function()
    local realpath = require('utils.files').realpath

    it('HOME', function()
        local homedir = vim.loop.os_homedir()
        assert.equals(realpath '~', forward_path(homedir))
    end)

    it('CWD', function()
        local cwd = vim.loop.cwd()
        assert.equals(realpath '.', forward_path(cwd))
    end)
end)

describe('Normalize', function()
    local normalize = require('utils.files').normalize

    it('HOME', function()
        local homedir = vim.loop.os_homedir()
        assert.equals(normalize '~', forward_path(homedir))
    end)

    if is_windows then
        it('Windows Path', function()
            local windows_path = [[c:\Users]]

            vim.opt.shellslash = false
            assert.equals(normalize(windows_path), forward_path(windows_path))

            vim.opt.shellslash = true
            assert.equals(normalize(windows_path), forward_path(windows_path))
        end)
    end
end)

describe('Basename', function()
    local basename = require('utils.files').basename

    it('Default', function()
        for _, path in ipairs(dirname_basename_paths) do
            assert(
                basename(path) == vim.fn.fnamemodify(path, ':t'),
                debug.traceback(
                    ('Error basename %s: %s ~= %s '):format(path, basename(path), vim.fn.fnamemodify(path, ':t'))
                )
            )
        end
    end)

    -- it('HOME', function()
    --     local username = vim.loop.os_get_passwd().username
    --     assert.equals(username, basename '~')
    --     assert.equals(username, basename(vim.loop.os_homedir()))
    -- end)

    it('Init file', function()
        local config_dir = vim.fn.stdpath 'config'
        local init_file = config_dir .. '/init.lua'
        assert.equals('init.lua', basename(init_file))
    end)

    it('Filename', function()
        assert.equals('init.lua', basename 'init.lua')
        assert.equals('test', basename './test')
        assert.equals('test', basename './test')
    end)

    -- it('Dirname', function()
    --     assert.equals('test', basename './test/')
    --     assert.equals('test', basename './test')
    -- end)

    -- it('CWD', function()
    --     local cwd = forward_path(vim.loop.cwd()):gsub('.*' .. separator(), '')
    --     assert.equals(cwd, basename '.')
    --     assert.equals(cwd, basename(vim.loop.cwd()))
    -- end)
end)

describe('Extension', function()
    local extension = require('utils.files').extension

    it('Filename', function()
        local config_dir = vim.fn.stdpath 'config'
        local init_file = config_dir .. '/init.lua'
        assert.equals('lua', extension(init_file))
        assert.equals('lua', extension 'init.lua')
        assert.equals('lua', extension '.././../init.test.lua')
        assert.equals('cpp', extension './test.cpp')
        assert.equals('c', extension './test.c')
        assert.equals('sh', extension '.bashrc.sh')
        assert.equals('', extension '.bashrc')
    end)
end)

describe('Filename', function()
    local filename = require('utils.files').filename

    it('without extension', function()
        local config_dir = vim.fn.stdpath 'config'
        local init_file = config_dir .. '/init.lua'
        assert.equals('init', filename(init_file))
        assert.equals('init', filename 'init.lua')
        assert.equals('init.test', filename '.././../init.test.lua')
        assert.equals('test', filename './test.cpp')
        assert.equals('test', filename './test.c')
        assert.equals('.bashrc', filename '.bashrc.sh')
        assert.equals('.bashrc', filename '.bashrc')
    end)
end)

describe('Dirname', function()
    local dirname = require('utils.files').dirname

    it('Getting dirname from directories and files', function()
        for _, path in ipairs(dirname_basename_paths) do
            assert(
                dirname(path) == vim.fn.fnamemodify(path, ':h'),
                debug.traceback(
                    ('Error dirname %s: %s ~= %s '):format(path, dirname(path), vim.fn.fnamemodify(path, ':h'))
                )
            )
        end

        local config_dir = forward_path(vim.fn.stdpath 'config')
        local data_dir = forward_path(vim.fn.stdpath 'data')
        local cache_dir = forward_path(vim.fn.stdpath 'cache')

        local init_file = forward_path(config_dir .. '/init.lua')
        -- local homedir = forward_path(vim.loop.os_homedir())

        assert.equals(config_dir, dirname(init_file))

        assert.equals(config_dir:gsub([[[/\]nvim.*]], ''), dirname(config_dir))
        assert.equals(data_dir:gsub([[[/\]nvim.*]], ''), dirname(data_dir))
        assert.equals(cache_dir:gsub([[[/\]nvim.*]], ''), dirname(cache_dir))

        assert.equals('~', dirname '~/.bashrc')
        if not is_windows then
            assert.equals('/', dirname '/')
            assert.equals('/tmp', dirname '/tmp/test')
        else
            assert.equals(forward_path 'c:\\', dirname 'c:\\')
            assert.equals(forward_path 'c:\\Temp', dirname 'c:\\Temp\\test')
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
        assert.is_true(is_file(path))
        local fd = assert(io.open(path))
        local rb_data = fd:read '*a'
        fd:close()
        if type(data) == type {} then
            rb_data = vim.split(rb_data, '[\r]?\n')
            -- Removing EOF jump
            if rb_data[#rb_data] == '' then
                rb_data[#rb_data] = nil
            end

            assert.are.same(rb_data, data)
        else
            -- BUG: Seems like IO does not read \r in windows but it does in unix
            if is_windows and data:match '\r' then
                rb_data = rb_data:gsub('\n', '\r\n')
            end
            assert.equals(rb_data, data)
        end
    end

    local function write(path, data, cb)
        if not cb then
            assert.is_true(writefile(path, data))
            check_data(path, data)
        else
            writefile(path, data, function()
                check_data(path, data)
                assert.is_true(false)
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
            assert.is_true(is_file(path))
            readfile(path, split, function(data)
                check_data(path, data)
            end)
        end
    end

    it('Creating new file', function()
        local msg = 'this is a test'
        assert.is_false(is_file(tmp))
        write(tmp, msg)
    end)

    it('Appending to exists file', function()
        local updatefile = require('utils.files').updatefile
        assert.is_true(is_file(tmp))

        local fd = assert(io.open(tmp))
        local msg = fd:read '*a'
        fd:close()

        local append_data = '\nappending stuff'
        updatefile(tmp, append_data)

        fd = assert(io.open(tmp))
        local data = fd:read '*a'
        fd:close()

        assert.equals(msg .. append_data, data)
    end)

    it('Overriding exists file', function()
        local msg = { 'This', 'Should', 'Override', 'the data' }
        assert.is_true(is_file(tmp))
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

    -- -- TODO: Need to find a way to test this async functions
    -- describe('Async', function()
    --     a.it('Creating new file', function()
    --         local msg = 'this is a test'
    --         assert.is_false(is_file(vim.fn.tempname()))
    --         a.run(function() write(tmp, msg, true) end)
    --     end)
    --
    --     a.it('Appending to exists file', function()
    --         local updatefile = require('utils.files').updatefile
    --         assert.is_true(is_file(tmp))
    --
    --         local fd = assert(io.open(tmp))
    --         local msg = fd:read '*a'
    --         fd:close()
    --
    --         local append_data = '\nappending more stuff'
    --         updatefile(tmp, append_data, function()
    --             fd = assert(io.open(tmp))
    --             local data = fd:read '*a'
    --             fd:close()
    --             assert.equals(msg .. append_data, data)
    --         end)
    --     end)
    --
    --     a.it('Overriding exists file', function()
    --         local msg = { 'This', 'Should', 'Override', 'the data', 'async' }
    --         assert.is_true(is_file(tmp))
    --         write(tmp, msg, true)
    --     end)
    --
    --     a.it('Reading file as string', function()
    --         read(tmp, false, true)
    --         read(init_file, false, true)
    --     end)
    --
    --     a.it('Reading file as table', function()
    --         read(tmp, true, true)
    --         read(init_file, true, true)
    --     end)
    -- end)
end)

if not is_windows then
    describe('Chmod', function()
        local chmod = require('utils.files').chmod

        it('Change file permissions', function()
            local writefile = require('utils.files').writefile
            local tmp = vim.fn.tempname()
            local is_file = require('utils.files').is_file

            local msg = 'this is a test'
            assert.is_false(is_file(tmp))
            assert.is_true(writefile(tmp, msg))
            assert.is_true(is_file(tmp))

            -- TODO: Need to check current permissions
            -- Removing write permissions
            assert.is_true(chmod(tmp, 400))
            assert.is_false(writefile(tmp, msg))
            assert.is_true(chmod(tmp, 600))
            assert.is_true(writefile(tmp, msg))
        end)
    end)
end

-- -- TODO: Glob and globpath does not return hidden files, cannot be used to verify function correctness
-- describe('ls', function()
--     it("List directory's files/dirs", function()
--         local ls = require('utils.files').ls
--         local homedir = vim.loop.os_homedir()
--
--         assert.are.same(vim.fn.globpath('.', '*', true, true), ls '.')
--         assert.are.same(vim.fn.globpath(homedir, '*', true, true), ls(homedir))
--     end)
--
--     it('Getting all files', function()
--         local get_files = require('utils.files').get_files
--         local homedir = vim.loop.os_homedir()
--         -- local cwd = vim.loop.cwd()
--         local is_file = require('utils.files').is_file
--
--         assert.are.same(vim.tbl_filter(is_file, vim.fn.globpath('.', '*', true, true)), get_files '.')
--         assert.are.same(vim.tbl_filter(is_file, vim.fn.globpath(homedir, '*', true, true)), get_files(homedir))
--     end)
--
--     it('Getting all directories', function()
--         local get_dirs = require('utils.files').get_dirs
--         local homedir = vim.loop.os_homedir()
--         -- local cwd = vim.loop.cwd()
--         local is_dir = require('utils.files').is_dir
--
--         assert.are.same(vim.tbl_filter(is_dir, vim.fn.globpath('.', '*', true, true)), get_dirs '.')
--         assert.are.same(vim.tbl_filter(is_dir, vim.fn.globpath(homedir, '*', true, true)), get_dirs(homedir))
--     end)
-- end)

describe('Rename', function()
    local rename = require('utils.files').rename

    it('file', function()
        local is_file = require('utils.files').is_file
        local writefile = require('utils.files').writefile
        local readfile = require('utils.files').readfile

        local tmpfile = vim.fn.tempname()
        local new_tmpfile = vim.fn.tempname()
        local msg = 'this is a test'

        assert.is_true(writefile(tmpfile, msg))

        assert.is_true(is_file(tmpfile))
        assert.is_false(is_file(new_tmpfile))

        assert.is_true(rename(tmpfile, new_tmpfile))

        assert.is_false(is_file(tmpfile))
        assert.is_true(is_file(new_tmpfile))

        assert.equals(msg, readfile(new_tmpfile, false))
    end)

    it('file to existing file', function()
        local is_file = require('utils.files').is_file
        local writefile = require('utils.files').writefile
        local readfile = require('utils.files').readfile

        local tmpfile = vim.fn.tempname()
        local new_tmpfile = vim.fn.tempname()
        local msg = 'this is a test'

        assert.is_true(writefile(tmpfile, msg))
        assert.is_true(writefile(new_tmpfile, 'this should be just a tmp'))

        assert.is_true(is_file(tmpfile))
        assert.is_true(is_file(new_tmpfile))

        assert.is_false(rename(tmpfile, new_tmpfile))
        assert.is_true(rename(tmpfile, new_tmpfile, true))

        assert.is_false(is_file(tmpfile))
        assert.is_true(is_file(new_tmpfile))

        assert.equals(msg, readfile(new_tmpfile, false))
    end)

    it('directory', function()
        local is_dir = require('utils.files').is_dir
        local mkdir = require('utils.files').mkdir

        local tmpfile = vim.fn.tempname()
        local new_tmpfile = vim.fn.tempname()

        assert.is_true(mkdir(tmpfile))
        assert.is_true(is_dir(tmpfile))
        assert.is_false(is_dir(new_tmpfile))

        assert.is_true(rename(tmpfile, new_tmpfile))

        assert.is_false(is_dir(tmpfile))
        assert.is_true(is_dir(new_tmpfile))
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
        assert.is_true(writefile(tmpfile, msg))

        assert.is_true(is_file(tmpfile))
        assert.is_true(delete(tmpfile))
        assert.is_false(is_file(tmpfile))
    end)

    it('empty directory', function()
        local is_dir = require('utils.files').is_dir
        local mkdir = require('utils.files').mkdir

        local tmpdir = vim.fn.tempname()
        assert.is_true(mkdir(tmpdir))

        assert.is_true(is_dir(tmpdir))
        assert.is_true(delete(tmpdir))
        assert.is_false(is_dir(tmpdir))
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
            assert.is_true(mkdir(tmpdir))
            assert.is_true(is_dir(tmpdir))

            local tmpfile = tmpdir .. '/test'
            local msg = 'this is a test'
            assert.is_true(writefile(tmpfile, msg))
            assert.is_true(is_file(tmpfile))

            assert.is_false(delete(tmpdir))
            assert.is_true(delete(tmpdir, true))
            assert.is_false(is_dir(tmpdir))
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
            assert.are.same(vim.fn.json_decode(tst), decode_json(tst))
        end
        assert.are.same(vim.fn.json_decode(data), decode_json(data))
    end)

    it('Encode', function()
        local encode_json = require('utils.files').encode_json
        local readfile = require('utils.files').readfile

        local config_dir = vim.fn.stdpath 'config'
        local projections = config_dir .. '/.projections.json'

        -- NOTE: This cannot be test 1:1 since both encodes generate diferent strings
        local internal
        local control
        for _, tst in ipairs(jsons) do
            internal = encode_json(tst)
            control = vim.fn.json_encode(tst)
            assert.are.same(vim.fn.json_decode(control), vim.fn.json_decode(internal))
        end

        local data = readfile(projections, false)
        internal = encode_json(vim.fn.json_decode(data))
        assert.are.same(vim.fn.json_decode(data), vim.fn.json_decode(internal))
    end)

    it('Read', function()
        local read_json = require('utils.files').read_json
        local readfile = require('utils.files').readfile
        local writefile = require('utils.files').writefile

        local config_dir = vim.fn.stdpath 'config'
        local projections = config_dir .. '/.projections.json'
        local tmp = vim.fn.tempname()

        for _, tst in ipairs(jsons_str) do
            assert.is_true(writefile(tmp, tst))
            assert.are.same(vim.fn.json_decode(tst), read_json(tmp))
        end
        assert.are.same(vim.fn.json_decode(readfile(projections, false)), read_json(projections))
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
            assert.is_true(dump_json(tmp, tst))
            assert.is_true(writefile(control, vim.fn.json_encode(tst)))
            assert.are.same(vim.fn.json_decode(readfile(control, false)), vim.fn.json_decode(readfile(tmp)))
        end
        assert.is_true(dump_json(tmp, vim.fn.json_decode(readfile(projections))))
        assert.are.same(vim.fn.json_decode(readfile(projections, false)), vim.fn.json_decode(readfile(tmp)))
    end)
end)

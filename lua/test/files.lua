describe('Check file and direcotries', function()
    local basedir, init_file, missing, homedir

    before_each(function()
        homedir = vim.loop.os_homedir()
        basedir = vim.fn.stdpath 'config'
        init_file = basedir .. '/init.lua'
        missing = vim.fn.tempname()
    end)

    it('exists', function()
        local exists = require('utils.files').exists
        assert.equals('directory', exists(basedir))
        assert.equals('file', exists(init_file))
        assert.is_false(exists(missing))
    end)

    it('is_file', function()
        local is_file = require('utils.files').is_file
        assert.is_true(is_file(init_file))
        assert.is_false(is_file(basedir))
        assert.is_false(is_file(missing))
    end)

    it('is_dir', function()
        local is_dir = require('utils.files').is_dir
        assert.is_true(is_dir(basedir))
        assert.is_true(is_dir(homedir))
        assert.is_false(is_dir(init_file))
        assert.is_false(is_dir(missing))
    end)
end)

describe('Mkdir', function()
    local mkdir

    before_each(function()
        mkdir = require('utils.files').mkdir
    end)

    it('Existing Directory', function()
        local homedir = vim.loop.os_homedir()
        assert.is_nil(mkdir(homedir)) -- No error = ok ?
    end)

    it('New Directory', function()
        local tmp = vim.fn.tempname()
        local is_dir = require('utils.files').is_dir
        assert.is_false(is_dir(tmp))
        mkdir(tmp)
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

    it('Symbolic link to File', function()
        local basedir = vim.fn.stdpath 'config'
        local init_file = basedir .. '/init.lua'
        testlink(init_file, nil, true)
    end)

    it('Hard link File', function()
        local basedir = vim.fn.stdpath 'config'
        local init_file = basedir .. '/init.lua'
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

    -- it("Missing SRC file/dir", function()
    --     local src = vim.fn.tempname()
    --     local dest = vim.fn.tempname()
    --     local is_file = require'utils.files'.is_file
    --     local is_dir = require'utils.files'.is_dir
    --     local link = require'utils.files'.link
    --
    --     assert.is_false(is_file(dest))
    --     assert.is_false(is_dir(dest))
    --     assert.has_error(link(src, dest))
    --     assert.is_false(is_file(dest))
    --     assert.is_false(is_dir(dest))
    -- end)

    describe('Force', function()
        it('Symbolic link to Directory', function()
            local dest = vim.fn.tempname()
            testlink('~', dest, true, false)
            testlink('~', dest, true, true)
        end)

        it('Symbolic link to File', function()
            local basedir = vim.fn.stdpath 'config'
            local init_file = basedir .. '/init.lua'
            local dest = vim.fn.tempname()
            testlink(init_file, dest, true, false)
            testlink(init_file, dest, true, true)
        end)

        it('Hard link File', function()
            local basedir = vim.fn.stdpath 'config'
            local init_file = basedir .. '/init.lua'
            local dest = vim.fn.tempname()
            testlink(init_file, dest, false, false)
            testlink(init_file, dest, false, true)
        end)
    end)
end)

describe('Absolute path', function()
    local is_absolute

    before_each(function()
        is_absolute = require('utils.files').is_absolute
    end)

    if vim.fn.has 'win32' == 1 then
        it('Windows', function()
            assert.is_true(is_absolute 'c:/ProgramData')
            assert.is_true(is_absolute 'D:/data')
            assert.is_false(is_absolute './home')
            assert.is_false(is_absolute [[c:\ProgramData]])
            assert.is_true(is_absolute [[c:\]])
            assert.is_true(is_absolute [[C:]])
        end)
    else
        it('Unix', function()
            assert.is_true(is_absolute '/')
            assert.is_true(is_absolute '/home/')
            assert.is_false(is_absolute 'home/')
            assert.is_false(is_absolute '.')
            assert.is_true(is_absolute '/../')
            assert.is_false(is_absolute '../')
            assert.is_false(is_absolute 'test')
        end)
    end
end)

describe('Root path', function()
    local is_root

    before_each(function()
        is_root = require('utils.files').is_root
    end)

    if vim.fn.has 'win32' == 1 then
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
            -- assert.is_false(is_root('/../'))
            assert.is_false(is_root '../')
            assert.is_false(is_root 'test')
        end)
    end
end)

describe('Realpath', function()
    local realpath

    before_each(function()
        realpath = require('utils.files').realpath
    end)

    it('HOME', function()
        local homedir = vim.loop.os_homedir()
        assert.equals(homedir, realpath '~')
    end)

    it('CWD', function()
        local cwd = vim.loop.cwd()
        assert.equals(cwd, realpath '.')
    end)
end)

describe('Normalize', function()
    local normalize_path

    before_each(function()
        normalize_path = require('utils.files').normalize_path
    end)

    it('HOME', function()
        local homedir = vim.loop.os_homedir()
        assert.equals(homedir, normalize_path '~')
    end)

    if vim.fn.has 'win32' == 1 then
        it('Windows Path', function()
            local windows_path = [[c:\Users]]

            vim.opt.shellslash = false
            assert.equals(windows_path, normalize_path(windows_path))

            vim.opt.shellslash = true
            assert.equals(windows_path:gsub([[\]], '/'), normalize_path(windows_path))
        end)
    end
end)

describe('Basename', function()
    local basename

    before_each(function()
        basename = require('utils.files').basename
    end)

    it('HOME', function()
        local username = vim.loop.os_get_passwd().username
        assert.equals(username, basename '~')
        assert.equals(username, basename(vim.loop.os_homedir()))
    end)

    it('Init file', function()
        local basedir = vim.fn.stdpath 'config'
        local init_file = basedir .. '/init.lua'
        assert.equals('init.lua', basename(init_file))
    end)

    it('Filename', function()
        assert.equals('init.lua', basename 'init.lua')
        assert.equals('test', basename './test')
        assert.equals('test', basename './test')
    end)

    it('CWD', function()
        local cwd = vim.loop.cwd():gsub('.*/', ''):gsub([[.*\]], '')
        assert.equals(cwd, basename '.')
        assert.equals(cwd, basename(vim.loop.cwd()))
    end)
end)

describe('Extension', function()
    local extension

    before_each(function()
        extension = require('utils.files').extension
    end)

    it('Filename', function()
        local basedir = vim.fn.stdpath 'config'
        local init_file = basedir .. '/init.lua'
        assert.equals('lua', extension(init_file))
        assert.equals('lua', extension 'init.lua')
        assert.equals('lua', extension '.././../init.test.lua')
        assert.equals('cpp', extension './test.cpp')
        assert.equals('c', extension './test.c')
        assert.equals('sh', extension '.bashrc.sh')
        assert.equals('', extension '.bashrc')
    end)
end)

describe('Basedir', function()
    local basedir

    before_each(function()
        basedir = require('utils.files').basedir
    end)

    it('Getting basedir from directories and files', function()
        local config_dir = vim.fn.stdpath 'config'
        local data_dir = vim.fn.stdpath 'data'
        local cache_dir = vim.fn.stdpath 'cache'

        local init_file = config_dir .. '/init.lua'
        local homedir = vim.loop.os_homedir()

        assert.equals(config_dir, basedir(init_file))

        assert.equals(config_dir:gsub([[[/\]nvim.*]], ''), basedir(config_dir))
        assert.equals(data_dir:gsub([[[/\]nvim.*]], ''), basedir(data_dir))
        assert.equals(cache_dir:gsub([[[/\]nvim.*]], ''), basedir(cache_dir))

        assert.equals(homedir, basedir '~/.bashrc')
        assert.equals('/', basedir '/')
        assert.equals('/tmp', basedir '/tmp/test')
    end)
end)

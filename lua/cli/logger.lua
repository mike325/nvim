local Logger = {}
Logger.__index = Logger

function Logger:new(opts)
    opts = opts or {}
    vim.validate {
        opts = { opts, 'table' },
        name = { opts.name, 'string', true },
        file = { opts.file, { 'string', 'boolean' }, true },
        stdout = { opts.stdout, 'boolean', true },
        stdout_level = { opts.stdout_level, { 'string', 'number' }, true },
        file_level = { opts.file_level, { 'string', 'number' }, true },
    }

    local obj = {
        _init = false,
        _name = opts.name or (_G.arg and (vim.fs.basename(_G.arg[0]):gsub('%.lua$', ''))) or 'nvim',
    }

    if _G['STORAGE'].loggers[obj._name] then
        return _G['STORAGE'].loggers[obj._name]
    end

    if opts.stdout or opts.stdout == nil then
        obj._stdout_level = opts.stdout_level or vim.lsp.log_levels.INFO
        if type(obj._stdout_level) ~= type(0) then
            obj._stdout_level = vim.lsp.log_levels[obj._stdout_level] or vim.lsp.log_levels.INFO
        end
    else
        obj._stdout_level = -1
    end

    if opts.file then
        obj._file = type(opts.file) == type '' and opts.file or obj._name .. '.log'
        obj._file_level = opts.file_level or vim.lsp.log_levels.DEBUG
        if type(obj._file_level) ~= type(0) then
            obj._file_level = vim.lsp.log_levels[obj._file_level] or vim.lsp.log_levels.DEBUG
        end
    else
        obj._file_level = -1
    end

    obj = setmetatable(obj, self)
    _G['STORAGE'].loggers[obj._name] = obj
    return obj
end

local function async_append_log(filename, data, cb)
    vim.loop.fs_open(filename, 'a+', 438, function(oerr, fd)
        assert(not oerr, oerr)
        vim.loop.fs_write(fd, data .. '\n', 0, function(rerr)
            assert(not rerr, rerr)
            vim.loop.fs_close(fd, function(cerr)
                assert(not cerr, cerr)
                if cb then
                    cb()
                end
            end)
        end)
    end)
end

function Logger.get(name)
    if _G['STORAGE'].loggers[name] then
        return _G['STORAGE'].loggers[name]
    end
    return nil
end

vim.iter({
    'debug',
    'info',
    'warn',
    'error',
}):each(function(level)
    local log_level = level:upper()
    Logger[level:lower()] = function(self, ...)
        local messages = vim.tbl_map(function(msg)
            return type(msg) == type '' and msg or vim.inspect(msg)
        end, { ... })
        local msg = table.concat(messages, ' ')
        if self._stdout_level > 0 then
            if self._stdout_level <= vim.lsp.log_levels[log_level] then
                vim.notify(msg, log_level, { title = self._name })
            end
        end
        if self._file_level > 0 then
            if self._file_level <= vim.lsp.log_levels[log_level] then
                local log_msg = '%s [%s] %s: %s'
                local log_exists = require('utils.files').is_file(self._file)
                if not log_exists or not self._init then
                    self._init = true
                    local init_msg = ('%s [%s] %s: %s'):format(
                        self._name,
                        'DEBUG',
                        os.date '%Y-%m-%d-%H:%M:%S',
                        'Logger init'
                    )
                    log_msg = log_msg:format(self._name, log_level, os.date '%Y-%m-%d-%H:%M:%S', msg)
                    async_append_log(self._file, init_msg, function()
                        async_append_log(self._file, log_msg)
                    end)
                else
                    async_append_log(
                        self._file,
                        log_msg:format(self._name, log_level, os.date '%Y-%m-%d-%H:%M:%S', msg)
                    )
                end
            end
        end
    end
end)

return Logger

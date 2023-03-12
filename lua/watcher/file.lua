local realpath = require('utils.files').realpath
local normalize = require('utils.files').normalize

local Watcher = {}
Watcher.__index = Watcher

local function on_change(watcher, err, fname, status)
    -- Do work...
    if not watcher._wait then
        for _, cb in ipairs(watcher._cb) do
            if vim.is_callable(cb) then
                cb(err, fname, status)
            else
                -- TODO: Add support to send err,fname,status to the autocmd
                vim.cmd.doautocmd { args = { 'User', cb } }
            end
        end
    end

    -- Debounce: stop/start.
    watcher:stop()
    vim.defer_fn(function()
        watcher:start()
    end, 100)
end

function Watcher:new(filename, cb)
    vim.validate {
        filename = { filename, 'string' },
        cb = { cb, { 'table', 'function', 'string' } },
    }

    if type(cb) ~= type {} then
        cb = { cb }
    end

    local watcher = vim.loop.new_fs_event()
    local obj = {
        _filename = realpath(normalize(filename)),
        _watcher = watcher,
        _cb = cb,
        _wait = false,
    }

    return setmetatable(obj, self)
end

-- NOTE: For some reason we get notified more than once, need this flag and a defer to
-- mitigate this and get just 1 notification per change
function Watcher:start()
    self._wait = false
    self._watcher:start(
        self._filename,
        {},
        vim.schedule_wrap(function(...)
            on_change(self, ...)
        end)
    )
end

function Watcher:stop()
    self._wait = true
    self._watcher:stop()
end

function Watcher:restart()
    self._watcher:stop()
    self._watcher:start()
end

function Watcher:subscribe(cb)
    vim.validate {
        cb = { cb, { 'function', 'table', 'string' } },
    }

    if type(cb) ~= type {} then
        cb = { cb }
    end
    vim.list_extend(self._cb, cb)
end

return Watcher

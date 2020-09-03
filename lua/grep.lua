local nvim = require'nvim'

if not nvim.has('nvim-0.5') then
    return nil
end

_G.Grep = {}

local grepjobs = {}

local function on_data(id, data, event)
    if data ~= nil and #data > 0 then
        vim.list_extend(grepjobs[id].data, data)
    end
end

local function on_exit(id, exit_code, event)
    if exit_code == 0 then
        local lines = {}

        for index, line in pairs(grepjobs[id].data) do
            line = vim.trim(line)
            if vim.fn.empty(line) == 0 and line ~= '\n' then
                lines[#lines + 1] = grepjobs[id].data[index]
            end
        end

        vim.fn.setqflist(
            {},
            'r',
            {
                contex = 'AsyncGrep',
                efm = grepjobs[id].format,
                lines = lines,
                title = 'Grep '..grepjobs[id].target,
            }
        )

        if vim.fn.getcwd() == grepjobs[id].cwd then
            local orientation = vim.o.splitbelow and 'botright' or 'topleft'
            nvim.command(orientation .. ' copen')
        else
            print('Grep '..grepjobs[id].target .. ' finished')
        end

    elseif exit_code == 1 then
        vim.fn.setqflist(
            {},
            'r',
            {
                contex = 'AsyncGrep',
                title = 'No results for '..grepjobs[id].target,
            }
        )
        nvim.echoerr('No results for '..grepjobs[id].target)
    else
        vim.fn.setqflist(
            {},
            'r',
            {
                contex = 'AsyncGrep',
                efm = grepjobs[id].format,
                lines = grepjobs[id].data,
                title = 'Error, Grep '..grepjobs[id].target..' exited with '..exit_code,
            }
        )
        nvim.echoerr('Grep exited with '..exit_code)
    end
    -- grepjobs[id] = nil
end

function _G.Grep.QueueJob(...)

    local cmd = vim.bo.grepprg or vim.o.grepprg

    local cwd = vim.fn.getcwd()
    local format = vim.o.grepformat

    for id, job in pairs(grepjobs) do
        if job['cwd'] == cwd then
            vim.fn.jobstop(id)
        end
    end

    cmd = vim.trim(cmd)

    local args = {...}

    -- print(string.format('Args %s', vim.inspect(args)))

    local flags = {}
    local search = {}
    for _, arg in pairs(args) do
        if arg:sub(1, 1) == '-' then
            flags[#flags + 1] = arg
        else
            search[#search + 1] = arg
        end
    end

    flags = vim.fn.join(flags, ' ')
    search = vim.fn.join(search, ' ')

    -- print(string.format('Flags Value %s', vim.inspect(flags)))
    -- print(string.format('Flags Size  %s', #flags))
    -- print(string.format('Flags Type  %s', type(flags)))

    -- print(string.format('Search Value %s', vim.inspect(search)))
    -- print(string.format('Search Size  %s', #search))
    -- print(string.format('Search Type  %s', type(search)))

    cmd = string.format('%s %s %s', cmd, flags, nvim.fn.shellescape(search))

    -- cmd = vim.split(cmd, ' ', true)

    -- print(string.format('CMD val  %s', cmd))
    -- print(string.format('CMD type %s', type(cmd)))
    -- print(string.format('Format %s', format))

    local id = vim.fn.jobstart(
        cmd,
        {
            cwd = cwd,
            on_stdout = on_data,
            on_stderr = on_data,
            on_exit   = on_exit,
        }
    )

    grepjobs[id] = {
        id = id,
        cmd = cmd,
        format = format,
        target = 'placeholder',
        data = {},
        cwd = cwd,
    }

end

nvim.nvim_set_command(
    'Grep',
    'call v:lua.Grep.QueueJob(<f-args>)',
    {nargs = '+', force = true}
)

return grepjobs

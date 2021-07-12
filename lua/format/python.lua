local nvim = require'neovim'
local executable = require'utils.files'.executable
local dump_to_qf = require'utils'.helpers.dump_to_qf

local echowarn = require'utils.messages'.echowarn
local echoerr  = require'utils.messages'.echoerr

local M = {}

local function on_data(jobid, data, event)
    local job = STORAGE.jobs[jobid]
    if not job.streams then
        job.streams = {}
        job.streams[event] = {}
    elseif not job.streams[event] then
        job.streams[event] = {}
    end

    if type(data) == 'string' then
        data = vim.split(data, '[\r]?\n')
    end

    vim.list_extend(job.streams[event], data)
end

local function parse_diff(output)
    local chunks = {}
    local current_chunk = 0
    for i=3,#output do
        local first,last = output[i]:match('^@@%s+[+-](%d+),(%d+)%s+[+-]%d+,%d+%s+@@$')
        -- print('Matching:', output[i])
        if first then
            current_chunk = current_chunk + 1
            chunks[current_chunk] = {}
            chunks[current_chunk].first = tonumber(first)
            chunks[current_chunk].last = tonumber(first) + tonumber(last)
            print('New chunk:',current_chunk, 'First:',first, 'Last:', chunks[current_chunk].last)
            chunks[current_chunk].lines = {}
        else
            if output[i]:sub(1,1) ~= '-' then
                -- print('New line:', output[i])
                local size = #chunks[current_chunk].lines
                chunks[current_chunk].lines[size + 1] = output[i]:sub(2, #output[i])
            end
        end
    end
    -- print('Chuncks:',vim.inspect(chunks))
    return chunks
end

local function external_formatprg(opts)
    local cmd = opts.cmd
    local buf = nvim.get_current_buf()

    local Job = RELOAD'job'
    local formatprg = Job:new{
        cmd = cmd,
        qf = {
            on_fail = {
                open = true,
                jump = false,
            },
            context = 'PyFormat',
            title = 'PyFormat',
        },
        opts = {
            on_exit = function(job, rc)
                if rc == 0 or rc == 1 then
                    local stdout = job:stdout()
                    if #stdout > 0 then
                        local chunks = parse_diff(stdout)
                        for _,chunk in pairs(chunks) do
                            local first = chunk.first
                            local last = chunk.last
                            local lines = chunk.lines
                            nvim.buf.set_lines(buf, first, last, false, lines)
                        end
                    else
                        echowarn('We should not be here, no format was detected')
                    end
                else
                    echoerr(('Failed to format code chunk, %s exited with code %s'):format(
                        job:exe,
                        rc
                    ))
                end
            end,
        },
    }

end

function M.format()
    local first = vim.v.lnum
    local last = first + vim.v.count
    local bufname = nvim.buf.get_name(0)
    local mode = nvim.get_mode()

    -- print('First:',first, 'Last:',last)

    if executable('yapf') then
        external_formatprg({
            cmd = {
                'yapf',
                '-d',
                '-l',
                first..'-'..last,
                '--style',
                'pep8',
                bufname,
            },
            first = first,
            last = last,
        })
    elseif executable('autopep8') then
        -- local cmd =
        external_formatprg({
            cmd = {
                'autopep8',
                '--diff',
                '--experimental',
                '--aggressive',
                '--max-line-length',
                '120',
                '--range',
                first,
                last,
                bufname,
            },
        })
    else
        -- Fallback to internal formater
        return 1
    end

    return 0
end

return M

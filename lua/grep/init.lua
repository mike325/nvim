local nvim = require('nvim')

local ok luajob = pcall(require, 'luajob')

if not ok then
    nvim.echoerr('Failed to load luajob and Async Grep')
    return nil
end

nvim.nvim_set_command('Grep' , [[ call v:lua.GrepStart(<q-args>) ]], {nargs='*', force=true})
-- nvim.nvim_set_command('GrepStop' , [[ call v:lua.GrepStop() ]], {force=true})

local stdout = {}
local stderr = {}
local grepjob

-- function GrepStop()
--     if grepjob ~= nil then
--         grepjob:stop()
--         grepjob = nil
--     end
-- end

function GrepStart(args)
    local grep = nvim.bo.grepprg
    local efm = nvim.o.grepformat

    local cmd = grep .. args

    grepjob = luajob:new({
        cmd = cmd,
        on_stdout = function(err, data)
            if err then
                stderr = nvim.list_extend(stderr, err)
            elseif data then
                local lines = nvim.split(data, '\n')
                stdout = nvim.list_extend(stdout, lines)
            end
        end,
        on_stderr = function(err, data)
            if data ~= nil then
                local lines = nvim.split(data, '\n')
                stderr = nvim.list_extend(stderr, lines)
            end
        end,
        on_exit = function (code, signal)
            if code == 0 then
                print('Grep finished')
            else
                print('Grep Failed, Code:', code)
            end

            local entries = {}
            local lines = #stderr > 0 and stderr or stdout

            for _,val in ipairs(lines) do
                val = val:gsub('^%s+', '')
                val = val:gsub('%s$', '')
                if #val > 0 then
                    entries[#entries + 1] = val
                end
            end

            local quickfix = {
                title = 'Grep '..args,
                efm = efm,
                lines = entries,
            }

            nvim.fn.setqflist({}, 'r', quickfix)
        end
    })

    grepjob:start()
end

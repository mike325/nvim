-- luacheck: globals unpack vim
-- local i = vim.inspect
local api = vim.api
local funcs = STORAGE.commands

local M = {}

local function get_wrapper(info)
    local scope = info.scope
    local lhs = info.lhs
    local nparams = info.nparams
    local varargs = info.varargs
    local bang = info.bang
    local bufnr = require'neovim'.win.get_buf(0)

    local cmd = [[lua STORAGE.commands]]

    cmd = cmd..("['%s']"):format(scope)

    if scope == 'b' then
        cmd = cmd..("['%s']"):format(bufnr)
    end

    cmd = cmd..("['%s']"):format(lhs)

    if bang and nparams == 1 and not varargs then
        cmd = cmd..("(%s)"):format([['<bang>' == '!']])
    elseif not bang and nparams == 1 and not varargs then
        cmd = cmd..("(%s)"):format('<q-args>')
    elseif not bang and (nparams > 1 or varargs) then
        cmd = cmd..("(%s)"):format('<f-args>')
    elseif bang and nparams == 2 and not varargs then
        cmd = cmd..("(%s, %s)"):format([['<bang>' == '!']], [[#{<q-args>} > 0 and <q-args> or ""]])
    elseif bang and (nparams > 2 or varargs) then
        cmd = cmd..("(%s, %s)"):format([['<bang>' == '!']], [[#{<f-args>} > 0 and <f-args> or ""]])
    else
        cmd = cmd..'()'
    end

    return cmd
end

local function func_handle(info)
    local scope = info.scope
    local lhs = info.lhs
    local rhs = info.rhs
    local bufnr = tostring(require'neovim'.win.get_buf(0))

    if scope == 'b' then
        if funcs.b[bufnr] == nil then
            funcs.b[bufnr] = {}
        end
        funcs.b[bufnr][lhs] = rhs

        if not vim.b.wipe_cmds then
            vim.cmd(
                ([[autocmd BufWipeout <buffer=%s> lua STORAGE.commands.b['%s'] = nil ]]):format(bufnr, bufnr)
            )
            vim.b.wipe_cmds = true
        end

    else
        funcs.g[lhs] = rhs
    end
end

function M.set_command(command)
    local echoerr = require'utils'.messages.echoerr

    if not require'utils'.tables.has_attrs(command, {'lhs'}) then
        echoerr('Missing arguments, set_command need a lhs attribbutes', 'Nvim Commands')
        return false
    end

    local cmd, nargs
    local scope = 'g'
    local bang = false
    local lhs  = command.lhs
    local rhs  = command.rhs
    local args = type(command.args) == 'table' and command.args or {command.args}

    if rhs == nil then
        cmd = {'delcommand'}
    elseif args.force then
        cmd = {'command!'}
        args.force = nil
    else
        cmd = {'command'}
    end

    local attr
    if rhs then
        for name,val in pairs(args) do
            if val then
                attr = '-'..name
                if type(val) ~= 'boolean' then
                    if attr == '-nargs' then
                        nargs = val
                    end
                    attr = attr..'='..val
                end
                if attr == '-buffer' then
                    scope = 'b'
                elseif attr == '-bang' then
                    bang = true
                end
                cmd[#cmd + 1] = attr
            end
        end
    end
    cmd[#cmd + 1] = lhs

    if type(rhs) == type('') then
        cmd[#cmd + 1] = rhs
    elseif type(rhs) == 'function' then
        local nparams = debug.getinfo(rhs).nparams
        local varargs = debug.getinfo(rhs).isvararg

        local wrapper = get_wrapper {
            lhs     = lhs,
            nparams = nparams,
            varargs = varargs,
            scope   = scope,
            bang    = bang,
        }

        if nargs == nil then
            if nparams == 1 and not varargs then
                nargs = '-nargs=1'
            elseif  nparams > 1 or varargs then
                nargs = '-nargs=*'
            end
            if nargs ~= nil then
                table.insert(cmd, #cmd, nargs)
            end
        end

        cmd[#cmd + 1] = wrapper
    end

    cmd = table.concat(cmd, ' ')
    local ok, err = pcall(api.nvim_command, cmd)

    if rhs and not ok then
        echoerr(err, 'Nvim Autocmd')
    elseif not rhs and not ok then
        require'utils'.messages.echowarn('Command not found: '..lhs, 'Nvim Autocmd')
    end

    if type(rhs) ~= type('') and ok then
        func_handle {
            rhs   = rhs,
            lhs   = lhs,
            scope = scope,
        }
    end
end


function M.rm_command(command, buffer)
    assert(
        type(command) == type('') or type(command) == type({}),
        debug.traceback('Invalid command: '..vim.inspect(command))
    )

    assert(
        type(buffer) == type(true) or type(buffer) == type(1) or buffer == nil,
        debug.traceback('Invalid buffer: '..vim.inspect(buffer))
    )

    if type(command) == type('') then
        command = {command}
    end

    for _,cmd in pairs(command) do
        if vim.api.nvim_call_function('exists', {':'..cmd}) == 2 then
            M.set_command { lhs = cmd }
        end
    end
end

return M

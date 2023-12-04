local nvim = require 'nvim'
local sys = require 'sys'

local exepath = require('utils.files').exepath
local getcwd = require('utils.files').getcwd
local is_dir = require('utils.files').is_dir
local is_file = require('utils.files').is_file
local get_dirs = require('utils.files').get_dirs

local is_windows = sys.name == 'windows'

local dap = vim.F.npcall(require, 'dap')
if not dap then
    return false
end

local executable = require('utils.files').executable

local lldb = exepath 'lldb-vscode'
local cppdbg

if not lldb then
    for version = 8, 13 do
        lldb = exepath('lldb-vscode-' .. tostring(version))
        if lldb then
            break
        end
    end
end

local function pythonPath()
    -- debugpy supports launching an application with a different interpreter
    -- then the one used to launch debugpy itself.
    -- The code below looks for a `venv` or `.venv` folder in the current directly
    -- and uses the python within.
    -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
    local cwd = getcwd()

    if vim.env.VIRTUAL_ENV then
        return vim.env.VIRTUAL_ENV .. '/bin/python'
    elseif executable(cwd .. '/venv/bin/python') then
        return cwd .. '/venv/bin/python'
    elseif executable(cwd .. '/.venv/bin/python') then
        return cwd .. '/.venv/bin/python'
    end

    return exepath 'python3' or exepath 'python'
end

local vscode_extensions_dir = sys.home .. '/.vscode/extensions'
if is_dir(vscode_extensions_dir) then
    for _, ext_dir in ipairs(vim.tbl_map(vim.fs.basename, get_dirs(vscode_extensions_dir))) do
        if ext_dir:match 'cpptools' then
            local debugger = 'OpenDebugAD7'
            if is_windows then
                debugger = debugger .. '.exe'
            end

            cppdbg = ('%s/%s/debugAdapters/bin/%s'):format(vscode_extensions_dir, ext_dir, debugger)
            if is_file(cppdbg) then
                dap.adapters.cppdbg = {
                    id = 'cppdbg',
                    type = 'executable',
                    command = is_windows and cppdbg:gsub('/', '\\') or cppdbg,
                }
                break
            end
        end
    end
end

if lldb then
    dap.adapters.lldb = {
        type = 'executable',
        command = is_windows and lldb:gsub('/', '\\') or lldb,
        name = 'lldb',
    }
end

if executable 'python3' or executable 'python' then
    dap.adapters.python = {
        type = 'executable',
        command = pythonPath(),
        args = { '-m', 'debugpy.adapter' },
    }

    dap.configurations.python = {
        {
            name = 'Launch debugpy',
            type = 'python', -- the type here established the link to the adapter definition: `dap.adapters.python`
            request = 'launch',
            -- Options below are for debugpy, see
            -- https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options
            program = '${file}', -- This configuration will launch the current file if used.
            pythonPath = pythonPath,
        },
    }
end

dap.configurations.cpp = {}
if lldb then
    table.insert(dap.configurations.cpp, {
        name = 'Launch lldb-vscode',
        type = 'lldb',
        request = 'launch',
        program = function()
            return vim.fn.input('Path to executable: ', getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = {},
        runInTerminal = false,
    })
end

if cppdbg then
    table.insert(dap.configurations.cpp, {
        name = 'Launch cppdbg',
        type = 'cppdbg',
        request = 'launch',
        program = function()
            return vim.fn.input('Path to executable: ', getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = true,
        args = {},
        runInTerminal = false,
    })
end

if #dap.configurations.cpp == 0 then
    dap.configurations.cpp = nil
end

dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

local sign = vim.fn.sign_define
sign('DapBreakpoint', { text = '●', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
sign('DapBreakpointCondition', { text = '●', texthl = 'DapBreakpointCondition', linehl = '', numhl = '' })
sign('DapLogPoint', { text = '◆', texthl = 'DapLogPoint', linehl = '', numhl = '' })

nvim.autocmd.DapConfig = {
    event = 'Filetype',
    pattern = 'dap-repl',
    callback = function()
        require('dap.ext.autocompl').attach()
    end,
}

local function list_breakpoints()
    dap.list_breakpoints()
    RELOAD('utils.qf').toggle()
end

local args = { noremap = true, silent = true }

-- require('dap.ui.variables').hover()
-- require('dap.ui.variables').scopes()
-- require('dap.ui.variables').visual_hover()
-- require('dap.ui.variables').toggle_multiline_display()

vim.keymap.set('n', '<F5>', require('dap').continue, args)
vim.keymap.set('n', '<F4>', function()
    require('dap').terminate()
    require('dap').close()
end, args)
vim.keymap.set('n', '=c', require('dap').run_to_cursor, args)
vim.keymap.set('n', ']s', require('dap').step_over, args)
vim.keymap.set('n', ']S', require('dap').step_into, args)
vim.keymap.set('n', '[s', require('dap').step_out, args)
vim.keymap.set('n', '=b', require('dap').toggle_breakpoint, args)
vim.keymap.set('n', '=B', function()
    require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
end, args)
vim.keymap.set('n', '=r', require('dap').repl.toggle, args)
vim.keymap.set('n', '<leader>L', list_breakpoints, args)
vim.keymap.set('n', 'gK', require('dap.ui.widgets').hover, args)

nvim.command.set('DapToggleBreakpoint', function()
    require('dap').toggle_breakpoint()
end)

nvim.command.set('DapRun2Cursor', function()
    require('dap').run_to_cursor()
end)

nvim.command.set('DapBreakpoint', function()
    require('dap').set_breakpoint()
end)

nvim.command.set('DapListBreakpoint', function()
    list_breakpoints()
end)

nvim.command.set('DapStart', function()
    require('dap').continue()
end)

nvim.command.set('DapStop', function()
    require('dap').terminate()
    require('dap').close()
end)

nvim.command.set('DapContinue', function()
    require('dap').continue()
end)

nvim.command.set('DapRepl', function()
    require('dap').repl.toggle()
end)

nvim.command.set('DapInfo', function()
    require('dap.ui.widgets').hover()
end)

nvim.command.set('DapStepOver', function(_)
    require('dap').step_over()
end, { nargs = '?' })

nvim.command.set('DapStepInto', function(_)
    require('dap').step_into()
end, { nargs = '?' })

nvim.command.set('DapStepOut', function(_)
    require('dap').step_out()
end, { nargs = '?' })

local dapui = vim.F.npcall(require, 'dapui')
if dapui then
    dapui.setup {}

    nvim.command.set('DapUI', function()
        require('dapui').toggle 'sidebar'
    end, {})

    vim.keymap.set('n', '=I', require('dapui').toggle, { noremap = true, silent = true })

    dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open 'sidebar'
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close 'sidebar'
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close 'sidebar'
    end
end

return true

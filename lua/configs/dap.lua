local nvim = require 'nvim'
local sys = require 'sys'

-- TODO:
-- - Define all mappings when session start and remove them on session close
-- - Add option to attach to process and to remote debug

local dap = vim.F.npcall(require, 'dap')
if not dap then
    return false
end

local utils = RELOAD 'utils.files'
local completions = RELOAD 'completions'
local is_windows = sys.name == 'windows'

local lldb = utils.exepath 'lldb-vscode'
if not lldb then
    for version = 8, 30 do
        lldb = utils.exepath('lldb-vscode-' .. tostring(version))
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
    local cwd = utils.getcwd()

    if vim.env.VIRTUAL_ENV then
        return vim.env.VIRTUAL_ENV .. '/bin/python'
    elseif utils.executable(cwd .. '/venv/bin/python') then
        return cwd .. '/venv/bin/python'
    elseif utils.executable(cwd .. '/.venv/bin/python') then
        return cwd .. '/.venv/bin/python'
    end

    return utils.exepath 'python3' or utils.exepath 'python'
end

local cppdbg
local vscode_extensions_dir = sys.home .. '/.vscode/extensions'
if utils.is_dir(vscode_extensions_dir) then
    for _, ext_dir in ipairs(vim.tbl_map(vim.fs.basename, utils.get_dirs(vscode_extensions_dir))) do
        if ext_dir:match 'cpptools' then
            local debugger = 'OpenDebugAD7'
            if is_windows then
                debugger = debugger .. '.exe'
            end

            cppdbg = ('%s/%s/debugAdapters/bin/%s'):format(vscode_extensions_dir, ext_dir, debugger)
            if utils.is_file(cppdbg) then
                if not is_windows and not utils.is_executable(cppdbg) then
                    utils.chmod_exec(cppdbg)
                end
                dap.adapters.cppdbg = {
                    id = 'cppdbg',
                    type = 'executable',
                    command = is_windows and cppdbg:gsub('/', '\\') or cppdbg,
                }
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

if utils.executable 'python3' or utils.executable 'python' then
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
            return vim.fn.input('Path to executable: ', '', 'file')
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
            return vim.fn.input('Path to executable: ', '', 'file')
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

local dapui = vim.F.npcall(require, 'dapui')
if dapui then
    dapui.setup {}
    vim.keymap.set('n', '=I', require('dapui').toggle, { noremap = true, silent = true })

    dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close()
    end
end

local function stop_debug_session()
    dap.terminate()
    dap.close()
    if dapui then
        dapui.close()
    end
end

local function start_debug_session()
    dap.continue()
end

local function list_breakpoints()
    dap.list_breakpoints()
    RELOAD('utils.qf').open()
end

vim.keymap.set('n', '<F5>', start_debug_session, { noremap = true, silent = true })
vim.keymap.set('n', '<F4>', stop_debug_session, { noremap = true, silent = true })
vim.keymap.set('n', 'gK', require('dap.ui.widgets').hover, { noremap = true, silent = true })
vim.keymap.set('n', '=c', start_debug_session, { noremap = true, silent = true })
vim.keymap.set('n', '=C', stop_debug_session, { noremap = true, silent = true })
vim.keymap.set('n', ']s', dap.step_over, { noremap = true, silent = true })
vim.keymap.set('n', '[s', dap.step_out, { noremap = true, silent = true })
vim.keymap.set('n', ']S', dap.step_into, { noremap = true, silent = true })
vim.keymap.set('n', '[S', dap.step_out, { noremap = true, silent = true })
vim.keymap.set('n', '=b', dap.toggle_breakpoint, { noremap = true, silent = true })
vim.keymap.set('n', '=r', dap.repl.toggle, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>L', list_breakpoints, { noremap = true, silent = true })

vim.keymap.set('n', '=B', function()
    local condition = vim.fn.input 'Breakpoint condition: '
    if condition ~= '' then
        dap.set_breakpoint(condition)
    end
end, { noremap = true, silent = true })

nvim.command.set('Dap', function(opts)
    local subcmd = opts.args:gsub('^%-+', '')

    local cmd_func = {
        stop = stop_debug_session,
        start = start_debug_session,
        continue = start_debug_session,
        restart = dap.restart,
        repl = dap.repl.toggle,
        breakpoint = dap.toggle_breakpoint,
        list = list_breakpoints,
        clear = dap.clear_breakpoints,
        run2cursor = dap.run_to_cursor,
    }

    if cmd_func[subcmd] then
        cmd_func[subcmd]()
    end
end, { desc = 'Manage DAP sessions', nargs = 1, complete = completions.dap_commands })

return true

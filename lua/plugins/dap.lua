local exepath = require('utils.files').exepath
local load_module = require('utils.helpers').load_module
local getcwd = require('utils.files').getcwd

local dap = load_module 'dap'

if not dap then
    return false
end

local executable = require('utils.files').executable

local set_autocmd = require('neovim.autocmds').set_autocmd
local set_command = require('neovim.commands').set_command
local lldb = exepath 'lldb-vscode'

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

dap.adapters.python = {
    type = 'executable',
    command = pythonPath(),
    args = { '-m', 'debugpy.adapter' },
}

dap.configurations.python = {
    {
        -- The first three options are required by nvim-dap
        type = 'python', -- the type here established the link to the adapter definition: `dap.adapters.python`
        request = 'launch',
        name = 'Launch file',
        -- Options below are for debugpy, see
        -- https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options
        program = '${file}', -- This configuration will launch the current file if used.
        pythonPath = pythonPath,
    },
}

if lldb then
    dap.adapters.lldb = {
        type = 'executable',
        command = lldb,
        name = 'lldb',
    }

    dap.configurations.cpp = {
        {
            name = 'Launch',
            type = 'lldb',
            request = 'launch',
            program = function()
                return vim.fn.input('Path to executable: ', getcwd() .. '/', 'file')
            end,
            cwd = '${workspaceFolder}',
            stopOnEntry = false,
            args = {},

            -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
            --
            --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
            --
            -- Otherwise you might get the following error:
            --
            --    Error on launch: Failed to attach to the target process
            --
            -- But you should be aware of the implications:
            -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
            runInTerminal = false,
        },
    }

    -- If you want to use this for rust and c, add something like this:
    dap.configurations.c = dap.configurations.cpp
    dap.configurations.rust = dap.configurations.cpp
end

vim.fn.sign_define('DapBreakpoint', { text = '🛑', texthl = '', linehl = '', numhl = '' })
-- vim.fn.sign_define('DapLogPoint', {text='🛑', texthl='', linehl='', numhl=''})
-- vim.fn.sign_define('DapStopped', {text='🛑', texthl='', linehl='', numhl=''})
-- vim.fn.sign_define('DapBreakpointRejected', {text='🛑', texthl='', linehl='', numhl=''})

set_autocmd {
    event = 'Filetype',
    pattern = 'dap-repl',
    cmd = "lua require('dap.ext.autocompl').attach()",
    group = 'DapConfig',
}

-- DAP APIs
--
-- dap.continue()
-- dap.run()
-- dap.run_last()
-- dap.launch()
-- dap.stop()
-- dap.disconnect()
-- dap.attach()
-- dap.set_breakpoint()
-- dap.toggle_breakpoint()
-- dap.list_breakpoints()
-- dap.set_exception_breakpoints()
-- dap.step_over()
-- dap.step_into()
-- dap.step_out()
-- dap.step_back()
-- dap.pause()
-- dap.reverse_continue()
-- dap.up()
-- dap.down()
-- dap.goto_({line})
-- dap.run_to_cursor()
-- dap.set_log_level()
-- dap.session()
-- dap.status()
--
-- dap.repl.open()
-- dap.repl.toggle()
-- dap.repl.close()
--
-- require('dap.ui.variables').hover()
-- require('dap.ui.variables').scopes()
-- require('dap.ui.variables').visual_hover()
-- require('dap.ui.variables').toggle_multiline_display()

local function list_breakpoints()
    dap.list_breakpoints()
    require('utils.helpers').toggle_qf()
end

local args = { noremap = true, silent = true }

vim.keymap.set('n', '<F5>', require('dap').continue, args)
vim.keymap.set('n', '<F4>', require('dap').close, args)
vim.keymap.set('n', '<F10>', require('dap').run_to_cursor, args)
vim.keymap.set('n', ']s', require('dap').step_over, args)
vim.keymap.set('n', ']S', require('dap').step_into, args)
vim.keymap.set('n', '[s', require('dap').step_out, args)
vim.keymap.set('n', '=b', require('dap').toggle_breakpoint, args)
vim.keymap.set('n', '=r', require('dap').repl.toggle, args)
vim.keymap.set('n', '<leader>L', list_breakpoints, args)
vim.keymap.set('n', 'gK', require('dap.ui.widgets').hover, args)

set_command {
    lhs = 'DapToggleBreakpoint',
    rhs = require('dap').toggle_breakpoint,
    args = { force = true },
}

set_command {
    lhs = 'DapRun2Cursor',
    rhs = require('dap').run_to_cursor,
    args = { force = true },
}

set_command {
    lhs = 'DapBreakpoint',
    rhs = require('dap').set_breakpoint,
    args = { force = true },
}

set_command {
    lhs = 'DapListBreakpoint',
    rhs = list_breakpoints,
    args = { force = true },
}

set_command {
    lhs = 'DapStart',
    rhs = require('dap').continue,
    args = { force = true },
}

set_command {
    lhs = 'DapStop',
    rhs = require('dap').stop,
    args = { force = true },
}

set_command {
    lhs = 'DapContinue',
    rhs = require('dap').continue,
    args = { force = true },
}

set_command {
    lhs = 'DapRepl',
    rhs = require('dap').repl.toggle,
    args = { force = true },
}

set_command {
    lhs = 'DapInfo',
    rhs = require('dap.ui.widgets').hover,
    args = { force = true },
}

set_command {
    lhs = 'DapStepOver',
    rhs = function(_)
        require('dap').step_over()
    end,
    args = { nargs = '?', force = true },
}

set_command {
    lhs = 'DapStepInto',
    rhs = function(_)
        require('dap').step_into()
    end,
    args = { nargs = '?', force = true },
}

set_command {
    lhs = 'DapStepOut',
    rhs = function(_)
        require('dap').step_out()
    end,
    args = { nargs = '?', force = true },
}

return true

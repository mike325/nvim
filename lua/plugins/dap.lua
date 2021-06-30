local nvim        = require'nvim'
local exepath     = require'utils.files'.exepath
local load_module = require'utils.helpers'.load_module
local getcwd      = require'utils.files'.getcwd

local dap = load_module'dap'

if not dap then
    return false
end

local set_autocmd = nvim.autocmds.set_autocmd
local set_command = nvim.commands.set_command
local set_mapping = nvim.mappings.set_mapping

local function pythonPath()
    -- debugpy supports launching an application with a different interpreter
    -- then the one used to launch debugpy itself.
    -- The code below looks for a `venv` or `.venv` folder in the current directly
    -- and uses the python within.
    -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
    local cwd = getcwd()

    if vim.env.VIRTUAL_ENV then
        return vim.env.VIRTUAL_ENV .. '/bin/python'
    elseif vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
        return cwd .. '/venv/bin/python'
    elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
        return cwd .. '/.venv/bin/python'
    end

    return exepath('python3') or exepath('python')
end

dap.adapters.python = {
    type = 'executable';
    command = pythonPath();
    args = { '-m', 'debugpy.adapter' };
}

dap.configurations.python = {
    {
        -- The first three options are required by nvim-dap
        type = 'python'; -- the type here established the link to the adapter definition: `dap.adapters.python`
        request = 'launch';
        name = "Launch file";
        -- Options below are for debugpy, see
        -- https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options
        program = "${file}"; -- This configuration will launch the current file if used.
        pythonPath = pythonPath;
    },
}

local lldb = exepath('lldb-vscode') or exepath('lldb-vscode-11')

if lldb then
    dap.adapters.lldb = {
        type = 'executable',
        command = lldb,
        name = "lldb"
    }

    dap.configurations.cpp = {
      {
        name = "Launch",
        type = "lldb",
        request = "launch",
        program = function()
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
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

vim.fn.sign_define('DapBreakpoint', {text='🛑', texthl='', linehl='', numhl=''})
-- vim.fn.sign_define('DapLogPoint', {text='🛑', texthl='', linehl='', numhl=''})
-- vim.fn.sign_define('DapStopped', {text='🛑', texthl='', linehl='', numhl=''})
-- vim.fn.sign_define('DapBreakpointRejected', {text='🛑', texthl='', linehl='', numhl=''})

set_autocmd{
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
    require'utils'.helpers.toggle_qf('qf')
end

local args = {noremap = true, silent = true}

set_mapping{
    mode = 'n',
    lhs = '<F5>',
    rhs = ":lua require'dap'.continue()<CR>",
    args = args,
}

set_mapping{
    mode = 'n',
    lhs = '<F6>',
    rhs = ":lua require'dap'.stop()<CR>",
    args = args,
}

set_mapping{
    mode = 'n',
    lhs = '<F10>',
    rhs = ":lua require'dap'.run_to_cursor()<CR>",
    args = args,
}

set_mapping{
    mode = 'n',
    lhs = ']s',
    rhs = ":lua require'dap'.step_over()<CR>",
    args = args,
}

set_mapping{
    mode = 'n',
    lhs = ']S',
    rhs = ":lua require'dap'.step_into()<CR>",
    args = args,
}

set_mapping{
    mode = 'n',
    lhs = '[s',
    rhs = ":lua require'dap'.step_out()<CR>",
    args = args,
}

set_mapping{
    mode = 'n',
    lhs = '=s',
    rhs = ":lua require'dap'.toggle_breakpoint()<CR>",
    args = args,
}

set_mapping{
    mode = 'n',
    lhs = '=r',
    rhs = ":lua require'dap'.repl.toggle()<CR>",
    args = args,
}

set_mapping{
    mode = 'n',
    lhs = '=b',
    rhs = list_breakpoints,
    args = args,
}

set_command{
    lhs = 'DapToggleBreakpoint',
    rhs = ":lua require'dap'.toggle_breakpoint()<CR>",
    args = { force = true, }
}

set_command{
    lhs = 'DapRun2Cursor',
    rhs = ":lua require'dap'.run_to_cursor()<CR>",
    args = { force = true, }
}

set_command{
    lhs = 'DapBreakpoint',
    rhs = ":lua require'dap'.set_breakpoint()<CR>",
    args = { force = true, }
}

set_command{
    lhs = 'DapListBreakpoint',
    rhs = list_breakpoints,
    args = { force = true, }
}

set_command{
    lhs = 'DapStart',
    rhs = ":lua require'dap'.continue()<CR>",
    args = { force = true, }
}

set_command{
    lhs = 'DapStop',
    rhs = ":lua require'dap'.stop()<CR>",
    args = { force = true, }
}

set_command{
    lhs = 'DapContinue',
    rhs = ":lua require'dap'.continue()<CR>",
    args = { force = true, }
}

set_command{
    lhs = 'DapRepl',
    rhs = ":lua require'dap'.repl.toggle()<CR>",
    args = { force = true, }
}

return true

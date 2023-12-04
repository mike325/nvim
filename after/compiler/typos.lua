local cmd = {
    'typos',
    '--format',
    'brief',
}

vim.cmd.CompilerSet { args = { 'makeprg=' .. table.concat(cmd, '\\ ') } }

-- TODO: Need to find a way to set this with the default CompilerSet command
vim.bo.efm = table.concat(vim.opt_global.efm:get(), ',')

vim.b.current_compiler = 'typos'

local cmd = {
    'pre-commit',
}

vim.cmd.CompilerSet { args = { 'makeprg=' .. table.concat(cmd, '\\ ') } }
vim.cmd.CompilerSet {
    args = {
        'errorformat=' .. table.concat(RELOAD('mappings').precommit_efm, ','):gsub(' ', '\\ '),
    },
}

vim.b.current_compiler = 'pre-commit'

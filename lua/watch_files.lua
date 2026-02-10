local ssh_config = vim.fs.joinpath(vim.uv.os_homedir(), '.ssh', 'config')

-- TODO: Add some lua files to enable auto reloading of settings
local watch_files = {
    [ssh_config] = 'ParseSSH',
    -- ['.clangd'] = 'Clangd',
    ['compile_commands.json'] = 'ParseFlags',
    ['compile_flags.txt'] = 'ParseFlags',
}

for fname, event in pairs(watch_files) do
    if require('utils.files').is_file(fname) then
        require('watcher.file'):new(require('utils.files').realpath(fname), event):start()
    end
end

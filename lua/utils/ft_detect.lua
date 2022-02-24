local nvim = require 'neovim'

if not nvim.has { 0, 7 } or not vim.filetype then
    vim.fn['filetypedetect#detect']()
    return false
end

vim.filetype.add {
    extension = {
        nginx = 'nginx',
        conf = 'dosini',
        si = 'dosini',
        sle = 'dosini',
        ['in'] = 'dosini',
        pdbrc = 'python',
        pkg = 'conf',
        log = 'log',
        rpt = 'log',
        rdl = 'log',
        ini = 'toml',
        xmp = 'xml',
    },
    filename = {
        ['.gitconfig'] = '.gitconfig',
        ['gitconfig'] = 'gitconfig',
        ['.editorconfig'] = 'toml',
        ['setup.cfg'] = 'toml',
        ['.flake8'] = 'toml',
        ['flake8'] = 'toml',
        ['.coveragerc'] = 'dosini',
        ['.bashrc'] = 'sh',
        ['.profile'] = 'sh',
        ['config.txt'] = 'dosini',
        ['nginx.conf'] = 'nginx',
        ['tmux.conf'] = 'tmux',
    },
    pattern = {
        ['.*/etc/nginx/.*'] = 'nginx',
        ['config%.txt'] = 'dosini',
        ['%.bash_.*'] = 'sh',
        ['%.bashrc%..*'] = 'sh',
        ['www%.overleaf%.com_.*%.txt'] = 'tex',
        ['github.com_.*%.txt'] = 'markdown',
        ['godbolt.org_.*%.txt'] = 'cpp',
        ['cppreference.com_.*%.txt'] = 'cpp',
        ['.*%.cppreference.com_.*%.txt'] = 'cpp',
        ['.*/zfunctions/.*'] = 'zsh',
    },
}

return true
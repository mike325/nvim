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
        expect = 'expect',
    },
    filename = {
        ['.gitconfig'] = '.gitconfig',
        ['gitconfig'] = 'gitconfig',
        ['.editorconfig'] = vim.fn.has 'nvim-0.9' == 1 and 'editorconfig' or 'dosini',
        ['setup.cfg'] = 'toml',
        ['.flake8'] = 'toml',
        ['flake8'] = 'toml',
        ['.coveragerc'] = 'dosini',
        ['.bashrc'] = 'sh',
        ['.profile'] = 'sh',
        ['config.txt'] = 'dosini',
        ['nginx.conf'] = 'nginx',
        ['tmux.conf'] = 'tmux',
        ['zsh.sh'] = 'zsh',
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
        ['.*'] = {
            priority = -math.huge,
            function(_, bufnr)
                local shebang = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
                if shebang then
                    local nvim_path = vim.pesc(vim.v.progpath)
                    local nvim_env_regex = vim.regex [[^#!\(env\|/usr/bin/env\|/bin/env\)\s\+\<nvim\>]]
                    if shebang:match(('^#!%s'):format(nvim_path)) or nvim_env_regex:match_str(shebang) then
                        return 'lua'
                    end
                end
            end,
        },
    },
}

return true

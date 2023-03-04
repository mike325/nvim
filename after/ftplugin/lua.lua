local nvim = require 'nvim'

vim.opt_local.suffixesadd:prepend '.lua'
vim.opt_local.suffixesadd:prepend 'init.lua'

local lua_runtime = vim.split(package.path, ';')
lua_runtime = vim.tbl_map(function(p)
    return p:gsub('\\', '/'):gsub('%?.*', '')
end, lua_runtime)

local runtimepaths = vim.api.nvim_get_runtime_file('', true)
runtimepaths = vim.tbl_map(function(p)
    return p:gsub('\\', '/') .. '/lua'
end, runtimepaths)

vim.opt_local.path:prepend { './lua/', '.' }
vim.opt_local.path:prepend(require('utils.tables').merge_uniq_list(runtimepaths, lua_runtime))

nvim.command.set('HelpNeovim', function(opts)
    local original_iskeyword = vim.bo.iskeyword

    vim.bo.iskeyword = vim.bo.iskeyword .. ',.'
    local word = vim.fn.expand '<cword>'
    vim.bo.iskeyword = original_iskeyword

    -- TODO: This is kind of a lame hack... since you could rename `vim.api` -> `a` or similar
    if word:match 'vim%.api' then
        local _, finish = word:find 'vim%.api%.'
        local api_function = word:sub(finish + 1)
        vim.cmd.help(api_function)
    elseif word:match 'vim%.fn' then
        local _, finish = word:find 'vim%.fn%.'
        local vim_function = word:sub(finish + 1) .. '()'
        vim.cmd.help(vim_function)
    elseif word:match 'vim%.[bw]?o' or word:match 'vim%.opt' then
        local _, finish = word:find 'vim%.[bw]?o%.'
        if not finish then
            _, finish = word:find 'vim%.opt[%w_]*%.'
        end
        local vim_option = "'" .. word:sub(finish + 1) .. "'"
        vim.cmd.help(vim_option)
    elseif word:match 'vim%.cmd' then
        local _, finish = word:find 'vim%.fn%.'
        local vim_cmd = ':' .. word:sub(finish + 1)
        vim.cmd.help(vim_cmd)
    else
        -- TODO: This should be exact match only. Not sure how to do that with `:help`
        -- TODO: Let users determine how magical they want the help finding to be
        local ok = pcall(vim.cmd.help, word)

        if not ok then
            ok = pcall(vim.cmd.help, vim.fn.expand '<cword>')
        end

        if not ok then
            local split_word = vim.split(word, '.', true)
            ok = pcall(vim.cmd.help, split_word[#split_word])
        end

        if not ok then
            vim.lsp.buf.hover()
        end
    end
end, {
    buffer = true,
    nargs = '*',
    desc = 'Open Neovim help with word under cursor',
})

vim.opt_local.keywordprg = ':HelpNeovim'

local ft = vim.opt_local.filetype:get()
require('utils.buffers').setup(ft, {
    define = [[^\s*\(local\s\+\)\?\(function\s\+\(\i\+[.:]\)\?\|\ze\i\+\s*=\s*\|\(\i\+[.:]\)\?\ze\s*=\s*\)]],
    -- TODO: this includeexpr does not include /init.lua files
    includeexpr = [[substitute(v:fname,'\.','/','g')]],
    include = [[\v\s*(RELOAD|require)]],
})

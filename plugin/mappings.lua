local sys = require 'sys'
local nvim = require 'nvim'

local executable = require('utils.files').executable
local set_abbr = require('nvim.abbrs').set_abbr
-- local completions = RELOAD 'completions'

if not vim.g.mapleader then
    vim.g.mapleader = ' '
end

set_abbr { mode = 'c', lhs = 'Gti', rhs = 'Git' }
set_abbr { mode = 'c', lhs = 'W', rhs = 'w' }
set_abbr { mode = 'c', lhs = 'Q', rhs = 'q' }
set_abbr { mode = 'c', lhs = 'q1', rhs = 'q!' }
set_abbr { mode = 'c', lhs = 'qa1', rhs = 'qa!' }
set_abbr { mode = 'c', lhs = 'w1', rhs = 'w!' }
set_abbr { mode = 'c', lhs = 'wA!', rhs = 'wa!' }
set_abbr { mode = 'c', lhs = 'wa1', rhs = 'wa!' }
set_abbr { mode = 'c', lhs = 'Qa1', rhs = 'qa!' }
set_abbr { mode = 'c', lhs = 'Qa!', rhs = 'qa!' }
set_abbr { mode = 'c', lhs = 'QA!', rhs = 'qa!' }

vim.keymap.set('n', 'q<', '<cmd>colder<CR>', { noremap = true })
vim.keymap.set('n', 'q>', '<cmd>cnewer<CR>', { noremap = true })
-- vim.keymap.set('n', '<l', '<cmd>lolder<CR>', { noremap = true })
-- vim.keymap.set('n', '>l', '<cmd>lnewer<CR>', { noremap = true })

vim.keymap.set('c', '<C-n>', '<down>', { noremap = true })
vim.keymap.set('c', '<C-p>', '<up>', { noremap = true })
vim.keymap.set('c', '<C-k>', '<left>', { noremap = true })
vim.keymap.set('c', '<C-j>', '<right>', { noremap = true })

vim.keymap.set('c', '<C-r><C-w>', "<C-r>=escape(expand('<cword>'), '#')<CR>", { noremap = true })
vim.keymap.set('c', '<C-r><C-n>', [[<C-r>=v:lua.vim.fs.basename(nvim_buf_get_name(0))<CR>]], { noremap = true })
vim.keymap.set('c', '<C-r><C-p>', [[<C-r>=bufname('%')<CR>]], { noremap = true })
vim.keymap.set('c', '<C-r><C-d>', [[<C-r>=v:lua.vim.fs.dirname(bufname('%'))..'/'<CR>]], { noremap = true })

vim.keymap.set('n', ',', ':', { noremap = true })
vim.keymap.set('x', ',', ':', { noremap = true })
vim.keymap.set('n', 'Y', 'y$', { noremap = true })
vim.keymap.set('x', '$', '$h', { noremap = true })
vim.keymap.set('n', 'Q', 'o<ESC>', { noremap = true })
vim.keymap.set('n', 'J', 'm`J``', { noremap = true })
vim.keymap.set('i', 'jj', '<ESC>', { noremap = true })
vim.keymap.set('x', '<BS>', '<ESC>', { noremap = true })

for key, direction in pairs { h = 'left', j = 'down', k = 'up', l = 'left' } do
    local map_opts = { noremap = true, desc = 'Move to the window located ' .. direction }
    vim.keymap.set('n', '<leader>' .. key, '<C-w>' .. key, map_opts)
end

local tab_idx = 1
while tab_idx <= 9 do
    local map_opts = { noremap = true, desc = 'Move to the ' .. tab_idx .. ' Tab' }
    vim.keymap.set('n', '<leader>' .. tab_idx, tab_idx .. 'gt', map_opts)
    tab_idx = tab_idx + 1
end
vim.keymap.set('n', '<leader>0', '<cmd>tablast<CR>', { noremap = true, desc = 'Move to the last tab' })

vim.keymap.set('n', '<leader><leader>n', '<cmd>tabnew<CR>', { noremap = true })

vim.keymap.set('n', '/', "m'/", { noremap = true })
vim.keymap.set('n', 'g/', "m'/\\v", { noremap = true })
vim.keymap.set('n', '0', '^', { noremap = true })
vim.keymap.set('n', '^', '0', { noremap = true })

vim.keymap.set('n', 'gV', '`[v`]', { noremap = true })

vim.keymap.set('t', '<ESC>', '<C-\\><C-n>', { noremap = true })
vim.keymap.set('n', '<BS>', '<C-o>', { noremap = true, silent = true })

vim.keymap.set('n', 'n', function()
    RELOAD('mappings.keymaps').nicenext 'n'
end, { noremap = true, silent = true, desc = 'n and center view' })
vim.keymap.set('n', 'N', function()
    RELOAD('mappings.keymaps').nicenext 'N'
end, { noremap = true, silent = true, desc = 'N and center view' })

vim.keymap.set('n', '<S-tab>', '<C-o>', { noremap = true })
vim.keymap.set('x', '<', '<gv', { noremap = true })
vim.keymap.set('x', '>', '>gv', { noremap = true })

vim.keymap.set(
    'n',
    'j',
    [[v:count ? (v:count >= 3 ? "m'" . v:count : '') . 'j' : 'gj']],
    { noremap = true, expr = true }
)

vim.keymap.set(
    'n',
    'k',
    [[v:count ? (v:count >= 3 ? "m'" . v:count : '') . 'k' : 'gk']],
    { noremap = true, expr = true }
)

vim.keymap.set('n', '<leader><leader>e', '<cmd>echo expand("%")<CR>', { noremap = true })

vim.keymap.set('n', 'i', function()
    return RELOAD('mappings.keymaps').smart_insert()
end, { noremap = true, expr = true, desc = 'Smart insert/indent' })

vim.keymap.set('n', 'c*', 'm`*``cgn', { noremap = true })
vim.keymap.set('n', 'c#', 'm`#``cgN', { noremap = true })
vim.keymap.set('n', 'cg*', 'm`g*``cgn', { noremap = true })
vim.keymap.set('n', 'cg#', 'm`#``cgN', { noremap = true })
vim.keymap.set('x', 'c', [["cy/<C-r>c<CR>Ncgn]], { noremap = true })
vim.keymap.set({ 'n', 'x' }, '¿', '`', { noremap = true })
vim.keymap.set({ 'n', 'x' }, '¿¿', '``', { noremap = true })
vim.keymap.set({ 'n', 'x' }, '¡', '^', { noremap = true })

vim.keymap.set('n', '<leader>p', '<C-^>', { noremap = true, desc = 'Shortcut to switch to alternate buffer' })

vim.keymap.set('n', '<leader>q', function()
    RELOAD('mappings.keymaps').smart_quit()
end, { noremap = true, silent = true, desc = 'Quit/close windows and tabs' })

vim.keymap.set('i', '<C-U>', '<C-G>u<C-U>', { noremap = true })

vim.keymap.set('n', '<leader>d', function()
    RELOAD('utils.buffers').delete()
end, { desc = 'Delete current buffer without changing the window layout' })

vim.keymap.set('n', '<leader><leader>d', function()
    RELOAD('utils.buffers').delete(vim.api.nvim_get_current_buf(), true)
end, { desc = 'Wipe current buffer without changing the window layout' })

local mapping_pairs = {
    arglist = '',
    buflist = 'b',
    quickfix = 'c',
    loclist = 'l',
}

for postfix_map, prefix_cmd in pairs(mapping_pairs) do
    local prefix = postfix_map:sub(1, 1)
    vim.keymap.set(
        'n',
        '[' .. prefix:upper(),
        ':<C-U>' .. prefix_cmd .. 'first<CR>zvzz',
        { noremap = true, silent = true, desc = 'Go to the first element of the ' .. postfix_map }
    )
    vim.keymap.set(
        'n',
        ']' .. prefix:upper(),
        ':<C-U>' .. prefix_cmd .. 'last<CR>zvzz',
        { noremap = true, silent = true, desc = 'Go to the last element of the ' .. postfix_map }
    )
    vim.keymap.set(
        'n',
        '[' .. prefix,
        ':<C-U>exe "".(v:count ? v:count : "")."' .. prefix_cmd .. 'previous"<CR>zvzz',
        { noremap = true, silent = true, desc = 'Go to the prev element of the ' .. postfix_map }
    )
    vim.keymap.set(
        'n',
        ']' .. prefix,
        ':<C-U>exe "".(v:count ? v:count : "")."' .. prefix_cmd .. 'next"<CR>zvzz',
        { noremap = true, silent = true, desc = 'Go to the next element of the ' .. postfix_map }
    )
end

vim.keymap.set(
    'n',
    ']<Space>',
    [[:<C-U>lua require"mappings.keymaps".add_nl(true)<CR>]],
    { noremap = true, silent = true, desc = 'Add N spaces down the cursor' }
)
vim.keymap.set(
    'n',
    '[<Space>',
    [[:<C-U>lua require"mappings.keymaps".add_nl(false)<CR>]],
    { noremap = true, silent = true, desc = 'Add N spaces up the cursor' }
)
vim.keymap.set(
    'n',
    '<C-L>',
    '<cmd>nohlsearch|diffupdate<CR>',
    { noremap = true, silent = true, desc = 'Clear search and update diff' }
)

vim.keymap.set(
    'n',
    '<leader>T',
    '<cmd>windo diffthis<CR>',
    { noremap = true, silent = true, desc = 'Diff the current windows' }
)

vim.keymap.set(
    'n',
    '<leader>O',
    '<cmd>windo diffoff<CR>',
    { noremap = true, silent = true, desc = 'Disable Diff view' }
)

vim.keymap.set('n', '=q', function()
    RELOAD('utils.qf').toggle()
end, { noremap = true, silent = true, desc = 'Toggle quickfix' })

vim.keymap.set('n', '=l', function()
    RELOAD('utils.qf').toggle { win = vim.api.nvim_get_current_win() }
end, { noremap = true, silent = true, desc = 'Toggle location list' })

vim.keymap.set('n', '<leader><leader>p', function()
    RELOAD('mappings').swap_window()
end, { noremap = true, silent = true, desc = 'Mark and swap windows' })

-- TODO: Check for GUIs
if sys.name == 'windows' then
    vim.keymap.set('n', '<C-h>', '<C-o>', { noremap = true, silent = true, desc = 'Windows support to jump backwards' })
    vim.keymap.set('x', '<C-h>', '<ESC>', { noremap = true, silent = true, desc = 'Same as <BS> mapping' })
    if not vim.g.started_by_firenvim then
        vim.keymap.set('n', '<C-z>', '<nop>', { noremap = true, desc = 'Remove C-z from windows mappings' })
    end
end

vim.keymap.set(
    'n',
    'gs',
    '<cmd>set opfunc=neovim#grep<CR>g@',
    { noremap = true, silent = true, desc = 'Grep search {motion}' }
)
vim.keymap.set(
    'v',
    'gs',
    ':<C-U>call neovim#grep(visualmode(), v:true)<CR>',
    { noremap = true, silent = true, desc = 'Grep search visual selection' }
)
vim.keymap.set('n', 'gss', function()
    local grepprg = vim.bo.grepprg ~= '' and vim.bo.grepprg or vim.o.grepprg
    grepprg = vim.split(grepprg, '%s+', { trimempty = true })
    local args = vim.list_extend(vim.list_slice(grepprg, 2, #grepprg), { vim.fn.expand '<cword>' })
    RELOAD('utils.async').grep { args = args }
end, { noremap = true, silent = true, desc = 'Grep search word under cursor' })

if executable 'scp' then
    vim.keymap.set(
        'n',
        '<leader><leader>s',
        '<cmd>SendFile<CR>',
        { noremap = true, silent = true, desc = 'Send the current file to a remote host' }
    )
    vim.keymap.set(
        'n',
        '<leader><leader>g',
        '<cmd>GetFile<CR>',
        { noremap = true, silent = true, desc = 'Get the current equivalent file from a remote host' }
    )
end

vim.keymap.set('n', '=F', function()
    RELOAD('utils.buffers').format { whole_file = true }
end, { noremap = true, silent = true, desc = 'Format the current buffer with the prefer formatting prg' })

vim.keymap.set('n', '=D', function()
    vim.diagnostic.setqflist()
    vim.cmd.wincmd 'J'
end, { noremap = true, silent = true, desc = 'Toggle diagnostics in the quickfix' })

vim.keymap.set('n', '=v', function()
    local configs = vim.diagnostic.config() or {}
    local force = false
    if configs.virtual_lines or configs.virtual_text then
        force = true
    end
    RELOAD('utils.diagnostics').toggle_virtual_lines(nil, force)
end, { noremap = true, silent = true, desc = 'Toggle diagnostics in the quickfix' })

vim.keymap.set('n', '=L', function()
    vim.diagnostic.setloclist()
end, { noremap = true, silent = true, desc = 'Toggle diagnostics in the location list' })

vim.keymap.set('n', '=d', function()
    vim.diagnostic.open_float()
end, { noremap = true, silent = true, desc = 'Show diagnostics under the cursor in a floating window' })

vim.keymap.set('n', '=j', function(opts)
    RELOAD('mappings').show_background_tasks(opts)
end, { noremap = true, desc = 'Show current background running tasks' })

vim.keymap.set('n', '=p', function()
    RELOAD('mappings').toggle_progress_win()
end, { noremap = true, silent = true, desc = 'Show progress of the selected task' })

vim.keymap.set('n', '<leader>c', function()
    local bufnr = vim.api.nvim_get_current_buf()

    local options = {
        filename = function()
            return vim.fs.basename(nvim.buf.get_name(bufnr))
        end,
        -- extension = true,
        filepath = function()
            return require('utils.files').realpath(nvim.buf.get_name(bufnr))
        end,
        dirname = function()
            return vim.fs.dirname(nvim.buf.get_name(bufnr))
        end,
        bufnr = function()
            return bufnr
        end,
    }

    vim.ui.select(
        vim.tbl_keys(options),
        { prompt = 'Select File/Buffer attribute: ' },
        vim.schedule_wrap(function(choice)
            if options[choice] then
                nvim.reg['"'] = options[choice]()
                nvim.reg['+'] = options[choice]()
                nvim.reg['*'] = options[choice]()

                -- local send_to_term = vim.env.SSH_CONNECTION and not vim.env.TMUX
                -- if send_to_term then
                --     require('utils.osc').send_osc52(vim.split(nvim.reg['"'], '\n'))
                -- end

                vim.notify(
                    'Clipboard value: ' .. nvim.reg['"'],
                    vim.log.levels.INFO,
                    { title = 'Item copied successfully' }
                )
            end
        end)
    )
end, { noremap = true, desc = 'Copy different Buffer/File related stuff' })

vim.keymap.set('n', '<leader>e', function()
    RELOAD('utils.arglist').edit()
end, { noremap = true, silent = true, desc = 'Edit a file in the arglist' })

vim.keymap.set('n', '<leader>A', function()
    RELOAD('utils.arglist').add { '%' }
end, { noremap = true, silent = true, desc = 'Add current buffer to the arglist' })

vim.keymap.set('n', '<leader>Q', function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    RELOAD('utils.qf').dump_files({ { bufnr = 0, lnum = cursor[1], col = cursor[2] } }, { action = 'a', open = false })
end, { noremap = true, silent = true, desc = 'Add current buffer to the quickfix' })

vim.keymap.set('n', '<leader>L', function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    RELOAD('utils.qf').dump_files(
        { { bufnr = 0, lnum = cursor[1], col = cursor[2] } },
        { action = 'a', open = false, win = 0 }
    )
end, { noremap = true, silent = true, desc = 'Add current buffer to the loclist' })

vim.keymap.set('n', '<leader>D', function()
    local cwd = vim.pesc(vim.uv.cwd() .. '/')
    local arg = (vim.api.nvim_buf_get_name(0):gsub(cwd, ''))
    RELOAD('utils.arglist').delete { arg }
end, { noremap = true, silent = true, desc = 'Delete current buffer to the arglist' })

vim.keymap.set('n', '=e', function()
    local buf = vim.api.nvim_get_current_buf()
    local filename = vim.api.nvim_buf_get_name(buf)
    if filename:match '^fugitive://' or not filename:match '^%w+://' then
        vim.cmd.Gedit()
    elseif filename:match '^gitsigns://' then
        local realfile = (filename:gsub('^gitsigns://.+/%.git/[a-zA-Z0-9~^]+:', ''))
        vim.cmd.edit(realfile)
    end
end, { noremap = true, silent = true, desc = 'Fugitive Gedit shortcut' })

if not nvim.has { 0, 10 } then
    -- TODO: Make this accept movements and visual selections
    vim.keymap.set('n', 'gx', function()
        local cfile = vim.fn.expand '<cfile>'
        local cword = vim.fn.expand '<cWORD>'
        vim.ui.open(cword:match '^[%w]+://' and cword or cfile)
    end, { noremap = true, silent = true, desc = 'Override gx to use vim.ui.open' })
end

vim.keymap.set('n', '<F5>', function()
    local dap = vim.F.npcall(require, 'dap')
    if dap then
        dap.continue()
    else
        if vim.g.termdebug_session then
            vim.cmd.Continue()
        else
            if not vim.g.loaded_termdebug then
                vim.cmd.packadd { args = { 'termdebug' }, bang = false }
                vim.g.loaded_termdebug = true
            end
            vim.cmd.Termdebug()
        end
    end
end, { noremap = true, silent = true, desc = 'Start a Debug session' })

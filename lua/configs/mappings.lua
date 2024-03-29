local sys = require 'sys'
local nvim = require 'nvim'

local executable = require('utils.files').executable
local set_abbr = require('nvim.abbrs').set_abbr
-- local completions = RELOAD 'completions'

local noremap = { noremap = true }
local noremap_silent = { noremap = true, silent = true }

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

vim.keymap.set('c', '<C-n>', '<down>', noremap)
vim.keymap.set('c', '<C-p>', '<up>', noremap)
vim.keymap.set('c', '<C-k>', '<left>', noremap)
vim.keymap.set('c', '<C-j>', '<right>', noremap)

vim.keymap.set('c', '<C-r><C-w>', "<C-r>=escape(expand('<cword>'), '#')<CR>", noremap)
vim.keymap.set('c', '<C-r><C-n>', [[<C-r>=v:lua.vim.fs.basename(nvim_buf_get_name(0))<CR>]], noremap)
vim.keymap.set('c', '<C-r><C-p>', [[<C-r>=bufname('%')<CR>]], noremap)
vim.keymap.set('c', '<C-r><C-d>', [[<C-r>=v:lua.vim.fs.dirname(bufname('%'))..'/'<CR>]], noremap)

vim.keymap.set('n', ',', ':', noremap)
vim.keymap.set('x', ',', ':', noremap)
vim.keymap.set('n', 'Y', 'y$', noremap)
vim.keymap.set('x', '$', '$h', noremap)
vim.keymap.set('n', 'Q', 'o<ESC>', noremap)
vim.keymap.set('n', 'J', 'm`J``', noremap)
vim.keymap.set('i', 'jj', '<ESC>', noremap)
vim.keymap.set('x', '<BS>', '<ESC>', noremap)

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

vim.keymap.set('n', '<leader><leader>n', '<cmd>tabnew<CR>', noremap)

vim.keymap.set({ 'n', 'x' }, '&', '<cmd>&&<CR>', noremap)

vim.keymap.set('n', '/', "m'/", noremap)
vim.keymap.set('n', 'g/', "m'/\\v", noremap)
vim.keymap.set('n', '0', '^', noremap)
vim.keymap.set('n', '^', '0', noremap)

vim.keymap.set('n', 'gV', '`[v`]', noremap)

vim.keymap.set('t', '<ESC>', '<C-\\><C-n>', noremap)
vim.keymap.set('n', '<BS>', '<C-o>', { noremap = true, silent = true })

vim.keymap.set('n', 'n', function()
    RELOAD('mappings').nicenext 'n'
end, { noremap = true, silent = true, desc = 'n and center view' })
vim.keymap.set('n', 'N', function()
    RELOAD('mappings').nicenext 'N'
end, { noremap = true, silent = true, desc = 'N and center view' })

vim.keymap.set('n', '<S-tab>', '<C-o>', noremap)
vim.keymap.set('x', '<', '<gv', noremap)
vim.keymap.set('x', '>', '>gv', noremap)

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

vim.keymap.set('n', '<leader><leader>e', '<cmd>echo expand("%")<CR>', noremap)

vim.keymap.set('n', 'i', function()
    return RELOAD('mappings').smart_insert()
end, { noremap = true, expr = true, desc = 'Smart insert/indent' })

vim.keymap.set('n', 'c*', 'm`*``cgn', noremap)
vim.keymap.set('n', 'c#', 'm`#``cgN', noremap)
vim.keymap.set('n', 'cg*', 'm`g*``cgn', noremap)
vim.keymap.set('n', 'cg#', 'm`#``cgN', noremap)
vim.keymap.set('x', 'c', [["cy/<C-r>c<CR>Ncgn]], noremap)
vim.keymap.set({ 'n', 'x' }, '¿', '`', noremap)
vim.keymap.set({ 'n', 'x' }, '¿¿', '``', noremap)
vim.keymap.set({ 'n', 'x' }, '¡', '^', noremap)

vim.keymap.set('n', '<leader>p', '<C-^>', noremap)

vim.keymap.set('n', '<leader>q', function()
    RELOAD('mappings').smart_quit()
end, { noremap = true, silent = true, desc = 'Quit/close windows and tabs' })

vim.keymap.set('i', '<C-U>', '<C-G>u<C-U>', noremap)

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

vim.keymap.set('n', ']<Space>', [[:<C-U>lua require"mappings".add_nl(true)<CR>]], noremap_silent)
vim.keymap.set('n', '[<Space>', [[:<C-U>lua require"mappings".add_nl(false)<CR>]], noremap_silent)
vim.keymap.set('n', '<C-L>', '<cmd>nohlsearch|diffupdate<CR>', noremap_silent)

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
    vim.keymap.set('n', '<C-h>', '<C-o>', { noremap = true, silent = true })
    vim.keymap.set('x', '<C-h>', '<ESC>', { noremap = true, silent = true, desc = 'Same as <BS> mapping' })
    if not vim.g.started_by_firenvim then
        vim.keymap.set('n', '<C-z>', '<nop>', noremap)
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
    RELOAD('utils.functions').send_grep_job()
end, { noremap = true, silent = true, desc = 'Grep search word under cursor' })

if executable 'scp' then
    vim.keymap.set('n', '<leader><leader>s', '<cmd>SendFile<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<leader><leader>g', '<cmd>GetFile<CR>', { noremap = true, silent = true })
end

-- TODO: Make this accept movements and visual selections
vim.keymap.set('n', 'gx', function()
    local cfile = vim.fn.expand '<cfile>'
    local cword = vim.fn.expand '<cWORD>'
    vim.ui.open(cword:match '^[%w]+://' and cword or cfile)
end, noremap_silent)

vim.opt.formatexpr = "v:lua.RELOAD('utils.buffers').format( { 'ft': &l:filetype })"
vim.keymap.set('n', '=F', function()
    RELOAD('utils.buffers').format { whole_file = true }
end, { noremap = true, silent = true, desc = 'Format the current buffer with the prefer formatting prg' })

vim.keymap.set('n', '=D', function()
    vim.diagnostic.setqflist()
    vim.cmd.wincmd 'J'
end, { noremap = true, silent = true, desc = 'Toggle diagnostics in the quickfix' })

vim.keymap.set('n', '=L', function()
    vim.diagnostic.setloclist()
end, { noremap = true, silent = true, desc = 'Toggle diagnostics in the location list' })

vim.keymap.set('n', '=d', function()
    vim.diagnostic.open_float()
end, { noremap = true, silent = true, desc = 'Show diagnostics under the cursor in a floating window' })

vim.keymap.set('n', ']d', function()
    vim.diagnostic.goto_next { wrap = true }
end, { noremap = true, silent = true, desc = 'Go to the next diagnostic' })

vim.keymap.set('n', '[d', function()
    vim.diagnostic.goto_prev { wrap = true }
end, { noremap = true, silent = true, desc = 'Go to the prev diagnostic' })

vim.keymap.set('n', '=j', function(opts)
    RELOAD('mappings').show_background_jobs(opts)
end, noremap)

vim.keymap.set('n', '=p', function()
    RELOAD('mappings').toggle_progress_win()
end, { noremap = true, silent = true, desc = 'Show progress of the selected job' })

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
                nvim.reg['+'] = options[choice]()
                vim.notify(
                    'Clipboard value: ' .. nvim.reg['+'],
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

vim.keymap.set('n', '<leader>D', function()
    local cwd = vim.pesc(vim.loop.cwd() .. '/')
    vim.cmd.argdelete((vim.api.nvim_buf_get_name(0):gsub(cwd, '')))
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

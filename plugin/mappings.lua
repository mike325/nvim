local sys = require 'sys'
local nvim = require 'nvim'

local executable = require('utils.files').executable
local set_abbr = require('nvim.abbrs').set_abbr
local completions = RELOAD 'completions'

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
vim.keymap.set('c', '<C-r><C-n>', [[<C-r>=luaeval("vim.fs.basename(vim.api.nvim_buf_get_name(0))")<CR>]], noremap)
vim.keymap.set('c', '<C-r><C-p>', [[<C-r>=luaeval("vim.api.nvim_buf_get_name(0)")<CR>]], noremap)
vim.keymap.set('c', '<C-r><C-d>', [[<C-r>=luaeval("vim.fs.dirname(vim.api.nvim_buf_get_name(0))..'/'")<CR>]], noremap)

vim.keymap.set('n', ',', ':', noremap)
vim.keymap.set('x', ',', ':', noremap)
vim.keymap.set('n', 'Y', 'y$', noremap)
vim.keymap.set('x', '$', '$h', noremap)
vim.keymap.set('n', 'Q', 'o<ESC>', noremap)
vim.keymap.set('n', 'J', 'm`J``', noremap)
vim.keymap.set('i', 'jj', '<ESC>', noremap)
vim.keymap.set('x', '<BS>', '<ESC>', noremap)

vim.keymap.set('n', '<leader>h', '<C-w>h', noremap)
vim.keymap.set('n', '<leader>j', '<C-w>j', noremap)
vim.keymap.set('n', '<leader>k', '<C-w>k', noremap)
vim.keymap.set('n', '<leader>l', '<C-w>l', noremap)

vim.keymap.set('n', '<leader>e', '<C-w>=', noremap)
vim.keymap.set('n', '<leader>1', '1gt', noremap)
vim.keymap.set('n', '<leader>2', '2gt', noremap)
vim.keymap.set('n', '<leader>3', '3gt', noremap)
vim.keymap.set('n', '<leader>4', '4gt', noremap)
vim.keymap.set('n', '<leader>5', '5gt', noremap)
vim.keymap.set('n', '<leader>6', '6gt', noremap)
vim.keymap.set('n', '<leader>7', '7gt', noremap)
vim.keymap.set('n', '<leader>8', '8gt', noremap)
vim.keymap.set('n', '<leader>9', '9gt', noremap)
vim.keymap.set('n', '<leader>0', '<cmd>tablast<CR>', noremap)
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

vim.keymap.set('n', '[Q', ':<C-U>cfirst<CR>zvzz', noremap_silent)
vim.keymap.set('n', ']Q', ':<C-U>clast<CR>zvzz', noremap_silent)
vim.keymap.set('n', '[q', ':<C-U>exe "".(v:count ? v:count : "")."cprevious"<CR>zvzz', noremap_silent)
vim.keymap.set('n', ']q', ':<C-U>exe "".(v:count ? v:count : "")."cnext"<CR>zvzz', noremap_silent)
vim.keymap.set('n', '[L', ':<C-U>lfirst<CR>zvzz', noremap_silent)
vim.keymap.set('n', ']L', ':<C-U>llast<CR>zvzz', noremap_silent)
vim.keymap.set('n', '[l', ':<C-U>exe "".(v:count ? v:count : "")."lprevious"<CR>zvzz', noremap_silent)
vim.keymap.set('n', ']l', ':<C-U>exe "".(v:count ? v:count : "")."lnext"<CR>zvzz', noremap_silent)
vim.keymap.set('n', '[B', ':<C-U>bfirst<CR>zvzz', noremap_silent)
vim.keymap.set('n', ']B', ':<C-U>blast<CR>zvzz', noremap_silent)
vim.keymap.set('n', '[b', ':<C-U>exe "".(v:count ? v:count : "")."bprevious"<CR>', noremap_silent)
vim.keymap.set('n', ']b', ':<C-U>exe "".(v:count ? v:count : "")."bnext"<CR>', noremap_silent)
vim.keymap.set('n', ']<Space>', [[:<C-U>lua require"mappings".add_nl(true)<CR>]], noremap_silent)
vim.keymap.set('n', '[<Space>', [[:<C-U>lua require"mappings".add_nl(false)<CR>]], noremap_silent)
vim.keymap.set('n', '<C-L>', '<cmd>nohlsearch|diffupdate<CR>', noremap_silent)

nvim.command.set('ClearQf', function()
    RELOAD('utils.qf').clear()
end)
nvim.command.set('ClearLoc', function()
    RELOAD('utils.qf').clear(nvim.get_current_win())
end)

vim.keymap.set('n', '=q', function()
    RELOAD('utils.qf').toggle()
end, { noremap = true, silent = true, desc = 'Toggle quickfix' })

vim.keymap.set('n', '=l', function()
    RELOAD('utils.qf').toggle { win = vim.api.nvim_get_current_win() }
end, { noremap = true, silent = true, desc = 'Toggle location list' })

vim.keymap.set('n', '<leader><leader>p', function()
    RELOAD('mappings').swap_window()
end, { noremap = true, silent = true, desc = 'Mark and swap windows' })

nvim.command.set('Terminal', function(opts)
    RELOAD('mappings').floating_terminal(opts)
end, { nargs = '*', desc = 'Show big center floating terminal window' })

nvim.command.set('MouseToggle', function()
    RELOAD('mappings').toggle_mouse()
end)

nvim.command.set('BufKill', function(opts)
    RELOAD('mappings').bufkill(opts)
end, { bang = true, nargs = 0 })

nvim.command.set('VerboseToggle', 'let &verbose=!&verbose | echo "Verbose " . &verbose')
nvim.command.set('RelativeNumbersToggle', 'set relativenumber! relativenumber?')
nvim.command.set('ModifiableToggle', 'setlocal modifiable! modifiable?')
nvim.command.set('CursorLineToggle', 'setlocal cursorline! cursorline?')
nvim.command.set('ScrollBindToggle', 'setlocal scrollbind! scrollbind?')
nvim.command.set('HlSearchToggle', 'setlocal hlsearch! hlsearch?')
nvim.command.set('NumbersToggle', 'setlocal number! number?')
nvim.command.set('SpellToggle', 'setlocal spell! spell?')
nvim.command.set('WrapToggle', 'setlocal wrap! wrap?')

nvim.command.set('Trim', function(opts)
    RELOAD('mappings').trim(opts)
end, { nargs = '?', complete = completions.toggle, bang = true })

nvim.command.set('GonvimSettngs', "execute('edit ~/.gonvim/setting.toml')")

nvim.command.set('FileType', function(opts)
    vim.opt_local.filetype = opts.args ~= '' and opts.args or 'text'
end, { nargs = '?', complete = 'filetype' })

nvim.command.set('FileFormat', function(opts)
    vim.opt_local.filetype = opts.args ~= '' and opts.args or 'unix'
end, { nargs = '?', complete = completions.fileformats })

nvim.command.set('SpellLang', function(opts)
    RELOAD('utils.functions').spelllangs(opts.args)
end, { nargs = '?', complete = completions.spells })

nvim.command.set('Qopen', function(opts)
    opts.size = tonumber(opts.args)
    if opts.size then
        opts.size = opts.size + 1
    end
    RELOAD('utils.qf').toggle(opts)
end, { nargs = '?' })

-- TODO: Check for GUIs
if sys.name == 'windows' then
    vim.keymap.set('n', '<C-h>', '<C-o>', { noremap = true, silent = true })
    vim.keymap.set('x', '<C-h>', '<ESC>', { noremap = true, silent = true, desc = 'Same as <BS> mapping' })
    if not vim.g.started_by_firenvim then
        vim.keymap.set('n', '<C-z>', '<nop>', noremap)
    end
else
    nvim.command.set('Chmod', function(opts)
        RELOAD('mappings').chmod(opts)
    end, { nargs = 1 })
end

nvim.command.set('MoveFile', function(opts)
    RELOAD('mappings').move_file(opts)
end, { bang = true, nargs = 1, complete = 'file' })

nvim.command.set('RenameFile', function(opts)
    RELOAD('mappings').rename_file(opts)
end, { bang = true, nargs = 1, complete = 'file' })

nvim.command.set('Mkdir', function(opts)
    vim.fn.mkdir(vim.fn.fnameescape(opts.args), 'p')
end, { nargs = 1, complete = 'dir' })

nvim.command.set('RemoveFile', function(opts)
    local target = opts.args ~= '' and opts.args or vim.api.nvim_buf_get_name(0)
    local utils = RELOAD 'utils.files'
    utils.delete(utils.realpath(target), opts.bang)
end, { bang = true, nargs = '?', complete = 'file' })

nvim.command.set('CopyFile', function(opts)
    local utils = RELOAD 'utils.files'
    local src = vim.api.nvim_buf_get_name(0)
    local dest = opts.fargs[1]
    utils.copy(src, dest, opts.bang)
end, { bang = true, nargs = 1, complete = 'file' })

nvim.command.set('Grep', function(opts)
    local search = opts.fargs[#opts.fargs]
    opts.fargs[#opts.fargs] = nil
    local args = opts.fargs
    if #args > 0 then
        local grepprg = vim.tbl_filter(function(k)
            return not k:match '^%s*$'
        end, RELOAD('utils.functions').select_grep(false, nil, true))

        vim.list_extend(args, vim.list_slice(grepprg, 2, #grepprg))
    end
    RELOAD('utils.functions').send_grep_job { search = search, args = args }
end, { nargs = '+', complete = 'file' })

nvim.command.set('LGrep', function(opts)
    local search = opts.fargs[#opts.fargs]
    opts.fargs[#opts.fargs] = nil

    local args = opts.fargs
    if #args > 0 then
        local grepprg = vim.tbl_filter(function(k)
            return not k:match '^%s*$'
        end, RELOAD('utils.functions').select_grep(false, nil, true))

        vim.list_extend(args, vim.list_slice(grepprg, 2, #grepprg))
    end

    RELOAD('utils.functions').send_grep_job { loc = true, search = search, args = args }
end, { nargs = '+', complete = 'file' })

nvim.command.set('Find', function(opts)
    local args = {
        args = opts.fargs,
        target = opts.args,
        cb = function(results)
            if #results > 0 then
                local qf_opts = {
                    open = true,
                    jump = false,
                    context = 'Finder',
                    title = 'Finder',
                    efm = '%f',
                    items = results,
                }
                RELOAD('utils.qf').set_list(qf_opts)
            else
                vim.notify('No files matching: ' .. opts.fargs[#opts.fargs], 'ERROR', { title = 'Find' })
            end
        end,
    }
    RELOAD('mappings').find(args)
end, { bang = true, nargs = '+', complete = 'file' })

nvim.command.set('LFind', function(opts)
    local args = {
        args = opts.fargs,
        target = opts.args,
        cb = function(results)
            if #results > 0 then
                local qf_opts = {
                    open = true,
                    jump = false,
                    win = nvim.get_current_win(),
                    context = 'Finder',
                    title = 'Finder',
                    efm = '%f',
                    items = results,
                }
                RELOAD('utils.qf').set_list(qf_opts)
            else
                vim.notify('No files matching: ' .. opts.fargs[#opts.fargs], 'ERROR', { title = 'Find' })
            end
        end,
    }
    RELOAD('mappings').find(args)
end, { bang = true, nargs = '+', complete = 'file' })

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

nvim.command.set('Make', function(opts)
    RELOAD('mappings').async_makeprg(opts)
end, { nargs = '*', desc = 'Async execution of current makeprg' })

if executable 'cscope' and not nvim.has { 0, 9 } then
    for query, _ in pairs(require('mappings').cscope_queries) do
        local cmd = 'C' .. query:sub(1, 1):upper() .. query:sub(2, #query)
        nvim.command.set(cmd, function(opts)
            RELOAD('mappings').cscope(opts.args, query)
        end, { nargs = '?', desc = 'cscope commad to find ' .. query .. ' under cursor or arg' })
    end
end

if executable 'scp' then
    nvim.command.set('SendFile', function(opts)
        RELOAD('mappings').remote_file(opts.args, true)
    end, {
        nargs = '*',
        complete = completions.ssh_hosts_completion,
        desc = 'Send current file to a remote location',
    })

    nvim.command.set('GetFile', function(opts)
        RELOAD('mappings').remote_file(opts.args, false)
    end, {
        nargs = '*',
        complete = completions.ssh_hosts_completion,
        desc = 'Get current file from a remote location',
    })

    vim.keymap.set('n', '<leader><leader>s', '<cmd>SendFile<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<leader><leader>g', '<cmd>GetFile<CR>', { noremap = true, silent = true })
end

nvim.command.set('Scratch', function(opts)
    RELOAD('mappings').scratch_buffer(opts)
end, {
    nargs = '?',
    complete = 'filetype',
    desc = 'Create a scratch buffer of the current or given filetype',
})

nvim.command.set('ConcealLevel', function()
    local conncall = vim.opt_local.conceallevel:get() or 0
    vim.opt_local.conceallevel = conncall > 0 and 0 or 2
end, { desc = 'Toogle conceal level between 0 and 2' })

nvim.command.set('Messages', function(opts)
    RELOAD('mappings').messages(opts)
end, { nargs = '?', complete = 'messages', desc = 'Populate quickfix with the :messages list' })

if executable 'pre-commit' then
    nvim.command.set('PreCommit', function(opts)
        RELOAD('mappings').precommit(opts)
    end, { nargs = '*' })
end

-- TODO: Add support to change between local and osc/remote open
nvim.command.set('Open', function(opts)
    RELOAD('utils.functions').open(opts.args)
end, {
    nargs = 1,
    complete = 'file',
    desc = 'Open file in the default OS external program',
})

-- TODO: Make this accept movements and visual selections
vim.keymap.set('n', 'gx', function()
    local cfile = vim.fn.expand '<cfile>'
    local cword = vim.fn.expand '<cWORD>'
    RELOAD('utils.functions').open(cword:match '^[%w]+://' and cword or cfile)
end, noremap_silent)

nvim.command.set('Repl', function(opts)
    RELOAD('mappings').repl(opts)
end, { nargs = '*', complete = 'filetype' })

-- TODO: May need to add a check for "zoom" executable but this should work even inside WSL
nvim.command.set('Zoom', function(opts)
    RELOAD('mappings').zoom_links(opts)
end, { nargs = 1, complete = completions.zoom_links, desc = 'Open Zoom call in a specific room' })

vim.opt.formatexpr = [[luaeval('RELOAD"utils.buffers".format({ft=_A})',&l:filetype)]]
vim.keymap.set('n', '=F', function()
    RELOAD('utils.buffers').format { whole_file = true }
end, { noremap = true, silent = true, desc = 'Format the current buffer with the prefer formatting prg' })

nvim.command.set('Edit', function(opts)
    RELOAD('mappings').edit(opts)
end, { nargs = '*', complete = 'file', desc = 'Open multiple files' })

nvim.command.set('DiffFiles', function(opts)
    RELOAD('mappings').diff_files(opts)
end, { nargs = '+', complete = 'file', desc = 'Open a new tab in diff mode with the given files' })

-- NOTE: I should not need to create this function, but I couldn't find a way to override
--       internal runtime compilers
nvim.command.set('Compiler', function(opts)
    RELOAD('mappings').custom_compiler(opts)
end, {
    nargs = 1,
    complete = 'compiler',
    desc = 'Set the given compiler with preference on the custom compilers located in the after directory',
})

nvim.command.set('Reloader', function(opts)
    RELOAD('mappings').reload_configs(opts)
end, {
    nargs = '?',
    desc = 'Change between git grep and the best available alternative',
    complete = completions.reload_configs,
})

nvim.command.set('AutoFormat', function(opts)
    RELOAD('mappings').autoformat(opts)
end, { nargs = '?', complete = completions.toggle, bang = true, desc = 'Toggle Autoformat autocmd' })

local ok, _ = pcall(require, 'packer')
if ok then
    nvim.command.set('CreateSnapshot', function(opts)
        RELOAD('mappings').create_snapshot(opts)
    end, { nargs = '?', desc = 'Creates a packer snapshot with a standard format' })
end

nvim.command.set('Wall', function(opts)
    RELOAD('mappings').wall(opts)
end, { desc = 'Saves all visible windows' })

nvim.command.set('AlternateGrep', function()
    RELOAD('mappings').alternate_grep()
end, { nargs = 0, desc = 'Change between git grep and the best available alternative' })

if executable 'gradle' then
    nvim.command.set('Gradle', function(opts)
        RELOAD('mappings').gradle(opts)
    end, { nargs = '+', desc = 'Execute Gradle async' })
end

-- TODO: Add support for nvim < 0.8
if nvim.has { 0, 8 } then
    nvim.command.set('Alternate', function(opts)
        RELOAD('mappings').alternate(opts)
    end, { nargs = 0, desc = 'Alternate between files', bang = true })

    nvim.command.set('A', function(opts)
        RELOAD('mappings').alternate(opts)
    end, { nargs = 0, desc = 'Alternate between files', bang = true })

    nvim.command.set('AlternateTest', function(opts)
        RELOAD('mappings').alternate_test(opts)
    end, { nargs = 0, desc = 'Alternate between files', bang = true })

    nvim.command.set('T', function(opts)
        RELOAD('mappings').alternate_test(opts)
    end, { nargs = 0, desc = 'Alternate between files', bang = true })

    -- nvim.command.set('AltMakefile', function(opts)
    --     RELOAD('mappings').alt_makefiles(opts)
    -- end, { nargs = 0, desc = 'Open related makefile', bang = true })
end

nvim.command.set('NotificationServer', function(opts)
    opts.enable = opts.args == 'enable' or opts.args == ''
    RELOAD('servers.notifications').start_server(opts)
end, { nargs = 1, complete = completions.toggle, bang = true })

nvim.command.set('RemoveEmpty', function(opts)
    RELOAD('utils.buffers').remove_empty(opts)
end, { nargs = 0, bang = true, desc = 'Remove empty buffers' })

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

nvim.command.set('DiagnosticsDump', function(opts)
    local severity = vim.diagnostic.severity[opts.args]
    if severity then
        severity = { min = severity }
    end
    vim.diagnostic.setqflist { severity = severity }
    vim.cmd.wincmd 'J'
end, { nargs = '?', bang = true, desc = 'Filter Diagnostics in Qf', complete = completions.severity_list })

nvim.command.set('DiagnosticsClear', function(opts)
    local ns = RELOAD('utils.buffers').get_diagnostic_ns(opts.args)
    local buf = not opts.bang and vim.api.nvim_get_current_buf() or nil
    vim.diagnostic.reset(ns, buf)
end, {
    bang = true,
    nargs = '?',
    desc = 'Clear diagnostics from the given NS',
    complete = completions.diagnostics_namespaces,
})

nvim.command.set('DiagnosticsHide', function(opts)
    local ns = RELOAD('utils.buffers').get_diagnostic_ns(opts.args)
    local buf = not opts.bang and vim.api.nvim_get_current_buf() or nil
    vim.diagnostic.hide(ns, buf)
end, {
    bang = true,
    nargs = '?',
    desc = 'Hide diagnostics from the given NS',
    complete = completions.diagnostics_namespaces,
})

nvim.command.set('DiagnosticsShow', function(opts)
    local ns = RELOAD('utils.buffers').get_diagnostic_ns(opts.args)
    local buf = not opts.bang and vim.api.nvim_get_current_buf() or nil
    vim.diagnostic.show(ns, buf)
end, {
    bang = true,
    nargs = '?',
    desc = 'Show diagnostics from the given NS',
    complete = completions.diagnostics_namespaces,
})

nvim.command.set(
    'DiagnosticsToggle',
    function(opts)
        local ns = RELOAD('utils.buffers').get_diagnostic_ns(opts.args)
        RELOAD('mappings').toggle_diagnostics(ns, opts.bang)
    end,
    { bang = true, nargs = '?', desc = 'Toggle column sign diagnostics', complete = completions.diagnostics_namespaces }
)

if executable 'scp' then
    nvim.command.set('SCPEdit', function(opts)
        local args = {
            host = opts.fargs[1],
            filename = opts.fargs[2],
        }
        RELOAD('utils.functions').scp_edit(args)
    end, { nargs = '*', desc = 'Edit remote file using scp', complete = completions.ssh_hosts_completion })
end

vim.keymap.set('n', '=j', function(opts)
    RELOAD('mappings').show_background_jobs(opts)
end, noremap)

nvim.command.set('KillJob', function(opts)
    RELOAD('mappings').kill_job(opts)
end, { nargs = '?', bang = true, desc = 'Kill the selected job' })

vim.keymap.set('n', '=p', function()
    RELOAD('mappings').toggle_progress_win()
end, { noremap = true, silent = true, desc = 'Show progress of the selected job' })

nvim.command.set('Progress', function(opts)
    RELOAD('mappings').show_job_progress(opts)
end, { nargs = 1, desc = 'Show progress of the selected job', complete = completions.background_jobs })

nvim.command.set('CLevel', function(opts)
    opts.level = opts.args
    RELOAD('utils.qf').filter_qf_diagnostics(opts)
end, {
    nargs = 1,
    bang = true,
    desc = 'Filter the quickfix by diagnostcis level',
    complete = completions.diagnostics_level,
})

nvim.command.set('LLevel', function(opts)
    opts.win = vim.api.nvim_get_current_win()
    opts.level = opts.args
    RELOAD('utils.qf').filter_qf_diagnostics(opts)
end, {
    nargs = 1,
    bang = true,
    desc = 'Filter the location list by diagnostcis level',
    complete = completions.diagnostics_level,
})

if executable 'git' then
    nvim.command.set('OpenChanges', function(opts)
        RELOAD('utils.buffers').open_changes(opts)
    end, {
        bang = true,
        nargs = '*',
        complete = completions.qf_file_options,
        desc = 'Open all modified files in the current git repository',
    })
end

-- NOTE: This could be smarter and list the hunks in the QF
nvim.command.set('ModifiedDump', function(opts)
    RELOAD('utils.qf').dump_files(
        vim.tbl_filter(function(buf)
            return vim.bo[buf].modified
        end, vim.api.nvim_list_bufs()),
        { open = true }
    )
end, {
    desc = 'Dump all unsaved files into the QF',
})

nvim.command.set('ModifiedSave', function(opts)
    local modified = vim.tbl_filter(function(buf)
        return vim.bo[buf].modified
    end, vim.api.nvim_list_bufs())
    for _, buf in ipairs(modified) do
        vim.api.nvim_buf_call(buf, function()
            vim.cmd.update()
        end)
    end
end, {
    desc = 'Save all modified buffers',
})

nvim.command.set('Qf2Loc', function(opts)
    local qfutils = RELOAD 'utils.qf'
    qfutils.qf_loclist_switcher { loc = true }
end, { desc = "Move the current QF to the window's location list" })

nvim.command.set('Loc2Qf', function(opts)
    local qfutils = RELOAD 'utils.qf'
    qfutils.qf_loclist_switcher()
end, { desc = "Move the current window's location list to the QF" })

nvim.command.set('TrimWhites', function(opts)
    RELOAD('utils.files').trimwhites(nvim.get_current_buf(), { opts.line1 - 1, opts.line2 })
end, { range = '%', desc = 'Alias to <,>s/\\s\\+$//g' })

nvim.command.set('ParseSSHConfig', function(opts)
    local hosts = RELOAD('threads.parsers').sshconfig()
    for host, attrs in pairs(hosts) do
        STORAGE.hosts[host] = attrs
    end
end, { desc = 'Parse SSH config' })

nvim.command.set('VNC', function(opts)
    RELOAD('mappings').vnc(opts.args, { '-Quality=high' })
end, { complete = completions.ssh_hosts_completion, nargs = 1, desc = 'Open a VNC connection to the given host' })

vim.keymap.set('n', '<leader>c', function()
    local options = {
        filename = function(bufnr)
            return vim.fs.basename(nvim.buf.get_name(bufnr or 0))
        end,
        -- extension = true,
        filepath = function(bufnr)
            return require('utils.files').realpath(nvim.buf.get_name(bufnr or 0))
        end,
        dirname = function(bufnr)
            return vim.fs.dirname(nvim.buf.get_name(bufnr or 0))
        end,
        bufnr = function()
            return vim.api.nvim_get_current_buf()
        end,
    }

    vim.ui.select(vim.tbl_keys(options), {
        prompt = 'Select File/Buffer attribute: ',
    }, function(choice)
        if options[choice] then
            local bufnr = vim.api.nvim_get_current_buf()
            nvim.reg['+'] = options[choice](bufnr)
            vim.notify(choice .. ' copied', 'INFO')
        end
    end)
end, { noremap = true, desc = 'Copy different Buffer/File related stuff' })

if executable 'gh' then
    nvim.command.set('OpenPRFiles', function(opts)
        local action = opts.args:gsub('%-', '')
        RELOAD('utils.gh').get_pr_changes(opts, function(output)
            local files = output.files
            local revision = output.revision
            local cwd = vim.pesc(require('utils.files').getcwd()) .. '/'
            for _, f in ipairs(files) do
                -- NOTE: using badd since `:edit` load every buffer and `bufadd()` set buffers as hidden
                vim.cmd.badd((f:gsub('^' .. cwd, '')))
            end
            local qfutils = RELOAD 'utils.qf'
            if action == 'qf' then
                qfutils.dump_files(files, { open = true })
            elseif action == 'hunks' then
                RELOAD('threads').queue_thread(RELOAD('threads.git').get_hunks, function(hunks)
                    if next(hunks) ~= nil then
                        qfutils.set_list {
                            items = hunks.items,
                            title = 'OpenPRChanges',
                            open = not qfutils.is_open(),
                        }
                    end
                end, { revision = revision, files = files })
            elseif action == 'open' or action == '' then
                vim.api.nvim_win_set_buf(0, vim.fn.bufadd(files[1]))
            end
        end)
    end, {
        nargs = '?',
        complete = completions.qf_file_options,
        desc = 'Open all modified files in the current PR',
    })
end

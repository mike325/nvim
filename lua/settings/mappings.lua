local sys  = require('sys')
local nvim = require('nvim')

-- local api = nvim.api

local regex = require('tools').regex

-- local parent      = sys.data
-- local mkdir       = nvim.fn.mkdir
-- local isdirectory = nvim.isdirectory
local has        = nvim.has
local executable = nvim.executable
local plugins    = nvim.plugins

local mappings = {}

local noremap = {noremap = true}
local noremap_silent = {noremap = true, silent = true}

function mappings.terminal(cmd)
    -- local split = nvim.o.splitbelow == true and 'botright' or 'topleft'
    local is_empty = (cmd == nil or #cmd == 0) and true or false
    local shell

    if not is_empty then
        shell = cmd
    elseif sys.name == 'windows' then
        if regex("&shell", [[^cmd\(\.exe\)\?$]]) == 1 then
            shell = 'powershell -noexit -executionpolicy bypass '
        else
            shell = nvim.o.shell
        end
    else
        shell = nvim.fn.fnamemodify(nvim.env.SHELL or '', ':t')
        if regex( "'"..shell.."'", [[\(t\)\?csh]]) == 1 then
            shell = executable('zsh') and 'zsh' or (executable('bash') and 'bash' or shell)
        end
    end

    local win = require("floating").window()

    nvim.ex.edit('term://'..shell)

    nvim.win.set_option(win, 'number', false)
    nvim.win.set_option(win, 'relativenumber', false)

    if is_empty then
        nvim.ex.startinsert()
    end
end

function mappings.python(version, args)
    local py2 = nvim.g.python_host_prog
    local py3 = nvim.g.python3_host_prog

    local pyversion = version == 3 and py3 or py2

    if pyversion == nil or pyversion == '' then
        nvim.echoerr('Python'..pyversion..' is not available in the system')
        return -1
    end

    local split = nvim.o.splitbelow and 'botright' or 'topleft'

    nvim.command(split..' split term://'..pyversion..' '..args)
end

function mappings.trim()
    if nvim.b.trim == nil or nvim.b.trim == 0 then
        nvim.b.trim = 1
        nvim.ex.echomsg([['Trim']])
    else
        nvim.b.trim = 0
        nvim.ex.echomsg([['NoTrim']])
    end
    return 0
end

if nvim.g.mapleader == nil then
    nvim.g.mapleader = ' '
end

nvim.nvim_set_mapping('n', ',', ':', noremap)
nvim.nvim_set_mapping('x', ',', ':', noremap)

nvim.nvim_set_mapping('n', 'Y', 'y$', noremap)
nvim.nvim_set_mapping('x', '$', '$h', noremap)

nvim.nvim_set_mapping('n', 'Q', 'o<ESC>', noremap)

nvim.nvim_set_mapping('n', 'J', 'm`J``', noremap)

nvim.nvim_set_mapping('i', 'jj', '<ESC>')

nvim.nvim_set_mapping('n', '<BS>', ':call mappings#bs()<CR>', noremap_silent)
nvim.nvim_set_mapping('x', '<BS>', '<ESC>', noremap)

nvim.nvim_set_mapping('i', '<TAB>'  , [[<C-R>=mappings#tab()<CR>]]     , noremap_silent)
nvim.nvim_set_mapping('i', '<S-TAB>', [[<C-R>=mappings#shifttab()<CR>]], noremap_silent)
nvim.nvim_set_mapping('i', '<CR>'   , [[<C-R>=mappings#enter()<CR>]]   , noremap_silent)

-- TODO: Check for GUIs
if sys.name == 'windows' then
    nvim.nvim_set_mapping('n', '<C-h>', ':call mappings#bs()<CR>', noremap_silent)
    nvim.nvim_set_mapping('x', '<C-h>', ':<ESC>', noremap)
    nvim.nvim_set_mapping('n', '<C-z>', '<nop>', noremap)
end

if nvim.nvim_get_mapping('n', '<C-L>') == nil then
    nvim.nvim_set_mapping('n', '<C-L>', ':nohlsearch|diffupdate<CR>', noremap_silent)
end

nvim.nvim_set_mapping('i', '<C-U>', '<C-G>u<C-U>', noremap)


if not has('nvim-0.5') then
    nvim.nvim_set_mapping('n', '<C-w>o'    , ':diffoff!<BAR>only<CR>', noremap)
    nvim.nvim_set_mapping('n', '<C-w><C-o>', ':diffoff!<BAR>only<CR>', noremap)
end

nvim.nvim_set_mapping('n', '<S-tab>', '<C-o>', noremap)

nvim.nvim_set_mapping('x', '<', '<gv', noremap)
nvim.nvim_set_mapping('x', '>', '>gv', noremap)

nvim.nvim_set_mapping(
    'n',
    'j',
    [[v:count ? (v:count >= 3 ? "m'" . v:count : '') . 'j' : 'gj']],
    {noremap = true, expr = true}
)

nvim.nvim_set_mapping(
    'n',
    'k',
    [[v:count ? (v:count >= 3 ? "m'" . v:count : '') . 'k' : 'gk']],
    {noremap = true, expr = true}
)

nvim.nvim_set_mapping('n', '<leader><leader>e', ':echo expand("%")<CR>', noremap)
-- nvim.nvim_set_mapping('n', '<leader>c', ':pclose<CR>', noremap)

nvim.nvim_set_mapping('n', 'i', 'mappings#IndentWithI()', {noremap = true, expr = true})

nvim.nvim_set_mapping('n', 'c*', 'm`*``cgn', noremap)
nvim.nvim_set_mapping('n', 'c#', 'm`#``cgN', noremap)
nvim.nvim_set_mapping('n', 'cg*', 'm`g*``cgn', noremap)
nvim.nvim_set_mapping('n', 'cg#', 'm`#``cgN', noremap)
nvim.nvim_set_mapping('x', 'c', [["cy/<C-r>c<CR>Ncgn]], noremap)

nvim.nvim_set_mapping('n', '¿', '`', noremap)
nvim.nvim_set_mapping('x', '¿', '`', noremap)
nvim.nvim_set_mapping('n', '¿¿', '``', noremap)
nvim.nvim_set_mapping('x', '¿¿', '``', noremap)

nvim.nvim_set_mapping('n', '¡', '^', noremap)
nvim.nvim_set_mapping('x', '¡', '^', noremap)

nvim.nvim_set_mapping('n', '<leader>p', '<C-^>', noremap)
-- nvim.nvim_set_mapping('n', '<leader>w', ':update<CR>', noremap)
nvim.nvim_set_mapping('n', '<leader>q', ':q!<CR>', noremap_silent)
nvim.nvim_set_mapping('n', '<leader>x', ':%!xxd<CR>', noremap)

nvim.nvim_set_mapping('n', '<leader>h', '<C-w>h', noremap)
nvim.nvim_set_mapping('n', '<leader>j', '<C-w>j', noremap)
nvim.nvim_set_mapping('n', '<leader>k', '<C-w>k', noremap)
nvim.nvim_set_mapping('n', '<leader>l', '<C-w>l', noremap)
nvim.nvim_set_mapping('n', '<leader>b', '<C-w>b', noremap)
nvim.nvim_set_mapping('n', '<leader>t', '<C-w>t', noremap)

nvim.nvim_set_mapping('n', '<leader>e', '<C-w>=', noremap)

nvim.nvim_set_mapping('n', '<leader>1', '1gt', noremap)
nvim.nvim_set_mapping('n', '<leader>2', '2gt', noremap)
nvim.nvim_set_mapping('n', '<leader>3', '3gt', noremap)
nvim.nvim_set_mapping('n', '<leader>4', '4gt', noremap)
nvim.nvim_set_mapping('n', '<leader>5', '5gt', noremap)
nvim.nvim_set_mapping('n', '<leader>6', '6gt', noremap)
nvim.nvim_set_mapping('n', '<leader>7', '7gt', noremap)
nvim.nvim_set_mapping('n', '<leader>8', '8gt', noremap)
nvim.nvim_set_mapping('n', '<leader>9', '9gt', noremap)
nvim.nvim_set_mapping('n', '<leader>0', ':tablast<CR>', noremap)
nvim.nvim_set_mapping('n', '<leader><leader>n', ':tabnew<CR>', noremap)

nvim.nvim_set_mapping('x', '<leader>1', '<ESC>1gt', noremap)
nvim.nvim_set_mapping('x', '<leader>2', '<ESC>2gt', noremap)
nvim.nvim_set_mapping('x', '<leader>3', '<ESC>3gt', noremap)
nvim.nvim_set_mapping('x', '<leader>4', '<ESC>4gt', noremap)
nvim.nvim_set_mapping('x', '<leader>5', '<ESC>5gt', noremap)
nvim.nvim_set_mapping('x', '<leader>6', '<ESC>6gt', noremap)
nvim.nvim_set_mapping('x', '<leader>7', '<ESC>7gt', noremap)
nvim.nvim_set_mapping('x', '<leader>8', '<ESC>8gt', noremap)
nvim.nvim_set_mapping('x', '<leader>9', '<ESC>9gt', noremap)
nvim.nvim_set_mapping('x', '<leader>0', '<ESC>:tablast<CR>', noremap)

-- Fucking Typos
nvim.nvim_set_abbr('c', 'Gti', 'Git', noremap)
nvim.nvim_set_abbr('c', 'W'  , 'w', noremap)
nvim.nvim_set_abbr('c', 'Q'  , 'q', noremap)
nvim.nvim_set_abbr('c', 'q1' , 'q!', noremap)
nvim.nvim_set_abbr('c', 'qa1', 'qa!', noremap)
nvim.nvim_set_abbr('c', 'w1' , 'w!', noremap)
nvim.nvim_set_abbr('c', 'wA!', 'wa!', noremap)
nvim.nvim_set_abbr('c', 'wa1', 'wa!', noremap)

nvim.nvim_set_mapping('c', '<C-n>', '<down>', noremap)
nvim.nvim_set_mapping('c', '<C-p>', '<up>', noremap)
nvim.nvim_set_mapping('c', '<C-r><C-w>', "<C-r>=escape(expand('<cword>'), '#')<CR>", noremap)

nvim.nvim_set_mapping('n', '&', ':&&<CR>', noremap)
nvim.nvim_set_mapping('x', '&', ':&&<CR>', noremap)

nvim.nvim_set_mapping('n', '/', 'ms/', noremap)
nvim.nvim_set_mapping('n', 'g/', 'ms/\\v', noremap)
nvim.nvim_set_mapping('n', '0', '^', noremap)
nvim.nvim_set_mapping('n', '^', '0', noremap)

nvim.nvim_set_mapping('n', 'gV', '`[v`]', noremap)

nvim.nvim_set_mapping('t', '<ESC>', '<C-\\><C-n>', noremap)

nvim.nvim_set_mapping('n', '<A-s>', '<C-w>s', noremap)
nvim.nvim_set_mapping('n', '<A-v>', '<C-w>v', noremap)

nvim.nvim_set_command(
    'Terminal',
    [[lua require'settings/mappings'.terminal(<q-args>)]],
    {nargs='?', force=true}
)

nvim.nvim_set_command('PowershellToggle'      , 'call windows#toggle_powershell()', {force=true})
nvim.nvim_set_command('RelativeNumbersToggle' , 'set relativenumber! relativenumber?', {force=true})
nvim.nvim_set_command('MouseToggle'           , 'call mappings#ToggleMouse()', {force=true})
nvim.nvim_set_command('ArrowsToggle'          , 'call mappings#ToggleArrows()', {force=true})
nvim.nvim_set_command('BufKill'               , 'call mappings#BufKill(<bang>0)'  , {bang = true, force = true})
nvim.nvim_set_command('BufClean'              , 'call mappings#BufClean(<bang>0)' , {bang = true, force = true})
nvim.nvim_set_command('ModifiableToggle'      , 'setlocal modifiable! modifiable?', {force=true})
nvim.nvim_set_command('CursorLineToggle'      , 'setlocal cursorline! cursorline?', {force=true})
nvim.nvim_set_command('ScrollBindToggle'      , 'setlocal scrollbind! scrollbind?', {force=true})
nvim.nvim_set_command('HlSearchToggle'        , 'setlocal hlsearch! hlsearch?', {force=true})
nvim.nvim_set_command('NumbersToggle'         , 'setlocal number! number?', {force=true})
nvim.nvim_set_command('PasteToggle'           , 'setlocal paste! paste?', {force=true})
nvim.nvim_set_command('SpellToggle'           , 'setlocal spell! spell?', {force=true})
nvim.nvim_set_command('WrapToggle'            , 'setlocal wrap! wrap?', {force=true})
nvim.nvim_set_command('VerboseToggle'         , 'let &verbose=!&verbose | echo "Verbose " . &verbose', {force=true})
nvim.nvim_set_command('TrimToggle'            , [[lua require"settings/mappings".trim()]], {force=true})
nvim.nvim_set_command('GonvimSettngs', "execute('edit ~/.gonvim/setting.toml')", {nargs='*', force = true})
nvim.nvim_set_command(
    'FileType',
    "call mappings#SetFileData('filetype', <q-args>, 'text')",
    {nargs='?', complete='filetype', force = true}
)
nvim.nvim_set_command(
    'FileFormat',
    "call mappings#SetFileData('fileformat', <q-args>, 'unix')",
    {nargs='?', complete='customlist,mappings#format', force = true}
)

nvim.nvim_set_command(
    'SpellLang',
    'lua require"tools".spelllangs(<q-args>)',
    {force = true, nargs = '?', complete = 'customlist,mappings#spells'}
)

nvim.nvim_set_command('ConncallLevel',  "call mappings#ConncallLevel(expand(<q-args>))", {nargs='?', force = true})
nvim.nvim_set_command(
    'Qopen',
    "execute((&splitbelow) ? 'botright' : 'topleft' ) . ' copen ' . expand(<q-args>)",
    {nargs='?', force = true}
)

nvim.nvim_set_mapping(
    'n',
    '=l',
    [[:call v:lua.tools.helpers.toggle_qf('loc')<CR>]],
    noremap_silent
)

nvim.nvim_set_mapping(
    'n',
    '=q',
    [[:call v:lua.tools.helpers.toggle_qf('qf')<CR>]],
    noremap_silent
)

nvim.nvim_set_mapping(
    'n',
    '<leader><leader>p',
    [[:<C-U>lua <<EOF
    local nvim = require'nvim'
    if nvim.t.swap_window == nil then
        nvim.t.swap_window   = 1
        nvim.t.swap_cursor   = nvim.win.get_cursor(0)
        nvim.t.swap_base_tab = nvim.tab.get_number(0)
        nvim.t.swap_base_win = nvim.tab.get_win(0)
        nvim.t.swap_base_buf = nvim.win.get_buf(0)
    else
        local swap_new_tab = nvim.tab.get_number(0)
        local swap_new_win = nvim.tab.get_win(0)
        local swap_new_buf = nvim.win.get_buf(0)
        if swap_new_tab == nvim.t.swap_base_tab and
           swap_new_win ~= nvim.t.swap_base_win and
           swap_new_buf ~= nvim.t.swap_base_buf
           then
               nvim.win.set_buf(0, nvim.t.swap_base_buf)
               nvim.win.set_buf(nvim.t.swap_base_win, swap_new_buf)
               nvim.win.set_cursor(0, nvim.t.swap_cursor)
               nvim.ex['normal!']('zz')
        end
        nvim.t.swap_window   = nil
        nvim.t.swap_cursor   = nil
        nvim.t.swap_base_tab = nil
        nvim.t.swap_base_win = nil
        nvim.t.swap_base_buf = nil
    end
EOF<CR>]],
    noremap_silent
)

if executable('svn') then
    nvim.nvim_set_command('SVNstatus', "execute('!svn status ' . <q-args>)", {nargs='*', force = true})
    nvim.nvim_set_command('SVN'      , "execute('!svn ' . <q-args>)"       , {complete='file', nargs='+', force = true})
    nvim.nvim_set_command('SVNupdate', "execute('!svn update ' . <q-args>)", {complete='file', nargs='*', force = true})
    -- command! -complete=file -bang SVNread execute('!svn revert ' . expand("%")) |
    --             \ let s:bang = empty(<bang>0) ? '' : '!' |
    --             \ execute('edit'.s:bang) |
    --             \ unlet s:bang
end

if plugins["iron.nvim"] == nil and (has('python') or has('python3'))then
    nvim.nvim_set_command(
        'Python',
        [[lua require'settings/mappings'.python(2, <q-args>)]],
        {complete='file', nargs='*', force = true}
    )
    nvim.nvim_set_command(
        'Python',
        [[lua require'settings/mappings'.python(3, <q-args>)]],
        {complete='file', nargs='*', force = true}
    )
    nvim.nvim_set_command(
        'Python3',
        [[lua require'settings/mappings'.python(3, <q-args>)]],
        {complete='file', nargs='*', force = true}
    )
end

if plugins["vim-bbye"] == nil then
    nvim.nvim_set_mapping('n', '<leader>d', ':bdelete!<CR>')
end

if plugins["vim-indexed-search"] == nil then
    -- nvim.nvim_set_mapping('n', '*', '*zz')
    -- nvim.nvim_set_mapping('n', '#', '#zz')
    nvim.nvim_set_mapping('n', 'n', ":call mappings#NiceNext('n')<cr>", noremap_silent)
    nvim.nvim_set_mapping('n', 'N', ":call mappings#NiceNext('N')<cr>", noremap_silent)
end

if plugins["vim-unimpaired"] == nil then
    nvim.nvim_set_mapping('n', '[Q', ':<C-U>exe "".(v:count ? v:count : "")."cfirst"<CR>zvzz'   , noremap_silent)
    nvim.nvim_set_mapping('n', ']Q', ':<C-U>exe "".(v:count ? v:count : "")."clast"<CR>zvzz'    , noremap_silent)
    nvim.nvim_set_mapping('n', '[q', ':<C-U>exe "".(v:count ? v:count : "")."cprevious"<CR>zvzz', noremap_silent)
    nvim.nvim_set_mapping('n', ']q', ':<C-U>exe "".(v:count ? v:count : "")."cnext"<CR>zvzz'    , noremap_silent)

    nvim.nvim_set_mapping('n', '[L', ':<C-U>exe "".(v:count ? v:count : "")."lfirst"<CR>zvzz'   , noremap_silent)
    nvim.nvim_set_mapping('n', ']L', ':<C-U>exe "".(v:count ? v:count : "")."llast"<CR>zvzz'    , noremap_silent)
    nvim.nvim_set_mapping('n', '[l', ':<C-U>exe "".(v:count ? v:count : "")."lprevious"<CR>zvzz', noremap_silent)
    nvim.nvim_set_mapping('n', ']l', ':<C-U>exe "".(v:count ? v:count : "")."lnext"<CR>zvzz'    , noremap_silent)

    nvim.nvim_set_mapping('n', '[B', ':<C-U>exe "".(v:count ? v:count : "")."bfirst"<CR>'   , noremap_silent)
    nvim.nvim_set_mapping('n', ']B', ':<C-U>exe "".(v:count ? v:count : "")."blast"<CR>'    , noremap_silent)
    nvim.nvim_set_mapping('n', '[b', ':<C-U>exe "".(v:count ? v:count : "")."bprevious"<CR>', noremap_silent)
    nvim.nvim_set_mapping('n', ']b', ':<C-U>exe "".(v:count ? v:count : "")."bnext"<CR>'    , noremap_silent)

    require('tools.helpers')

    nvim.nvim_set_mapping(
        'n',
        ']<Space>',
        [[:<C-U>call v:lua.tools.helpers.add_nl(v:true)<CR>]],
        noremap_silent
    )

    nvim.nvim_set_mapping(
        'n',
        '[<Space>',
        [[:<C-U>call v:lua.tools.helpers.add_nl(v:false)<CR>]],
        noremap_silent
    )

end

if plugins["vim-vinegar"] == nil and plugins["nerdtree"] == nil then
    nvim.nvim_set_mapping('n', '-', ':Explore<CR>')
end

if plugins["vim-eunuch"] == nil and nvim.has('nvim-0.5') then

    require'tools.helpers'

    -- TODO: Make this work with embedded lua
    nvim.nvim_set_command(
        'Move',
        [[call v:lua.tools.helpers.rename(expand('%:p'), expand(<q-args>), empty(<bang>0) ? 0 : 1)]],
        {force = true, bang = true, nargs = 1, complete = 'file'}
    )

    nvim.nvim_set_command(
        'Rename',
        [[call v:lua.tools.helpers.rename(expand('%:p'), expand('%:p:h').'/'.expand(<q-args>), empty(<bang>0) ? 0 : 1)]],
        {force = true, bang = true, nargs = 1, complete = 'file'}
    )

    nvim.nvim_set_command(
        'Mkdir',
        [[call mkdir(fnameescape(expand(<q-args>)), 'p')]],
        {force = true, bang = true, nargs = 1, complete = 'dir'}
    )

    nvim.nvim_set_command(
        'Remove',
        [[call v:lua.tools.helpers.delete(fnamemodify(empty(<q-args>) ? expand("%") : expand(<q-args>), ":p"), empty(<bang>0) ? 0 : 1)]],
        {force = true, bang = true, nargs = '?', complete = 'file'}
    )

end

-- if plugins["vim-fugitive"] == nil and executable('git') then
--     -- TODO
-- end

return mappings

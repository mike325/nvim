-- luacheck: globals unpack vim
local api = vim.api

local sys  = require('sys')
local nvim = require('nvim')
local plugs = require('nvim').plugs

-- local parent      = require('sys').data
local has         = require('nvim').fn.has
-- local mkdir       = require('nvim').fn.mkdir
-- local isdirectory = require('nvim').fn.isdirectory
local executable  = require('nvim').fn.executable

nvim.nvim_set_mapping('n', ',', ':', {noremap = true})
nvim.nvim_set_mapping('x', ',', ':', {noremap = true})

nvim.nvim_set_mapping('n', 'Y', 'y$', {noremap = true})
nvim.nvim_set_mapping('x', '$', '$h', {noremap = true})

nvim.nvim_set_mapping('n', 'Q', 'o<ESC>', {noremap = true})

nvim.nvim_set_mapping('n', 'J', 'm`J``', {noremap = true})

nvim.nvim_set_mapping('i', 'jj', '<ESC>')

nvim.nvim_set_mapping('n', '<BS>', ':call mappings#bs()<CR>', {noremap = true, silent = true})
nvim.nvim_set_mapping('x', '<BS>', '<ESC>', {noremap = true})

-- TODO: Check for GUIs
if sys.name == 'windows' then
    nvim.nvim_set_mapping('n', '<C-h>', ':call mappings#bs()<CR>', {noremap = true, silent = true})
    nvim.nvim_set_mapping('x', '<C-h>', ':<ESC>', {noremap = true})
    nvim.nvim_set_mapping('n', '<C-z>', '<nop>', {noremap = true})
end

if nvim.nvim_get_mapping('n', '<C-L>') == nil then
    nvim.nvim_set_mapping('n', '<C-L>', ':nohlsearch|diffupdate<CR>', {noremap = true, silent = true})
end

nvim.nvim_set_mapping('i', '<C-U>', '<C-G>u<C-U>', {noremap = true})

nvim.nvim_set_mapping('n', '<C-w>o'    , ':diffoff!<BAR>only<CR>', {noremap = true, silent = true})
nvim.nvim_set_mapping('n', '<C-w><C-o>', ':diffoff!<BAR>only<CR>', {noremap = true, silent = true})

nvim.nvim_set_mapping('n', '<S-tab>', '<C-o>', {noremap = true})

nvim.nvim_set_mapping('x', '<', '<gv', {noremap = true})
nvim.nvim_set_mapping('x', '>', '>gv', {noremap = true})

nvim.nvim_set_mapping(
    'n',
    'j',
    [[v:count ? (v:count >= 3 ? "m'" . v:count : '') . 'j' : 'gj']],
    {noremap = true, silent = true, expr = true}
)

nvim.nvim_set_mapping(
    'n',
    'k',
    [[v:count ? (v:count >= 3 ? "m'" . v:count : '') . 'k' : 'gk']],
    {noremap = true, silent = true, expr = true}
)

nvim.nvim_set_mapping('n', '<leader><leader>e', ':echo expand("%")<CR>', {noremap = true})
nvim.nvim_set_mapping('n', '<leader>c', ':pclose<CR>', {noremap = true})

nvim.nvim_set_mapping('n', 'i', 'mappings#IndentWithI()', {noremap = true, expr = true})

nvim.nvim_set_mapping('n', 'c*', '*Ncgn', {noremap = true})
nvim.nvim_set_mapping('n', 'c#', '#NcgN', {noremap = true})
nvim.nvim_set_mapping('n', 'cg*', 'g*Ncgn', {noremap = true})
nvim.nvim_set_mapping('n', 'cg#', 'g#NcgN', {noremap = true})
nvim.nvim_set_mapping('x', 'c', '"cy/<C-r>c<CR>Ncgn', {noremap = true, silent = true})

nvim.nvim_set_mapping('n', '¿', '`', {noremap = true})
nvim.nvim_set_mapping('x', '¿', '`', {noremap = true})
nvim.nvim_set_mapping('n', '¿¿', '``', {noremap = true})
nvim.nvim_set_mapping('x', '¿¿', '``', {noremap = true})

nvim.nvim_set_mapping('n', '¡', '^', {noremap = true})
nvim.nvim_set_mapping('x', '¡', '^', {noremap = true})

nvim.nvim_set_mapping('n', '<leader>p', '<C-^>', {noremap = true})
nvim.nvim_set_mapping('n', '<leader>w', ':update<CR>', {noremap = true})
nvim.nvim_set_mapping('n', '<leader>q', ':q!<CR>', {noremap = true})
nvim.nvim_set_mapping('n', '<leader>x', ':%!xxd<CR>', {noremap = true})

nvim.nvim_set_mapping('n', '<leader>h', '<C-w>h', {noremap = true})
nvim.nvim_set_mapping('n', '<leader>j', '<C-w>j', {noremap = true})
nvim.nvim_set_mapping('n', '<leader>k', '<C-w>k', {noremap = true})
nvim.nvim_set_mapping('n', '<leader>l', '<C-w>l', {noremap = true})

nvim.nvim_set_mapping('n', '<leader>e', '<C-w>=', {noremap = true})

nvim.nvim_set_mapping('n', '<leader>1', '1gt', {noremap = true})
nvim.nvim_set_mapping('n', '<leader>2', '2gt', {noremap = true})
nvim.nvim_set_mapping('n', '<leader>3', '3gt', {noremap = true})
nvim.nvim_set_mapping('n', '<leader>4', '4gt', {noremap = true})
nvim.nvim_set_mapping('n', '<leader>5', '5gt', {noremap = true})
nvim.nvim_set_mapping('n', '<leader>6', '6gt', {noremap = true})
nvim.nvim_set_mapping('n', '<leader>7', '7gt', {noremap = true})
nvim.nvim_set_mapping('n', '<leader>8', '8gt', {noremap = true})
nvim.nvim_set_mapping('n', '<leader>9', '9gt', {noremap = true})
nvim.nvim_set_mapping('n', '<leader>0', ':tablast<CR>', {noremap = true})
nvim.nvim_set_mapping('n', '<leader><leader>n', ':tabnew<CR>', {noremap = true})

nvim.nvim_set_mapping('x', '<leader>1', '<ESC>1gt', {noremap = true})
nvim.nvim_set_mapping('x', '<leader>2', '<ESC>2gt', {noremap = true})
nvim.nvim_set_mapping('x', '<leader>3', '<ESC>3gt', {noremap = true})
nvim.nvim_set_mapping('x', '<leader>4', '<ESC>4gt', {noremap = true})
nvim.nvim_set_mapping('x', '<leader>5', '<ESC>5gt', {noremap = true})
nvim.nvim_set_mapping('x', '<leader>6', '<ESC>6gt', {noremap = true})
nvim.nvim_set_mapping('x', '<leader>7', '<ESC>7gt', {noremap = true})
nvim.nvim_set_mapping('x', '<leader>8', '<ESC>8gt', {noremap = true})
nvim.nvim_set_mapping('x', '<leader>9', '<ESC>9gt', {noremap = true})
nvim.nvim_set_mapping('x', '<leader>0', '<ESC>:tablast<CR>', {noremap = true})

-- Fucking Typos
nvim.nvim_set_abbr('c', 'Gti', 'Git', {noremap = true})
nvim.nvim_set_abbr('c', 'W'  , 'w', {noremap = true})
nvim.nvim_set_abbr('c', 'Q'  , 'q', {noremap = true})
nvim.nvim_set_abbr('c', 'q1' , 'q!', {noremap = true})
nvim.nvim_set_abbr('c', 'qa1', 'qa!', {noremap = true})
nvim.nvim_set_abbr('c', 'w1' , 'w!', {noremap = true})
nvim.nvim_set_abbr('c', 'wA!', 'wa!', {noremap = true})
nvim.nvim_set_abbr('c', 'wa1', 'wa!', {noremap = true})

nvim.nvim_set_mapping('c', '<C-n>', '<down>', {noremap = true})
nvim.nvim_set_mapping('c', '<C-p>', '<up>', {noremap = true})
nvim.nvim_set_mapping('c', '<C-r><C-w>', "<C-r>=escape(expand('<cword>'), '#')<CR>", {noremap = true})

nvim.nvim_set_mapping('n', '&', ':&&<CR>', {noremap = true})
nvim.nvim_set_mapping('x', '&', ':&&<CR>', {noremap = true})

nvim.nvim_set_mapping('n', '/', 'ms/', {noremap = true})
nvim.nvim_set_mapping('n', 'g/', 'ms/\\v', {noremap = true})
nvim.nvim_set_mapping('n', '0', '^', {noremap = true})
nvim.nvim_set_mapping('n', '^', '0', {noremap = true})

nvim.nvim_set_mapping('n', 'gV', '`[v`]', {noremap = true})

nvim.nvim_set_mapping('t', '<ESC>', '<C-\\><C-n>', {noremap = true})

nvim.nvim_set_mapping('n', '<A-s>', '<C-w>s', {noremap = true})
nvim.nvim_set_mapping('n', '<A-v>', '<C-w>v', {noremap = true})

nvim.nvim_set_command('Terminal'              , 'call mappings#terminal(<q-args>)', {nargs='?', force=true})
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
nvim.nvim_set_command('TrimToggle'            , 'call mappings#Trim()', {force=true})
nvim.nvim_set_command('GonvimSettngs', "execute('edit ~/.gonvim/setting.toml')", {nargs='*'}, {force=true})
nvim.nvim_set_command('FileType'     , "call mappings#SetFileData('filetype', <q-args>, 'text')", {nargs='?', complete='filetype', force = true})
nvim.nvim_set_command('FileFormat'   , "call mappings#SetFileData('fileformat', <q-args>, 'unix')", {nargs='?', complete='customlist,mappings#format', force = true})

nvim.nvim_set_command(
    'SpellLang',
    'lua require"tools".spelllangs(<q-args>)',
    {force = true, nargs = '?', complete = 'customlist,mappings#spells'}
)

nvim.nvim_set_command('ConncallLevel',  "call mappings#ConncallLevel(expand(<q-args>))", {nargs='?', force = true})
nvim.nvim_set_command('Qopen', "execute((&splitbelow) ? 'botright' : 'topleft' ) . ' copen ' . expand(<q-args>)", {nargs='?', force = true})

if executable('svn') == 1 then
    nvim.nvim_set_command('SVNstatus', "execute('!svn status ' . <q-args>)", {nargs='*', force = true})
    nvim.nvim_set_command('SVN'      , "execute('!svn ' . <q-args>)"       , {complete='file', nargs='+', force = true})
    nvim.nvim_set_command('SVNupdate', "execute('!svn update ' . <q-args>)", {complete='file', nargs='*', force = true})
    -- command! -complete=file -bang SVNread execute('!svn revert ' . expand("%")) |
    --             \ let s:bang = empty(<bang>0) ? '' : '!' |
    --             \ execute('edit'.s:bang) |
    --             \ unlet s:bang
end

if plugs["denite.nvim"] == nil and plugs["fzf.vim"] == nil then
    -- nvim.nvim_set_command('Oldfiles', 'edit <args>', {nargs=1, complete='customlist,tools#oldfiles', force = true})
end

if plugs["iron.nvim"] == nil and (has('python') == 1 or has('python3') == 1)then
    nvim.nvim_set_command('Python' , 'call mappings#Python(2, <q-args>)', {complete='file', nargs='*', force = true})
    nvim.nvim_set_command('Python3', 'call mappings#Python(3, <q-args>)', {complete='file', nargs='*', force = true})
end

if plugs["ultisnips"] == nil and plugs["vim-snipmate"] == nil then
    nvim.nvim_set_mapping('i', '<TAB>', [[pumvisible() ? "\<C-n>" : "\<TAB>"]], {noremap = true, expr = true})
    nvim.nvim_set_mapping('i', '<S-TAB>', [[pumvisible() ? "\<C-p>" : ""]], {noremap = true, expr = true})
    nvim.nvim_set_mapping('i', '<CR>', '<C-R>=mappings#NextSnippetOrReturn()<CR>', {noremap = true, silent = true})
end

if plugs["vim-bbye"] == nil then
    nvim.nvim_set_mapping('n', '<leader>d', ':bdelete!<CR>')
end

if plugs["vim-indexed-search"] == nil then
    -- nvim.nvim_set_mapping('n', '*', '*zz')
    -- nvim.nvim_set_mapping('n', '#', '#zz')
    nvim.nvim_set_mapping('n', 'n', ":call mappings#NiceNext('n')<cr>", {noremap = true})
    nvim.nvim_set_mapping('n', 'N', ":call mappings#NiceNext('N')<cr>", {noremap = true})
end

if plugs["vim-unimpaired"] == nil then
    nvim.nvim_set_mapping('n', '[Q', ':<C-U>exe "".(v:count ? v:count : "")."cfirst"<CR>zvzz'   , {noremap = true})
    nvim.nvim_set_mapping('n', ']Q', ':<C-U>exe "".(v:count ? v:count : "")."clast"<CR>zvzz'    , {noremap = true})
    nvim.nvim_set_mapping('n', '[q', ':<C-U>exe "".(v:count ? v:count : "")."cprevious"<CR>zvzz', {noremap = true})
    nvim.nvim_set_mapping('n', ']q', ':<C-U>exe "".(v:count ? v:count : "")."cnext"<CR>zvzz'    , {noremap = true})

    nvim.nvim_set_mapping('n', '[L', ':<C-U>exe "".(v:count ? v:count : "")."lfirst"<CR>zvzz'   , {noremap = true})
    nvim.nvim_set_mapping('n', ']L', ':<C-U>exe "".(v:count ? v:count : "")."llast"<CR>zvzz'    , {noremap = true})
    nvim.nvim_set_mapping('n', '[l', ':<C-U>exe "".(v:count ? v:count : "")."lprevious"<CR>zvzz', {noremap = true})
    nvim.nvim_set_mapping('n', ']l', ':<C-U>exe "".(v:count ? v:count : "")."lnext"<CR>zvzz'    , {noremap = true})

    nvim.nvim_set_mapping('n', '[B', ':<C-U>exe "".(v:count ? v:count : "")."bfirst"<CR>'   , {noremap = true})
    nvim.nvim_set_mapping('n', ']B', ':<C-U>exe "".(v:count ? v:count : "")."blast"<CR>'    , {noremap = true})
    nvim.nvim_set_mapping('n', '[b', ':<C-U>exe "".(v:count ? v:count : "")."bprevious"<CR>', {noremap = true})
    nvim.nvim_set_mapping('n', ']b', ':<C-U>exe "".(v:count ? v:count : "")."bnext"<CR>'    , {noremap = true})
end

if plugs["vim-vinegar"] == nil and plugs["nerdtree"] == nil then
    nvim.nvim_set_mapping('n', '-', ':Explore<CR>')
end

if plugs["vim-eunuch"] == nil then

    -- command! -bang -nargs=1 -complete=file Move
    --             \ let s:name = expand(<q-args>) |
    --             \ let s:current = expand('%:p') |
    --             \ if (rename(s:current, s:name)) |
    --             \   execute 'edit ' . s:name |
    --             \   execute 'bwipeout! '.s:current |
    --             \ endif |
    --             \ unlet s:name |
    --             \ unlet s:current

    -- command! -bang -nargs=1 -complete=file Rename
    --             \ let s:name = expand('%:p:h') . '/' . expand(<q-args>) |
    --             \ let s:current = expand('%:p') |
    --             \ if (rename(s:current, s:name)) |
    --             \   execute 'edit ' . s:name |
    --             \   execute 'bwipeout! '.s:current |
    --             \ endif |
    --             \ unlet s:name |
    --             \ unlet s:current

    -- command! -bang -nargs=1 -complete=dir Mkdir
    --             \ let s:bang = empty(<bang>0) ? 0 : 1 |
    --             \ let s:dir = expand(<q-args>) |
    --             \ if exists('*mkdir') |
    --             \   call mkdir(fnameescape(s:dir), (s:bang) ? "p" : "") |
    --             \ else |
    --             \   echoerr "Failed to create dir '" . s:dir . "' mkdir is not available" |
    --             \ endif |
    --             \ unlet s:bang |
    --             \ unlet s:dir

    -- command! -bang -nargs=? -complete=file Remove
    --             \ let s:bang = empty(<bang>0) ? 0 : 1 |
    --             \ let s:target = fnamemodify(empty(<q-args>) ? expand("%") : expand(<q-args>), ":p") |
    --             \ if filereadable(s:target) || bufloaded(s:target) |
    --             \   if filereadable(s:target) |
    --             \       if delete(s:target) == -1 |
    --             \           echoerr "Failed to delete the file '" . s:target . "'" |
    --             \       endif |
    --             \   endif |
    --             \   if bufloaded(s:target) |
    --             \       let s:cmd = (s:bang) ? "bwipeout! " : "bdelete! " |
    --             \       try |
    --             \           execute s:cmd . s:target |
    --             \       catch /E94/ |
    --             \           echoerr "Failed to delete/wipe '" . s:target . "'" |
    --             \       finally |
    --             \           unlet s:cmd |
    --             \       endtry |
    --             \   endif |
    --             \ elseif isdirectory(s:target) |
    --             \   let s:flag = (s:bang) ? "rf" : "d" |
    --             \   if delete(s:target, s:flag) == -1 |
    --             \       echoerr "Failed to remove '" . s:target . "'" |
    --             \   endif |
    --             \   unlet s:flag |
    --             \ else |
    --             \   echoerr "Failed to remove '" . s:target . "'" |
    --             \ endif |
    --             \ unlet s:bang |
    --             \ unlet s:target

end

if plugs["vim-fugitive"] == nil and executable('git') == 1 then
    -- command! -nargs=+ Git execute(((&splitbelow) ? 'botright' : 'topleft' ) . ' 20split term://git ' . <q-args>)
    -- command! -nargs=* Gstatus execute(((&splitbelow) ? 'botright' : 'topleft' ) . ' 20split term://git status ' . <q-args>)
    -- command! -nargs=* Gcommit execute(((&splitbelow) ? 'botright' : 'topleft' ) . ' 20split term://git commit ' . <q-args>)
    -- command! -nargs=* Gpush  execute(((&splitbelow) ? 'botright' : 'topleft' ) . ' 20split term://git push ' .<q-args>)
    -- command! -nargs=* Gpull  execute('!git pull ' .<q-args>)
    -- command! -nargs=* Gwrite  execute('!git add ' . expand("%") . ' ' .<q-args>)
    -- command! -bang Gread execute('!git reset HEAD ' . expand("%") . ' && git checkout -- ' . expand("%")) |
    --             \ let s:bang = empty(<bang>0) ? '' : '!' |
    --             \ execute('edit'.s:bang) |
    --             \ unlet s:bang

    -- nvim.nvim_set_mapping('n', '<leader>gw', ':Gwrite<CR>')
    -- nvim.nvim_set_mapping('n', '<leader>gs', ':Gstatus<CR>')
    -- nvim.nvim_set_mapping('n', '<leader>gc', ':Gcommit<CR>')
    -- nvim.nvim_set_mapping('n', '<leader>gr', ':Gread<CR>')
end

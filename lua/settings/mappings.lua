-- luacheck: max line length 150
local sys  = require('sys')
local nvim = require('nvim')

-- local api = nvim.api

-- local regex = require('tools').regex
local iregex = require('tools').regex

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
        if iregex(nvim.o.shell, [[^cmd\(\.exe\)\?$]]) then
            shell = 'powershell -noexit -executionpolicy bypass '
        else
            shell = nvim.o.shell
        end
    else
        shell = nvim.fn.fnamemodify(nvim.env.SHELL or '', ':t')
        if iregex(shell, [[\(t\)\?csh]]) then
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
    if not nvim.b.trim then
        print('Trim')
    else
        print('NoTrim')
    end
    nvim.b.trim = not nvim.b.trim
end

if nvim.g.mapleader == nil then
    nvim.g.mapleader = ' '
end

nvim.nvim_set_mapping{ mode = 'n', lhs = ',',    rhs = ':',  args = noremap }
nvim.nvim_set_mapping{ mode = 'x', lhs = ',',    rhs = ':',  args = noremap }
nvim.nvim_set_mapping{ mode = 'n', lhs = 'Y',    rhs = 'y$', args = noremap }
nvim.nvim_set_mapping{ mode = 'x', lhs = '$',    rhs = '$h', args = noremap }
nvim.nvim_set_mapping{ mode = 'n', lhs = 'Q',    rhs = 'o<ESC>', args = noremap }
nvim.nvim_set_mapping{ mode = 'n', lhs = 'J',    rhs = 'm`J``', args = noremap }
nvim.nvim_set_mapping{ mode = 'i', lhs = 'jj',   rhs = '<ESC>' }
nvim.nvim_set_mapping{ mode = 'x', lhs = '<BS>', rhs = '<ESC>', args = noremap }

nvim.nvim_set_mapping{
    mode = 'n',
    lhs = '<BS>',
    rhs = ':call mappings#bs()<CR>',
    args = noremap_silent,
}

nvim.nvim_set_mapping{
    mode = 'i',
    lhs  = '<TAB>',
    rhs  = [[<C-R>=mappings#tab()<CR>]],
    args = noremap_silent,
}

nvim.nvim_set_mapping{
    mode = 'i',
    lhs  = '<S-TAB>',
    rhs  = [[<C-R>=mappings#shifttab()<CR>]],
    args = noremap_silent,
}

nvim.nvim_set_mapping{
    mode = 'i',
    lhs  = '<CR>',
    rhs  = [[<C-R>=mappings#enter()<CR>]],
    args = noremap_silent,
}

-- TODO: Check for GUIs
if sys.name == 'windows' then
    nvim.nvim_set_mapping{
        mode = 'n',
        lhs = '<C-h>',
        rhs = ':call mappings#bs()<CR>',
        args = noremap_silent,
    }
    nvim.nvim_set_mapping{
        mode = 'x',
        lhs = '<C-h>',
        rhs = ':<ESC>',
        args = noremap,
    }
    nvim.nvim_set_mapping{
        mode = 'n',
        lhs = '<C-z>',
        rhs = '<nop>',
        args = noremap,
    }
end

if not nvim.nvim_get_mapping{ mode = 'n', lhs = '<C-L>' } then
    nvim.nvim_set_mapping{
        mode = 'n',
        lhs  = '<C-L>',
        rhs  = ':nohlsearch|diffupdate<CR>',
        args = noremap_silent,
    }
end

nvim.nvim_set_mapping{
    mode = 'i',
    lhs  = '<C-U>',
    rhs  = '<C-G>u<C-U>',
    args = noremap,
}

if not has('nvim-0.5') then
    nvim.nvim_set_mapping{
        mode = 'n',
        lhs = '<C-w>o',
        rhs = ':diffoff!<BAR>only<CR>',
        args =noremap,
    }
    nvim.nvim_set_mapping{
        mode = 'n',
        lhs = '<C-w><C-o>',
        rhs = ':diffoff!<BAR>only<CR>',
        args = noremap,
    }
end

nvim.nvim_set_mapping{
    mode = 'n',
    lhs = '<S-tab>',
    rhs = '<C-o>',
    args = noremap,
}

nvim.nvim_set_mapping{
    mode = 'x',
    lhs = '<',
    rhs = '<gv',
    args = noremap,
}

nvim.nvim_set_mapping{
    mode = 'x',
    lhs = '>',
    rhs = '>gv',
    args = noremap,
}

nvim.nvim_set_mapping{
    mode = 'n',
    lhs = 'j',
    rhs = [[v:count ? (v:count >= 3 ? "m'" . v:count : '') . 'j' : 'gj']],
    args = {noremap = true, expr = true},
}

nvim.nvim_set_mapping{
    mode = 'n',
    lhs = 'k',
    rhs = [[v:count ? (v:count >= 3 ? "m'" . v:count : '') . 'k' : 'gk']],
    args = {noremap = true, expr = true},
}

nvim.nvim_set_mapping{
    mode = 'n',
    lhs = '<leader><leader>e',
    rhs = ':echo expand("%")<CR>',
    args = noremap,
}

-- nvim.nvim_set_mapping{
--     mode = 'n',
--     lhs = '<leader>c',
--     rhs = ':pclose<CR>',
--     args = noremap,
-- }

nvim.nvim_set_mapping{
    mode = 'n',
    lhs = 'i',
    rhs = 'mappings#IndentWithI()',
    args = {noremap = true, expr = true},
}

nvim.nvim_set_mapping{ mode = 'n', lhs = 'c*',  rhs = 'm`*``cgn',             args = noremap }
nvim.nvim_set_mapping{ mode = 'n', lhs = 'c#',  rhs = 'm`#``cgN',             args = noremap }
nvim.nvim_set_mapping{ mode = 'n', lhs = 'cg*', rhs = 'm`g*``cgn',            args = noremap }
nvim.nvim_set_mapping{ mode = 'n', lhs = 'cg#', rhs = 'm`#``cgN',             args = noremap }
nvim.nvim_set_mapping{ mode = 'x', lhs = 'c',   rhs = [["cy/<C-r>c<CR>Ncgn]], args = noremap }

nvim.nvim_set_mapping{ mode = 'n', lhs = '¿',  rhs = '`',  args = noremap }
nvim.nvim_set_mapping{ mode = 'x', lhs = '¿',  rhs = '`',  args = noremap }
nvim.nvim_set_mapping{ mode = 'n', lhs = '¿¿', rhs = '``', args = noremap }
nvim.nvim_set_mapping{ mode = 'x', lhs = '¿¿', rhs = '``', args = noremap }

nvim.nvim_set_mapping{ mode = 'n', lhs = '¡', rhs = '^', args = noremap }
nvim.nvim_set_mapping{ mode = 'x', lhs = '¡', rhs = '^', args = noremap }

-- nvim.nvim_set_mapping{ mode = 'n', lhs = '<leader>w', rhs = ':update<CR>', args = noremap }

nvim.nvim_set_mapping{ mode = 'n', lhs = '<leader>p', rhs = '<C-^>',       args = noremap }
nvim.nvim_set_mapping{ mode = 'n', lhs = '<leader>q', rhs = ':q!<CR>',     args = noremap_silent }
nvim.nvim_set_mapping{ mode = 'n', lhs = '<leader>x', rhs = ':%!xxd<CR>',  args = noremap }

nvim.nvim_set_mapping{ mode = 'n', lhs = '<leader>h', rhs = '<C-w>h', args = noremap }
nvim.nvim_set_mapping{ mode = 'n', lhs = '<leader>j', rhs = '<C-w>j', args = noremap }
nvim.nvim_set_mapping{ mode = 'n', lhs = '<leader>k', rhs = '<C-w>k', args = noremap }
nvim.nvim_set_mapping{ mode = 'n', lhs = '<leader>l', rhs = '<C-w>l', args = noremap }
nvim.nvim_set_mapping{ mode = 'n', lhs = '<leader>b', rhs = '<C-w>b', args = noremap }
nvim.nvim_set_mapping{ mode = 'n', lhs = '<leader>t', rhs = '<C-w>t', args = noremap }

nvim.nvim_set_mapping{ mode = 'n', lhs = '<leader>e', rhs = '<C-w>=', args = noremap }

nvim.nvim_set_mapping{ mode = 'n', lhs = '<leader>1', rhs = '1gt', args = noremap }
nvim.nvim_set_mapping{ mode = 'n', lhs = '<leader>2', rhs = '2gt', args = noremap }
nvim.nvim_set_mapping{ mode = 'n', lhs = '<leader>3', rhs = '3gt', args = noremap }
nvim.nvim_set_mapping{ mode = 'n', lhs = '<leader>4', rhs = '4gt', args = noremap }
nvim.nvim_set_mapping{ mode = 'n', lhs = '<leader>5', rhs = '5gt', args = noremap }
nvim.nvim_set_mapping{ mode = 'n', lhs = '<leader>6', rhs = '6gt', args = noremap }
nvim.nvim_set_mapping{ mode = 'n', lhs = '<leader>7', rhs = '7gt', args = noremap }
nvim.nvim_set_mapping{ mode = 'n', lhs = '<leader>8', rhs = '8gt', args = noremap }
nvim.nvim_set_mapping{ mode = 'n', lhs = '<leader>9', rhs = '9gt', args = noremap }
nvim.nvim_set_mapping{ mode = 'n', lhs = '<leader>0', rhs = ':tablast<CR>', args = noremap }
nvim.nvim_set_mapping{ mode = 'n', lhs = '<leader><leader>n', rhs = ':tabnew<CR>', args = noremap }

nvim.nvim_set_mapping{ mode = 'x', lhs = '<leader>1', rhs = '<ESC>1gt', args = noremap }
nvim.nvim_set_mapping{ mode = 'x', lhs = '<leader>2', rhs = '<ESC>2gt', args = noremap }
nvim.nvim_set_mapping{ mode = 'x', lhs = '<leader>3', rhs = '<ESC>3gt', args = noremap }
nvim.nvim_set_mapping{ mode = 'x', lhs = '<leader>4', rhs = '<ESC>4gt', args = noremap }
nvim.nvim_set_mapping{ mode = 'x', lhs = '<leader>5', rhs = '<ESC>5gt', args = noremap }
nvim.nvim_set_mapping{ mode = 'x', lhs = '<leader>6', rhs = '<ESC>6gt', args = noremap }
nvim.nvim_set_mapping{ mode = 'x', lhs = '<leader>7', rhs = '<ESC>7gt', args = noremap }
nvim.nvim_set_mapping{ mode = 'x', lhs = '<leader>8', rhs = '<ESC>8gt', args = noremap }
nvim.nvim_set_mapping{ mode = 'x', lhs = '<leader>9', rhs = '<ESC>9gt', args = noremap }
nvim.nvim_set_mapping{ mode = 'x', lhs = '<leader>0', rhs = '<ESC>:tablast<CR>', args = noremap }

-- Fucking Typos
nvim.nvim_set_abbr{ mode = 'c', lhs = 'Gti', rhs = 'Git' }
nvim.nvim_set_abbr{ mode = 'c', lhs = 'W'  , rhs = 'w' }
nvim.nvim_set_abbr{ mode = 'c', lhs = 'Q'  , rhs = 'q' }
nvim.nvim_set_abbr{ mode = 'c', lhs = 'q1' , rhs = 'q!' }
nvim.nvim_set_abbr{ mode = 'c', lhs = 'qa1', rhs = 'qa!' }
nvim.nvim_set_abbr{ mode = 'c', lhs = 'w1' , rhs = 'w!' }
nvim.nvim_set_abbr{ mode = 'c', lhs = 'wA!', rhs = 'wa!' }
nvim.nvim_set_abbr{ mode = 'c', lhs = 'wa1', rhs = 'wa!' }

nvim.nvim_set_mapping{ mode = 'c', lhs = '<C-n>', rhs = '<down>', args = noremap }
nvim.nvim_set_mapping{ mode = 'c', lhs = '<C-p>', rhs = '<up>', args = noremap }
nvim.nvim_set_mapping{
    mode = 'c',
    lhs = '<C-r><C-w>',
    rhs = "<C-r>=escape(expand('<cword>'), '#')<CR>",
    args = noremap
}

nvim.nvim_set_mapping{ mode = 'n', lhs = '&', rhs = ':&&<CR>', args = noremap }
nvim.nvim_set_mapping{ mode = 'x', lhs = '&', rhs = ':&&<CR>', args = noremap }

nvim.nvim_set_mapping{ mode = 'n', lhs = '/',  rhs = 'ms/',    args = noremap }
nvim.nvim_set_mapping{ mode = 'n', lhs = 'g/', rhs = 'ms/\\v', args = noremap }
nvim.nvim_set_mapping{ mode = 'n', lhs = '0',  rhs = '^',      args = noremap }
nvim.nvim_set_mapping{ mode = 'n', lhs = '^',  rhs = '0',      args = noremap }

nvim.nvim_set_mapping{ mode = 'n', lhs = 'gV', rhs = '`[v`]', args = noremap }

nvim.nvim_set_mapping{ mode = 't', lhs = '<ESC>', rhs = '<C-\\><C-n>', args = noremap }

nvim.nvim_set_mapping{ mode = 'n', lhs = '<A-s>', rhs = '<C-w>s', args = noremap }
nvim.nvim_set_mapping{ mode = 'n', lhs = '<A-v>', rhs = '<C-w>v', args = noremap }

nvim.nvim_set_command{
    lhs = 'Terminal',
    rhs = [[lua require'settings/mappings'.terminal(<q-args>)]],
    args = {nargs='?', force=true}
}

nvim.nvim_set_command{
    lhs = 'PowershellToggle',
    rhs = 'call windows#toggle_powershell()',
    args = {force=true}
}

nvim.nvim_set_command{
    lhs = 'RelativeNumbersToggle',
    rhs = 'set relativenumber! relativenumber?',
    args = {force=true}
}

nvim.nvim_set_command{
    lhs = 'MouseToggle',
    rhs = 'call mappings#ToggleMouse()',
    args = {force=true}
}

nvim.nvim_set_command{
    lhs = 'ArrowsToggle',
    rhs = 'call mappings#ToggleArrows()',
    args = {force=true}
}

nvim.nvim_set_command{
    lhs = 'BufKill',
    rhs = 'call mappings#BufKill(<bang>0)',
    args = {bang = true,
    force = true}
}

nvim.nvim_set_command{
    lhs = 'BufClean',
    rhs = 'call mappings#BufClean(<bang>0)',
    args = {bang = true,
    force = true}
}

nvim.nvim_set_command{
    lhs = 'ModifiableToggle',
    rhs = 'setlocal modifiable! modifiable?',
    args = {force=true}
}

nvim.nvim_set_command{
    lhs = 'CursorLineToggle',
    rhs = 'setlocal cursorline! cursorline?',
    args = {force=true}
}

nvim.nvim_set_command{
    lhs = 'ScrollBindToggle',
    rhs = 'setlocal scrollbind! scrollbind?',
    args = {force=true}
}

nvim.nvim_set_command{
    lhs = 'HlSearchToggle',
    rhs = 'setlocal hlsearch! hlsearch?',
    args = {force=true}
}

nvim.nvim_set_command{
    lhs = 'NumbersToggle',
    rhs = 'setlocal number! number?',
    args = {force=true}
}

nvim.nvim_set_command{
    lhs = 'PasteToggle',
    rhs = 'setlocal paste! paste?',
    args = {force=true}
}

nvim.nvim_set_command{
    lhs = 'SpellToggle',
    rhs = 'setlocal spell! spell?',
    args = {force=true}
}

nvim.nvim_set_command{
    lhs = 'WrapToggle',
    rhs = 'setlocal wrap! wrap?',
    args = {force=true}
}

nvim.nvim_set_command{
    lhs = 'VerboseToggle',
    rhs = 'let &verbose=!&verbose | echo "Verbose " . &verbose',
    args = {force=true}
}

nvim.nvim_set_command{
    lhs = 'TrimToggle',
    rhs = [[lua require"settings/mappings".trim()]],
    args = {force=true}
}

nvim.nvim_set_command{
    lhs = 'GonvimSettngs',
    rhs = "execute('edit ~/.gonvim/setting.toml')",
    args = {nargs='*', force = true}
}

nvim.nvim_set_command{
    lhs = 'FileType',
    rhs = "call mappings#SetFileData('filetype', <q-args>, 'text')",
    args = {nargs='?', complete='filetype', force = true}
}

nvim.nvim_set_command{
    lhs = 'FileFormat',
    rhs = "call mappings#SetFileData('fileformat', <q-args>, 'unix')",
    args = {nargs='?', complete='customlist,mappings#format', force = true}
}

nvim.nvim_set_command{
    lhs = 'SpellLang',
    rhs = 'lua require"tools".spelllangs(<q-args>)',
    args = {force = true, nargs = '?', complete = 'customlist,mappings#spells'}
}

nvim.nvim_set_command{
    lhs = 'ConncallLevel',
    rhs = "call mappings#ConncallLevel(expand(<q-args>))",
    args = {nargs='?', force = true}
}

nvim.nvim_set_command{
    lhs = 'Qopen',
    rhs = "execute((&splitbelow) ? 'botright' : 'topleft' ) . ' copen ' . expand(<q-args>)",
    args = {nargs='?', force = true}
}

nvim.nvim_set_mapping{
    mode = 'n',
    lhs = '=l',
    rhs = [[:call v:lua.tools.helpers.toggle_qf('loc')<CR>]],
    args = noremap_silent
}
nvim.nvim_set_mapping{
    mode = 'n',
    lhs = '=q',
    rhs = [[:call v:lua.tools.helpers.toggle_qf('qf')<CR>]],
    args = noremap_silent
}

nvim.nvim_set_mapping{
    mode = 'n',
    lhs = '<leader><leader>p',
    rhs = [[:<C-U>lua <<EOF
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
    args = noremap_silent
}

if executable('svn') then

    nvim.nvim_set_command{
        lhs = 'SVNstatus',
        rhs = "execute('!svn status ' . <q-args>)",
        args = {nargs='*', force = true}
    }

    nvim.nvim_set_command{
        lhs = 'SVN',
        rhs = "execute('!svn ' . <q-args>)",
        args = {complete='file', nargs='+', force = true}
    }

    nvim.nvim_set_command{
        lhs = 'SVNupdate',
        rhs = "execute('!svn update ' . <q-args>)",
        args = {complete='file', nargs='*', force = true}
    }

    -- command! -complete=file -bang SVNread execute('!svn revert ' . expand("%")) |
    --             \ let s:bang = empty(<bang>0) ? '' : '!' |
    --             \ execute('edit'.s:bang) |
    --             \ unlet s:bang
end

if plugins["iron.nvim"] == nil and (has('python') or has('python3'))then
    nvim.nvim_set_command{
        lhs = 'Python',
        rhs = [[lua require'settings/mappings'.python(2, <q-args>)]],
        args = {complete='file', nargs='*', force = true}
    }

    nvim.nvim_set_command{
        lhs = 'Python',
        rhs = [[lua require'settings/mappings'.python(3, <q-args>)]],
        args = {complete='file', nargs='*', force = true}
    }

    nvim.nvim_set_command{
        lhs = 'Python3',
        rhs = [[lua require'settings/mappings'.python(3, <q-args>)]],
        args = {complete='file', nargs='*', force = true}
    }
end

if plugins["vim-bbye"] == nil then
    nvim.nvim_set_mapping{ mode = 'n', lhs = '<leader>d', rhs = ':bdelete!<CR>' }
end

if plugins["vim-indexed-search"] == nil then
    -- nvim.nvim_set_mapping{ mode = 'n', lhs = '*', rhs = '*zz' }
    -- nvim.nvim_set_mapping{ mode = 'n', lhs = '#', rhs = '#zz' }
    nvim.nvim_set_mapping{ mode = 'n', lhs = 'n', rhs = ":call mappings#NiceNext('n')<cr>", args = noremap_silent }
    nvim.nvim_set_mapping{ mode = 'n', lhs = 'N', rhs = ":call mappings#NiceNext('N')<cr>", args = noremap_silent }
end

if plugins["vim-unimpaired"] == nil then
    nvim.nvim_set_mapping{
        mode = 'n',
        lhs = '[Q',
        rhs = ':<C-U>exe "".(v:count ? v:count : "")."cfirst"<CR>zvzz',
        args = noremap_silent
    }

    nvim.nvim_set_mapping{
        mode = 'n',
        lhs = ']Q',
        rhs = ':<C-U>exe "".(v:count ? v:count : "")."clast"<CR>zvzz',
        args = noremap_silent
    }

    nvim.nvim_set_mapping{
        mode = 'n',
        lhs = '[q',
        rhs = ':<C-U>exe "".(v:count ? v:count : "")."cprevious"<CR>zvzz',
        args = noremap_silent
    }

    nvim.nvim_set_mapping{
        mode = 'n',
        lhs = ']q',
        rhs = ':<C-U>exe "".(v:count ? v:count : "")."cnext"<CR>zvzz',
        args = noremap_silent
    }

    nvim.nvim_set_mapping{
        mode = 'n',
        lhs = '[L',
        rhs = ':<C-U>exe "".(v:count ? v:count : "")."lfirst"<CR>zvzz',
        args = noremap_silent
    }

    nvim.nvim_set_mapping{
        mode = 'n',
        lhs = ']L',
        rhs = ':<C-U>exe "".(v:count ? v:count : "")."llast"<CR>zvzz',
        args = noremap_silent
    }

    nvim.nvim_set_mapping{
        mode = 'n',
        lhs = '[l',
        rhs = ':<C-U>exe "".(v:count ? v:count : "")."lprevious"<CR>zvzz',
        args = noremap_silent
    }

    nvim.nvim_set_mapping{
        mode = 'n',
        lhs = ']l',
        rhs = ':<C-U>exe "".(v:count ? v:count : "")."lnext"<CR>zvzz',
        args = noremap_silent
    }

    nvim.nvim_set_mapping{
        mode = 'n',
        lhs = '[B',
        rhs = ':<C-U>exe "".(v:count ? v:count : "")."bfirst"<CR>',
        args = noremap_silent
    }

    nvim.nvim_set_mapping{
        mode = 'n',
        lhs = ']B',
        rhs = ':<C-U>exe "".(v:count ? v:count : "")."blast"<CR>',
        args = noremap_silent
    }

    nvim.nvim_set_mapping{
        mode = 'n',
        lhs = '[b',
        rhs = ':<C-U>exe "".(v:count ? v:count : "")."bprevious"<CR>',
        args = noremap_silent
    }

    nvim.nvim_set_mapping{
        mode = 'n',
        lhs = ']b',
        rhs = ':<C-U>exe "".(v:count ? v:count : "")."bnext"<CR>',
        args = noremap_silent
    }

    nvim.nvim_set_mapping{
        mode = 'n',
        lhs = ']<Space>',
        rhs = [[:<C-U>lua require'tools.helpers'.add_nl(true)<CR>]],
        args = noremap_silent
    }

    nvim.nvim_set_mapping{
        mode = 'n',
        lhs = '[<Space>',
        rhs = [[:<C-U>lua require'tools.helpers'.add_nl(false)<CR>]],
        args = noremap_silent,
    }

end

if plugins["vim-vinegar"] == nil and plugins["nerdtree"] == nil then
    nvim.nvim_set_mapping{ mode = 'n', lhs = '-', rhs = ':Explore<CR>' }
end

if plugins["vim-eunuch"] == nil and nvim.has('nvim-0.5') then

    require'tools.helpers'

    -- TODO: Make this work with embedded lua
    nvim.nvim_set_command{
        lhs = 'MoveFile',
        rhs = [[call v:lua.tools.helpers.rename(expand('%:p'), expand(<q-args>), empty(<bang>0) ? 0 : 1)]],
        args = {force = true, bang = true, nargs = 1, complete = 'file'}
    }

    nvim.nvim_set_command{
        lhs = 'RenameFile',
        rhs = [[call v:lua.tools.helpers.rename(expand('%:p'), expand('%:p:h').'/'.expand(<q-args>), empty(<bang>0) ? 0 : 1)]],
        args = {force = true, bang = true, nargs = 1, complete = 'file'}
    }

    nvim.nvim_set_command{
        lhs = 'Mkdir',
        rhs = [[call mkdir(fnameescape(expand(<q-args>)), 'p')]],
        args = {force = true, bang = true, nargs = 1, complete = 'dir'}
    }

    nvim.nvim_set_command{
        lhs = 'RemoveFile',
        rhs = [[call v:lua.tools.helpers.delete(fnamemodify(empty(<q-args>) ? expand("%") : expand(<q-args>), ":p"), empty(<bang>0) ? 0 : 1)]],
        args = {force = true, bang = true, nargs = '?', complete = 'file'}
    }

end

-- if plugins["vim-fugitive"] == nil and executable('git') then
--     -- TODO
-- end

return mappings

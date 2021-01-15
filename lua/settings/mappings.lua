-- luacheck: max line length 150
local sys  = require'sys'
local nvim = require'nvim'

local iregex     = require'tools'.strings.iregex
local executable = require'tools'.files.executable

-- local set_autocmd = nvim.autocmds.set_autocmd
local set_abbr    = nvim.abbrs.set_abbr
local set_command = nvim.commands.set_command
local set_mapping = nvim.mappings.set_mapping
local get_mapping = nvim.mappings.get_mapping

local has     = nvim.has
local plugins = nvim.plugins

local mappings = {}

local noremap = {noremap = true}
local noremap_silent = {noremap = true, silent = true}

if nvim.g.mapleader == nil then
    nvim.g.mapleader = ' '
end

set_mapping{ mode = 'n', lhs = ',',    rhs = ':',  args = noremap }
set_mapping{ mode = 'x', lhs = ',',    rhs = ':',  args = noremap }
set_mapping{ mode = 'n', lhs = 'Y',    rhs = 'y$', args = noremap }
set_mapping{ mode = 'x', lhs = '$',    rhs = '$h', args = noremap }
set_mapping{ mode = 'n', lhs = 'Q',    rhs = 'o<ESC>', args = noremap }
set_mapping{ mode = 'n', lhs = 'J',    rhs = 'm`J``', args = noremap }
set_mapping{ mode = 'i', lhs = 'jj',   rhs = '<ESC>' }
set_mapping{ mode = 'x', lhs = '<BS>', rhs = '<ESC>', args = noremap }

set_mapping{
    mode = 'n',
    lhs = '<BS>',
    rhs = ':call mappings#bs()<CR>',
    args = noremap_silent,
}

set_mapping{
    mode = 'i',
    lhs  = '<TAB>',
    rhs  = [[<C-R>=mappings#tab()<CR>]],
    args = noremap_silent,
}

set_mapping{
    mode = 'i',
    lhs  = '<S-TAB>',
    rhs  = [[<C-R>=mappings#shifttab()<CR>]],
    args = noremap_silent,
}

set_mapping{
    mode = 'i',
    lhs  = '<CR>',
    rhs  = [[<C-R>=mappings#enter()<CR>]],
    args = noremap_silent,
}

-- TODO: Check for GUIs
if sys.name == 'windows' then
    set_mapping{
        mode = 'n',
        lhs = '<C-h>',
        rhs = ':call mappings#bs()<CR>',
        args = noremap_silent,
    }
    set_mapping{
        mode = 'x',
        lhs = '<C-h>',
        rhs = ':<ESC>',
        args = noremap,
    }
    set_mapping{
        mode = 'n',
        lhs = '<C-z>',
        rhs = '<nop>',
        args = noremap,
    }
end

if not get_mapping{ mode = 'n', lhs = '<C-L>' } then
    set_mapping{
        mode = 'n',
        lhs  = '<C-L>',
        rhs  = ':nohlsearch|diffupdate<CR>',
        args = noremap_silent,
    }
end

set_mapping{
    mode = 'i',
    lhs  = '<C-U>',
    rhs  = '<C-G>u<C-U>',
    args = noremap,
}

if not has('nvim-0.5') then
    set_mapping{
        mode = 'n',
        lhs = '<C-w>o',
        rhs = ':diffoff!<BAR>only<CR>',
        args =noremap,
    }
    set_mapping{
        mode = 'n',
        lhs = '<C-w><C-o>',
        rhs = ':diffoff!<BAR>only<CR>',
        args = noremap,
    }
end

set_mapping{
    mode = 'n',
    lhs = '<S-tab>',
    rhs = '<C-o>',
    args = noremap,
}

set_mapping{
    mode = 'x',
    lhs = '<',
    rhs = '<gv',
    args = noremap,
}

set_mapping{
    mode = 'x',
    lhs = '>',
    rhs = '>gv',
    args = noremap,
}

set_mapping{
    mode = 'n',
    lhs = 'j',
    rhs = [[v:count ? (v:count >= 3 ? "m'" . v:count : '') . 'j' : 'gj']],
    args = {noremap = true, expr = true},
}

set_mapping{
    mode = 'n',
    lhs = 'k',
    rhs = [[v:count ? (v:count >= 3 ? "m'" . v:count : '') . 'k' : 'gk']],
    args = {noremap = true, expr = true},
}

set_mapping{
    mode = 'n',
    lhs = '<leader><leader>e',
    rhs = ':echo expand("%")<CR>',
    args = noremap,
}

-- set_mapping{
--     mode = 'n',
--     lhs = '<leader>c',
--     rhs = ':pclose<CR>',
--     args = noremap,
-- }

set_mapping{
    mode = 'n',
    lhs = 'i',
    rhs = function()
        local current_line = nvim.fn.line('.')
        local last_line = nvim.fn.line('$')
        local buftype = nvim.bo.buftype
        if #nvim.fn.getline('.') == 0 and last_line ~= current_line and buftype ~= 'terminal' then
            return '"_ddO'
        end
        return 'i'
    end,
    args = {noremap = true, expr = true},
}

set_mapping{ mode = 'n', lhs = 'c*',  rhs = 'm`*``cgn',             args = noremap }
set_mapping{ mode = 'n', lhs = 'c#',  rhs = 'm`#``cgN',             args = noremap }
set_mapping{ mode = 'n', lhs = 'cg*', rhs = 'm`g*``cgn',            args = noremap }
set_mapping{ mode = 'n', lhs = 'cg#', rhs = 'm`#``cgN',             args = noremap }
set_mapping{ mode = 'x', lhs = 'c',   rhs = [["cy/<C-r>c<CR>Ncgn]], args = noremap }

set_mapping{ mode = 'n', lhs = '¿',  rhs = '`',  args = noremap }
set_mapping{ mode = 'x', lhs = '¿',  rhs = '`',  args = noremap }
set_mapping{ mode = 'n', lhs = '¿¿', rhs = '``', args = noremap }
set_mapping{ mode = 'x', lhs = '¿¿', rhs = '``', args = noremap }

set_mapping{ mode = 'n', lhs = '¡', rhs = '^', args = noremap }
set_mapping{ mode = 'x', lhs = '¡', rhs = '^', args = noremap }

-- set_mapping{ mode = 'n', lhs = '<leader>w', rhs = ':update<CR>', args = noremap }

set_mapping{ mode = 'n', lhs = '<leader>p', rhs = '<C-^>',       args = noremap }
set_mapping{ mode = 'n', lhs = '<leader>q', rhs = ':q!<CR>',     args = noremap_silent }
set_mapping{ mode = 'n', lhs = '<leader>x', rhs = ':%!xxd<CR>',  args = noremap }

set_mapping{ mode = 'n', lhs = '<leader>h', rhs = '<C-w>h', args = noremap }
set_mapping{ mode = 'n', lhs = '<leader>j', rhs = '<C-w>j', args = noremap }
set_mapping{ mode = 'n', lhs = '<leader>k', rhs = '<C-w>k', args = noremap }
set_mapping{ mode = 'n', lhs = '<leader>l', rhs = '<C-w>l', args = noremap }
set_mapping{ mode = 'n', lhs = '<leader>b', rhs = '<C-w>b', args = noremap }
set_mapping{ mode = 'n', lhs = '<leader>t', rhs = '<C-w>t', args = noremap }

set_mapping{ mode = 'n', lhs = '<leader>e', rhs = '<C-w>=', args = noremap }

set_mapping{ mode = 'n', lhs = '<leader>1', rhs = '1gt', args = noremap }
set_mapping{ mode = 'n', lhs = '<leader>2', rhs = '2gt', args = noremap }
set_mapping{ mode = 'n', lhs = '<leader>3', rhs = '3gt', args = noremap }
set_mapping{ mode = 'n', lhs = '<leader>4', rhs = '4gt', args = noremap }
set_mapping{ mode = 'n', lhs = '<leader>5', rhs = '5gt', args = noremap }
set_mapping{ mode = 'n', lhs = '<leader>6', rhs = '6gt', args = noremap }
set_mapping{ mode = 'n', lhs = '<leader>7', rhs = '7gt', args = noremap }
set_mapping{ mode = 'n', lhs = '<leader>8', rhs = '8gt', args = noremap }
set_mapping{ mode = 'n', lhs = '<leader>9', rhs = '9gt', args = noremap }
set_mapping{ mode = 'n', lhs = '<leader>0', rhs = ':tablast<CR>', args = noremap }
set_mapping{ mode = 'n', lhs = '<leader><leader>n', rhs = ':tabnew<CR>', args = noremap }

set_mapping{ mode = 'x', lhs = '<leader>1', rhs = '<ESC>1gt', args = noremap }
set_mapping{ mode = 'x', lhs = '<leader>2', rhs = '<ESC>2gt', args = noremap }
set_mapping{ mode = 'x', lhs = '<leader>3', rhs = '<ESC>3gt', args = noremap }
set_mapping{ mode = 'x', lhs = '<leader>4', rhs = '<ESC>4gt', args = noremap }
set_mapping{ mode = 'x', lhs = '<leader>5', rhs = '<ESC>5gt', args = noremap }
set_mapping{ mode = 'x', lhs = '<leader>6', rhs = '<ESC>6gt', args = noremap }
set_mapping{ mode = 'x', lhs = '<leader>7', rhs = '<ESC>7gt', args = noremap }
set_mapping{ mode = 'x', lhs = '<leader>8', rhs = '<ESC>8gt', args = noremap }
set_mapping{ mode = 'x', lhs = '<leader>9', rhs = '<ESC>9gt', args = noremap }
set_mapping{ mode = 'x', lhs = '<leader>0', rhs = '<ESC>:tablast<CR>', args = noremap }

-- Fucking Typos
set_abbr{ mode = 'c', lhs = 'Gti', rhs = 'Git' }
set_abbr{ mode = 'c', lhs = 'W'  , rhs = 'w' }
set_abbr{ mode = 'c', lhs = 'Q'  , rhs = 'q' }
set_abbr{ mode = 'c', lhs = 'q1' , rhs = 'q!' }
set_abbr{ mode = 'c', lhs = 'qa1', rhs = 'qa!' }
set_abbr{ mode = 'c', lhs = 'w1' , rhs = 'w!' }
set_abbr{ mode = 'c', lhs = 'wA!', rhs = 'wa!' }
set_abbr{ mode = 'c', lhs = 'wa1', rhs = 'wa!' }
set_abbr{ mode = 'c', lhs = 'Qa1', rhs = 'qa!' }
set_abbr{ mode = 'c', lhs = 'Qa!', rhs = 'qa!' }
set_abbr{ mode = 'c', lhs = 'QA!', rhs = 'qa!' }

set_mapping{ mode = 'c', lhs = '<C-n>', rhs = '<down>', args = noremap }
set_mapping{ mode = 'c', lhs = '<C-p>', rhs = '<up>', args = noremap }
set_mapping{
    mode = 'c',
    lhs = '<C-r><C-w>',
    rhs = "<C-r>=escape(expand('<cword>'), '#')<CR>",
    args = noremap
}

set_mapping{ mode = 'n', lhs = '&', rhs = ':&&<CR>', args = noremap }
set_mapping{ mode = 'x', lhs = '&', rhs = ':&&<CR>', args = noremap }

set_mapping{ mode = 'n', lhs = '/',  rhs = 'ms/',    args = noremap }
set_mapping{ mode = 'n', lhs = 'g/', rhs = 'ms/\\v', args = noremap }
set_mapping{ mode = 'n', lhs = '0',  rhs = '^',      args = noremap }
set_mapping{ mode = 'n', lhs = '^',  rhs = '0',      args = noremap }

set_mapping{ mode = 'n', lhs = 'gV', rhs = '`[v`]', args = noremap }

set_mapping{ mode = 't', lhs = '<ESC>', rhs = '<C-\\><C-n>', args = noremap }

set_mapping{ mode = 'n', lhs = '<A-s>', rhs = '<C-w>s', args = noremap }
set_mapping{ mode = 'n', lhs = '<A-v>', rhs = '<C-w>v', args = noremap }

set_command{
    lhs = 'Terminal',
    rhs = function(cmd)
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
    end,
    args = {nargs='?', force=true}
}

if executable('powershell') then
    set_command{
        lhs = 'PowershellToggle',
        rhs = 'call windows#toggle_powershell()',
        args = {force=true}
    }
end

set_command{
    lhs = 'RelativeNumbersToggle',
    rhs = 'set relativenumber! relativenumber?',
    args = {force=true}
}

set_command{
    lhs = 'MouseToggle',
    rhs = 'call mappings#ToggleMouse()',
    args = {force=true}
}

set_command{
    lhs = 'ArrowsToggle',
    rhs = 'call mappings#ToggleArrows()',
    args = {force=true}
}

set_command{
    lhs = 'BufKill',
    rhs = 'call mappings#BufKill(<bang>0)',
    args = {bang = true,
    force = true}
}

set_command{
    lhs = 'BufClean',
    rhs = 'call mappings#BufClean(<bang>0)',
    args = {bang = true,
    force = true}
}

set_command{
    lhs = 'ModifiableToggle',
    rhs = 'setlocal modifiable! modifiable?',
    args = {force=true}
}

set_command{
    lhs = 'CursorLineToggle',
    rhs = 'setlocal cursorline! cursorline?',
    args = {force=true}
}

set_command{
    lhs = 'ScrollBindToggle',
    rhs = 'setlocal scrollbind! scrollbind?',
    args = {force=true}
}

set_command{
    lhs = 'HlSearchToggle',
    rhs = 'setlocal hlsearch! hlsearch?',
    args = {force=true}
}

set_command{
    lhs = 'NumbersToggle',
    rhs = 'setlocal number! number?',
    args = {force=true}
}

set_command{
    lhs = 'SpellToggle',
    rhs = 'setlocal spell! spell?',
    args = {force=true}
}

set_command{
    lhs = 'WrapToggle',
    rhs = 'setlocal wrap! wrap?',
    args = {force=true}
}

set_command{
    lhs = 'VerboseToggle',
    rhs = 'let &verbose=!&verbose | echo "Verbose " . &verbose',
    args = {force=true}
}

set_command{
    lhs = 'TrimToggle',
    rhs = function ()
        if not nvim.b.trim then
            print('Trim')
        else
            print('NoTrim')
        end
        nvim.b.trim = not nvim.b.trim
    end,
    args = {force=true}
}

set_command{
    lhs = 'GonvimSettngs',
    rhs = "execute('edit ~/.gonvim/setting.toml')",
    args = {nargs='*', force = true}
}

set_command{
    lhs = 'FileType',
    rhs = "call mappings#SetFileData('filetype', <q-args>, 'text')",
    args = {nargs='?', complete='filetype', force = true}
}

set_command{
    lhs = 'FileFormat',
    rhs = "call mappings#SetFileData('fileformat', <q-args>, 'unix')",
    args = {nargs='?', complete='customlist,mappings#format', force = true}
}

set_command{
    lhs = 'SpellLang',
    rhs = 'lua require"tools".helpers.spelllangs(<q-args>)',
    args = {force = true, nargs = '?', complete = 'customlist,mappings#spells'}
}

set_command{
    lhs = 'ConncallLevel',
    rhs = "call mappings#ConncallLevel(expand(<q-args>))",
    args = {nargs='?', force = true}
}

set_command{
    lhs = 'Qopen',
    rhs = "execute((&splitbelow) ? 'botright' : 'topleft' ) . ' copen ' . expand(<q-args>)",
    args = {nargs='?', force = true}
}

set_mapping{
    mode = 'n',
    lhs = '=l',
    rhs = [[:lua require'tools'.helpers.toggle_qf('loc')<CR>]],
    args = noremap_silent
}

set_mapping{
    mode = 'n',
    lhs = '=q',
    rhs = [[:lua require'tools'.helpers.toggle_qf('qf')<CR>]],
    args = noremap_silent
}

set_mapping{
    mode = 'n',
    lhs = '<leader><leader>p',
    rhs = function()
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
    end,
    args = noremap_silent
}

if executable('svn') then

    set_command{
        lhs = 'SVNstatus',
        rhs = "execute('!svn status ' . <q-args>)",
        args = {nargs='*', force = true}
    }

    set_command{
        lhs = 'SVN',
        rhs = "execute('!svn ' . <q-args>)",
        args = {complete='file', nargs='+', force = true}
    }

    set_command{
        lhs = 'SVNupdate',
        rhs = "execute('!svn update ' . <q-args>)",
        args = {complete='file', nargs='*', force = true}
    }

end

if plugins["vim-bbye"] == nil then
    set_mapping{
        mode = 'n',
        lhs = '<leader>d',
        rhs = function()
            local current_buf = nvim.win.get_buf(0)
            local is_wipe = nvim.buf.get_option(current_buf, 'bufhidden') == 'wipe'
            local prev_buf = nvim.fn.expand('#') ~= '' and nvim.fn.bufnr(nvim.fn.expand('#')) or -1
            local is_loaded = nvim.buf.is_loaded

            local new_view = is_loaded(prev_buf) and prev_buf or nvim.create_buf(true, false)

            nvim.win.set_buf(0, new_view)
            if not is_wipe then
                vim.cmd(([[bdelete! %s]]):format(current_buf))
            end
            -- This wipeout the buffer, which is not what we want
            -- nvim.buf.delete(current_buf, {unload = true, force = true})
        end,
    }
end

if plugins["vim-indexed-search"] == nil then
    -- set_mapping{ mode = 'n', lhs = '*', rhs = '*zz' }
    -- set_mapping{ mode = 'n', lhs = '#', rhs = '#zz' }
    set_mapping{ mode = 'n', lhs = 'n', rhs = ":call mappings#NiceNext('n')<cr>", args = noremap_silent }
    set_mapping{ mode = 'n', lhs = 'N', rhs = ":call mappings#NiceNext('N')<cr>", args = noremap_silent }
end

if plugins["vim-unimpaired"] == nil then
    set_mapping{
        mode = 'n',
        lhs = '[Q',
        rhs = ':<C-U>exe "".(v:count ? v:count : "")."cfirst"<CR>zvzz',
        args = noremap_silent
    }

    set_mapping{
        mode = 'n',
        lhs = ']Q',
        rhs = ':<C-U>exe "".(v:count ? v:count : "")."clast"<CR>zvzz',
        args = noremap_silent
    }

    set_mapping{
        mode = 'n',
        lhs = '[q',
        rhs = ':<C-U>exe "".(v:count ? v:count : "")."cprevious"<CR>zvzz',
        args = noremap_silent
    }

    set_mapping{
        mode = 'n',
        lhs = ']q',
        rhs = ':<C-U>exe "".(v:count ? v:count : "")."cnext"<CR>zvzz',
        args = noremap_silent
    }

    set_mapping{
        mode = 'n',
        lhs = '[L',
        rhs = ':<C-U>exe "".(v:count ? v:count : "")."lfirst"<CR>zvzz',
        args = noremap_silent
    }

    set_mapping{
        mode = 'n',
        lhs = ']L',
        rhs = ':<C-U>exe "".(v:count ? v:count : "")."llast"<CR>zvzz',
        args = noremap_silent
    }

    set_mapping{
        mode = 'n',
        lhs = '[l',
        rhs = ':<C-U>exe "".(v:count ? v:count : "")."lprevious"<CR>zvzz',
        args = noremap_silent
    }

    set_mapping{
        mode = 'n',
        lhs = ']l',
        rhs = ':<C-U>exe "".(v:count ? v:count : "")."lnext"<CR>zvzz',
        args = noremap_silent
    }

    set_mapping{
        mode = 'n',
        lhs = '[B',
        rhs = ':<C-U>exe "".(v:count ? v:count : "")."bfirst"<CR>',
        args = noremap_silent
    }

    set_mapping{
        mode = 'n',
        lhs = ']B',
        rhs = ':<C-U>exe "".(v:count ? v:count : "")."blast"<CR>',
        args = noremap_silent
    }

    set_mapping{
        mode = 'n',
        lhs = '[b',
        rhs = ':<C-U>exe "".(v:count ? v:count : "")."bprevious"<CR>',
        args = noremap_silent
    }

    set_mapping{
        mode = 'n',
        lhs = ']b',
        rhs = ':<C-U>exe "".(v:count ? v:count : "")."bnext"<CR>',
        args = noremap_silent
    }

    set_mapping{
        mode = 'n',
        lhs = ']<Space>',
        rhs = [[:<C-U>lua require'tools'.helpers.add_nl(true)<CR>]],
        args = noremap_silent
    }

    set_mapping{
        mode = 'n',
        lhs = '[<Space>',
        rhs = [[:<C-U>lua require'tools'.helpers.add_nl(false)<CR>]],
        args = noremap_silent,
    }

    set_mapping{
        mode = 'n',
        lhs = ']e',
        rhs = [[:<C-U>lua require'tools'.helpers.move_line(true)<CR>]],
        args = noremap_silent
    }

    set_mapping{
        mode = 'n',
        lhs = '[e',
        rhs = [[:<C-U>lua require'tools'.helpers.move_line(false)<CR>]],
        args = noremap_silent,
    }

end

if plugins["vim-vinegar"] == nil and plugins["nerdtree"] == nil then
    set_mapping{ mode = 'n', lhs = '-', rhs = ':Explore<CR>' }
end

if plugins["vim-eunuch"] == nil then

    set_command{
        lhs = 'MoveFile',
        rhs = function(new_path, bang)
            local current_path = nvim.fn.expand('%:p')
            local is_dir = require'tools'.files.is_dir
            local is_file = require'tools'.files.is_file

            if is_file(current_path) and is_dir(new_path) then
                new_path = new_path .. '/' .. nvim.fn.fnamemodify(current_path, ':t')
            end

            require'tools'.files.rename(current_path, new_path, bang)
        end,
        args = {force = true, bang = true, nargs = 1, complete = 'file'}
    }

    set_command{
        lhs = 'RenameFile',
        rhs = function(args, bang)
            local current_path = nvim.fn.expand('%:p')
            local current_dir = nvim.fn.expand('%:h')
            require'tools'.files.rename(current_path, current_dir..'/'..args, bang)
        end,
        args = {force = true, bang = true, nargs = 1, complete = 'file'}
    }

    set_command{
        lhs = 'Mkdir',
        rhs = function(args)
            nvim.fn.mkdir(nvim.fn.fnameescape(args), 'p')
        end,
        args = {force = true, nargs = 1, complete = 'dir'}
    }

    set_command{
        lhs = 'RemoveFile',
        rhs = function(args, bang)
            local current_buffer = nvim.fn.expand('%')
            local target = args ~= '' and args or current_buffer
            require'tools'.files.delete(nvim.fn.fnamemodify(target, ":p"), bang)
        end,
        args = {force = true, bang = true, nargs = '?', complete = 'file'}
    }

end

return mappings

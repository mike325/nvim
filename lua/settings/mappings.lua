-- luacheck: max line length 150
local sys  = require'sys'
local nvim = require'nvim'

-- local split          = require'tools'.strings.split
local iregex         = require'tools'.strings.iregex
local executable     = require'tools'.files.executable
local is_file        = require'tools'.files.is_file
local writefile      = require'tools'.files.writefile
local normalize_path = require'tools'.files.normalize_path
local realpath       = require'tools'.files.realpath
local basename       = require'tools'.files.basename
local read_json      = require'tools'.files.read_json

-- local echoerr    = require'tools'.messages.echoerr
-- local clear_lst  = require'tools'.tables.clear_lst

-- local set_autocmd = nvim.autocmds.set_autocmd
local set_abbr    = nvim.abbrs.set_abbr
local set_command = nvim.commands.set_command
local set_mapping = nvim.mappings.set_mapping
local get_mapping = nvim.mappings.get_mapping

local has     = nvim.has
local plugins = nvim.plugins

local noremap = {noremap = true}
local noremap_silent = {noremap = true, silent = true}

if nvim.g.mapleader == nil then
    nvim.g.mapleader = ' '
end

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
            require'tools'.buffers.delete()
        end,
    }
end

if plugins["vim-indexed-search"] == nil then
    -- set_mapping{ mode = 'n', lhs = '*', rhs = '*zz' }
    -- set_mapping{ mode = 'n', lhs = '#', rhs = '#zz' }
    set_mapping{
        mode = 'n',
        lhs = 'n',
        rhs = "<cmd>call mappings#NiceNext('n')<cr>",
        args = noremap_silent
    }

    set_mapping{
        mode = 'n',
        lhs = 'N',
        rhs = "<cmd>call mappings#NiceNext('N')<cr>",
        args = noremap_silent
    }

end

if plugins["vim-unimpaired"] == nil then
    set_mapping{
        mode = 'n',
        lhs = '[Q',
        rhs = ':<C-U>cfirst<CR>zvzz',
        args = noremap_silent
    }

    set_mapping{
        mode = 'n',
        lhs = ']Q',
        rhs = ':<C-U>clast<CR>zvzz',
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
        rhs = ':<C-U>lfirst<CR>zvzz',
        args = noremap_silent
    }

    set_mapping{
        mode = 'n',
        lhs = ']L',
        rhs = ':<C-U>llast<CR>zvzz',
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
        rhs = ':<C-U>bfirst<CR>zvzz',
        args = noremap_silent
    }

    set_mapping{
        mode = 'n',
        lhs = ']B',
        rhs = ':<C-U>blast<CR>zvzz',
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
    set_mapping{ mode = 'n', lhs = '-', rhs = '<cmd>Explore<CR>' }
end

if plugins["vim-eunuch"] == nil then

    set_command{
        lhs = 'MoveFile',
        rhs = function(new_path, bang)
            local current_path = nvim.fn.expand('%:p')
            local is_dir = require'tools'.files.is_dir

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


if has('nvim-0.5') then
    set_command {
        lhs = 'Grep',
        rhs = function(args)
            require'settings.functions'.send_grep_job(args)
        end,
        args = {nargs = '+', force = true}
    }

    set_mapping{
        mode = 'n',
        lhs = 'gs',
        rhs = '<cmd>set opfunc=neovim#grep<CR>g@',
        args = noremap_silent,
    }

    set_mapping{
        mode = 'n',
        lhs = 'gss',
        rhs = function()
            require'settings.functions'.send_grep_job(nvim.fn.expand('<cword>'))
        end,
        args = noremap_silent,
    }

    set_mapping{
        mode = 'v',
        lhs = 'gs',
        rhs = ':<C-U>call neovim#grep(visualmode(), v:true)<CR>',
        args = noremap_silent,
    }

    set_command {
        lhs = 'Make',
        rhs = function(args)

            local ok, val = pcall(nvim.buf.get_option, 0, 'makeprg')
            local cmd = ok and val or vim.o.makeprg

            if cmd:sub(#cmd, #cmd) == '%' then
                cmd = cmd:gsub('%%', vim.fn.expand('%'))
            end

            cmd = cmd .. args

            require'jobs'.send_job{
                cmd = cmd,
                opts = {
                    on_exit = function(jobid, rc, _)
                        local jobs = require'jobs'
                        local lines = {}
                        if jobs.jobs[jobid].streams then
                            if #jobs.jobs[jobid].streams.stderr > 0 then
                                lines = jobs.jobs[jobid].streams.stderr
                            else
                                lines = jobs.jobs[jobid].streams.stdout
                            end
                        end

                        local qf_opts = jobs.jobs[jobid].qf or {}
                        qf_opts.lines = lines

                        require'tools'.helpers.dump_to_qf(qf_opts)
                    end
                },
                qf = {
                    -- open = false,
                    loc = true,
                    jump = true,
                    context = 'AsyncMake',
                    title = cmd,
                },
            }

        end,
        args = {nargs = '*', force = true}
    }
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
    rhs = function()
        local ok, _ = pcall(nvim.ex.pop)
        if not ok then
            local key = nvim.replace_termcodes("<C-o>", true, false, true)
            nvim.feedkeys(key, 'n', true)
            -- local jumps
            -- ok, jumps = pcall(nvim.exec, 'jumps', true)
            -- if ok and #jumps > 0 then
            --     jumps = vim.split(jumps, '\n')
            --     table.remove(jumps, 1)
            --     table.remove(jumps, #jumps)
            --     local current_jump
            --     for i=1,#jumps do
            --         local jump = vim.trim(jumps[i]);
            --         jump = split(jump, ' ');
            --         if jump[1] == 0 then
            --             current_jump = i;
            --         end
            --         jumps[i] = jump;
            --     end
            --     if current_jump > 1 then
            --         local current_buf = nvim.win.get_buf(0)
            --         local jump_buf = jumps[current_jump - 1][4]
            --         if current_buf ~= jump_buf then
            --             if not nvim.buf.is_valid(jump_buf) or not nvim.buf.is_loaded(jump_buf) then
            --                 nvim.ex.edit(jump_buf)
            --             end
            --         end
            --         nvim.win.set_cursor(0, jumps[current_jump - 1][2], jumps[current_jump - 1][3])
            --     end
            -- end
        end
    end,
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
        rhs = '<cmd>call mappings#bs()<CR>',
        args = noremap_silent,
    }
    set_mapping{
        mode = 'x',
        lhs = '<C-h>',
        rhs = '<cmd><ESC>',
        args = noremap,
    }
    if not nvim.g.started_by_firenvim then
        set_mapping{
            mode = 'n',
            lhs = '<C-z>',
            rhs = '<nop>',
            args = noremap,
        }
    end
else
    set_command{
        lhs = 'Chmod',
        rhs = function(mode)
            local filename = nvim.fn.expand('%')
            local files = require'tools'.files
            if not mode:match('^%d+$') then
                require'tools'.messages.echoerr('Not a valid permissions mode: '..mode)
                return
            end
            if files.is_file(filename) then
                files.chmod(filename, mode)
            end
        end,
        args = {nargs=1, force=true}
    }
end

if not get_mapping{ mode = 'n', lhs = '<C-L>' } then
    set_mapping{
        mode = 'n',
        lhs  = '<C-L>',
        rhs  = '<cmd>nohlsearch|diffupdate<CR>',
        args = noremap_silent,
    }
end

if executable('powershell') then
    set_command{
        lhs = 'PowershellToggle',
        rhs = 'call windows#toggle_powershell()',
        args = {force=true}
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
        rhs = '<cmd>diffoff!<BAR>only<CR>',
        args =noremap,
    }
    set_mapping{
        mode = 'n',
        lhs = '<C-w><C-o>',
        rhs = '<cmd>diffoff!<BAR>only<CR>',
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
    rhs = '<cmd>echo expand("%")<CR>',
    args = noremap,
}

-- set_mapping{
--     mode = 'n',
--     lhs = '<leader>c',
--     rhs = '<cmd>pclose<CR>',
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

-- set_mapping{ mode = 'n', lhs = '<leader>w', rhs = '<cmd>update<CR>', args = noremap }

set_mapping{ mode = 'n', lhs = '<leader>p', rhs = '<C-^>',       args = noremap }
set_mapping{ mode = 'n', lhs = '<leader>x', rhs = '<cmd>%!xxd<CR>',  args = noremap }

set_mapping{
    mode = 'n',
    lhs = '<leader>q',
    rhs = function()
        local tabs = nvim.list_tabpages()
        local wins = nvim.tab.list_wins(0)
        if #wins > 1 and nvim.fn.expand('%') ~= '[Command Line]' then
            nvim.win.hide(0)
        elseif #tabs > 1 then
            nvim.ex['tabclose!']()
        else
            nvim.exec('quit!', false)
        end
    end,
    args = noremap_silent,
}

set_mapping{ mode = 'n', lhs = '<leader>h', rhs = '<C-w>h', args = noremap }
set_mapping{ mode = 'n', lhs = '<leader>j', rhs = '<C-w>j', args = noremap }
set_mapping{ mode = 'n', lhs = '<leader>k', rhs = '<C-w>k', args = noremap }
set_mapping{ mode = 'n', lhs = '<leader>l', rhs = '<C-w>l', args = noremap }
-- set_mapping{ mode = 'n', lhs = '<leader>b', rhs = '<C-w>b', args = noremap }
-- set_mapping{ mode = 'n', lhs = '<leader>t', rhs = '<C-w>t', args = noremap }

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
set_mapping{ mode = 'n', lhs = '<leader>0', rhs = '<cmd>tablast<CR>', args = noremap }
set_mapping{ mode = 'n', lhs = '<leader><leader>n', rhs = '<cmd>tabnew<CR>', args = noremap }

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

set_mapping{ mode = 'n', lhs = '&', rhs = '<cmd>&&<CR>', args = noremap }
set_mapping{ mode = 'x', lhs = '&', rhs = '<cmd>&&<CR>', args = noremap }

set_mapping{ mode = 'n', lhs = '/',  rhs = 'ms/',    args = noremap }
set_mapping{ mode = 'n', lhs = 'g/', rhs = 'ms/\\v', args = noremap }
set_mapping{ mode = 'n', lhs = '0',  rhs = '^',      args = noremap }
set_mapping{ mode = 'n', lhs = '^',  rhs = '0',      args = noremap }

set_mapping{ mode = 'n', lhs = 'gV', rhs = '`[v`]', args = noremap }

set_mapping{ mode = 't', lhs = '<ESC>', rhs = '<C-\\><C-n>', args = noremap }

-- set_mapping{ mode = 'n', lhs = '<A-s>', rhs = '<C-w>s', args = noremap }
-- set_mapping{ mode = 'n', lhs = '<A-v>', rhs = '<C-w>v', args = noremap }

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
    rhs = [[<cmd>lua require'tools'.helpers.toggle_qf('loc')<CR>]],
    args = noremap_silent
}

set_mapping{
    mode = 'n',
    lhs = '=q',
    rhs = [[<cmd>lua require'tools'.helpers.toggle_qf('qf')<CR>]],
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

-- TODO: make this a "true" zoom and use <C-w>o wincmd
set_mapping{
    mode = 'n',
    lhs = '<C-w>z',
    rhs = function()
        nvim.t.zoom = not nvim.t.zoom
        if nvim.t.zoom then
            nvim.t.windows = nvim.fn.winrestcmd()
            nvim.ex.wincmd('_')
            nvim.ex.wincmd('|')
            nvim.ex['normal!']('zz')
        else
            nvim.command(nvim.t.windows)
            nvim.t.zoom = nil
            nvim.t.windows = nil
        end
    end,
    args = noremap_silent
}

-- TODO: Support Rsync
if executable('scp') then
    local function convert_path(path, send)
        path = realpath(normalize_path(path))

        local remote_path = './'
        local paths = {}
        local projects = {}
        local path_json = normalize_path('~/.config/remotes/paths.json')
        if is_file(path_json) then
            local configs = read_json(path_json) or {}
            paths = configs.paths or {}
            projects = configs.projects or  {}
        end

        local project = path:match('projects/([%w%d%.-_]+)')
        if not project then
            for short,full in pairs(projects) do
                if short ~= 'default' and path:match('/('..short..')[%w%d%.-_]*') then
                    project = full
                    break
                end
            end
            if not project then
                project = nvim.env.PROJECT or projects.default or 'mike'
            end
        end

        for loc,remote in pairs(paths) do
            if loc:match('%%PROJECT') then
                loc = loc:gsub('%%PROJECT', project)
            end
            loc = normalize_path(loc)
            if path:match(loc) then
                local tail = path:gsub(loc, '')
                if remote:match('%%PROJECT') then
                    remote = remote:gsub('%%PROJECT', project)
                end
                remote_path = remote .. '/' .. tail
                break
            end
        end

        if not send and remote_path == './' then
            remote_path = remote_path .. basename(path)
        end

        return remote_path
    end

    local function remote_cmd(host, send)

        local filename = nvim.fn.expand('%')
        local virtual_filename

        if filename:match('^[%w%d_]+://') then
            if filename:match('^fugitive://') then
                filename = filename:gsub('%.git/+%d+/+', '')
            end
            filename = filename:gsub('^[%w%d_]+://', '')
            virtual_filename = nvim.fn.tempname()
        end

        assert(is_file(filename), 'Not a regular file '..filename)

        if virtual_filename and send then
            writefile(virtual_filename, nvim.buf.get_lines(0, 0, -1, true))
        end

        local remote_path = ('%s:%s'):format(host, convert_path(filename, send))
        local rcmd = [[scp -r "%s" "%s"]]
        if send then
            rcmd = rcmd:format(virtual_filename or filename, remote_path)
        else
            rcmd = rcmd:format(remote_path, virtual_filename or filename)
        end
        return rcmd
    end

    local function get_host(host)
        if not host or host == '' then
            host = nvim.fn.input('Enter hostname > ', '', 'customlist,mappings#ssh_hosts_completion')
            assert(type(host) == 'string' and host ~= '', 'Invalid hostname')
        end
        return host
    end

    set_command{
        lhs = 'SendFile',
        rhs = function(host)
            host = get_host(host)
            local cmd = remote_cmd(host, true)
            require'jobs'.send_job{
                cmd = cmd,
                opts = {
                    pty = true,
                },
            }
        end,
        args = {
            nargs = '*',
            force = true,
            complete = 'customlist,mappings#ssh_hosts_completion'
        }
    }

    set_command{
        lhs = 'GetFile',
        rhs = function(host)
            host = get_host(host)
            local cmd = remote_cmd(host, false)
            require'jobs'.send_job{
                cmd = cmd,
                opts = {
                    pty = true,
                },
            }
        end,
        args = {
            nargs = '*',
            force = true,
            complete = 'customlist,mappings#ssh_hosts_completion'
        }
    }

    set_mapping{
        mode = 'n',
        lhs = '<leader><leader>s',
        rhs = '<cmd>SendFile<CR>',
        args = {noremap = true, silent = true},
    }

    set_mapping{
        mode = 'n',
        lhs = '<leader><leader>g',
        rhs = '<cmd>GetFile<CR>',
        args = {noremap = true, silent = true},
    }

end

local scratchs = {}

set_command{
    lhs = 'Scratch',
    rhs = function(ft)
        ft = (ft and ft ~= '') and ft or nvim.bo.filetype
        scratchs[ft] = scratchs[ft] or nvim.fn.tempname()
        local buf = nvim.fn.bufnr(scratchs[ft], true)

        if ft and ft ~= '' then
            nvim.buf.set_option(buf, 'filetype', ft)
        end
        nvim.buf.set_option(buf, 'bufhidden', 'hide')

        local wins = nvim.tab.list_wins(0)
        local scratch_win

        for _,win in pairs(wins) do
            if nvim.win.get_buf(win) == buf then
                scratch_win = win
                break
            end
        end

        if not scratch_win then
            scratch_win = nvim.open_win(
                buf,
                true,
                {relative='editor', width=1, height=1, row=1, col=1}
            )
        end

        nvim.set_current_win(scratch_win)
        nvim.ex.wincmd('K')
    end,
    args = {
        nargs = '?',
        force = true,
        complete = 'filetype'
    }
}

if executable('cscope') then
    local function cscope(cword, action)
        local actions = {
            definition = 'find g',
            callers = 'find c',
            file = 'find f',
            text = 'find t',
        }
        cword = (cword and cword ~= '') and cword or nvim.fn.expand('<cword>')
        action = actions[action] or 'g'
        nvim.ex.cscope(action..' '..cword)
    end

    set_command{
        lhs = 'CDefinition',
        rhs = function(cword)
            cscope(cword, 'definition')
        end,
        args = {nargs='?', force = true}
    }

    set_command{
        lhs = 'CCallers',
        rhs = function(cword)
            cscope(cword, 'callers')
        end,
        args = {nargs='?', force = true}
    }

    set_command{
        lhs = 'CFile',
        rhs = function(cword)
            cscope(cword, 'file')
        end,
        args = {complete='file', nargs='?', force = true}
    }

    set_command{
        lhs = 'CText',
        rhs = function(cword)
            cscope(cword, 'text')
        end,
        args = {nargs='?', force = true}
    }
end

pcall(require, 'host/mappings')

return true

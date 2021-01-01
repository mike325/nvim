local sys          = require'sys'
local nvim         = require'nvim'
local load_module  = require'tools'.helpers.load_module

local executable   = nvim.executable
local filereadable = nvim.filereadable

local iron = load_module'iron'

if iron == nil then
    return false
end

local preferred = {}
local definitions = {}
local default = ''

-- local python = require'python'
-- local python_executable = python['3'].version ~= nil and python['3'].path or python['2'].path

if nvim.env.SHELL ~= nil then
    iron.core.add_repl_definitions {
        c = {
            shell = {
                command = {nvim.env.SHELL}
            }
        },
        cpp = {
            shell = {
                command = {nvim.env.SHELL}
            }
        }
    }

    preferred['c'] = 'shell'
    preferred['cpp'] = 'shell'
end

-- iron.core.add_repl_definitions{
--     python = {
--         django = {
--             command = {python_executable, './manage.py', 'shell'},
--         },
--     },
-- }

-- TODO: Find a way to detect available COM ports
-- TODO: Handle WSL
if executable('rshell') and sys.name ~= 'windows' then
    iron.core.add_repl_definitions{
        python = {
            micropython = {
                command = {'rshell', '-p', '/dev/ttyUSB0'},
            },
        },
    }
end

if executable('ipython') then
    preferred['python'] = 'ipython'
end

if sys.name == 'windows' then
    local wsl = {
        'debian',
        'ubuntu',
        'fedora',
    }

    for _, distro in pairs(wsl) do
        if filereadable(sys.home..'/AppData/Local/Microsoft/WindowsApps/'..distro..'.exe') then
            definitions[distro] = {
                command = {distro}
            }
            if default == '' then
                default = distro
            end
        end
    end

    if #definitions > 0 then
        iron.core.add_repl_definitions{
            sh = definitions,
        }
        preferred['sh'] = default
    end
else
    preferred['sh'] = 'bash'
end

iron.core.set_config{
    preferred = preferred,
    repl_open_cmd = 'botright split',
}

nvim.g.iron_map_defaults = 0
nvim.g.iron_map_extended = 0

if nvim.has('nvim-0.4') then
    nvim.nvim_set_mapping{
        mode = 'n',
        lhs = 'gs',
        rhs = '<Plug>(iron-send-motion)',
    }
    nvim.nvim_set_mapping{
        mode = 'v',
        lhs = 'gs',
        rhs = '<Plug>(iron-visual-send)',
    }
    nvim.nvim_set_mapping{
        mode = 'n',
        lhs = 'gsr',
        rhs = '<Plug>(iron-repeat-cmd)',
    }
    nvim.nvim_set_mapping{
        mode = 'n',
        lhs = '<leader><leader>l',
        rhs = '<Plug>(iron-send-line)',
    }
    nvim.nvim_set_mapping{
        mode = 'n',
        lhs = 'gs<CR>',
        rhs = '<Plug>(iron-cr)',
    }
    nvim.nvim_set_mapping{
        mode = 'n',
        lhs = 'gsq',
        rhs = '<Plug>(iron-exit)',
    }
    nvim.nvim_set_mapping{
        mode = 'n',
        lhs = '=r', rhs = ':IronRepl<CR><ESC>',
        args = {noremap = true, silent = true},
    }
else
    nvim.command('nmap              gs                   <Plug>(iron-send-motion)')
    nvim.command('nmap              gs                   <Plug>(iron-visual-send)')
    nvim.command('nmap              gsr                  <Plug>(iron-repeat-cmd)')
    nvim.command('nmap              <leader><leader>l    <Plug>(iron-send-line)')
    nvim.command('nmap              gs<CR>               <Plug>(iron-cr)')
    nvim.command('nmap              gsq                  <Plug>(iron-exit)')
    nvim.command('nnoremap <silent> =r                   :IronRepl<CR><ESC>')
end

return true

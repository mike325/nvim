local nvim         = require('nvim')
local sys          = require('sys')
local floating     = require('floating').window
local executable   = require('nvim').fn.executable
local filereadable = require('nvim').fn.filereadable

local python = require('python')

local configs = {
    iron = function(m)

        local python_executable = python['3'].version ~= nil and python['3'].path or python['2'].path

        m.core.add_repl_definitions{
            python = {
                django = {
                    command = {python_executable, './manage.py', 'shell'},
                },
            },
        }

        local preferred = {}

        if executable('ipython') == 1 then
            preferred['python'] = 'ipython'
        end

        if sys.name == 'windows' then
            local wsl = {
                'debian',
                'ubuntu',
                'fedora',
            }

            local definitions = {}
            local default = ''

            for _,distro in ipairs(wsl) do
                if filereadable(sys.home..'/AppData/Local/Microsoft/WindowsApps/'..distro..'.exe') == 1 then
                    definitions[distro] = {
                        command = {distro}
                    }
                    if default == '' then
                        default = distro
                    end
                end
            end

            if #definitions > 0 then
                m.core.add_repl_definitions{
                    sh = definitions,
                }
                preferred['sh'] = default
            end
        else
            preferred['sh'] = 'bash'
        end

        m.core.set_config({
            preferred = preferred,
            repl_open_cmd = 'botright split',
        })

        nvim.g.iron_map_defaults = 0
        nvim.g.iron_map_extended = 0

        if nvim.has('nvim-0.4') then
            nvim.nvim_set_mapping('n', 'gs', '<Plug>(iron-send-motion)')
            nvim.nvim_set_mapping('v', 'gs', '<Plug>(iron-visual-send)')
            nvim.nvim_set_mapping('n', 'gsr', '<Plug>(iron-repeat-cmd)')
            nvim.nvim_set_mapping('n', '<leader><leader>l', '<Plug>(iron-send-line)')
            nvim.nvim_set_mapping('n', 'gs<CR>', '<Plug>(iron-cr)')
            nvim.nvim_set_mapping('n', 'gsq', '<Plug>(iron-exit)')
            nvim.nvim_set_mapping('n', '=r', ':IronRepl<CR><ESC>', {noremap = true, silent = true})
        else
            nvim.command('nmap              gs                   <Plug>(iron-send-motion)')
            nvim.command('nmap              gs                   <Plug>(iron-visual-send)')
            nvim.command('nmap              gsr                  <Plug>(iron-repeat-cmd)')
            nvim.command('nmap              <leader><leader>l    <Plug>(iron-send-line)')
            nvim.command('nmap              gs<CR>               <Plug>(iron-cr)')
            nvim.command('nmap              gsq                  <Plug>(iron-exit)')
            nvim.command('nnoremap <silent> =r                   :IronRepl<CR><ESC>')
        end

    end,
}

for name,setup in pairs(configs) do
    local ok, rc = pcall(require, name)
    if ok then
        setup(rc)
    end
end

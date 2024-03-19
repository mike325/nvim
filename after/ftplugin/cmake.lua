local executable = require('utils.files').executable

if executable('cmake') then
    require('utils.buffers').setup()
end

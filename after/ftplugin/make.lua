local executable = require('utils.files').executable

if executable 'make' then
    RELOAD('filetypes.make').setup()
end

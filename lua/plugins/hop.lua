local load_module = require('utils.helpers').load_module
local set_mapping = require('neovim.mappings').set_mapping

local hop = load_module 'hop'

if not hop then
    return false
end

hop.setup {}

set_mapping {
    mode = 'n',
    lhs = 'f',
    rhs = "<cmd>lua require'hop'.hint_char1()<CR>",
    args = { noremap = true },
}

set_mapping {
    mode = 'n',
    lhs = 'F',
    rhs = "<cmd>lua require'hop'.hint_char1()<CR>",
    args = { noremap = true },
}

set_mapping {
    mode = 'n',
    lhs = 't',
    rhs = "<cmd>lua require'hop'.hint_char1()<CR>",
    args = { noremap = true },
}

set_mapping {
    mode = 'n',
    lhs = 'T',
    rhs = "<cmd>lua require'hop'.hint_char1()<CR>",
    args = { noremap = true },
}

return true

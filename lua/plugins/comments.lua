local load_module = require('utils.functions').load_module

local comment = load_module 'Comment'
if not comment then
    return false
end

comment.setup {}

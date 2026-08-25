local M = {
    select = {
        ['af'] = '@conditional.outer',
        ['if'] = '@conditional.inner',
        ['am'] = '@function.outer', -- Same as [m, ]m "method"
        ['im'] = '@function.inner',
        ['ak'] = '@class.outer',
        ['ik'] = '@class.inner',
        ['ia'] = '@parameter.inner',
        ['aa'] = '@parameter.inner',
        ['ir'] = '@loop.inner', -- "repeat" mnemonic
        ['ar'] = '@loop.outer',
        ['ac'] = '@comment.outer',
        ['ic'] = '@comment.outer',
    },
    swap = {
        swap_next = {
            -- ["<leader>k"] = "@class.outer",
            -- ["<leader>f"] = "@loop.outer",
            -- ["<leader>c"] = "@comment.outer",
            ['<leader>f'] = '@conditional.outer',
            ['<leader>a'] = '@parameter.inner',
            ['<leader>m'] = '@function.outer',
        },
        swap_previous = {
            -- ["<leader><leader>k"] = "@class.outer",
            -- ["<leader><leader>f"] = "@loop.outer",
            -- ["<leader><leader>c"] = "@comment.outer",
            ['<leader><leader>f'] = '@conditional.outer',
            ['<leader><leader>a'] = '@parameter.inner',
            ['<leader><leader>m'] = '@function.outer',
        },
    },
    move = {
        previous = {
            range_start = {
                ['[f'] = '@conditional.outer',
                ['[m'] = '@function.outer',
                ['[k'] = '@class.outer',
                ['[r'] = '@loop.outer',
                ['[C'] = '@comment.outer',
                -- ['[a'] = '@parameter.inner',
            },
            range_end = {
                ['[F'] = '@conditional.outer',
                ['[M'] = '@function.outer',
                ['[K'] = '@class.outer',
                ['[R'] = '@loop.outer',
                -- ['[C'] = '@comment.outer',
                -- ['[A'] = '@parameter.inner',
            },
        },
        next = {
            range_start = {
                [']f'] = '@conditional.outer',
                [']m'] = '@function.outer',
                [']k'] = '@class.outer',
                [']r'] = '@loop.outer',
                [']C'] = '@comment.outer',
                -- [']a'] = '@parameter.inner',
            },
            range_end = {
                [']F'] = '@conditional.outer',
                [']M'] = '@function.outer',
                [']K'] = '@class.outer',
                [']R'] = '@loop.outer',
                -- [']C'] =  '@comment.outer',
                -- [']A'] = '@parameter.inner',
            },
        },
    },
}

return M

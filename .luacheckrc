-- vim: ft=lua tw=80

-- Rerun tests only if their modification time changed.
std = 'luajit'
cache = true

ignore = {
    "212", -- Unused argument
    "121", -- Setting global variable values
    "122", -- Setting global variable fields
}

read_globals = {
    "packer_plugins",
    "bit",
    "vim",
    "nvim",
    "python",
    "P",
    "RELOAD",
    "PASTE",
    "STORAGE",
    "ASYNC",
    "use",
    "use_rocks",
    "describe",
    "it",
    "before_each",
    "after_each",
    "setup",
    "teardown",
    "assert",
}

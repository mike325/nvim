-- vim: ft=lua tw=80

-- Rerun tests only if their modification time changed.
std = 'luajit'
cache = true

ignore = {
    "212", -- Unused argument
}

read_globals = {
    "bit",
    "vim",
    "nvim",
    "python",
    "P",
    "RELOAD",
    "PASTE",
    "use",
    "use_rocks",
}

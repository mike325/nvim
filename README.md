    ███╗   ███╗██╗██╗  ██╗███████╗    ██████╗  █████╗
    ████╗ ████║██║██║ ██╔╝██╔════╝   ██╔═══██╗██╔══██╗
    ██╔████╔██║██║█████╔╝ █████╗     ████████║███████║
    ██║╚██╔╝██║██║██╔═██╗ ██╔══╝     ██╔═══██║██╔══██║
    ██║ ╚═╝ ██║██║██║  ██╗███████╗   ╚██████╔╝██║  ██║
    ╚═╝     ╚═╝╚═╝╚═╝  ╚═╝╚══════╝    ╚═════╝ ╚═╝  ╚═╝
---

This repo have mi personal Vim/Neovim settings that I have been collecting
for a while, feel free to change anything to fit your needs or suggest me
something that you think could be useful.

Since I use Vim in quite different environments my settings tries to get
the same behavior, as much as possible, for most of the cases.

This settings require Vim >= 7.4 or Neovim >= 0.17,
**python** and **lua** support are optional **but** highly recommend!

I have personally tested this configurations in the following environment:

* Linux
    * Debian 8/8.5 jessie
        - Vim 7.4.143

    * Ubuntu 14.04 trusty
        - Vim 7.4.52
        - Neovim 0.17

    * SUSE Linux Enterprise Server 11
        - Vim 8.0.104

    * openSUSE 13.2
        - Vim 8.0.104

    * Archlinux
        - Vim 8.0.427
        - Neovim 0.17

* Android (In my nexus 6 via Termux)
    * Marshmallow 6.0/6.1
        - Vim 8.0.0104 (without python modules)
        - Neovim 0.2-dev (without python modules)

    * Nougat 7.0
        - Vim 8.0.0104 (without python modules)
        - Neovim 0.2-dev (without python modules)

* Windows 8.1
    * Cygwin
        - Vim 8.0.94
    * Git bash (some problems loading python modules)
        - Vim 8.0.27
    * gVim 8.0 64 bits

**Note**: I have not use this settings on a Mac, because I don't have one, feel
free to use my vim files and tell me if they worked for you.

## Install
---

You can test my settings by cloning this repo into your `$HOME`

```
git clone --recursive https://git.prodeveloper.me/mike/.vim.git ~/.vim

ln -s ~/.vim/init.vim ~/.vimrc
```

If you are using gVim in Windows you may want to use the following procedure:
(inside git bash)
```
git clone --recursive https://git.prodeveloper.me/mike/.vim.git ~/vimfiles

cp ~/vimfiles/init.vim ~/_vimrc
```

If you are using [Neovim](https://neovim.io/) you just need to move the repo
to `~/.config/nvim`

    mv ~/.vim ~/.config/nvim

or just clone it there

    git clone --recursive https://git.prodeveloper.me/mike/.vim.git ~/.config/nvim

To use Neovim in Windows (highly unstable and not well tested) clone the repo
in the following location

    git clone --recursive https://git.prodeveloper.me/mike/.vim.git ~/AppData/Local/nvim/

Once you have cloned the repo just run `:PlugInstall` inside Vim/Neovim to
complete the installation process.

If you want to deactivate some plugins just comment its line in the init.vim, ex.
`" Plug 'majutsushi/tagbar'`. And run `:PlugClean` to delete the plugin.

Feel free to change anything to fit your needs!

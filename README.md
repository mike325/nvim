# Vimrc

```shell
                                                             -`
                                             ...            .o+`
                                          .+++s+   .h`.    `ooo/
                                         `+++%++  .h+++   `+oooo:
                                         +++o+++ .hhs++. `+oooooo:
                                         +s%%so%.hohhoo'  'oooooo+:
                                         `+ooohs+h+sh++`/:  ++oooo+:
                                          hh+o+hoso+h+`/++++.+++++++:
                                           `+h+++h.+ `/++++++++++++++:
                                                    `/+++ooooooooooooo/`
                                                   ./ooosssso++osssssso+`
                                                  .oossssso-````/osssss::`
                                                 -osssssso.      :ssss``to.
                                                :osssssss/  Mike  osssl   +
                                               /ossssssss/   8a   +sssslb
                                             `/ossssso+/:-        -:/+ossss'.-
                                            `+sso+:-`                 `.-/+oso:
                                           `++:.                           `-/+/
                                           .`                                 `/
```


This repo have mi personal Vim/Neovim settings that I have been collecting for a while, feel free to change
anything to fit your needs or suggest me something that you think could be useful.

This settings require Vim >= 7.4 or Neovim >= 0.17 with **python** and **lua** support and **ctags**.

I have personally test this configurations in the following environment:

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
        - Vim 8.0.94
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
    * Gvim 8.0 64 bits

You can test my settings by cloning this repo into your `$HOME`

```
git clone --recursive https://github.com/mike325/.vim.git ~/.vim

ln -s ~/.vim/init.vim ~/.vimrc
```

If you are using GVim in Windows you may want to use the following procedure:
(inside git bash)
```
git clone --recursive https://github.com/mike325/.vim.git ~/vimfiles

cp ~/vimfiles/init.vim ~/_vimrc
```

If you are using [Neovim](https://neovim.io/) you just need to move the repo to `~/.config/nvim`

    mv ~/.vim ~/.config/nvim

or just clone it there

    git clone --recursive https://github.com/mike325/.vim.git ~/.config/nvim

To use Neovim in Windows (highly unstable and not well tested) clone the repo
in the following location

    git clone --recursive https://github.com/mike325/.vim.git ~/AppData/Local/nvim/

Once you have cloned the repo just run `:PlugInstall` inside Vim/Neovim to complete the installation process.

Included plugins:
- Default plugins
    * [Vim-colorschemes](https://github.com/flazz/vim-colorschemes)
    * [neoSolarized](https://github.com/icymind/NeoSolarized)
    * [Gruvbox](https://github.com/morhetz/gruvbox)
    * [DelimitMate](https://github.com/Raimondi/delimitMate)
    * [Nerdtree](https://github.com/scrooloose/nerdtree)
    * [Nerdcommenter](https://github.com/scrooloose/nerdcommenter)
    * [Vim-airline](https://github.com/vim-airline/vim-airline)
    * [Vim-airline-themes](https://github.com/vim-airline/vim-airline-themes)
    * [Vim-airline-clock](https://github.com/enricobacis/vim-airline-clock)
    * [Vim-gitgutter](https://github.com/airblade/vim-gitgutter)
    * [Vim-fugitive](https://github.com/tpope/vim-fugitive)
    * [Committia.vim](https://github.com/rhysd/committia.vim)
    * [Vim-git](https://github.com/tpope/vim-git)
    * [Tabular](https://github.com/godlygeek/tabular)
    * [Vim-surround](https://github.com/tpope/vim-surround)
    * [Vim-bbye](https://github.com/moll/vim-bbye)
    * [Vim-signature](https://github.com/kshenoy/vim-signature)
    * [Ctrlp.vim](https://github.com/kien/ctrlp.vim)
    * [Vim-misc](https://github.com/xolox/vim-misc)
    * [Vim-session](https://github.com/xolox/vim-session)
    * [Hexmode](https://github.com/fidian/hexmode)
    * [Vim-snippets](https://github.com/honza/vim-snippets)
    * [Vim-move](https://github.com/matze/vim-move)
    * [Vim-abolish](https://github.com/tpope/vim-abolish)
    * [Vim-repeat](https://github.com/tpope/vim-repeat)
    * [IndentLine](https://github.com/Yggdroot/indentLine)
    * [Vim-pasta](https://github.com/sickill/vim-pasta)
    * [Vim-autoformat](https://github.com/chiel92/vim-autoformat)
    * [Vim-grepper](https://github.com/mhinz/vim-grepper)
    * [dockerfile.vim](https://github.com/ekalinin/Dockerfile.vim)
    * [Vim-json](https://github.com/elzr/vim-json)
    * [Vim-lua](https://github.com/tbastos/vim-lua)
    * [Vim-cpp-enhanced-highlight](https://github.com/octol/vim-cpp-enhanced-highlight)
    * [Vim-qml](https://github.com/peterhoeg/vim-qml)
    * [Vimtex](https://github.com/lervag/vimtex)
    * [Vim-windowswap](https://github.com/wesQ3/vim-windowswap)

- If go is install
    * [Vim-go](https://github.com/fatih/vim-go)

- If Vim is running (instead of NeoVim)
    * [Vim-sensible](https://github.com/tpope/vim-sensible)

- If ctags is install
    * [Tagbar](https://github.com/majutsushi/tagbar)

- If vim 8 of neovim is running
    * [Neomake](https://github.com/neomake/neomake)

- If python interface is available
    * [Ultisnips](https://github.com/SirVer/ultisnips)
    * [Python-mode](https://github.com/python-mode/python-mode)

    - If python3 interface is available and Neovim is running
        * [Deoplete](https://github.com/Shougo/deoplete.nvim)
        * [Deoplete-jedi](https://github.com/zchee/deoplete-jedi)
        * [Deoplete-clang](https://github.com/zchee/deoplete-clang)
        * [Deoplete-go](https://github.com/zchee/deoplete-go)
        * [Deoplete-ternjs](https://github.com/carlitux/deoplete-ternjs)
        * [Vim-javacomplete2](https://github.com/artur-shaik/vim-javacomplete2)

    - If Deoplete could not be installed
        * [YouCompleteMe](https://github.com/Valloric/YouCompleteMe)
        * [Ycm-generator](https://github.com/rdnetto/ycm-generator)

    - If YouCompleteMe was not installed
        * [Jedi](https://github.com/davidhalter/jedi-vim)

    - If Neomake was not available
        * [Syntactic](https://github.com/vim-syntastic/syntastic)

- If python interface is not available
    * [Vim-addon-mw-utils](https://github.com/MarcWeber/vim-addon-mw-utils)
    * [Tlib_vim](https://github.com/tomtom/tlib_vim)
    * [Vim-snipmate](https://github.com/garbas/vim-snipmate)

- If YouCompleteMe and Deoplete were not installed and lua is available
    * [NeoComplete](https://github.com/Shougo/neocomplete.vim)

- If NeoComplete was not installed is not available
    * [SimpleAutoComplPop](https://github.com/roxma/SimpleAutoComplPop)
    * [Supertab](https://github.com/ervandew/supertab)

If you want to deactivate some plugins just comment its line in the init.vim, ex. `" Plug 'majutsushi/tagbar'`.
And run `:PlugClean` to delete the plugin.

Feel free to change anything to fit your needs!

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

If you are using Gvim in Windows you may want to use the following procedure:
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
    * [Vim Sensible](https://github.com/tpope/vim-sensible) (Not necessary in Neovim)
    * [Colorschemes](https://github.com/flazz/vim-colorschemes)
    * [deliMate](https://github.com/Raimondi/delimitMate)
    * [NeoSolarized](https://github.com/icymind/NeoSolarized)
    * [Gruvbox](https://github.com/morhetz/gruvbox)
    * [NERDTree](https://github.com/scrooloose/nerdtree)
    * [NERDCommenter](https://github.com/scrooloose/nerdcommenter)
    * [Vim Airline](https://github.com/vim-airline/vim-airline)
    * [Vim Airline Themes](https://github.com/vim-airline/vim-airline-themes)
    * [Gitgutter](https://github.com/airblade/vim-gitgutter)
    * [Fugitive](https://github.com/tpope/vim-fugitive)
    * [Vim-git](https://github.com/tpope/vim-git)
    * [Committia](https://github.com/rhysd/committia.vim)
    * [Tabular](https://github.com/godlygeek/tabular)
    * [EasyMotions](https://github.com/easymotion/vim-easymotion)
    * [Surround](https://github.com/tpope/vim-surround)
    * [BufferBye](https://github.com/moll/vim-bbye)
    * [Signature](https://github.com/kshenoy/vim-signature)
    * [CtrP](https://github.com/kien/ctrlp.vim)
    * [Vim misc](https://github.com/xolox/vim-misc)
    * [Sessions](https://github.com/xolox/vim-session)
    * [Hexmode](https://github.com/fidian/hexmode)
    * [Snippets](https://github.com/honza/vim-snippets)
    * [Move](https://github.com/matze/vim-move)
    * [MacroEdit](https://github.com/dohsimpson/vim-macroeditor)
    * [Tagbar](https://github.com/majutsushi/tagbar) (Only if ctags has been installed)
    * [Abolish](https://github.com/tpope/vim-abolish)
    * [Repeat](https://github.com/tpope/vim-repeat)
    * [indentLine](https://github.com/Yggdroot/indentLine)
    * [Pasta](https://github.com/sickill/vim-pasta)
    * [Autoformat](https://github.com/chiel92/vim-autoformat)
    * [Neomake](https://github.com/neomake/neomake) (Only available for Neovim and Vim 8)
    * [Switch](https://github.com/AndrewRadev/switch.vim)
    * [Vim-go](https://github.com/fatih/vim-go)
    * [Grepper](https://github.com/mhinz/vim-grepper)
    * [EasyTags](https://github.com/xolox/vim-easytags) (Only if ctags has been installed)
    * [Dockerfile.vim](https://github.com/ekalinin/Dockerfile.vim)
    * [Vim-json](https://github.com/elzr/vim-json)
    * [Vim-lua](https://github.com/tbastos/vim-lua)
    * [Vim-cpp-enhanced-highlight](https://github.com/octol/vim-cpp-enhanced-highlight)
    * [Python-mode](https://github.com/python-mode/python-mode)
    * [Vim-qml](https://github.com/peterhoeg/vim-qml)
    * [Vimtex](https://github.com/lervag/vimtex)
    * [Vim-windowswap](https://github.com/wesQ3/vim-windowswap)

- If python interface is available
    * [Ultisnips](https://github.com/SirVer/ultisnips)

    - If python3 interface is available and Neovim is running
        * [Deoplete](https://github.com/Shougo/deoplete.nvim)
        * [Deoplete-jedi](https://github.com/zchee/deoplete-jedi)
        * [Deoplete-clang](https://github.com/zchee/deoplete-clang)
        * [Deoplete-go](https://github.com/zchee/deoplete-go)
        * [deoplete-ternjs](https://github.com/carlitux/deoplete-ternjs)
        * [Vim-javacomplete2](https://github.com/artur-shaik/vim-javacomplete2)

    - If Deoplete could not be installed
        * [YouCompleteMe](https://github.com/Valloric/YouCompleteMe)
        * [Ycm-generator](https://github.com/rdnetto/ycm-generator)

    - If YouCompleteMe was not installed
        * [Jedi](https://github.com/davidhalter/jedi-vim)

    - If Neomake was not available
        * [Syntactic](https://github.com/vim-syntastic/syntastic)

- If python interface is not available
    * [Addons mw ultis](https://github.com/MarcWeber/vim-addon-mw-utils)
    * [Tlib](https://github.com/tomtom/tlib_vim)
    * [SnipMate](https://github.com/garbas/vim-snipmate)

- If YouCompleteMe was not installed and Neovim is being used

- If YouCompleteMe was not installed and lua is available
    * [NeoComplete](https://github.com/Shougo/neocomplete.vim)

- If YouCompleteMe was not installed and lua is not available
    * [SimpleAutoComplPop](https://github.com/roxma/SimpleAutoComplPop)
    * [Supertab](https://github.com/ervandew/supertab)

If you want to deactivate some plugins just comment its line in the init.vim, ex. `" Plug 'majutsushi/tagbar'`.
And run `:PlugClean` to delete the plugin.

Feel free to change anything to fit your needs!

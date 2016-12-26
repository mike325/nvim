# Vimrc
This repo have mi personal Vim/Neovim setings that I have been collecting for a while, feel free to change
anything to fit your needs or suggest me something that you think could be useful.

This settings require Vim >= 7.4 or Neovim >= 0.12 with **python** and **lua** support and **ctags**.

I have personally tested this configurations in the following environments:

* Linux
    * Debian 8/8.5 jessie
        - Vim 7.4.143

    * Ubuntu 14.04 trusty
        - Vim 7.4.52

    * Archlinux
        - Vim 8.0.94
        - Neovim 0.15

* Android (In my nexus 6 via Termux)
    * Marshmallow 6.0/6.1 
        - Vim 8.0.0104 (without python modules)
        - Neovim 0.2-dev (without python modules)

    * Nougat 7.0
        - Vim 8.0.0104 (without python modules)
        - Neovim 0.2-dev (without python modules)

* Windows
    * Cygwin 
        - Vim 8.0.94
    * Git bash (some problems loading python modules)
        - Vim 8.0.27

You can test my settings by clonning this repo into your `$HOME`

```
git clone --recursive https://github.com/mike325/.vim.git ~/.vim

ln -s ~/.vim/init.vim ~/.vimrc
```

If you are using [Neovim](https://neovim.io/) you just need to move the repo to `~/.config/nvim`
    
    mv ~/.vim ~/.config/nvim

or just clone it there

    git clone --recursive https://github.com/mike325/.vim.git ~/.config/nvim

Included plugins:

* [Airline-themes](https://github.com/vim-airline/vim-airline-themes/)
* [Airline](https://github.com/vim-airline/vim-airline/)
* [Bufferbye](https://github.com/moll/vim-bbye)
* [Colorschemes](https://github.com/flazz/vim-colorschemes)
* [Ctrlp](https://github.com/kien/ctrlp.vim)
* [DelimitMate](https://github.com/Raimondi/delimitMate.git)
* [dockerfile](https://github.com/ekalinin/Dockerfile.vim)
* [Easymotion](https://github.com/easymotion/vim-easymotion)
* [Fugitive](https://github.com/tpope/vim-fugitive)
* [Gitglutter](https://github.com/airblade/vim-gitgutter)
* [Multicursors](https://github.com/terryma/vim-multiple-cursors)
* [Nerdcommenter](https://github.com/scrooloose/nerdcommenter)
* [Nerdtree-tabs](https://github.com/jistr/vim-nerdtree-tabs)
* [Nerdtree](https://github.com/scrooloose/nerdtree)
* [Polyglot](https://github.com/sheerun/vim-polyglot)
* [Sensible](https://github.com/tpope/vim-sensible)
* [Sessions](https://github.com/xolox/vim-session)
* [Signature](https://github.com/kshenoy/vim-signature)
* [Snippets](https://github.com/honza/vim-snippets)
* [Supertab](https://github.com/ervandew/supertab)
* [Tabular](https://github.com/godlygeek/tabular)
* [Tagbar](https://github.com/majutsushi/tagbar)
* [Ultisnips](https://github.com/SirVer/ultisnips)
* [Vim-misc](https://github.com/xolox/vim-misc)
* [Vim-surround](https://github.com/tpope/vim-surround)
* [Jedi](https://github.com/davidhalter/jedi-vim)
* [Hexmode](https://github.com/fidian/hexmode)

If you want to test a more specific configuration or you don't have **python**, **lua** or **ctags** 
try to clone the repo and then init the submodules that you want to setup.

```
git clone https://github.com/mike325/.vim.git ~/.vim
ln -s ~/.vim/init.vim ~/.vimrc
cd ~/.vim
git submodule update --init --recursive bundle/nerdtree
```
Feel free to change anything to fit your needs! 

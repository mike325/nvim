# Vimrc
This repo have mi personal Vim/Neovim setings that I have been collecting for a while, feel free to change
anything to fit your needs or suggest me something that you think could be useful.

*This settings require Vim >= 7.4 or Neovim >= 0.12 with **python** and **lua** support and **ctags**.*

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

I you 

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

* [airline-themes](https://github.com/vim-airline/vim-airline-themes/)
* [airline](https://github.com/vim-airline/vim-airline/)
* [bufferbye](https://github.com/moll/vim-bbye)
* [colorschemes](https://github.com/flazz/vim-colorschemes)
* [ctrlp](https://github.com/kien/ctrlp.vim)
* [delimitMate](https://github.com/Raimondi/delimitMate.git)
* [Dockerfile](https://github.com/ekalinin/Dockerfile.vim)
* [easymotion](https://github.com/easymotion/vim-easymotion)
* [fugitive](https://github.com/tpope/vim-fugitive)
* [gitglutter](https://github.com/airblade/vim-gitgutter)
* [multicursors](https://github.com/terryma/vim-multiple-cursors)
* [nerdcommenter](https://github.com/scrooloose/nerdcommenter)
* [nerdtree-tabs](https://github.com/jistr/vim-nerdtree-tabs)
* [nerdtree](https://github.com/scrooloose/nerdtree)
* [polyglot](https://github.com/sheerun/vim-polyglot)
* [sensible](https://github.com/tpope/vim-sensible)
* [sessions](https://github.com/xolox/vim-session)
* [signature](https://github.com/kshenoy/vim-signature)
* [snippets](https://github.com/honza/vim-snippets)
* [supertab](https://github.com/ervandew/supertab)
* [tabular](https://github.com/godlygeek/tabular)
* [tagbar](https://github.com/majutsushi/tagbar)
* [ultisnips](https://github.com/SirVer/ultisnips)
* [vim-misc](https://github.com/xolox/vim-misc)
* [vim-surround](https://github.com/tpope/vim-surround)
* [jedi](https://github.com/davidhalter/jedi-vim)
* [hexmode](https://github.com/fidian/hexmode)

If you want to test a more specific configuration or you don't have **python**, **lua** or **ctags** try to clone the repo 
and then init the submodules that you want to setup.

```
git clone https://github.com/mike325/.vim.git ~/.vim
ln -s ~/.vim/init.vim ~/.vimrc
cd ~/.vim
git submodule update --init --recursive bundle/nerdtree
```
Feel free to change anything to fit your needs! 

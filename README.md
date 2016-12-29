# Vimrc
This repo have mi personal Vim/Neovim setings that I have been collecting for a while, feel free to change
anything to fit your needs or suggest me something that you think could be useful.

*This settings require Vim >= 7.4 or Neovim >= 0.12 with **python** and **lua** support and **ctags**.*

I have personally test this configurations in the following enviroments:

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
git clone --recursive https://git.prodeveloper.me/mike/.vim.git ~/.vim

ln -s ~/.vim/init.vim ~/.vimrc
```

If you are using [Neovim](https://neovim.io/) you just need to move the repo to `~/.config/nvim`
    
    mv ~/.vim ~/.config/nvim

or just clone it there

    git clone --recursive https://git.prodeveloper.me/mike/.vim.git ~/.config/nvim

Once you have cloneed the repo just run `:PlugInstall` inside vim/neovim to complete the installation process.

Included plugins:
- Default plugins
    * [Vim Sensible](https://github.com/tpope/vim-sensible)
    * [Colorschemes](https://github.com/flazz/vim-colorschemes)
    * [deliMate](https://github.com/Raimondi/delimitMate)
    * [NERDTree](https://github.com/scrooloose/nerdtree')
    * [NERDTreeTabs](https://github.com/jistr/vim-nerdtree-tabs)
    * [NERDCommenter](https://github.com/scrooloose/nerdcommenter)
    * [Multiple-cursors](https://github.com/terryma/vim-multiple-cursors)
    * [Vim Airline](https://github.com/vim-airline/vim-airline')
    * [Vim Airline Themes](https://github.com/vim-airline/vim-airline-themes)
    * [Gitgutter](https://github.com/airblade/vim-gitgutter)
    * [Fugitive](https://github.com/tpope/vim-fugitive)
    * [Committia](https://github.com/rhysd/committia.vim)
    * [Tagbar](https://github.com/majutsushi/tagbar)
    * [Tabular](https://github.com/godlygeek/tabular)
    * [EasyMotions](https://github.com/easymotion/vim-easymotion)
    * [Surround](https://github.com/tpope/vim-surround)
    * [BufferBye](https://github.com/moll/vim-bbye)
    * [Signature](https://github.com/kshenoy/vim-signature)
    * [CtrP](https://github.com/kien/ctrlp.vim)
    * [Vim misc](https://github.com/xolox/vim-misc)
    * [Sessions](https://github.com/xolox/vim-session)
    * [Polyglot](https://github.com/sheerun/vim-polyglot)
    * [Hexmode](https://github.com/fidian/hexmode)
    * [Snippets](https://github.com/honza/vim-snippets)
    * [Move](https://github.com/matze/vim-move)
    * [MacroEdit](https://github.com/dohsimpson/vim-macroeditor)

- If python interface is available
    * [Ultisnips](https://github.com/SirVer/ultisnips)
    * [YouCompleteMe](https://github.com/Valloric/YouCompleteMe)

    - If YouCompleteMe was not installed
        * [Jedi](https://github.com/davidhalter/jedi-vim)
        * [Syntactic](https://github.com/vim-syntastic/syntastic)

- If python interface is not available
    * [Addons mw ultis](https://github.com/MarcWeber/vim-addon-mw-utils)
    * [Tlib](https://github.com/tomtom/tlib_vim)
    * [SnipMate](https://github.com/garbas/vim-snipmate)

- If YouCompleteMe was not installed and Neovim is being used
    * [Deoplete](https://github.com/Shougo/deoplete.nvim')

- If YouCompleteMe was not installed and lua is available
    * [NeoComplete](https://github.com/Shougo/neocomplete.vim)

- If YouCompleteMe was not installed and lua is not available
    * [Supertab](https://github.com/ervandew/supertab)

If you want to deactivate some plugins just comment its line in the init.vim, ex. " Plug 'majutsushi/tagbar'.
And run `:PlugInstall` all maps and settings will be automatically disable.

Feel free to change anything to fit your needs! 

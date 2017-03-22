#!/usr/bin/env bash

INSTALL_PKGS=0
CLONE=0
PYTHON_PKGS=0
TYPE="vim"

display_help()
{
    echo ""
    echo ""
    echo "  Usage $0 [OPCIONAL FLAGS]"
    echo ""
    echo "      Opcional Flags"
    echo ""
    echo "          -h, --help"
    echo ""
}

function backup_dir()
{
    if [[ ! -z "$1" ]]; then
        DIR="$1"
        if [[ -d "$DIR" ]]; then
            mv "$DIR" "${DIR}_bk"
        fi
    fi
}

display_error_message()
{
    ERROR_MESSAGE="$1"
    printf "[X]     $ERROR_MESSAGE \n"
}

display_status_message()
{
    STATUS_MESSAGGE="$1"
    printf "[*]     $STATUS_MESSAGGE \n"
}

function install_python_stuff()
{
    if [[ ! -z "$1" ]]; then
        REQUIREMENTS="$1"
        if hash pip2 2>/dev/null; then
            pip2 install --user -r "$REQUIREMENTS"
        fi

        if hash pip3 2>/dev/null; then
            pip3 install --user -r "$REQUIREMENTS"
        fi
    fi
}

function clone_repo()
{
    local VIMDIR="$1"
    git clone --recursive https://github.com/mike325/.vim "$VIMDIR"
}

function copy_repo()
{
    local VIMDIR="$1"
    cd "$VIMDIR" && git submodule update --recursive
}

function init_env()
{
    # local TYPE=""
    local VIMDIR=""
    local SAVE_CW="$(pwd)"

    # if [[ ! -z "$1" ]]; then
    #     local TYPE="$1"
    # else
    #     local TYPE="vim"
    # fi

    if [[ "$TYPE" == "vim" ]]; then
        local VIMDIR="$HOME/.vim"
    else
        local VIMDIR="$HOME/.config/nvim"
    fi

    backup_dir "$VIMDIR"

    if [[ "$CLONE" -eq 0 ]]; then
        copy_repo "$VIMDIR"
    else
        clone_repo "$VIMDIR"
    fi

    if [[ "$PYTHON_PKGS" -eq 1 ]]; then
        install_python_stuff "${VIMDIR}/requirements.txt"
    fi

    cd "$SAVE_CW"
}

function install_pkgs()
{
    # Ctags
    # Powerline fonts
    # Clang
    # Go
    # Nodejs

    local PKGS=("ctags" "clang")
    local INSTALL_PKG=""

    if hash yaourt 2>/dev/null; then
        local INSTALL_PKG="yaourt -S"
    elif hash pacman 2>/dev/null; then
        local INSTALL_PKG="pacman -S"
    elif hash apt-get 2>/dev/null; then
        local install_pkg="apt-get install"
    elif hash dnf 2>/dev/null; then
        local INSTALL_PKG="dnf install"
    fi

    if [[ "$(whoami)" == root ]]; then
        sh -C "$INSTALL_PKG ${PKGS[@]}"
    elif [[ "$(groups)" =~ sudo ]]; then
        if [[ $INSTALL_PKG =~ "yaourt" ]]; then
            sh -C "$INSTALL_PKG  ${PKGS[@]}"
        else
            sudo "$INSTALL_PKG" "${PKGS[@]}"
        fi
    fi
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -h|--help)
            display_help
            exit 0
            ;;
        -c|--clone)
            CLONE=1
            ;;
        -i|--install)
            INSTALL_PKGS=1
            ;;
        -p|--python)
            PYTHON_PKGS=1
            ;;
        -t|--type)
            if [[ ! -z "$1" ]]; then
                TYPE="$1"
                shift
            fi
            ;;
        *)
            display_error_message "Unkwon option $1"
            display_help
            exit 1
            ;;
    esac
    shift
done

init_env

if [[ "$INSTALL_PKGS" -eq 1 ]]; then
    install_pkgs
fi

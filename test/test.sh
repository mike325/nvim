#!/usr/bin/env bash

#
#                              -`
#              ...            .o+`
#           .+++s+   .h`.    `ooo/
#          `+++%++  .h+++   `+oooo:
#          +++o+++ .hhs++. `+oooooo:
#          +s%%so%.hohhoo'  'oooooo+:
#          `+ooohs+h+sh++`/:  ++oooo+:
#           hh+o+hoso+h+`/++++.+++++++:
#            `+h+++h.+ `/++++++++++++++:
#                     `/+++ooooooooooooo/`
#                    ./ooosssso++osssssso+`
#                   .oossssso-````/osssss::`
#                  -osssssso.      :ssss``to.
#                 :osssssss/  Mike  osssl   +
#                /ossssssss/   8a   +sssslb
#              `/ossssso+/:-        -:/+ossss'.-
#             `+sso+:-`                 `.-/+oso:
#            `++:.                           `-/+/
#            .`                                 `/

_ALL=1
_VERBOSE=0
_NOCOLOR=0
_NOLOG=0
_WARN_COUNT=0
_ERR_COUNT=0

_VIM=0
_NVIM=0

_PROGS=()
_PYTHON2=0
_PYTHON3=0

_NAME="$0"
_NAME="${_NAME##*/}"
_LOG="${_NAME%%.*}.log"

_SCRIPT_PATH="$0"

_SCRIPT_PATH="${_SCRIPT_PATH%/*}"

_TEST_TYPE=("bare" "minimal" "full")
_ARGS=" --cmd version -Es -V2 "

trap '{ exit_append; }' EXIT

if hash realpath 2>/dev/null; then
    _SCRIPT_PATH=$(realpath "$_SCRIPT_PATH")
else
    pushd "$_SCRIPT_PATH" 1> /dev/null || exit 1
    _SCRIPT_PATH="$(pwd -P)"
    popd 1> /dev/null || exit 1
fi

# _DEFAULT_SHELL="${SHELL##*/}"
_CURRENT_SHELL="bash"

if [ -z "$SHELL_PLATFORM" ]; then
    if [[ -n $TRAVIS_OS_NAME ]]; then
        export SHELL_PLATFORM="$TRAVIS_OS_NAME"
    else
        case "$OSTYPE" in
            *'linux'*   ) export SHELL_PLATFORM='linux' ;;
            *'darwin'*  ) export SHELL_PLATFORM='osx' ;;
            *'freebsd'* ) export SHELL_PLATFORM='bsd' ;;
            *'cygwin'*  ) export SHELL_PLATFORM='cygwin' ;;
            *'msys'*    ) export SHELL_PLATFORM='msys' ;;
            *'windows'* ) export SHELL_PLATFORM='windows' ;;
            *           ) export SHELL_PLATFORM='unknown' ;;
        esac
    fi
fi

_ARCH="$(uname -m)"

case "$SHELL_PLATFORM" in
    # TODO: support more linux distros
    linux)
        if [[ -f /etc/arch-release ]]; then
            _OS='arch'
        elif [[ "$(cat /etc/issue)" == Ubuntu* ]]; then
            _OS='ubuntu'
        elif [[ -f /etc/debian_version ]] || [[ "$(cat /etc/issue)" == Debian* ]]; then
            if [[ $_ARCH == *\ armv7* ]]; then # Raspberry pi 3 uses armv7 cpu
                _OS='raspbian'
            else
                _OS='debian'
            fi
        fi
        ;;
    cygwin|msys|windows)
        _OS='windows'
        ;;
    osx)
        _OS='macos'
        ;;
    bsd)
        _OS='bsd'
        ;;
esac

if ! hash is_windows 2>/dev/null; then
    function is_windows() {
        if [[ $SHELL_PLATFORM == 'msys' ]] || [[ $SHELL_PLATFORM == 'cygwin' ]] || [[ $SHELL_PLATFORM == 'windows' ]]; then
            return 0
        fi
        return 1
    }
fi

if ! hash is_osx 2>/dev/null; then
    function is_osx() {
        if [[ $SHELL_PLATFORM == 'osx' ]]; then
            return 0
        fi
        return 1
    }
fi

if [[ -n "$ZSH_NAME" ]]; then
    _CURRENT_SHELL="zsh"
elif [[ -n "$BASH" ]]; then
    _CURRENT_SHELL="bash"
else
    # shellcheck disable=SC2009,SC2046
    # _CURRENT_SHELL="$(ps | grep $$ | grep -Eo '(ba|z|tc|c)?sh')"
    # _CURRENT_SHELL="${_CURRENT_SHELL##*/}"
    # _CURRENT_SHELL="${_CURRENT_SHELL##*:}"
    if [[ -z "$_CURRENT_SHELL" ]]; then
        _CURRENT_SHELL="${SHELL##*/}"
    fi
fi

# colors
# shellcheck disable=SC2034
black="\033[0;30m"
# shellcheck disable=SC2034
red="\033[0;31m"
# shellcheck disable=SC2034
green="\033[0;32m"
# shellcheck disable=SC2034
yellow="\033[0;33m"
# shellcheck disable=SC2034
blue="\033[0;34m"
# shellcheck disable=SC2034
purple="\033[0;35m"
# shellcheck disable=SC2034
cyan="\033[0;36m"
# shellcheck disable=SC2034
white="\033[0;37;1m"
# shellcheck disable=SC2034
orange="\033[0;91m"
# shellcheck disable=SC2034
normal="\033[0m"
# shellcheck disable=SC2034
reset_color="\033[39m"

function help_user() {
    cat<<EOF
Description

Usage:
    $_NAME [OPTIONAL]

    Optional Flags

        --nolog
            Disable log writting

        --nocolor
            Disable color output

        -v, --verbose
            Enable debug messages

        -h, --help
            Display help, if you are seeing this, that means that you already know it (nice)
EOF
}

function __parse_args() {
    if [[ $# -lt 2 ]]; then
        error_msg "Internal error in __parse_args function trying to parse $1"
        exit 1
    fi

    local arg="$1"
    local name="$2"

    local pattern="^--${name}=[a-zA-Z0-9.:@_/~-]+$"

    if [[ -n "$3" ]]; then
        local pattern="^--${name}=$3$"
    fi

    if [[ $arg =~ $pattern ]]; then
        local left_side="${arg#*=}"
        echo "${left_side/#\~/$HOME}"
    else
        echo "$arg"
    fi
}

function warn_msg() {
    local warn_message="$1"
    if [[ $_NOCOLOR -eq 0 ]]; then
        printf "\n${yellow}[!] Warning:${reset_color}\t %s" "$warn_message"
    else
        printf "\n[!] Warning:\t %s" "$warn_message"
    fi
    _WARN_COUNT=$(( _WARN_COUNT + 1 ))
    if [[ $_NOLOG -eq 0 ]]; then
        printf "[!] Warning:\t %s\n" "$warn_message" >> "${_LOG}"
    fi
    return 0
}

function error_msg() {
    local error_message="$1"
    if [[ $_NOCOLOR -eq 0 ]]; then
        printf "\n${red}[X] Error:${reset_color}\t %s" "$error_message" 1>&2
    else
        printf "\n[X] Error:\t %s" "$error_message" 1>&2
    fi
    _ERR_COUNT=$(( _ERR_COUNT + 1 ))
    if [[ $_NOLOG -eq 0 ]]; then
        printf "[X] Error:\t\t %s\n" "$error_message" >> "${_LOG}"
    fi
    return 0
}

function status_msg() {
    local status_message="$1"
    if [[ $_NOCOLOR -eq 0 ]]; then
        printf "\n${green}[*] Info:${reset_color}\t %s" "$status_message"
    else
        printf "\n[*] Info:\t %s" "$status_message"
    fi
    if [[ $_NOLOG -eq 0 ]]; then
        printf "[*] Info:\t\t %s\n" "$status_message" >> "${_LOG}"
    fi
    return 0
}

function verbose_msg() {
    local debug_message="$1"
    if [[ $_VERBOSE -eq 1 ]]; then
        if [[ $_NOCOLOR -eq 0 ]]; then
            printf "\n${purple}[+] Debug:${reset_color}\t %s" "$debug_message"
        else
            printf "\n[+] Debug:\t %s" "$debug_message"
        fi
    fi
    if [[ $_NOLOG -eq 0 ]]; then
        printf "[+] Debug:\t\t %s\n" "$debug_message" >> "${_LOG}"
    fi
    return 0
}

function initlog() {
    if [[ $_NOLOG -eq 0 ]]; then
        rm -f "${_LOG}" 2>/dev/null
        touch "${_LOG}" &>/dev/null
        if [[ -f "${_SCRIPT_PATH}/shell/banner" ]]; then
            cat "${_SCRIPT_PATH}/shell/banner" > "${_LOG}"
        fi
    fi
    return 0
}

function exit_append() {
    if [[ $_NOLOG -eq 0 ]]; then
        if [[ $_WARN_COUNT -gt 0 ]] || [[ $_ERR_COUNT -gt 0 ]]; then
            printf "\n\n" >> "${_LOG}"
        fi

        if [[ $_WARN_COUNT -gt 0 ]]; then
            printf "[*] Warnings:\t%s\n" "$_WARN_COUNT" >> "${_LOG}"
        fi
        if [[ $_ERR_COUNT -gt 0 ]]; then
            printf "[*] Errors:\t\t%s\n" "$_ERR_COUNT" >> "${_LOG}"
            echo
            cat "${_LOG}"
        fi
    fi
    return 0
}

function get_runtime_files() {
    prog="$1"
    if is_windows; then
        if [[ $prog == nvim ]]; then
            echo "$HOME/AppData/Local/nvim/init.vim"
        else
            echo "$HOME/.vim/vimrc"
        fi
    else
        if [[ $prog == nvim ]]; then
            echo "$HOME/.config/nvim/init.vim"
        else
            echo "$HOME/.vim/vimrc"
        fi
    fi
}

function install_pynvim() {
    if hash pip2 2>/dev/null; then
        pip2 install --user pynvim
        _PYTHON2=1
    else
        warn_msg "Skipping python 2 test with Neovim"
    fi

    if hash pip3 2>/dev/null; then
        pip3 install --user pynvim
        _PYTHON3=1
    else
        warn_msg "Skipping python 3 test with Neovim"
    fi

    if [[ $_PYTHON2 -eq 1 ]] || [[ $_PYTHON3 -eq 1 ]]; then
        return 0
    fi

    return 1
}

function run_test() {
    local prog="$1"
    local rsp=0
    local args

    if [[ $prog == nvim ]] && [[ $SHELL_PLATFORM == 'linux' ]]; then
        status_msg "Setting YCM flag"
        export YCM=1
    else
        unset YCM
    fi

    if [[ $prog == nvim ]]; then
        if [[ $_PYTHON2 -eq 0 ]] && [[ $_PYTHON3 -eq 0 ]]; then
            local testname="stable Neovim without python"
        else
            local testname="stable Neovim with python"
        fi
    else
        local testname="stock Vim"
    fi

    local exit_args=" -c 'autocmd VimEnter * qa!' "

    for test_type in  "${_TEST_TYPE[@]}"; do

        args="-u $(get_runtime_files ${prog}) ${_ARGS}"
        if [[ $prog == vim ]]; then
            args="$args -N"
        fi
        args="$args $exit_args"

        if [[ $test_type == full ]]; then
            args=" ${args} -c 'PlugInstall' "
        elif [[ $test_type == minimal ]]; then
            local args="${args} --cmd 'let g:mininal=1' -c 'PlugInstall' "
        elif [[ $test_type == bare ]]; then
            local args="${args} --cmd 'let g:bare=1'"
        fi

        status_msg "Testing ${test_type} ${testname}"
        verbose_msg "Using $(get_runtime_files ${prog})"

        verbose_msg "Running ${prog} ${args}"
        if  [[ $prog == nvim ]] && ! hash nvim 2>/dev/null; then
            error_msg "Neovim is not install or is missing in the path, test ${test_type} ${testname} fail"
            rsp=1
        elif ! eval "${prog} ${args}"; then
            error_msg "${test_type} ${testname} fail"
            rsp=1
        fi
    done

    return $rsp
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        --nolog)
            _NOLOG=1
            ;;
        --nocolor)
            _NOCOLOR=1
            ;;
        --verbose)
            _VERBOSE=1
            ;;
        -h|--help)
            help_user
            exit 0
            ;;
        -v|--vim)
            _VIM=1
            _ALL=0
            ;;
        -n|--neovim|--nvim)
            _NVIM=1
            _ALL=0
            ;;
        *)
            initlog
            error_msg "Unknown argument $key"
            help_user
            exit 1
            ;;
    esac
    shift
done

initlog

if [[ $_ALL -eq 1 ]]; then
    _PROGS=("vim" "nvim")
else
    [[ $_VIM -eq 1 ]] && _PROGS+=("vim")
    [[ $_NVIM -eq 1 ]] && _PROGS+=("nvim")
fi

for prog in "${_PROGS[@]}"; do
    run_test "$prog"
done

if { [[ $_ALL -eq 1 ]] || [[ $_NVIM -eq 1 ]] ; } &&  install_pynvim; then
    run_test "$prog"
fi

if [[ $_ERR_COUNT -gt 0 ]]; then
    exit 1
fi

exit 0

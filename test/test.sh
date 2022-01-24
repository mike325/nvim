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

ALL=1
VERBOSE=0
NOCOLOR=0
NOLOG=0
WARN_COUNT=0
ERR_COUNT=0

VIM=0
NVIM=0

PROGS=()
PYTHON2=0
PYTHON3=0

NAME="$0"
NAME="${NAME##*/}"
LOG="${NAME%%.*}.log"

SCRIPT_PATH="$0"
SCRIPT_PATH="${SCRIPT_PATH%/*}"

TEST_TYPE=("bare" "minimal" "full")
ARGS=" --cmd version -Es -V2 "

# _DEFAULT_SHELL="${SHELL##*/}"
CURRENT_SHELL="bash"

OS='unknown'
ARCH="$(uname -m)"

trap '{ exit_append; }' EXIT

if hash realpath 2>/dev/null; then
    SCRIPT_PATH=$(realpath "$SCRIPT_PATH")
else
    pushd "$SCRIPT_PATH" 1>/dev/null  || exit 1
    SCRIPT_PATH="$(pwd -P)"
    popd 1>/dev/null  || exit 1
fi

if [ -z "$SHELL_PLATFORM" ]; then
    if [[ -n $TRAVIS_OS_NAME ]]; then
        export SHELL_PLATFORM="$TRAVIS_OS_NAME"
    else
        case "$OSTYPE" in
            *'linux'*)    export SHELL_PLATFORM='linux' ;;
            *'darwin'*)   export SHELL_PLATFORM='osx' ;;
            *'freebsd'*)  export SHELL_PLATFORM='bsd' ;;
            *'cygwin'*)   export SHELL_PLATFORM='cygwin' ;;
            *'msys'*)     export SHELL_PLATFORM='msys' ;;
            *'windows'*)  export SHELL_PLATFORM='windows' ;;
            *)            export SHELL_PLATFORM='unknown' ;;
        esac
    fi
fi

case "$SHELL_PLATFORM" in
    # TODO: support more linux distros
    linux)
        if [[ -f /etc/arch-release ]]; then
            OS='arch'
        elif [[ "$(cat /etc/issue)" == Ubuntu* ]]; then
            OS='ubuntu'
        elif [[ -f /etc/debian_version ]] || [[ "$(cat /etc/issue)" == Debian* ]]; then
            if [[ $ARCH == *\ armv7* ]]; then # Raspberry pi 3 uses armv7 cpu
                OS='raspbian'
            else
                OS='debian'
            fi
        fi
        ;;
    cygwin | msys | windows)
        OS='windows'
        ;;
    osx)
        OS='macos'
        ;;
    bsd)
        OS='bsd'
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

if [[ -n $ZSH_NAME ]]; then
    CURRENT_SHELL="zsh"
elif [[ -n $BASH ]]; then
    CURRENT_SHELL="bash"
else
    # shellcheck disable=SC2009,SC2046
    # _CURRENT_SHELL="$(ps | grep $$ | grep -Eo '(ba|z|tc|c)?sh')"
    # _CURRENT_SHELL="${_CURRENT_SHELL##*/}"
    # _CURRENT_SHELL="${_CURRENT_SHELL##*:}"
    if [[ -z $CURRENT_SHELL ]]; then
        CURRENT_SHELL="${SHELL##*/}"
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
    cat <<EOF
Description

Usage:
    $NAME [OPTIONAL]

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

    if [[ -n $3   ]]; then
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
    if [[ $NOCOLOR -eq 0 ]]; then
        printf "\n${yellow}[!] Warning:${reset_color}\t %s" "$warn_message"
    else
        printf "\n[!] Warning:\t %s" "$warn_message"
    fi
    WARN_COUNT=$((WARN_COUNT + 1))
    if [[ $NOLOG -eq 0 ]]; then
        printf "[!] Warning:\t %s\n" "$warn_message" >>"${LOG}"
    fi
    return 0
}

function error_msg() {
    local error_message="$1"
    if [[ $NOCOLOR -eq 0 ]]; then
        printf "\n${red}[X] Error:${reset_color}\t %s" "$error_message" 1>&2
    else
        printf "\n[X] Error:\t %s" "$error_message" 1>&2
    fi
    ERR_COUNT=$((ERR_COUNT + 1))
    if [[ $NOLOG -eq 0 ]]; then
        printf "[X] Error:\t\t %s\n" "$error_message" >>"${LOG}"
    fi
    return 0
}

function status_msg() {
    local status_message="$1"
    if [[ $NOCOLOR -eq 0 ]]; then
        printf "\n${green}[*] Info:${reset_color}\t %s" "$status_message"
    else
        printf "\n[*] Info:\t %s" "$status_message"
    fi
    if [[ $NOLOG -eq 0 ]]; then
        printf "[*] Info:\t\t %s\n" "$status_message" >>"${LOG}"
    fi
    return 0
}

function verbose_msg() {
    local debug_message="$1"
    if [[ $VERBOSE -eq 1 ]]; then
        if [[ $NOCOLOR -eq 0 ]]; then
            printf "\n${purple}[+] Debug:${reset_color}\t %s" "$debug_message"
        else
            printf "\n[+] Debug:\t %s" "$debug_message"
        fi
    fi
    if [[ $NOLOG -eq 0 ]]; then
        printf "[+] Debug:\t\t %s\n" "$debug_message" >>"${LOG}"
    fi
    return 0
}

function initlog() {
    if [[ $NOLOG -eq 0 ]]; then
        rm -f "${LOG}" 2>/dev/null
        touch "${LOG}" &>/dev/null
        if [[ -f "${SCRIPT_PATH}/shell/banner" ]]; then
            cat "${SCRIPT_PATH}/shell/banner" >"${LOG}"
        fi
    fi
    return 0
}

function exit_append() {
    if [[ $NOLOG -eq 0 ]]; then
        if [[ $WARN_COUNT -gt 0 ]] || [[ $ERR_COUNT -gt 0 ]]; then
            printf "\n\n" >>"${LOG}"
        fi

        if [[ $WARN_COUNT -gt 0 ]]; then
            printf "[*] Warnings:\t%s\n" "$WARN_COUNT" >>"${LOG}"
        fi
        if [[ $ERR_COUNT -gt 0 ]]; then
            printf "[*] Errors:\t\t%s\n" "$ERR_COUNT" >>"${LOG}"
            echo
            cat "${LOG}"
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
    if hash pip3 2>/dev/null; then
        pip3 install --user wheel pynvim
        PYTHON3=1
    else
        warn_msg "Skipping python 3 test with Neovim"
    fi

    if hash pip2 2>/dev/null; then
        pip2 install --user wheel pynvim
        PYTHON2=1
    else
        warn_msg "Skipping python 2 test with Neovim"
    fi

    if [[ $PYTHON2 -eq 1 ]] || [[ $PYTHON3 -eq 1 ]]; then
        return 0
    fi

    return 1
}

function run_test() {
    local prog="$1"
    local rsp=0
    local args

    # if [[ $prog == nvim ]] && [[ $SHELL_PLATFORM == 'linux' ]]; then
    #     status_msg "Setting YCM flag"
    #     export YCM=1
    # else
    #     unset YCM
    # fi

    if [[ $prog == nvim ]]; then
        if [[ $PYTHON2 -eq 0 ]] && [[ $PYTHON3 -eq 0 ]]; then
            local testname="stable Neovim without python"
        else
            local testname="stable Neovim with python"
        fi
    else
        local testname="stock Vim"
    fi

    local exit_args=" -c 'autocmd VimEnter * qa!' "

    for test_type in  "${TEST_TYPE[@]}"; do

        args="-u $(get_runtime_files "${prog}") ${ARGS}"
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
        verbose_msg "Using $(get_runtime_files "${prog}")"

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
            NOLOG=1
            ;;
        --nocolor)
            NOCOLOR=1
            ;;
        --verbose)
            VERBOSE=1
            ;;
        -h | --help)
            help_user
            exit 0
            ;;
        -v | --vim)
            VIM=1
            ALL=0
            ;;
        -n | --neovim | --nvim)
            NVIM=1
            ALL=0
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
verbose_msg "Log Disable   : ${NOLOG}"
verbose_msg "Current Shell : ${CURRENT_SHELL}"
verbose_msg "Platform      : ${SHELL_PLATFORM}"
verbose_msg "Architecture  : ${ARCH}"
verbose_msg "OS            : ${OS}"

if [[ $ALL -eq 1 ]]; then
    PROGS=("vim" "nvim")
else
    [[ $VIM -eq 1 ]] && PROGS+=("vim")
    [[ $NVIM -eq 1 ]] && PROGS=("nvim")
fi

for prog in "${PROGS[@]}"; do
    run_test "$prog"
done

if { [[ $ALL -eq 1 ]] || [[ $NVIM -eq 1 ]]; } && install_pynvim; then
    run_test "$prog"
fi

if [[ $ERR_COUNT -gt 0 ]]; then
    exit 1
fi

exit 0

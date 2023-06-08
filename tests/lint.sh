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

VERBOSE=0
NOCOLOR=0
NOLOG=0
WARN_COUNT=0
ERR_COUNT=0
# FROM_STDIN=()

NAME="$0"
NAME="${NAME##*/}"
LOG="${NAME%%.*}.log"

SCRIPT_PATH="$0"
SCRIPT_PATH="${SCRIPT_PATH%/*}"

OS='unknown'
ARCH="$(uname -m)"

trap '{ exit_append; }' EXIT

if hash realpath 2>/dev/null; then
    SCRIPT_PATH=$(realpath "$SCRIPT_PATH")
else
    pushd "$SCRIPT_PATH" 1>/dev/null || exit 1
    SCRIPT_PATH="$(pwd -P)"
    popd 1>/dev/null || exit 1
fi

if [ -z "$SHELL_PLATFORM" ]; then
    if [[ -n $TRAVIS_OS_NAME ]]; then
        export SHELL_PLATFORM="$TRAVIS_OS_NAME"
    else
        case "$OSTYPE" in
            *'linux'*) export SHELL_PLATFORM='linux' ;;
            *'darwin'*) export SHELL_PLATFORM='osx' ;;
            *'freebsd'*) export SHELL_PLATFORM='bsd' ;;
            *'cygwin'*) export SHELL_PLATFORM='cygwin' ;;
            *'msys'*) export SHELL_PLATFORM='msys' ;;
            *'windows'*) export SHELL_PLATFORM='windows' ;;
            *) export SHELL_PLATFORM='unknown' ;;
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
        if [[ $SHELL_PLATFORM =~ (msys|cygwin|windows) ]]; then
            return 0
        fi
        return 1
    }
fi

if ! hash is_wls 2>/dev/null; then
    function is_wls() {
        if [[ "$(uname -r)" =~ Microsoft ]]; then
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
    if [[ -z $CURRENT_SHELL ]]; then
        CURRENT_SHELL="${SHELL##*/}"
    fi
fi

if ! hash is_64bits 2>/dev/null; then
    # TODO: This should work with ARM 64bits
    function is_64bits() {
        if [[ $ARCH == 'x86_64' ]]; then
            return 0
        fi
        return 1
    }
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

        --nolog         Disable log writting
        --nocolor       Disable color output
        -v, --verbose   Enable debug messages
        -h, --help      Display this help message
EOF
}

function __parse_args() {
    if [[ $# -lt 2 ]]; then
        error_msg "Internal error in __parse_args function trying to parse $1"
        exit 1
    fi

    local arg="$1"
    local lint="$2"

    local pattern="^--${lint}=[a-zA-Z0-9.:@_/~-]+$"

    if [[ -n $3 ]]; then
        local pattern="^--${lint}=$3$"
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
        printf "${yellow}[!] Warning:${reset_color}\t %s\n" "$warn_message"
    else
        printf "[!] Warning:\t %s\n" "$warn_message"
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
        printf "${red}[X] Error:${reset_color}\t %s\n" "$error_message" 1>&2
    else
        printf "[X] Error:\t %s\n" "$error_message" 1>&2
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
        printf "${green}[*] Info:${reset_color}\t %s\n" "$status_message"
    else
        printf "[*] Info:\t %s\n" "$status_message"
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
            printf "${purple}[+] Debug:${reset_color}\t %s\n" "$debug_message"
        else
            printf "[+] Debug:\t %s\n" "$debug_message"
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
        if ! touch "${LOG}" &>/dev/null; then
            error_msg "Fail to init log file"
            NOLOG=1
            return 1
        fi
        if [[ -f "${SCRIPT_PATH}/shell/banner" ]]; then
            cat "${SCRIPT_PATH}/shell/banner" >"${LOG}"
        fi
        if ! is_osx; then
            LOG=$(readlink -e "${LOG}")
        fi
        verbose_msg "Using log at ${LOG}"
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
        fi
    fi
    return 0
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
        -v | --verbose)
            VERBOSE=1
            ;;
        -h | --help)
            help_user
            exit 0
            ;;
        # -)
        #     while read -r from_stdin; do
        #         FROM_STDIN=("$from_stdin")
        #     done
        #     break
        #     ;;
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
verbose_msg "OS platform   : ${OS}"
verbose_msg "Architecture  : ${ARCH}"

#######################################################################
#                           CODE Goes Here                            #
#######################################################################

if ! hash fd 2>/dev/null; then
    error_msg "Missing fd aborting linting"
    exit 1
fi

if hash shellcheck 2>/dev/null; then
    status_msg "Running shellcheck"
    verbose_msg "Shellcheck version: $(shellcheck --version)"
    if ! fd -e sh --exclude zsh -X shellcheck -x -a -e 1117,2034; then
        error_msg 'Fail shellcheck test'
        exit 2
    fi
else
    error_msg "Missing shellcheck, skipping Shell lint"
fi

if hash flake8 2>/dev/null; then
    status_msg "Running python check"
    verbose_msg "flake8 version: $(flake8 --version)"
    if ! fd -e py -X flake8 --max-line-length=120 --max-complexity=18; then
        error_msg "Failed python lint test"
        exit 3
    fi
else
    error_msg "Missing flake8, skipping Python lint"
fi

if hash vint 2>/dev/null; then
    status_msg "Running VimL lint"
    verbose_msg "Vint version: $(vint --version)"
    if ! fd -e vim --exclude plug --exclude ftdetect -X vint --enable-neovim -t -s || ! fd -e vim . ftdetect -X vint --enable-neovim -t -w; then
        error_msg 'Fail VimL lint test'
        exit 2
    fi
else
    error_msg "Missing vint, skipping VimL lint"
fi

if hash luacheck 2>/dev/null; then
    status_msg "Running luacheck"
    verbose_msg "luacheck version: $(luacheck --version)"
    if ! luacheck --std luajit lua/; then
        warn_msg 'Fail luacheck lint test'
    fi
elif [[ -f "$HOME/.luarocks/bin/luacheck" ]]; then
    status_msg "Running luacheck"
    if ! "$HOME/.luarocks/bin/luacheck" --std luajit lua/; then
        warn_msg 'Fail luacheck lint test'
    fi
elif hash nvim 2>/dev/null; then
    lua_version=$(nvim --version | grep -i luajit | awk '{print $2}')
    if [[ -f ~/.cache/nvim/packer_hererocks/$lua_version/bin/luacheck ]]; then
        if ! ~/.cache/nvim/packer_hererocks/"$lua_version"/bin/luacheck --std luajit lua/; then
            warn_msg 'Fail luacheck lint test'
        fi
    else
        error_msg "Missing luacheck, skipping lua lint"
    fi
else
    error_msg "Missing luacheck, skipping lua lint"
fi

if [[ $ERR_COUNT -gt 0 ]]; then
    exit 1
fi

exit 0

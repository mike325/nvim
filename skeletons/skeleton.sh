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

_VERBOSE=0
_NOCOLOR=0

_NAME="$0"
_NAME="${_NAME##*/}"

_SCRIPT_PATH="$0"

_SCRIPT_PATH="${_SCRIPT_PATH%/*}"

if hash realpath 2>/dev/null; then
    _SCRIPT_PATH=$(realpath "$_SCRIPT_PATH")
else
    pushd "$_SCRIPT_PATH" 1> /dev/null || exit 1
    _SCRIPT_PATH="$(pwd -P)"
    popd 1> /dev/null || exit 1
fi

# _DEFAULT_SHELL="${SHELL##*/}"
_CURRENT_SHELL="bash"
_IS_WINDOWS=0

if [ -z "$SHELL_PLATFORM" ]; then
    export SHELL_PLATFORM='UNKNOWN'
    case "$OSTYPE" in
      *'linux'*   ) export SHELL_PLATFORM='LINUX' ;;
      *'darwin'*  ) export SHELL_PLATFORM='OSX' ;;
      *'freebsd'* ) export SHELL_PLATFORM='BSD' ;;
      *'cygwin'*  ) export SHELL_PLATFORM='CYGWIN' ;;
      *'msys'*    ) export SHELL_PLATFORM='MSYS' ;;
    esac
fi

# Windows stuff
if [[ $SHELL_PLATFORM == 'MSYS' ]] || [[ $SHELL_PLATFORM == 'CYGWIN' ]]; then
    # Windows bash does not have pgrep by default
    # shellcheck disable=SC2009
    _CURRENT_SHELL="$(ps | grep $$ | awk '{ print $8 }')"
    _CURRENT_SHELL="${_CURRENT_SHELL##*/}"
    # Windows does not support links we will use cp instead
    # shellcheck disable=SC2034
    _IS_WINDOWS=1
else
    _CURRENT_SHELL="$(ps | head -2 | tail -n 1 | awk '{ print $4 }')"
    # Hack when using sudo
    if [[ $_CURRENT_SHELL == "sudo" ]] || [[ $_CURRENT_SHELL == "su" ]]; then
        _CURRENT_SHELL="$(ps | head -4 | tail -n 1 | awk '{ print $4 }')"
    fi
fi

# colors
black="\033[0;30m"
red="\033[0;31m"
green="\033[0;32m"
yellow="\033[0;33m"
blue="\033[0;34m"
purple="\033[0;35m"
cyan="\033[0;36m"
white="\033[0;37;1m"
orange="\033[0;91m"
normal="\033[0m"
reset_color="\033[39m"

function help_user() {
    echo ""
    echo "  Description"
    echo ""
    echo "  Usage:"
    echo "      $_NAME [OPTIONAL]"
    echo ""
    echo "      Optional Flags"
    echo ""
    echo "          --nocolor"
    echo "              Disable color output"
    echo ""
    echo "          -v, --verbose"
    echo "              Enable debug messages"
    echo ""
    echo "          -h, --help"
    echo "              Display help, if you are seeing this, that means that you already know it (nice)"
    echo ""
}

function __parse_args() {
    if [[ $# -lt 2 ]]; then
        echo ""
    fi

    local arg="$1"
    local name="$2"

    local pattern="^--${name}[=][a-zA-Z0-9._-/~]+$"

    if [[ ! -z "$3" ]]; then
        local pattern="^--${name}[=]$3$"
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
        printf "${yellow}[!] Warning:${reset_color}\t %s \n" "$warn_message"
    else
        printf "[!] Warning:\t %s \n" "$warn_message"
    fi
    return 0
}

function error_msg() {
    local error_message="$1"
    if [[ $_NOCOLOR -eq 0 ]]; then
        printf "${red}[X] Error:${reset_color}\t %s \n" "$error_message" 1>&2
    else
        printf "[X] Error:\t %s \n" "$error_message" 1>&2
    fi
    return 0
}

function status_msg() {
    local status_message="$1"
    if [[ $_NOCOLOR -eq 0 ]]; then
        printf "${green}[*] Info:${reset_color}\t %s \n" "$status_message"
    else
        printf "[*] Info:\t %s \n" "$status_message"
    fi
    return 0
}

function verbose_msg() {
    if [[ $_VERBOSE -eq 1 ]]; then
        local debug_message="$1"
        if [[ $_NOCOLOR -eq 0 ]]; then
            printf "${purple}[+] Debug:${reset_color}\t %s \n" "$debug_message"
        else
            printf "[+] Debug:\t %s \n" "$debug_message"
        fi
    fi
    return 0
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        --nocolor)
            _NOCOLOR=1
            ;;
        -v|--verbose)
            _VERBOSE=1
            ;;
        -h|--help)
            help_user
            exit 0
            ;;
        *)
            error_msg "Unknown argument $1"
            help_user
            exit 1
            ;;
    esac
    shift
done


exit 0

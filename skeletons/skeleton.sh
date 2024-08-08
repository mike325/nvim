#!/usr/bin/env bash
# shellcheck disable=SC2317

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
QUIET=0
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
    pushd "$SCRIPT_PATH" 1>/dev/null  || exit 1
    SCRIPT_PATH="$(pwd -P)"
    popd 1>/dev/null  || exit 1
fi

if [[ -n $ZSH_NAME ]]; then
    CURRENT_SHELL="zsh"
elif [[ -n $BASH ]]; then
    CURRENT_SHELL="bash"
else
    # shellcheck disable=SC2009,SC2046
    if [[ -z $CURRENT_SHELL ]]; then
        CURRENT_SHELL="${SHELL##*/}"
    fi
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
        elif [[ -f /etc/redhat-release ]] && [[ "$(cat /etc/redhat-release)" == Red\ Hat* ]]; then
            OS='redhat'
        elif [[ -f /etc/issue ]] && [[ "$(cat /etc/issue)" == Ubuntu* ]]; then
            OS='ubuntu'
        elif [[ -f /etc/debian_version ]] || [[ "$(cat /etc/issue)" == Debian* ]]; then
            if [[ $ARCH =~ armv.* ]] || [[ $ARCH == aarch64 ]]; then
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

if ! hash is_root 2>/dev/null; then
    function is_root() {
        if ! is_windows && [[ $EUID -eq 0 ]]; then
            return 0
        fi
        return 1
    }
fi

if ! hash has_sudo 2>/dev/null; then
    function has_sudo() {
        if ! is_windows && hash sudo 2>/dev/null && [[ "$(groups)" =~ sudo ]]; then
            return 0
        fi
        return 1
    }
fi

if ! hash is_arm 2>/dev/null; then
    function is_arm() {
        local arch
        arch="$(uname -m)"
        if [[ $arch =~ ^arm ]] || [[ $arch =~ ^aarch ]]; then
            return 0
        fi
        return 1
    }
fi

if ! hash is_64bits 2>/dev/null; then
    function is_64bits() {
        local arch
        arch="$(uname -m)"
        if [[ $arch == 'x86_64' ]] || [[ $arch == 'arm64' ]]; then
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
        --nolog         Disable log writing
        --nocolor       Disable color output
        -v, --verbose   Enable debug messages
        -q, --quiet     Suppress all output but the errors
        -h, --help      Display this help message
EOF
}

function warn_msg() {
    local msg="$1"
    if [[ $QUIET -eq 0 ]]; then
        if [[ $NOCOLOR -eq 0 ]]; then
            printf "${yellow}[!] Warning:${reset_color}\t %s\n" "$msg"
        else
            printf "[!] Warning:\t %s\n" "$msg"
        fi
    fi
    WARN_COUNT=$((WARN_COUNT + 1))
    if [[ $NOLOG -eq 0 ]]; then
        printf "[!] Warning:\t %s\n" "$msg" >>"${LOG}"
    fi
    return 0
}

function error_msg() {
    local msg="$1"
    if [[ $NOCOLOR -eq 0 ]]; then
        printf "${red}[X] Error:${reset_color}\t %s\n" "$msg" 1>&2
    else
        printf "[X] Error:\t %s\n" "$msg" 1>&2
    fi
    ERR_COUNT=$((ERR_COUNT + 1))
    if [[ $NOLOG -eq 0 ]]; then
        printf "[X] Error:\t %s\n" "$msg" >>"${LOG}"
    fi
    return 0
}

function status_msg() {
    local msg="$1"
    if [[ $QUIET -eq 0 ]]; then
        if [[ $NOCOLOR -eq 0 ]]; then
            printf "${green}[*] Info:${reset_color}\t %s\n" "$msg"
        else
            printf "[*] Info:\t %s\n" "$msg"
        fi
    fi
    if [[ $NOLOG -eq 0 ]]; then
        printf "[*] Info:\t\t %s\n" "$msg" >>"${LOG}"
    fi
    return 0
}

function verbose_msg() {
    local msg="$1"
    if [[ $VERBOSE -eq 1 ]]; then
        if [[ $NOCOLOR -eq 0 ]]; then
            printf "${purple}[+] Debug:${reset_color}\t %s\n" "$msg"
        else
            printf "[+] Debug:\t %s\n" "$msg"
        fi
    fi
    if [[ $NOLOG -eq 0 ]]; then
        printf "[+] Debug:\t\t %s\n" "$msg" >>"${LOG}"
    fi
    return 0
}

function __parse_args() {
    if [[ $# -lt 2 ]]; then
        error_msg "Internal error in __parse_args function trying to parse $1"
        exit 1
    fi

    local flag="$2"
    local value="$1"

    local pattern="^--${flag}=[a-zA-Z0-9.:@_/~-]+$"

    if [[ -n $3   ]]; then
        local pattern="^--${flag}=$3$"
    fi

    if [[ $value =~ $pattern ]]; then
        local left_side="${value#*=}"
        echo "${left_side/#\~/$HOME}"
    else
        echo "$value"
    fi
}

function initlog() {
    if [[ $NOLOG -eq 0 ]]; then
        [[ -n $LOG ]] && rm -f "${LOG}" 2>/dev/null
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
            printf "[*] Errors:\t%s\n" "$ERR_COUNT" >>"${LOG}"
        fi
    fi
    return 0
}

function raw_output() {
    local msg="echo \"$1\""
    if [[ $NOLOG -eq 0 ]]; then
        msg="$msg | tee ${LOG}"
    fi
    if ! sh -c "$msg"; then
        return 1
    fi
    return 0
}

function shell_exec() {
    local cmd="$1"
    if [[ $QUIET -eq 0 ]]; then
        if [[ $NOLOG -eq 0 ]]; then
            cmd="$cmd | tee ${LOG}"
        fi
        if ! sh -c "$cmd"; then
            return 1
        fi
    elif [[ $NOLOG -eq 0 ]]; then
        if ! sh -c "$cmd >> ${LOG}"; then
            return 1
        fi
    else
        if ! sh -c "$cmd &>/dev/null"; then
            return 1
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
        -q | --quiet)
            QUIET=1
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
verbose_msg "Architecture  : ${ARCH}"
verbose_msg "OS            : ${OS}"

# mapfile -t VAR < <(cmd)

#######################################################################
#                           CODE Goes Here                            #
#######################################################################

#######################################################################
#                           CODE Goes Here                            #
#######################################################################
if [[ $ERR_COUNT -gt 0 ]]; then
    exit 1
fi

exit 0

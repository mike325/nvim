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
VERSION="0.1"
AUTHOR=""

VERBOSE=false
QUIET=false
PRINT_VERSION=false
NOCOLOR=false
NOLOG=false
DRY_RUN=false
WARN_COUNT=false
ERR_COUNT=false
# FROM_STDIN=()

NAME="$0"
NAME="${NAME##*/}"
NAME="${NAME##*-}"
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
    # shellcheck disable=SC2329
    function is_windows() {
        if [[ $SHELL_PLATFORM =~ (msys|cygwin|windows) ]]; then
            return 0
        fi
        return 1
    }
fi

if ! hash is_wls 2>/dev/null; then
    # shellcheck disable=SC2329
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
    # shellcheck disable=SC2329
    function is_root() {
        if ! is_windows && [[ $EUID -eq 0 ]]; then
            return 0
        fi
        return 1
    }
fi

if ! hash has_sudo 2>/dev/null; then
    # shellcheck disable=SC2329
    function has_sudo() {
        if ! is_windows && hash sudo 2>/dev/null && [[ "$(groups)" =~ sudo ]]; then
            return 0
        fi
        return 1
    }
fi

if ! hash is_arm 2>/dev/null; then
    # shellcheck disable=SC2329
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
    # shellcheck disable=SC2329
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
        --log               Enable log writing
        --nolog             Disable log writing
        --nocolor           Disable color output
        -v, --verbose       Enable debug messages
        -q, --quiet         Suppress most output
        -V, --version       Print script version and exits
        --dry, --dry-run    Enable dry run
        -h, --help          Display this help message
EOF
}

# shellcheck disable=SC2329
function warn_msg() {
    local msg="$1"
    if [[ $QUIET == false ]]; then
        if [[ $NOCOLOR == false ]]; then
            printf "${yellow}[!] Warning:${reset_color}\t %s\n" "$msg"
        else
            printf "[!] Warning:\t %s\n" "$msg"
        fi
    fi
    WARN_COUNT=$((WARN_COUNT + 1))
    if [[ $NOLOG == false ]]; then
        printf "[!] Warning:\t %s\n" "$msg" >>"${LOG}"
    fi
    return 0
}

function error_msg() {
    local msg="$1"
    if [[ $NOCOLOR == false ]]; then
        printf "${red}[X] Error:${reset_color}\t %s\n" "$msg" 1>&2
    else
        printf "[X] Error:\t %s\n" "$msg" 1>&2
    fi
    ERR_COUNT=$((ERR_COUNT + 1))
    if [[ $NOLOG == false ]]; then
        printf "[X] Error:\t %s\n" "$msg" >>"${LOG}"
    fi
    return 0
}

# shellcheck disable=SC2329
function status_msg() {
    local msg="$1"
    if [[ $QUIET == false ]]; then
        if [[ $NOCOLOR == false ]]; then
            printf "${green}[*] Info:${reset_color}\t %s\n" "$msg"
        else
            printf "[*] Info:\t %s\n" "$msg"
        fi
    fi
    if [[ $NOLOG == false ]]; then
        printf "[*] Info:\t\t %s\n" "$msg" >>"${LOG}"
    fi
    return 0
}

function verbose_msg() {
    local msg="$1"
    if [[ $VERBOSE == true ]]; then
        if [[ $NOCOLOR == false ]]; then
            printf "${purple}[+] Debug:${reset_color}\t %s\n" "$msg"
        else
            printf "[+] Debug:\t %s\n" "$msg"
        fi
    fi
    if [[ $NOLOG == false ]]; then
        printf "[+] Debug:\t\t %s\n" "$msg" >>"${LOG}"
    fi
    return 0
}

# shellcheck disable=SC2329
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
    if [[ $NOLOG == false ]]; then
        [[ -n $LOG ]] && rm -f "${LOG}" 2>/dev/null
        if ! touch "${LOG}" &>/dev/null; then
            error_msg "Fail to init log file"
            NOLOG=true
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

# shellcheck disable=SC2329
function exit_append() {
    if [[ $NOLOG == false ]]; then
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

# shellcheck disable=SC2329
function raw_output() {
    local msg="echo \"$1\""
    if [[ $NOLOG == false ]]; then
        msg="$msg | tee -a ${LOG}"
    fi
    if ! sh -c "$msg"; then
        return 1
    fi
    return 0
}

# shellcheck disable=SC2329
function shell_exec() {
    # TODO: Redirect stderr to stdout?  2>&1
    local cmd="$1"
    local verbose="${2:-$VERBOSE}"
    verbose_msg "cmd: $cmd"
    if [[ $DRY_RUN == true ]]; then
        return 0
    fi

    if [[ $verbose == true ]]; then
        if [[ $NOLOG == false ]]; then
            cmd="$cmd | tee -a ${LOG}"
            cmd="$cmd; test \${PIPESTATUS[0]} -eq 0"
        fi
        if ! sh -c "$cmd"; then
            return 1
        fi
    elif [[ $NOLOG == false ]]; then
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

# mapfile -t VAR < <(cmd)
# shellcheck disable=SC2329
function parse_cmd_output() {
    local cmd="$1"
    local exit_with_error=0

    # TODO: Read cmd exit code
    while IFS= read -r line; do
        raw_output "$line"
    done < <(sh -c "$cmd")

    # shellcheck disable=SC2086
    return $exit_with_error
}

# shellcheck disable=SC2329
function has_fetcher() {
    if hash curl 2>/dev/null || hash wget 2>/dev/null; then
        return 0
    fi
    return 1
}

# shellcheck disable=SC2329
function download_asset() {
    if [[ $# -lt 2 ]]; then
        error_msg "Not enough args"
        return 1
    fi

    if ! has_fetcher; then
        error_msg "This system has neither curl nor wget to download the asset $1"
        return 2
    fi

    local asset="$1"
    local url="$2"
    local dest=""
    if [[ -n $3 ]]; then
        local dest="$3"
    fi

    local cmd=""
    verbose_msg "Fetching $url"

    if hash curl 2>/dev/null; then
        cmd='curl -L '
        if [[ $VERBOSE == false ]]; then
            cmd="$cmd -s "
        fi
        cmd="$cmd $url"
        if [[ -n $dest ]]; then
            cmd="$cmd -o $dest"
        fi
    else  # If not curl, wget is available since we checked with "has_fetcher"
        cmd='wget '
        if [[ $VERBOSE == false ]]; then
            cmd="$cmd -q "
        fi
        if [[ -n $dest ]]; then
            cmd="$cmd -O $dest"
        fi
        cmd="$cmd $url"
    fi

    if [[ ! -d $dest ]] && [[ ! -f $dest ]]; then
        verbose_msg "Downloading $asset"
        if sh -c "$cmd"; then
            return 0
        else
            error_msg "Failed to download $asset"
            return 5
        fi
    else
        warn_msg "$asset already exists in $dest, skipping download"
        return 5
    fi
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        --log)
            NOLOG=false
            ;;
        --nolog)
            NOLOG=true
            ;;
        --nocolor)
            NOCOLOR=true
            ;;
        -v | --verbose)
            VERBOSE=true
            ;;
        -q | --quiet)
            QUIET=true
            ;;
        -V | --version)
            PRINT_VERSION=true
            ;;
        --dry | --dry-run | --dry_run | --dryrun)
            DRY_RUN=true
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

if [[ ! -t 1 ]]; then
    NOCOLOR=true
fi

if [[ $PRINT_VERSION == true ]]; then
    echo -e "\n$NAME version: ${VERSION}"
    exit 0
fi

initlog
if [[ -n $AUTHOR ]]; then
    verbose_msg "Author         : ${AUTHOR}"
fi
verbose_msg "Script version : ${VERSION}"
verbose_msg "Date           : $(date)"
verbose_msg "Log Disable    : ${NOLOG}"
if [[ $NOLOG == false ]]; then
    verbose_msg "Log location   : ${LOG}"
fi
verbose_msg "Current Shell  : ${CURRENT_SHELL}"
verbose_msg "Platform       : ${SHELL_PLATFORM}"
verbose_msg "Architecture   : ${ARCH}"
verbose_msg "OS             : ${OS}"
verbose_msg "DRY RUN        : ${DRY_RUN}"

#######################################################################
#                           CODE Goes Here                            #
#######################################################################

if ! hash nvim 2>/dev/null; then
    error_msg "Missing neovim executable"
    exit 1
fi

locations=(
    'deps'
    'packer'
    'host'
)

plugin_type=(
    'start'
    'opt'
)

MINI_DIR=""

for dir in "${locations[@]}"; do
    for runtime_type in "${plugin_type[@]}"; do
        if is_windows; then
            MINI_PATH="$HOME/AppData/Local/nvim-data/site/pack/$dir/$runtime_type/"
        else
            MINI_PATH="$HOME/.local/share/nvim/site/pack/$dir/$runtime_type/"
        fi
        if [[ -d "$MINI_PATH/mini.nvim" ]]; then
            verbose_msg "Found mini in $MINI_PATH"
            MINI_DIR="$MINI_PATH/mini.nvim"
            break
        fi
    done
    if [[ -n $MINI_DIR ]]; then
        break
    fi
done

if [[ -z $MINI_DIR ]]; then
    if is_windows; then
        MINI_DIR="$HOME/AppData/Local/nvim-data/site/pack/deps/start"
    else
        MINI_DIR="$HOME/.local/share/nvim/site/pack/deps/start"
    fi

    if [[ ! -d $MINI_DIR ]]; then
        status_msg "Cloning repository"
        if ! git clone --recursive https://github.com/echasnovski/mini.nvim "$MINI_DIR/mini.nvim"; then
            error_msg "Failed to clone mini.nvim"
            exit 1
        fi
    else
        verbose_msg "Mini already cloned"
    fi
fi

nvim -V1 --version | tee -a test.log
status_msg "Starting unittests"
if ! nvim --headless --cmd 'let g:minimal=1' --cmd "let g:no_output=1" --cmd "lua require'nvim'.setup(true)" -c "lua MiniTest.execute(MiniTest.collect())"; then
    error_msg "Failed to run nvim tests"
fi

#######################################################################
#                           CODE Goes Here                            #
#######################################################################
if [[ $ERR_COUNT -gt 0 ]]; then
    exit 1
fi

exit 0

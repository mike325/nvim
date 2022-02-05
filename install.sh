#!/usr/bin/env bash
# shellcheck disable=SC1117

#   Author: Mike 8a
#   Description: Install all my basic configs and scripts
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
#            .`   github.com/mike325/dotfiles   `/

# TODO: create a install.ps1 to install
# - scoop and aditional buckets versions, extras and nerd-fonts
# - chocolatey

ALL=1
COOL_FONTS=0
DOTCONFIGS=0
VIM=0
NVIM=0
BIN=0
SHELL_SCRIPTS=0
# SHELL_FRAMEWORK=0
EMACS=0
DOTFILES=0
GIT=0
FORCE_INSTALL=0
BACKUP=0
BACKUP_DIR="$HOME/.local/backup_$(date '+%d.%b.%Y_%H-%M-%S')"
VERBOSE=0
PORTABLES=0
SYSTEMD=0
NOCOLOR=0
NOLOG=0
PYTHON=0
PKGS=0
TMP="/tmp/"
PKG_FILE=""
NEOVIM_DOTFILES=0

NEOVIM_DEV=0

CMD="ln -fns"

PYTHON_VERSION="all"
PROTOCOL="https"
GIT_USER="mike325"
GIT_HOST="github.com"
URL=""

# GIT_SSH=0

VERSION="0.5.0"

NAME="$0"
NAME="${NAME##*/}"
LOG="${NAME%%.*}.log"
WARN_COUNT=0
ERR_COUNT=0

SCRIPT_PATH="$0"
SCRIPT_PATH="${SCRIPT_PATH%/*}"

OS='unknown'
ARCH="$(uname -m)"

trap '{ exit_append; }' EXIT
trap '{ clean_up; }' SIGTERM SIGINT

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

function is_windows() {
    if [[ $SHELL_PLATFORM =~ (msys|cygwin|windows) ]]; then
        return 0
    fi
    return 1
}

function is_wsl() {
    if [[ "$(uname -r)" =~ Microsoft ]]; then
        return 0
    fi
    return 1
}

function is_osx() {
    if [[ $SHELL_PLATFORM == 'osx' ]]; then
        return 0
    fi
    return 1
}

function is_linux() {
    if ! is_windows && ! is_wsl && ! is_osx; then
        return 0
    fi
    return 1
}

function is_root() {
    if ! is_windows && [[ $EUID -eq 0 ]]; then
        return 0
    fi
    return 1
}

function has_sudo() {
    if ! is_windows && hash sudo 2>/dev/null && [[ "$(groups)" =~ sudo ]]; then
        return 0
    fi
    return 1
}

function is_64bits() {
    local arch
    arch="$(uname -m)"
    if [[ $arch == 'x86_64' ]] || [[ $arch == 'arm64' ]]; then
        return 0
    fi
    return 1
}

function has_fetcher() {
    if hash curl 2>/dev/null || hash wget 2>/dev/null; then
        return 0
    fi
    return 1
}

if is_windows; then
    # Windows does not support links we will use cp instead
    CMD="cp -rf"
    USER="$USERNAME"
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
    Simple installer of this dotfiles, by default install (link) all settings and configurations
    if any flag is given, the script will install just want is being told to do.

Usage:
    $NAME [OPTIONS]

    Optional Flags
        --host
            Change default git host, the new host (ex. gitlab.com) must have the following repos
                - .vim
                - .emacs.d
                - dotfiles

            Default: github.com

        --user
            Change default git user, the new user (ex. mike325) must have the following repos
                - .vim
                - .emacs.d
                - dotfiles

            Default: mike325

        -p, --protocol
            Alternate between different git protocol
                - https (default)
                - ssh
                - git (not tested)

            Default: https

        --url
            Provie full git url (ex. https://gitlab.com/mike325), the new base user must have
            the following repos
                - .vim
                - .emacs.d
                - dotfiles

            Default: https://$GIT_HOST/$GIT_USER

        --backup,
            Backup all existing files into $HOME/.local/backup or the provided dir
            ----    Backup will be auto activated if windows is running or '-c/--copy' flag is used

            Default: off in linux on in windows

        -f, --force
            Force installation, remove all previous conflict files before installing
            This flag is always disable by default

            Default: off

        --shell_scripts
            Install some bash/zsh shell scripts like:
                - tmux tpm
                - z.sh
                - screenfetch
            Current shell:   $CURRENT_SHELL

            Default: on

        -w, --shell_frameworks, --shell_frameworks=SHELL
            Install shell frameworks, bash-it or oh-my-zsh according to the current shell
            Current shell:   $CURRENT_SHELL
            If SHELL is given then force install SHELL framework (bash or zsh)

            Default: on

        -c, --copy
            By default all dotfiles are linked using 'ln -s' command, this flag change
            the command to 'cp -rf' this way you can remove the folder after installation
            but you need to re-download the files each time you want to update the files
            ----    Ignored option in Windows platform
            ----    WARNING!!! if you use the option -f/--force all host Setting will be deleted!!!

            Default: off in linux on in windows

        -s, --shell
            Install:
                - Shell alias in $HOME/.config/shell
                - Shell basic configurations \${SHELL}rc for bash, zsh, tcsh and csh
                - Everything inside ./dotconfigs into $HOME
                - Python startup script in $HOME/.local/lib/

            Default: on

        -d, --dotfiles
            Download my dotfiles repo in case, this options is meant to be used in case this
            script is standalone executed
                Default URL: $PROTOCOL://$GIT_HOST/$GIT_USER/dotfiles

            Default: off unless this script is executed from outside of the repo

        -e, --emacs
            Download and install my evil Emacs dotfiles
                Default URL: $PROTOCOL://$GIT_HOST/$GIT_USER/.emacs.d

            Default: on

        -v, --vim
            Download and install my Vim dotfiles
                Default URL: $PROTOCOL://$GIT_HOST/$GIT_USER/.vim

            Default: on

        -n, --nvim, --neovim=[stable|dev]
            Download Neovim executable (portable in windows and linux) if it hasn't been Installed
            Download and install my Vim dotfiles in Neovim's dir.
            Check if vim dotfiles are already install and copy/link (depends of '-c/copy' flag) them,
            otherwise download them from vim's dotfiles repo
                Default URL: $PROTOCOL://$GIT_HOST/$GIT_USER/.vim
            Select the type of neovim version to download using 'stable' or 'dev'

            Default: on

        -b, --bin
            Install shell functions and scripts in $HOME/.local/bin

            Default: on

        -g, --git
            Install git configurations into $HOME/.config/git and $HOME/.gitconfig
            Install:
                - Gitconfigs
                - Hooks
                - Templates

            Default: on

        -t, --portables
            Install isolated/portable programs into $HOME/.local/bin
                - neovim
                - shellcheck
                - texlab
                - fd
                - ripgrep
                - pip2 and pip3
                - efm-langserver
                - fzf (GNU/Linux only)
                - jq (GNU/Linux only)

            Default: on

        --fonts, --powerline
            Install the powerline patched fonts
                * Since the patched fonts have different install method for Windows
                they are just download
                * This options is ignored if the install script is executed in a SSH session

            Default: on

        --python, --python=VERSION
            If no version is given install python2 and python3 dependencies from:
                - ./packages/${OS}/python2
                - ./packages/${OS}/python3
            else install packages from the given version (2 or 3)

            Default: on with python2 and python3

        --pkgs, --packages, --packages=PKG_FILE [--only]
            Install all .pkg files from ./packages/${OS}/
            if the package file is given then force install packages from there
            Additional flag --only cancel all other flags

            Default: off

        -y, systemd
            Install user's systemd services (Just in Linux systems)
                * Services are install in $HOME/.config/systemd/user

            Default: on

        --nolog
            Disable log writting

            Default: off

        --nocolor
            Disable color output

            Default: off

        --verbose
            Output debug messages

            Default: off

        --version
            Display the version and exit

        -h, --help
            Display help, if you are seeing this, that means that you already know it (nice)

EOF
}

function warn_msg() {
    local msg="$1"
    if [[ $NOCOLOR -eq 0 ]]; then
        printf "${yellow}[!] Warning:${reset_color}\t %s\n" "$msg"
    else
        printf "[!] Warning:\t %s\n" "$msg"
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
    if [[ $NOCOLOR -eq 0 ]]; then
        printf "${green}[*] Info:${reset_color}\t %s\n" "$msg"
    else
        printf "[*] Info:\t %s\n" "$msg"
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

function clean_up() {
    verbose_msg "Cleaning up by interrupt"
    verbose_msg "Cleanning up rg ${TMP}/rg.*" && rm -rf "${TMP}/rg.*" 2>/dev/null
    verbose_msg "Cleanning up rg $TMP/ripgrep-*" && rm -rf "$TMP/ripgrep-*" 2>/dev/null
    verbose_msg "Cleanning up fd ${TMP}/fd.*" && rm -rf "${TMP}/fd.*" 2>/dev/null
    verbose_msg "Cleanning up fd $TMP/fd-*" && rm -rf "$TMP/fd-*" 2>/dev/null
    verbose_msg "Cleanning up pip $TMP/get-pip.py" && rm -rf "$TMP/get-pip.py" 2>/dev/null
    verbose_msg "Cleanning up shellcheck $TMP/shellcheck*" && rm -rf "$TMP/shellcheck*" 2>/dev/null
    verbose_msg "Cleanning up ctags $TMP/ctags*" && rm -rf "$TMP/ctags*" 2>/dev/null
    verbose_msg "Cleanning up nvim $TMP/nvim" && rm -rf "$TMP/nvim" 2>/dev/null
    exit_append
    exit 1
}

function setup_config() {
    local pre_cmd="$1"
    local post_cmd="$2"

    if [[ $BACKUP -eq 1 ]]; then
        # We check if the target exist since we could be adding new
        # scripts that may no be installed
        if [[ -f $post_cmd   ]] || [[ -d $post_cmd   ]]; then
            local name="${post_cmd##*/}"
            # We want to copy all non symbolic links
            if [[ ! -L $post_cmd   ]]; then
                verbose_msg "Backing up $post_cmd to ${BACKUP_DIR}/${name}"
                cp -rf --backup=numbered "$post_cmd" "${BACKUP_DIR}/${name}"
            elif [[ -d "$post_cmd/host" ]] && [[ $(ls -A "$post_cmd/host") ]]; then
                # Check for host specific settings only if it's not empty
                verbose_msg "Backing up $post_cmd/host to ${BACKUP_DIR}/${name}/host"
                cp -rf --backup=numbered "$post_cmd/host" "${BACKUP_DIR}/${name}"
            else
                verbose_msg "Nothing to backup in $post_cmd"
            fi

            rm -rf "$post_cmd"
        fi
    elif [[ $FORCE_INSTALL -eq 1 ]]; then
        verbose_msg "Removing $post_cmd"
        rm -rf "$post_cmd"
    elif [[ -f $post_cmd   ]] || [[ -e $post_cmd   ]] || [[ -d $post_cmd   ]]; then
        warn_msg "Skipping ${post_cmd##*/}, already exists in ${post_cmd%/*}"
        return 1
    fi

    verbose_msg "Executing -> $CMD $pre_cmd $post_cmd"
    if sh -c "$CMD $pre_cmd $post_cmd"; then
        if [[ $BACKUP -eq 1 ]] && [[ $CMD == "cp -rf" ]]; then
            local name="${post_cmd##*/}"
            if [[ -d "${BACKUP_DIR}/${name}/host" ]] && [[ $(ls -A "${BACKUP_DIR}/${name}/host") ]]; then
                status_msg "Restoring shell/host folder"
                verbose_msg "Restoring shell host from ${BACKUP_DIR}/${name}/host"
                cp -rf "${BACKUP_DIR}/${name}/host" "$post_cmd/host"
            fi
        fi
        return 0
    else
        if [[ $CMD == "cp -rf" ]]; then
            error_msg "Fail to copy $pre_cmd"
        else
            error_msg "Fail to link $pre_cmd"
        fi
        return 1
    fi

}

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
        if [[ $VERBOSE -eq 0 ]]; then
            cmd="$cmd -s "
        fi
        cmd="$cmd $url"
        if [[ -n $dest ]]; then
            cmd="$cmd -o $dest"
        fi
    else  # If not curl, wget is available since we checked with "has_fetcher"
        cmd='wget '
        if [[ $VERBOSE -eq 0 ]]; then
            cmd="$cmd -q "
        fi
        if [[ -n $dest ]]; then
            cmd="$cmd -O $dest"
        fi
        cmd="$cmd $url"
    fi

    if [[ $BACKUP -eq 1 ]]; then
        if [[ -e $dest ]] || [[ -d $dest ]]; then
            verbose_msg "Backing up $dest into $BACKUP_DIR"
            mv --backup=numbered "$dest" "$BACKUP_DIR"
        fi
    elif [[ $FORCE_INSTALL -eq 1 ]]; then
        verbose_msg "Removing $dest"
        rm -rf "$dest"
    elif [[ -e $dest ]] || [[ -d $dest ]]; then
        warn_msg "Skipping $asset, already exists in ${dest%/*}"
        return 4
    fi

    if [[ ! -d $dest ]] && [[ ! -f $dest ]]; then
        verbose_msg "Downloading $asset"
        if eval "$cmd"; then
            return 0
        else
            error_msg "Failed to download $asset"
            return 5
        fi
    else
        warn_msg "$asset already exists in $dest, skipping download"
        return 5
    fi

    return 1
}

function clone_repo() {
    local repo="$1"
    local dest="$2"

    if hash git 2>/dev/null; then
        if [[ $BACKUP -eq 1 ]]; then
            if [[ -e $dest ]] || [[ -d $dest ]]; then
                verbose_msg "Backing up $dest into $BACKUP_DIR"
                mv --backup=numbered "$dest" "$BACKUP_DIR"
            fi
        elif [[ $FORCE_INSTALL -eq 1 ]]; then
            verbose_msg "Removing $dest"
            rm -rf "$dest"
        elif [[ -e $dest ]] || [[ -d $dest ]]; then
            warn_msg "Skipping ${repo##*/}, already exists in $dest"
            return 1
        fi

        if [[ ! -d $dest ]] && [[ ! -f $dest ]]; then
            verbose_msg "Cloning $repo into $dest"
            # TODO: simplify this crap
            if [[ $VERBOSE -eq 1 ]]; then
                if git clone --recursive "$repo" "$dest"; then
                    return 0
                fi
            else
                if git clone --quiet --recursive "$repo" "$dest" &>/dev/null; then
                    return 0
                fi
            fi
        else
            warn_msg "$dest already exists, skipping cloning"
            return 3
        fi
    else
        error_msg "Git command is not available"
        return 2
    fi
    return 1
}

function setup_bin() {
    status_msg "Getting shell functions and scripts"

    for script in "${SCRIPT_PATH}"/bin/*; do
        local scriptname="${script##*/}"

        local file_basename="${scriptname%%.*}"
        # local file_extention="${scriptname##*.}"

        verbose_msg "Setup $script into $HOME/.local/bin/$file_basename"
        setup_config "$script" "$HOME/.local/bin/$file_basename"
    done
    return 0
}

function setup_dotconfigs() {

    local github="https://github.com"
    local rst=0

    status_msg "Getting python startup script"
    setup_config "${SCRIPT_PATH}/scripts/pythonstartup.py" "$HOME/.local/lib/pythonstartup.py"

    status_msg "Getting dotconfigs"
    for script in "${SCRIPT_PATH}"/dotconfigs/*; do
        local scriptname="${script##*/}"

        # local file_basename="${scriptname%%.*}"
        # local file_extention="${scriptname##*.}"

        verbose_msg "Setup $script into $HOME/.${scriptname}"
        setup_config "$script" "$HOME/.${scriptname}"
    done

    local sh_shells=(bash zsh)
    local csh_shells=(tcsh csh)

    status_msg "Getting Shell init files"

    for shell in "${sh_shells[@]}"; do
        status_msg "Setting up ${shell}rc"
        if [[ ! -f "$HOME/.${shell}rc" ]] || [[ $FORCE_INSTALL -eq 1 ]]; then
            setup_config "${SCRIPT_PATH}/shell/init/shellrc.sh" "$HOME/.${shell}rc"
        else
            warn_msg "The file $HOME/.${shell}rc already exists, trying $HOME/.${shell}rc.$USER"
            setup_config "${SCRIPT_PATH}/shell/init/shellrc.sh" "$HOME/.${shell}rc.$USER"
        fi
    done

    setup_config "${SCRIPT_PATH}/shell/init/profile" "$HOME/.profile"
    # setup_config "${SCRIPT_PATH}/shell/init/profile" "$HOME/.zprofile"

    for shell in "${csh_shells[@]}"; do
        status_msg "Setting up ${shell}rc"
        if [[ ! -f "$HOME/.${shell}rc" ]]; then
            setup_config "${SCRIPT_PATH}/shell/init/shellrc.csh" "$HOME/.${shell}rc"
        else
            warn_msg "The file $HOME/.${shell}rc already exists, trying $HOME/.${shell}rc.$USER"
            setup_config "${SCRIPT_PATH}/shell/init/shellrc.csh" "$HOME/.${shell}rc.$USER"
        fi
    done

    if is_windows; then
        status_msg "Setting up Windows profile"
        if [[ ! -f "$HOME/Documents/WindowsPowerShell/profile.ps1" ]]; then
            [[ ! -d "$HOME/Documents/WindowsPowerShell/" ]] && mkdir -p "$HOME/Documents/WindowsPowerShell/"
            setup_config "${SCRIPT_PATH}/shell/init/profile.ps1" "$HOME/Documents/WindowsPowerShell/profile.ps1"
        fi
    fi

    setup_config "${SCRIPT_PATH}/shell/" "$HOME/.config/shell" || rst=1

    if hash tmux 2>/dev/null; then
        status_msg "Setting Tmux plugins"

        [[ ! -d "$HOME/.tmux/plugins/tpm" ]] && mkdir -p "$HOME/.tmux/plugins/"

        if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
            if ! clone_repo "$github/tmux-plugins/tpm" "$HOME/.tmux/plugins/tpm"; then
                error_msg "Failed to clone tmux plugin manager"
                rst=1
            fi
        else
            warn_msg "Skipping TPM, already install in $HOME/.tmux/plugins/tpm"
        fi

    else
        warn_msg "Skipping tmux configs, tmux is not installed"
    fi

    return $rst
}

function setup_shell_scripts() {
    local rst=0

    if [[ $CURRENT_SHELL =~ (ba|z)?sh ]]; then
        local github='https://raw.githubusercontent.com'
        [[ ! -d "$HOME/.config/shell/scripts/" ]] && mkdir -p "$HOME/.config/shell/scripts/"

        if [[ ! -f "$HOME/.config/shell/scripts/z.sh" ]]; then
            status_msg 'Getting Z'
            local z="${github}/rupa/z/master/z.sh"
            if  download_asset "Z script" "${z}" "$TMP/z.sh"; then
                mv "$TMP/z.sh" "$HOME/.config/shell/scripts/z.sh"
                [[ ! -f "$HOME/.z" ]] && touch "$HOME/.z"
            else
                error_msg 'Failed to download Z script'
                rst=1
            fi
        else
            warn_msg "Z script already install"
            rst=1
        fi

    else
        error_msg "Not compatible shell ${CURRENT_SHELL}"
        rst=1
    fi

    if has_fetcher && { ! hash screenfetch 2>/dev/null || [[ $FORCE_INSTALL -eq 1 ]];  }; then
        [[ $FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing screenfetch install'
        status_msg 'Getting screenfetch'
        local pkg='screenfetch'
        local url="https://git.io/vaHfR"
        if  download_asset "screenfetch script" "${url}" "$TMP/${pkg}"; then
            mv "$TMP/${pkg}" "$HOME/.local/bin/"
            chmod u+x "$HOME/.local/bin/${pkg}"
        else
            error_msg 'Failed to download screenfetch script'
            rst=1
        fi
    elif ! has_fetcher; then
        error_msg "No curl neither wget to download screenfetch"
        rst=2
    else
        warn_msg "Skipping screenfetch, already installed"
        rst=2
    fi

    return $rst
}

function setup_git() {
    status_msg "Installing Global Git settings"
    setup_config "${SCRIPT_PATH}/git/gitconfig" "$HOME/.gitconfig"

    status_msg "Installing Global Git templates and hooks"
    setup_config "${SCRIPT_PATH}/git" "$HOME/.config/git"

    status_msg "Setting up local git commands"
    [[ ! -d "$HOME/.config/git/host" ]] && mkdir -p "$HOME/.config/git/host"

    # Since we are initializing the system, we want to copy our own hooks in this repo
    status_msg "Settings git hooks for the current dotfiles"
    if [[ ! -d "${SCRIPT_PATH}/.git/hooks" ]]; then
        setup_config "${SCRIPT_PATH}/git/templates/hooks/" "${SCRIPT_PATH}/.git/hooks"
    else
        [[ ! -d "${SCRIPT_PATH}/.git/hooks" ]] && mkdir -p "${SCRIPT_PATH}/.git/hooks"
        for hooks in "${SCRIPT_PATH}"/git/templates/hooks/*; do
            local scriptname="${script##*/}"

            local file_basename="${scriptname%%.*}"
            # local file_extention="${scriptname##*.}"

            verbose_msg "Getting $hooks into ${SCRIPT_PATH}/.git/hooks/${hooks##*/}"

            setup_config "$hooks" "${SCRIPT_PATH}/.git/hooks/${hooks##*/}"
        done
    fi
    return 0
}

function get_vim_dotfiles() {
    status_msg "Cloning vim dotfiles in $HOME/.vim"

    # If we couldn't clone our repo, return
    if ! clone_repo "$URL/.vim" "$HOME/.vim"; then
        error_msg "Failed to clone Vim's configs"
        return 1
    fi

    if [[ ! -f "$HOME/.vim/vimrc" ]] && ! setup_config "$HOME/.vim/init.vim" "$HOME/.vimrc"; then
        error_msg "Vimrc link failed"
        return 1
    fi

    if [[ ! -f "$HOME/.vim/gvimrc" ]] && ! setup_config "$HOME/.vim/ginit.vim" "$HOME/.gvimrc"; then
        error_msg "gvimrc link failed"
        return 1
    fi

    if is_windows; then

        if [[ -d "$HOME/.vim" ]] && [[ ! -d "$HOME/vimfiles" ]]; then
            status_msg "Copying vim dir into in $HOME/vimfiles"
            if ! setup_config "$HOME/.vim" "$HOME/vimfiles"; then
                error_msg "We couldn't copy vim dir"
                return 1
            fi
        else
            status_msg "Cloning vim dotfiles in $HOME/vimfiles"
            if ! clone_repo "$URL/.vim" "$HOME/vimfiles"; then
                error_msg "Couldn't get vim repo"
                return 1
            fi
        fi

        if [[ ! -f "$HOME/vimfiles/vimrc" ]] && ! setup_config "$HOME/vimfiles/init.vim" "$HOME/_vimrc"; then
            error_msg "Vimrc link failed"
            return 1
        fi

        if [[ ! -f "$HOME/vimfiles/gvimrc" ]] && ! setup_config "$HOME/.vim/ginit.vim" "$HOME/_gvimrc"; then
            error_msg "gvimrc link failed"
            return 1
        fi

    fi

    return 0
}

function get_nvim_dotfiles() {
    status_msg "Setting up neovim"

    if [[ $PORTABLES -eq 0 ]] && [[ $ALL -eq 0 ]] && [[ $NEOVIM_DOTFILES -eq 0 ]] && ! [[ $ARCH =~ ^arm ]]; then
        local args="--portable"

        [[ $FORCE_INSTALL -eq 1 ]] && args=" --force $args"
        [[ $NOCOLOR -eq 1 ]] && args=" --nocolor $args"
        [[ $VERBOSE -eq 1 ]] && args=" --verbose $args"
        [[ $NEOVIM_DEV -eq 1 ]] && args=" --dev $args"
        if ! hash nvim 2>/dev/null  || [[ $FORCE_INSTALL -eq 1 ]]; then
            if ! eval "${SCRIPT_PATH}/bin/get_nvim.sh ${args}"; then
                error_msg ""
                return 1
            fi
        fi
    elif [[ $ARCH =~ ^arm ]]; then
        warn_msg "Skipping neovim install, Portable not available for ARM systemas"
    elif [[ $NEOVIM_DOTFILES -eq 0 ]]; then
        verbose_msg "Skipping neovim install, already install with defaults or portables"
    fi

    if is_windows; then

        # If we couldn't clone our repo, return
        status_msg "Getting neovim in $HOME/AppData/Local/nvim"
        if [[ -d "$HOME/.vim" ]]; then
            setup_config "$HOME/.vim" "$HOME/AppData/Local/nvim"
            setup_config "$HOME/.vim" "$HOME/.config/nvim"
        elif [[ -d "$HOME/vimfiles" ]]; then
            setup_config "$HOME/vimfiles" "$HOME/AppData/Local/nvim"
            setup_config "$HOME/.vim" "$HOME/.config/nvim"
        else
            status_msg "Cloning neovim dotfiles in $HOME/AppData/Local/nvim"
            if ! clone_repo "$URL/.vim" "$HOME/.config/nvim"; then
                error_msg "Fail to clone dotvim files"
                return 1
            fi
        fi

    else

        # if the current command creates a symbolic link and we already have some vim
        # settings, lets use them
        status_msg "Checking existing vim dotfiles"
        if [[ -d "$HOME/.vim" ]]; then
            [[ $CMD == "ln -s" ]] && status_msg "Linking current vim dotfiles"
            [[ $CMD == "cp -rf" ]] && status_msg "Copying current vim dotfiles"
            if ! setup_config "$HOME/.vim" "$HOME/.config/nvim"; then
                error_msg "Failed gettings dotvim files"
                return 1
            fi
        else
            status_msg "Cloning neovim dotfiles in $HOME/.config/nvim"
            if ! clone_repo "$URL/.vim" "$HOME/.config/nvim"; then
                error_msg "Fail to clone dotvim files"
                return 1
            fi
        fi
    fi

    return 0
}

function _windows_portables() {
    local rst=0
    local github='https://github.com'

    if ! has_fetcher; then
        error_msg "Missing curl and wget, aborting portables installation"
        return 3
    fi

    if ! hash shellcheck 2>/dev/null || [[ $FORCE_INSTALL -eq 1 ]]; then
        [[ $FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing shellcheck install'
        status_msg "Getting shellcheck"
        local pkg='shellcheck-latest.zip'
        local url="${github}/koalaman/shellcheck"
        if download_asset "Shellcheck" "${url}/releases/download/latest/${pkg}" "$TMP/${pkg}"; then
            [[ -d "$TMP/shellcheck-latest" ]] && rm -rf "$TMP/shellcheck-latest"
            unzip -o "$TMP/${pkg}" -d "$TMP/shellcheck-latest"
            chmod +x "$TMP/shellcheck-latest/shellcheck.exe"
            mv "$TMP/shellcheck-latest/shellcheck.exe" "$HOME/.local/bin/shellcheck.exe"
            verbose_msg "Cleanning up pkg ${TMP}/${pkg}" && rm -rf "${TMP:?}/${pkg}"
            verbose_msg "Cleanning up data $TMP/shellcheck-latest" && rm -rf "$TMP/shellcheck-latest"
        else
            rst=1
        fi
    else
        warn_msg "Skipping shellcheck, already installed"
        rst=2
    fi

    if ! hash bat 2>/dev/null || [[ $FORCE_INSTALL -eq 1 ]]; then
        [[ $FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing bat install'
        status_msg "Getting bat"
        local pkg='bat.zip'
        local url="${github}/sharkdp/bat"
        if hash curl 2>/dev/null; then
            # shellcheck disable=SC2155
            local version="$(curl -Ls ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1)"
        else
            # shellcheck disable=SC2155
            local version="$(wget -qO- ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1)"
        fi
        status_msg "Downloading bat version: ${version}"
        local os_type='x86_64-pc-windows-msvc'
        if download_asset "Bat" "${url}/releases/download/${version}/bat-${version}-${os_type}.zip" "$TMP/${pkg}"; then
            pushd "$TMP" 1>/dev/null  || return 1
            verbose_msg "Extracting into $TMP/${pkg}"
            if ! unzip -o "$TMP/${pkg}" -d "$TMP/bat-${version}-${os_type}/"; then
                error_msg "An error occurred extracting zip file"
                rst=1
            else
                chmod u+x "$TMP/bat-${version}-${os_type}/bat-${version}-${os_type}/bat.exe"
                mv "$TMP/bat-${version}-${os_type}/bat-${version}-${os_type}/bat.exe" "$HOME/.local/bin/"
            fi
            verbose_msg "Cleanning up pkg ${TMP}/${pkg}" && rm -rf "${TMP:?}/${pkg}"
            verbose_msg "Cleanning up data $TMP/bat-${version}-${os_type}" && rm -rf "$TMP/bat-${version}-${os_type}/"
            popd 1>/dev/null  || return 1
        else
            rst=1
        fi
    else
        warn_msg "Skipping bat, already installed"
        rst=2
    fi

    if ! hash delta 2>/dev/null || [[ $FORCE_INSTALL -eq 1 ]]; then
        [[ $FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing delta install'
        status_msg "Getting delta"
        local pkg='delta.zip'
        local url="${github}/dandavison/delta"
        if hash curl 2>/dev/null; then
            # shellcheck disable=SC2155
            local version="$(curl -Ls ${url}/tags | grep -oE '[0-9]+\.[0-9]+\.[0-9]+$' | sort -uhr | head -n 1)"
        else
            # shellcheck disable=SC2155
            local version="$(wget -qO- ${url}/tags | grep -oE '[0-9]+\.[0-9]+\.[0-9]+$' | sort -uhr | head -n 1)"
        fi
        status_msg "Downloading delta version: ${version}"
        local os_type='x86_64-pc-windows-msvc'
        if download_asset "delta" "${url}/releases/download/${version}/delta-${version}-${os_type}.zip" "$TMP/${pkg}"; then
            pushd "$TMP" 1>/dev/null  || return 1
            verbose_msg "Extracting into $TMP/${pkg}"
            if ! unzip -o "$TMP/${pkg}"; then
                error_msg "An error occurred extracting zip file"
                rst=1
            else
                chmod u+x "$TMP/delta-${version}-${os_type}/delta.exe"
                mv "$TMP/delta-${version}-${os_type}/delta.exe" "$HOME/.local/bin/"
            fi
            verbose_msg "Cleanning up pkg ${TMP}/${pkg}" && rm -rf "${TMP:?}/${pkg}"
            verbose_msg "Cleanning up data $TMP/delta-${version}-${os_type}" && rm -rf "$TMP/delta-${version}-${os_type}/"
            popd 1>/dev/null  || return 1
        else
            rst=1
        fi
    else
        warn_msg "Skipping delta, already installed"
        rst=2
    fi

    if ! hash rg 2>/dev/null || [[ $FORCE_INSTALL -eq 1 ]]; then
        [[ $FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing rg install'
        status_msg "Getting rg"
        local pkg='ripgrep.zip'
        local url="${github}/BurntSushi/ripgrep"
        if hash curl 2>/dev/null; then
            # shellcheck disable=SC2155
            local version="$( curl -Ls ${url}/tags | grep -oE '[0-9]+\.[0-9]+\.[0-9]+$' | sort -u | tail -n 1)"
        else
            # shellcheck disable=SC2155
            local version="$( wget -qO- ${url}/tags | grep -oE '[0-9]+\.[0-9]+\.[0-9]+$' | sort -u | tail -n 1)"
        fi
        status_msg "Downloading rg version: ${version}"
        local os_type="${ARCH}-pc-windows-gnu"
        if download_asset "Ripgrep" "${url}/releases/download/${version}/ripgrep-${version}-${os_type}.zip" "$TMP/${pkg}"; then
            pushd "$TMP" 1>/dev/null  || return 1
            verbose_msg "Extracting into $TMP/${pkg}"
            if ! unzip -o "$TMP/${pkg}"; then
                error_msg "An error occurred extracting zip file"
                rst=1
            else
                chmod u+x "$TMP/ripgrep-${version}-${os_type}/rg.exe"
                mv "$TMP/ripgrep-${version}-${os_type}/rg.exe" "$HOME/.local/bin/"
            fi
            verbose_msg "Cleanning up pkg ${TMP}/${pkg}" && rm -rf "${TMP:?}/${pkg}"
            verbose_msg "Cleanning up data $TMP/ripgrep-${version}-${os_type}" && rm -rf "$TMP/ripgrep-${version}-${os_type}/"
            popd 1>/dev/null  || return 1
        else
            rst=1
        fi
    else
        warn_msg "Skipping rg, already installed"
        rst=2
    fi

    if ! hash fd 2>/dev/null || [[ $FORCE_INSTALL -eq 1 ]]; then
        [[ $FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing fd install'
        status_msg "Getting fd"
        local pkg='fd.zip'
        local url="${github}/sharkdp/fd"
        if hash curl 2>/dev/null; then
            # shellcheck disable=SC2155
            local version="$( curl -Ls ${url}/tags | grep -oE 'v[0-9]\.[0-9]\.[0-9]$' | sort -u | tail -n 1)"
        else
            # shellcheck disable=SC2155
            local version="$( wget -qO- ${url}/tags | grep -oE 'v[0-9]\.[0-9]\.[0-9]$' | sort -u | tail -n 1)"
        fi
        status_msg "Downloading fd version: ${version}"
        local os_type="${ARCH}-pc-windows-gnu"
        if download_asset "Fd" "${url}/releases/download/${version}/fd-${version}-${os_type}.zip" "$TMP/${pkg}"; then
            pushd "$TMP" 1>/dev/null  || return 1
            verbose_msg "Extracting into $TMP/${pkg}"
            if ! unzip -o "$TMP/${pkg}" -d "$TMP/fd-${version}-${os_type}/"; then
                error_msg "An error occurred extracting zip file"
                rst=1
            else
                chmod u+x "$TMP/fd-${version}-${os_type}/fd-${version}-${os_type}/fd.exe"
                mv "$TMP/fd-${version}-${os_type}/fd-${version}-${os_type}/fd.exe" "$HOME/.local/bin/"
            fi
            verbose_msg "Cleanning up pkg ${TMP}/${pkg}" && rm -rf "${TMP:?}/${pkg}"
            verbose_msg "Cleanning up data $TMP/fd-${version}-${os_type}/fd-${version}-${os_type}" && rm -rf "$TMP/fd-${version}-${os_type}/fd-${version}-${os_type}/"
            popd 1>/dev/null  || return 1
        else
            rst=1
        fi
    else
        warn_msg "Skipping fd, already installed"
        rst=2
    fi

    if ! hash texlab 2>/dev/null || [[ $FORCE_INSTALL -eq 1 ]]; then
        [[ $FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing texlab install'
        status_msg "Getting texlab"
        local pkg='texlab.zip'
        local url="${github}/latex-lsp/texlab"
        if hash curl 2>/dev/null; then
            # shellcheck disable=SC2155
            local version="$(curl -Ls ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1)"
        else
            # shellcheck disable=SC2155
            local version="$(wget -qO- ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1)"
        fi
        status_msg "Downloading texlab version: ${version}"
        local os_type="${ARCH}-windows"
        if download_asset "texlab" "${url}/releases/download/${version}/texlab-${os_type}.zip" "$TMP/${pkg}"; then
            pushd "$TMP" 1>/dev/null  || return 1
            verbose_msg "Extracting into $TMP/${pkg}"
            unzip -o "$TMP/${pkg}"
            chmod u+x "$TMP/texlab.exe"
            mv "$TMP/texlab.exe" "$HOME/.local/bin/"
            verbose_msg "Cleanning up pkg ${TMP}/${pkg}" && rm -rf "${TMP:?}/${pkg}"
            popd 1>/dev/null  || return 1
        else
            rst=1
        fi
    else
        warn_msg "Skipping texlab, already installed"
        rst=2
    fi

    if is_64bits && { ! hash mc 2>/dev/null || [[ $FORCE_INSTALL -eq 1 ]];  }; then
        [[ $FORCE_INSTALL -eq 1 ]] && { [[ -f "$HOME/.local/bin/mc.exe" ]] && status_msg 'Forcing minio client install' && rm -rf "$HOME/.local/bin/mc.exe"; }
        status_msg "Getting minio client"
        if download_asset "Minio client" "https://dl.min.io/client/mc/release/windows-amd64/mc.exe" "$HOME/.local/bin/mc.exe"; then
            chmod +x "$HOME/.local/bin/mc.exe"
        else
            rst=1
        fi
    elif ! is_64bits; then
        error_msg "Minio portable is only Available for x86 64 bits"
        rst=1
    else
        warn_msg "Skipping minio client, already installed"
        rst=2
    fi

    if [[ $ARCH == 'x86_64' ]] && { ! hash efm-langserver 2>/dev/null || [[ $FORCE_INSTALL -eq 1 ]]; }; then
        [[ $FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing efm-langserver install'
        status_msg "Getting efm-langserver"
        local pkg='efm-langserver.zip'
        local url="${github}/mattn/efm-langserver"
        if hash curl 2>/dev/null; then
            # shellcheck disable=SC2155
            local version="$(curl -Ls ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1)"
        else
            # shellcheck disable=SC2155
            local version="$(wget -qO- ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1)"
        fi
        status_msg "Downloading efm-langserver version: ${version}"
        local os_type="windows_amd64"
        if download_asset "efm-langserver" "${url}/releases/download/${version}/efm-langserver_${version}_${os_type}.zip" "$TMP/${pkg}"; then
            pushd "$TMP" 1>/dev/null  || return 1
            verbose_msg "Extracting into $TMP/${pkg}"
            unzip -o "$TMP/${pkg}"
            chmod u+x "$TMP/efm-langserver_${version}_${os_type}/efm-langserver.exe"
            mv "$TMP/efm-langserver_${version}_${os_type}/efm-langserver.exe" "$HOME/.local/bin/"
            verbose_msg "Cleanning up pkg ${TMP}/${pkg}" && rm -rf "${TMP:?}/${pkg}"
            popd 1>/dev/null  || return 1
        else
            rst=1
        fi
    elif ! [[ $ARCH == 'x86_64' ]]; then
        error_msg "efm-langserver portable is only Available for x86 64 bits"
        rst=1
    else
        warn_msg "Skipping efm-langserver, already installed"
        rst=2
    fi

    if  ! hash shfmt 2>/dev/null || [[ $FORCE_INSTALL -eq 1 ]]; then
        [[ $FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing shfmt install'
        status_msg "Getting shfmt"
        local pkg='shfmt.exe'
        local url="${github}/mvdan/sh"
        if hash curl 2>/dev/null; then
            # shellcheck disable=SC2155
            local version="$(curl -Ls ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1)"
        else
            # shellcheck disable=SC2155
            local version="$(wget -qO- ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1)"
        fi
        status_msg "Downloading shfmt version: ${version}"
        local os_type
        if [[ $ARCH == 'x86_64' ]]; then
            os_type="windows_amd64"
        elif [[ $ARCH == 'x86' ]]; then
            os_type="windows_386"
        else
            os_type="windows_arm"
        fi
        if download_asset "shfmt" "${url}/releases/download/${version}/shfmt_${version}_${os_type}.exe" "$TMP/${pkg}"; then
            pushd "$TMP" 1>/dev/null  || return 1
            chmod u+x "$TMP/${pkg}"
            mv "$TMP/${pkg}" "$HOME/.local/bin/${pkg}"
            popd 1>/dev/null  || return 1
        else
            rst=1
        fi
    else
        warn_msg "Skipping shfmt, already installed"
        rst=2
    fi

    if [[ $ARCH == 'x86_64' ]] && { ! hash stylua 2>/dev/null || [[ $FORCE_INSTALL -eq 1 ]];  }; then
        [[ $FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing stylua install'
        status_msg "Getting stylua"
        local pkg='stylua.zip'
        local url="${github}/johnnymorganz/stylua"
        if hash curl 2>/dev/null; then
            # shellcheck disable=SC2155
            local version="$(curl -Ls ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1)"
        else
            # shellcheck disable=SC2155
            local version="$(wget -qO- ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1)"
        fi
        status_msg "Downloading stylua version: ${version}"
        if download_asset "stylua" "${url}/releases/download/${version}/stylua-${version#v}-win64.zip" "$TMP/${pkg}"; then
            pushd "$TMP" 1>/dev/null  || return 1
            verbose_msg "Extracting into $TMP/${pkg}" && unzip -o "$TMP/${pkg}" -d "$TMP/"
            chmod u+x "$TMP/stylua.exe"
            mv "$TMP/stylua.exe" "$HOME/.local/bin/"
            verbose_msg "Cleanning up pkg ${TMP}/${pkg}" && rm -rf "${TMP:?}/${pkg}"
            popd 1>/dev/null  || return 1
        else
            rst=1
        fi
    elif ! [[ $ARCH == 'x86_64' ]]; then
        error_msg "stylua portable is only Available for x86 64 bits"
        rst=1
    else
        warn_msg "Skipping stylua, already installed"
        rst=2
    fi

    return $rst
}

function _linux_portables() {
    local rst=0
    local github='https://github.com'

    if ! hash fzf 2>/dev/null || [[ $FORCE_INSTALL -eq 1 ]]; then
        [[ $FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing FZF install'
        status_msg "Getting FZF"
        if ! clone_repo "${github}/junegunn/fzf" "$HOME/.fzf"; then
            error_msg "Fail to clone FZF"
            rst=1
        fi
        if [[ $VERBOSE -eq 1 ]]; then
            if ! "$HOME/.fzf/install" --all --no-update-rc; then
                error_msg "Fail to install FZF"
                rst=1
            fi
        else
            if ! "$HOME/.fzf/install" --all --no-update-rc &>/dev/null; then
                error_msg "Fail to install FZF"
                rst=1
            fi
        fi
    else
        warn_msg "Skipping FZF, already installed"
        rst=2
    fi

    if [[ $ARCH =~ ^armv6   ]]; then
        warn_msg "Skipping no ARMv6 compatible portables"
        return 2
    fi

    if ! has_fetcher; then
        error_msg "Missing curl and wget, aborting portables installation"
        return 3
    fi

    if ! hash lazygit 2>/dev/null || [[ $FORCE_INSTALL -eq 1 ]]; then
        [[ $FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing lazygit install'
        status_msg "Getting lazygit"
        local pkg='lazygit.tar.gz'
        local url="${github}/jesseduffield/lazygit"
        if hash curl 2>/dev/null; then
            # shellcheck disable=SC2155
            local version="$(curl -Ls ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1)"
        else
            # shellcheck disable=SC2155
            local version="$(wget -qO- ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1)"
        fi
        status_msg "Downloading lazygit version: ${version}"
        if [[ $ARCH =~ ^arm   ]]; then
            local os_type='Linux_arm64'
        elif [[ $ARCH == 'x86'   ]]; then
            local os_type="Linux_32-bit"
        else
            local os_type="Linux_${ARCH}"
        fi
        if download_asset "lazygit" "${url}/releases/download/${version}/lazygit_${version#v}_${os_type}.tar.gz" "$TMP/${pkg}"; then
            pushd "$TMP" 1>/dev/null  || return 1
            verbose_msg "Extracting into $TMP/${pkg}" && tar xf "$TMP/${pkg}"
            chmod u+x "$TMP/lazygit"
            mv "$TMP/lazygit" "$HOME/.local/bin/"
            verbose_msg "Cleanning up pkg ${TMP}/${pkg}" && rm -rf "${TMP:?}/${pkg}"
            popd 1>/dev/null  || return 1
        else
            rst=1
        fi
    else
        warn_msg "Skipping lazygit, already installed"
        rst=2
    fi

    if ! hash bat 2>/dev/null || [[ $FORCE_INSTALL -eq 1 ]]; then
        [[ $FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing bat install'
        status_msg "Getting bat"
        local pkg='bat.tar.xz'
        local url="${github}/sharkdp/bat"
        if hash curl 2>/dev/null; then
            # shellcheck disable=SC2155
            local version="$(curl -Ls ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1)"
        else
            # shellcheck disable=SC2155
            local version="$(wget -qO- ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1)"
        fi
        status_msg "Downloading bat version: ${version}"
        if [[ $ARCH =~ ^arm   ]]; then
            local os_type='arm-unknown-linux-gnueabihf'
        else
            local os_type="${ARCH}-unknown-linux-musl"
        fi
        if download_asset "Bat" "${url}/releases/download/${version}/bat-${version}-${os_type}.tar.gz" "$TMP/${pkg}"; then
            pushd "$TMP" 1>/dev/null  || return 1
            verbose_msg "Extracting into $TMP/${pkg}" && tar xf "$TMP/${pkg}"
            chmod u+x "$TMP/bat-${version}-${os_type}/bat"
            mv "$TMP/bat-${version}-${os_type}/bat" "$HOME/.local/bin/"
            verbose_msg "Cleanning up pkg ${TMP}/${pkg}" && rm -rf "${TMP:?}/${pkg}"
            verbose_msg "Cleanning up data $TMP/bat-${version}-${os_type}" && rm -rf "$TMP/bat-${version}-${os_type}/"
            popd 1>/dev/null  || return 1
        else
            rst=1
        fi
    else
        warn_msg "Skipping bat, already installed"
        rst=2
    fi

    if ! hash delta 2>/dev/null || [[ $FORCE_INSTALL -eq 1 ]]; then
        [[ $FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing delta install'
        status_msg "Getting delta"
        local pkg='delta.tar.gz'
        local url="${github}/dandavison/delta"
        if hash curl 2>/dev/null; then
            # shellcheck disable=SC2155
            local version="$(curl -Ls ${url}/tags | grep -oE '[0-9]+\.[0-9]+\.[0-9]+$' | sort -ruh | head -n 1)"
        else
            # shellcheck disable=SC2155
            local version="$(wget -qO- ${url}/tags | grep -oE '[0-9]+\.[0-9]+\.[0-9]+$' | sort -ruh | head -n 1)"
        fi
        status_msg "Downloading delta version: ${version}"
        if [[ $ARCH =~ ^arm   ]]; then
            local os_type='arm-unknown-linux-gnueabihf'
        else
            local os_type="${ARCH}-unknown-linux-musl"
        fi
        if download_asset "delta" "${url}/releases/download/${version}/delta-${version}-${os_type}.tar.gz" "$TMP/${pkg}"; then
            pushd "$TMP" 1>/dev/null  || return 1
            verbose_msg "Extracting into $TMP/${pkg}" && tar xf "$TMP/${pkg}"
            chmod u+x "$TMP/delta-${version}-${os_type}/delta"
            mv "$TMP/delta-${version}-${os_type}/delta" "$HOME/.local/bin/"
            verbose_msg "Cleanning up pkg ${TMP}/${pkg}" && rm -rf "${TMP:?}/${pkg}"
            verbose_msg "Cleanning up data $TMP/delta-${version}-${os_type}" && rm -rf "$TMP/delta-${version}-${os_type}/"
            popd 1>/dev/null  || return 1
        else
            rst=1
        fi
    else
        warn_msg "Skipping delta, already installed"
        rst=2
    fi

    if ! hash rg 2>/dev/null || [[ $FORCE_INSTALL -eq 1 ]]; then
        [[ $FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing rg install'
        status_msg "Getting rg"
        local pkg='rg.tar.xz'
        local url="${github}/BurntSushi/ripgrep"
        if hash curl 2>/dev/null; then
            # shellcheck disable=SC2155
            local version="$(curl -Ls ${url}/tags | grep -oE '[0-9]+\.[0-9]+\.[0-9]+$' | sort -u | tail -n 1)"
        else
            # shellcheck disable=SC2155
            local version="$(wget -qO- ${url}/tags | grep -oE '[0-9]+\.[0-9]+\.[0-9]+$' | sort -u | tail -n 1)"
        fi

        status_msg "Downloading rg version: ${version}"

        if [[ $ARCH =~ ^arm   ]]; then
            local os_type='arm-unknown-linux-gnueabihf'
        else
            local os_type="${ARCH}-unknown-linux-musl"
        fi

        if download_asset "Ripgrep" "${url}/releases/download/${version}/ripgrep-${version}-${os_type}.tar.gz" "$TMP/${pkg}"; then
            pushd "$TMP" 1>/dev/null  || return 1
            verbose_msg "Extracting into $TMP/${pkg}" && tar xf "$TMP/${pkg}"
            chmod u+x "$TMP/ripgrep-${version}-${os_type}/rg"
            mv "$TMP/ripgrep-${version}-${os_type}/rg" "$HOME/.local/bin/"
            verbose_msg "Cleanning up pkg ${TMP}/${pkg}" && rm -rf "${TMP:?}/${pkg}"
            verbose_msg "Cleanning up data $TMP/ripgrep-${version}-${os_type}" && rm -rf "$TMP/ripgrep-${version}-${os_type}"
            popd 1>/dev/null  || return 1
        else
            rst=1
        fi
    else
        warn_msg "Skipping ripgrep, already installed"
        rst=2
    fi

    if ! hash fd 2>/dev/null || [[ $FORCE_INSTALL -eq 1 ]]; then
        [[ $FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing fd install'
        status_msg "Getting fd"
        local pkg='fd.tar.xz'
        local url="${github}/sharkdp/fd"
        if hash curl 2>/dev/null; then
            # shellcheck disable=SC2155
            local version="$(curl -Ls ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | tail -n 1)"
        else
            # shellcheck disable=SC2155
            local version="$(wget -qO- ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | tail -n 1)"
        fi
        status_msg "Downloading fd version: ${version}"
        if [[ $ARCH =~ ^arm   ]]; then
            local os_type='arm-unknown-linux-gnueabihf'
        else
            local os_type="${ARCH}-unknown-linux-musl"
        fi
        if download_asset "Fd" "${url}/releases/download/${version}/fd-${version}-${os_type}.tar.gz" "$TMP/${pkg}"; then
            pushd "$TMP" 1>/dev/null  || return 1
            verbose_msg "Extracting into $TMP/${pkg}" && tar xf "$TMP/${pkg}"
            chmod u+x "$TMP/fd-${version}-${os_type}/fd"
            mv "$TMP/fd-${version}-${os_type}/fd" "$HOME/.local/bin/"
            verbose_msg "Cleanning up pkg ${TMP}/${pkg}" && rm -rf "${TMP:?}/${pkg}"
            verbose_msg "Cleanning up data $TMP/fd-${version}-${os_type}" && rm -rf "$TMP/fd-${version}-${os_type}/"
            popd 1>/dev/null  || return 1
        else
            rst=1
        fi
    else
        warn_msg "Skipping fd, already installed"
        rst=2
    fi

    if [[ $ARCH =~ ^arm ]]; then
        warn_msg "Skipping no ARM compatible portables"
        return 2
    fi

    if [[ $ARCH == 'x86_64' ]] && { ! hash shellcheck 2>/dev/null || [[ $FORCE_INSTALL -eq 1 ]]; }; then
        [[ $FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing shellcheck install'
        status_msg "Getting shellcheck"
        local pkg='shellcheck-latest.linux.x86_64.tar.xz'
        local url="${github}/koalaman/shellcheck"
        if download_asset "Shellcheck" "${url}/releases/download/latest/${pkg}" "$TMP/${pkg}"; then
            pushd "$TMP" 1>/dev/null  || return 1
            verbose_msg "Extracting into $TMP/${pkg}" && tar xf "$TMP/${pkg}"
            chmod u+x "$TMP/shellcheck-latest/shellcheck"
            mv "$TMP/shellcheck-latest/shellcheck" "$HOME/.local/bin/"
            verbose_msg "Cleanning up pkg ${TMP}/${pkg}" && rm -rf "${TMP:?}/${pkg}"
            verbose_msg "Cleanning up data $TMP/shellcheck-latest/" && rm -rf "$TMP/shellcheck-latest/"
            popd 1>/dev/null  || return 1
        else
            rst=1
        fi
    elif ! hash shellcheck 2>/dev/null && [[ $ARCH != 'x86_64' ]]; then
        warn_msg "Shellcheck does not have prebuild binaries for non 64 bits x86 devices"
        rst=2
    else
        warn_msg "Skipping shellcheck, already installed"
        rst=2
    fi

    if is_64bits && { ! hash texlab 2>/dev/null || [[ $FORCE_INSTALL -eq 1 ]];  }; then
        [[ $FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing texlab install'
        status_msg "Getting texlab"
        local pkg='texlab.tar.gz'
        local url="${github}/latex-lsp/texlab"
        if hash curl 2>/dev/null; then
            # shellcheck disable=SC2155
            local version="$(curl -Ls ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1)"
        else
            # shellcheck disable=SC2155
            local version="$(wget -qO- ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1)"
        fi
        status_msg "Downloading texlab version: ${version}"
        local os_type="${ARCH}-linux"
        if download_asset "texlab" "${url}/releases/download/${version}/texlab-${os_type}.tar.gz" "$TMP/${pkg}"; then
            pushd "$TMP" 1>/dev/null  || return 1
            verbose_msg "Extracting into $TMP/${pkg}" && tar xf "$TMP/${pkg}"
            chmod u+x "$TMP/texlab"
            mv "$TMP/texlab" "$HOME/.local/bin/"
            verbose_msg "Cleanning up pkg ${TMP}/${pkg}" && rm -rf "${TMP:?}/${pkg}"
            popd 1>/dev/null  || return 1
        else
            rst=1
        fi
    elif ! is_64bits; then
        error_msg "Texlab portable is only Available for x86 64 bits"
        rst=1
    else
        warn_msg "Skipping texlab, already installed"
        rst=2
    fi

    if is_64bits && { ! hash mc 2>/dev/null || [[ $FORCE_INSTALL -eq 1 ]];  }; then
        [[ $FORCE_INSTALL -eq 1 ]] && { [[ -f "$HOME/.local/bin/mc" ]] && status_msg 'Forcing minio client install' && rm -rf "$HOME/.local/bin/mc"; }
        status_msg "Getting minio client"
        if download_asset "MinioClient" "https://dl.min.io/client/mc/release/linux-amd64/mc" "$HOME/.local/bin/mc"; then
            chmod +x "$HOME/.local/bin/mc"
        else
            rst=1
        fi
    elif ! is_64bits; then
        error_msg "Minio portable is only Available for x86 64 bits"
        rst=1
    else
        warn_msg "Skipping minio client, already installed"
        rst=2
    fi

    if ! hash jq 2>/dev/null || [[ $FORCE_INSTALL -eq 1 ]]; then
        [[ $FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing jq install'
        status_msg "Getting jq"
        local pkg='jq'
        local url="${github}/stedolan/jq"
        if hash curl 2>/dev/null; then
            # shellcheck disable=SC2155
            local version="$( curl -Ls ${url}/tags | grep -oE 'jq-[0-9]+\.[0-9]+$' | sort -u | tail -n 1)"
        else
            # shellcheck disable=SC2155
            local version="$( wget -qO- ${url}/tags | grep -oE 'jq-[0-9]+\.[0-9]+$' | sort -u | tail -n 1)"
        fi
        status_msg "Downloading jq version: ${version}"
        local os_type="linux32"
        if is_64bits; then
            os_type="linux64"
        fi
        if download_asset "jq" "${url}/releases/download/${version}/jq-${os_type}" "$TMP/${pkg}"; then
            pushd "$TMP" 1>/dev/null  || return 1
            chmod u+x "$TMP/${pkg}"
            mv "$TMP/${pkg}" "$HOME/.local/bin/"
            popd 1>/dev/null  || return 1
        else
            rst=1
        fi
    else
        warn_msg "Skipping jq, already installed"
        rst=2
    fi

    if [[ $ARCH == 'x86_64' ]] && { ! hash efm-langserver 2>/dev/null || [[ $FORCE_INSTALL -eq 1 ]];  }; then
        [[ $FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing efm-langserver install'
        status_msg "Getting efm-langserver"
        local pkg='efm-langserver.tar.gz'
        local url="${github}/mattn/efm-langserver"
        if hash curl 2>/dev/null; then
            # shellcheck disable=SC2155
            local version="$(curl -Ls ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1)"
        else
            # shellcheck disable=SC2155
            local version="$(wget -qO- ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1)"
        fi
        status_msg "Downloading efm-langserver version: ${version}"
        local os_type="linux_amd64"
        if download_asset "efm-langserver" "${url}/releases/download/${version}/efm-langserver_${version}_${os_type}.tar.gz" "$TMP/${pkg}"; then
            pushd "$TMP" 1>/dev/null  || return 1
            verbose_msg "Extracting into $TMP/${pkg}" && tar xf "$TMP/${pkg}"
            chmod u+x "$TMP/efm-langserver_${version}_${os_type}/efm-langserver"
            mv "$TMP/efm-langserver_${version}_${os_type}/efm-langserver" "$HOME/.local/bin/"
            verbose_msg "Cleanning up pkg ${TMP}/${pkg}" && rm -rf "${TMP:?}/${pkg}"
            popd 1>/dev/null  || return 1
        else
            rst=1
        fi
    elif ! [[ $ARCH == 'x86_64' ]]; then
        error_msg "efm-langserver portable is only Available for x86 64 bits"
        rst=1
    else
        warn_msg "Skipping efm-langserver, already installed"
        rst=2
    fi

    if  ! hash gh 2>/dev/null || [[ $FORCE_INSTALL -eq 1 ]]; then
        [[ $FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing github cli install'
        status_msg "Getting gh"
        local pkg='gh.tar.gz'
        local url="${github}/cli/cli"
        if hash curl 2>/dev/null; then
            # shellcheck disable=SC2155
            local version="$(curl -Ls ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1 | cut -dv -f2)"
        else
            # shellcheck disable=SC2155
            local version="$(wget -qO- ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1 | cut -dv -f2)"
        fi
        status_msg "Downloading github cli version: ${version}"
        local os_type
        if [[ $ARCH == 'x86_64' ]]; then
            os_type="linux_amd64"
        elif [[ $ARCH == 'x86' ]]; then
            os_type="linux_386"
        elif [[ $ARCH == 'armv7' ]] || [[ $ARCH == 'arm64' ]]; then
            os_type="linux_arm64"
        else
            os_type="linux_arm6"
        fi
        if download_asset "gh" "${url}/releases/download/v${version}/gh_${version}_${os_type}.tar.gz" "$TMP/${pkg}"; then
            pushd "$TMP" 1>/dev/null  || return 1
            verbose_msg "Extracting into $TMP/${pkg}" && tar xf "$TMP/${pkg}"
            chmod u+x "$TMP/gh_${version}_${os_type}/bin/gh"
            mv "$TMP/gh_${version}_${os_type}/bin/gh" "$HOME/.local/bin/"
            verbose_msg "Cleanning up pkg ${TMP}/${pkg}" && rm -rf "${TMP:?}/${pkg}"
            popd 1>/dev/null  || return 1
        else
            rst=1
        fi
    else
        warn_msg "Skipping gh, already installed"
        rst=2
    fi

    if ! hash shfmt 2>/dev/null || [[ $FORCE_INSTALL -eq 1 ]]; then
        [[ $FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing shfmt install'
        status_msg "Getting shfmt"
        local pkg='shfmt'
        local url="${github}/mvdan/sh"
        if hash curl 2>/dev/null; then
            # shellcheck disable=SC2155
            local version="$(curl -Ls ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1)"
        else
            # shellcheck disable=SC2155
            local version="$(wget -qO- ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1)"
        fi
        status_msg "Downloading shfmt version: ${version}"
        local os_type
        if [[ $ARCH == 'x86_64' ]]; then
            os_type="linux_amd64"
        elif [[ $ARCH == 'x86' ]]; then
            os_type="linux_386"
        elif [[ $ARCH == 'armv7' ]] || [[ $ARCH == 'arm64' ]]; then
            os_type="linux_arm64"
        else
            os_type="linux_arm"
        fi
        if download_asset "shfmt" "${url}/releases/download/${version}/shfmt_${version}_${os_type}" "$TMP/${pkg}"; then
            pushd "$TMP" 1>/dev/null  || return 1
            chmod u+x "$TMP/${pkg}"
            mv "$TMP/${pkg}" "$HOME/.local/bin/${pkg}"
            popd 1>/dev/null  || return 1
        else
            rst=1
        fi
    else
        warn_msg "Skipping shfmt, already installed"
        rst=2
    fi

    if [[ $ARCH == 'x86_64' ]] && { ! hash stylua 2>/dev/null || [[ $FORCE_INSTALL -eq 1 ]];  }; then
        [[ $FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing stylua install'
        status_msg "Getting stylua"
        local pkg='stylua.zip'
        local url="${github}/johnnymorganz/stylua"
        if hash curl 2>/dev/null; then
            # shellcheck disable=SC2155
            local version="$(curl -Ls ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1)"
        else
            # shellcheck disable=SC2155
            local version="$(wget -qO- ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1)"
        fi
        status_msg "Downloading stylua version: ${version}"
        if download_asset "stylua" "${url}/releases/download/${version}/stylua-${version#v}-linux.zip" "$TMP/${pkg}"; then
            pushd "$TMP" 1>/dev/null  || return 1
            verbose_msg "Extracting into $TMP/${pkg}" && unzip -o "$TMP/${pkg}" -d "$TMP/" &>/dev/null
            chmod u+x "$TMP/stylua"
            mv "$TMP/stylua" "$HOME/.local/bin/"
            verbose_msg "Cleanning up pkg ${TMP}/${pkg}" && rm -rf "${TMP:?}/${pkg}"
            popd 1>/dev/null  || return 1
        else
            rst=1
        fi
    elif ! [[ $ARCH == 'x86_64' ]]; then
        error_msg "stylua portable is only Available for x86 64 bits"
        rst=1
    else
        warn_msg "Skipping stylua, already installed"
        rst=2
    fi

    return $rst
}

# TODO: Add GNU global as a windows portable
# TODO: Add compile option to auto compile some programs
function get_portables() {
    local rst=0

    local github='https://github.com'

    if ! [[ $ARCH =~ ^arm ]] && { ! hash nvim 2>/dev/null || [[ $FORCE_INSTALL -eq 1 ]];  }; then
        [[ $FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing Neovim install'
        status_msg "Getting Neovim"

        local args="--portable"

        [[ $FORCE_INSTALL -eq 1 ]] && args=" --force $args"
        [[ $NOCOLOR -eq 1 ]] && args=" --nocolor $args"
        [[ $VERBOSE -eq 1 ]] && args=" --verbose $args"
        [[ $NEOVIM_DEV -eq 1 ]] && args=" --dev $args"

        if ! eval "${SCRIPT_PATH}/bin/get_nvim.sh ${args}"; then
            error_msg "Fail to install Neovim"
            rst=1
        fi
    elif [[ $ARCH =~ ^arm ]]; then
        warn_msg "Skipping neovim install, Portable not available for ARM systemas"
    else
        warn_msg "Skipping Neovim, already installed"
        rst=2
    fi

    status_msg "Checking portable programs"
    if has_fetcher; then
        if is_windows; then
            _windows_portables
            rst=$?
        elif is_osx; then
            warn_msg "mac support is WIP"
            return 0
        else
            _linux_portables
            rst=$?
        fi
    else
        error_msg "Curl is not available to download portables"
        return 1
    fi
    return $rst
}

function get_emacs_dotfiles() {
    status_msg "Installing Evil Emacs"

    # If we couldn't clone our repo, return
    clone_repo "$URL/.emacs.d" "$HOME/.emacs.d" && return $?

    # verbose_msg "Creating dir $HOME/.config/systemd/user" && mkdir -p "$HOME/.config/systemd/user"
    # if setup_config "${SCRIPT_PATH}/services/emacs.service" "$HOME/.config/systemd/user/emacs.service"
    # then
    #     return 0
    # fi

    return 0
}

function setup_shell_framework() {
    status_msg "Getting shell framework"

    local args=""

    [[ $FORCE_INSTALL -eq 1 ]] && args=" --force $args"
    [[ $NOCOLOR -eq 1 ]] && args=" --nocolor $args"
    [[ $VERBOSE -eq 1 ]] && args=" --verbose $args"

    verbose_msg "Calling get_shell as -> ${SCRIPT_PATH}/bin/get_shell.sh $args -s $CURRENT_SHELL"
    eval "${SCRIPT_PATH}/bin/get_shell.sh $args -s $CURRENT_SHELL" || return 1

    return 0
}

function get_dotfiles() {
    SCRIPT_PATH="$HOME/.local/dotfiles"

    status_msg "Installing dotfiles in $SCRIPT_PATH"

    [[ ! -d "$HOME/.local/" ]] && mkdir -p "$HOME/.local/"

    if clone_repo "$URL/dotfiles" "$SCRIPT_PATH"; then
        return 0
    fi
    return 1
}

function get_cool_fonts() {
    local github='https://github.com'
    if [[ -z $SSH_CONNECTION ]]; then
        status_msg "Gettings powerline fonts"
        if clone_repo "${github}/powerline/fonts" "$HOME/.local/fonts"; then
            if is_windows; then
                # We could indeed run $ powershell $HOME/.local/fonts/install.ps1
                # BUT administrator promp will pop up for EVERY font (too fucking much)
                warn_msg "Please run $HOME/.local/fonts/install.ps1 inside administrator's powershell"
            else
                if is_osx; then
                    mkdir -p "$HOME/Library/Fonts"
                fi
                status_msg "Installing cool fonts"
                if [[ $VERBOSE -eq 1 ]]; then
                    "$HOME"/.local/fonts/install.sh
                else
                    "$HOME"/.local/fonts/install.sh 1>/dev/null
                fi
            fi
        else
            error_msg "Fail to install cool fonts"
        fi

    else
        warn_msg "We cannot install cool fonts in a remote session, please run this in you desktop environment"
    fi
    return 0
}

function setup_systemd() {
    if ! is_windows && ! is_osx; then
        if hash systemctl 2>/dev/null; then
            status_msg "Setting up User's systemd services"
            if [[ -d "$HOME/.config/systemd/user" ]] && [[ $FORCE_INSTALL -eq 1 ]]; then
                [[ $FORCE_INSTALL -eq 1 ]] && { warn_msg "Removing old systemd dir" && rm -rf "$HOME/.config/systemd/user"; }
                setup_config "${SCRIPT_PATH}/systemd/user" "$HOME/.config/systemd/user"
            elif [[ -d "$HOME/.config/systemd/user/" ]]; then
                warn_msg "Systemd folder already exist, copying files manually, files won't be auto updated"
                for service in "${SCRIPT_PATH}"/systemd/user/*.service; do
                    local servicename="${service##*/}"

                    local file_basename="${servicename%%.*}"
                    # local file_extention="${scriptname##*.}"

                    verbose_msg "Setup $service in $HOME/.config/systemd/user/${servicename}"
                    setup_config "${service}" "$HOME/.config/systemd/user/${servicename}"
                done
            else
                [[ ! -d "$HOME/.config/systemd/" ]] && mkdir -p "$HOME/.config/systemd/"
                setup_config "${SCRIPT_PATH}/systemd/user/" "$HOME/.config/systemd/user"
            fi
            status_msg "Please reload user's units with 'systemctl --user daemon-reload'"
            # status_msg "Reloding User's units"
            # systemctl --user daemon-reload
        else
            warn_msg "This system doesn't have systemd package"
            return 1
        fi
    else
        warn_msg "Systemd's services work just in Linux environment"
        return 1
    fi
    return 0
}

function _get_pip() {
    local version="$1"

    if [[ $FORCE_INSTALL -eq 1 ]] || ! hash "pip${version}" 2>/dev/null; then

        if [[ ! -f "$TMP/get-pip.py" ]]; then
            if ! download_asset "PIP" "https://bootstrap.pypa.io/get-pip.py" "$TMP/get-pip.py"; then
                return 1
            fi
            chmod u+x "$TMP/get-pip.py"
        fi

        if [[ $version -eq 3 ]]; then
            local python=("9" "8" "7" "6" "5" "4")
            for version in "${python[@]}"; do
                if hash "python3.${version}" 2>/dev/null; then
                    status_msg "Installing pip3 with python3.${version}"
                    if [[ $VERBOSE -eq 1 ]]; then
                        if "python3.${version}" "$TMP/get-pip.py" --user; then
                            break
                        else
                            error_msg "Fail to install pip for python3.${version}"
                            return 1
                        fi
                    else
                        if "python3.${version}" "$TMP/get-pip.py" --user 1>/dev/null; then
                            break
                        else
                            error_msg "Fail to install pip for python3.${version}"
                            return 1
                        fi
                    fi
                fi
            done
        else
            status_msg "Installing pip2"
            if [[ $VERBOSE -eq 1 ]]; then
                if ! python2 $TMP/get-pip.py --user; then
                    error_msg "Fail to install pip for python2"
                    return 1
                fi
            else
                if ! python2 $TMP/get-pip.py --user 1>/dev/null; then
                    error_msg "Fail to install pip for python2"
                    return 1
                fi
            fi
        fi
    else
        warn_msg "Skipping pip, already installed"
    fi

    return 0
}

function setup_python() {
    if [[ $PYTHON_VERSION == 'all' ]]; then
        # Start to setup just python3 by default since python2 is officially deprecated
        # Python2 can be set with --python=2
        local versions=(3)
    else
        local versions=("$PYTHON_VERSION")
    fi

    for version in "${versions[@]}"; do

        if [[ $FORCE_INSTALL -eq 1 ]] || ! hash "pip${version}" 2>/dev/null; then
            if ! _get_pip "$version"; then
                continue
            fi
        fi

        if ! hash "pip${version}" 2>/dev/null; then
            error_msg "Failed to locate pip${version} executable in the path"
            continue
        fi

        if [[ ! -f "${SCRIPT_PATH}/packages/${OS}/python${version}/requirements.txt" ]]; then
            warn_msg "Skipping requirements for pip ${version} in OS: ${OS}"
        else
            [[ $OS == unknown ]] && warn_msg "Unknown OS, trying to install generic pip packages"
            status_msg "Setting up python ${version} dependencies"
            verbose_msg "Using ${SCRIPT_PATH}/packages/${OS}/python${version}/requirements.txt"

            if [[ $VERBOSE -eq 1 ]]; then
                local quiet=""
            else
                # shellcheck disable=SC2034
                local quiet="--quiet"
            fi

            # if [[ -z $VIRTUAL_ENV ]]; then
            #     # shellcheck disable=SC2016
            #     local cmd="pip${version} install ${quiet} --user -r ${SCRIPT_PATH}/packages/${OS}/python${version}/requirements.txt"
            # else
            #     # shellcheck disable=SC2016
            #     local cmd="pip${version} install ${quiet} -r ${SCRIPT_PATH}/packages/${OS}/python${version}/requirements.txt"
            # fi

            verbose_msg "Pip command --> ${cmd}"
            if ! eval "$cmd"; then
                error_msg "Fail to install python ${version} dependencies"
            fi
        fi
    done

    return 0
}

function setup_pkgs() {
    local rc=0
    if is_osx; then
        warn_msg "macOS support still WIP"
    else
        if ! is_windows && [[ $EUID -ne 0 ]] && [[ ! $(groups) =~ sudo ]]; then
            error_msg "User: ${USER} is neither root nor belongs to the sudo group"
            return 1
        elif is_windows; then
            warn_msg "Windows package install must be run from privilege Git bash terminal"
        fi
        local cmd=""
        if [[ -z $PKG_FILE ]]; then
            if ! ls "${SCRIPT_PATH}/packages/${OS}"/*.pkg >/dev/null; then
                error_msg "No package file for \"${OS}\" OS"
                return 2
            fi
            declare -a pkgs=("${SCRIPT_PATH}/packages/${OS}"/*.pkg)
        elif [[ -f $PKG_FILE ]]; then
            local pkgs=("$PKG_FILE")
        else
            local pkgs=("${SCRIPT_PATH}/packages/${OS}/${PKG_FILE}.pkg")
        fi
        for pkg in "${pkgs[@]}"; do
            verbose_msg "Package file $pkg"
            local cmd=""
            local filename
            filename=$(basename "$pkg")
            local cmdname="${filename%.pkg}"
            if ! hash "${cmdname}" 2>/dev/null; then
                warn_msg "Skipping pacakges from ${filename}, ${cmdname} is not install or missing in the PATH"
                continue
            fi
            while IFS= read -r line; do
                if [[ -z $cmd ]] && [[ $line =~ ^sudo\ .* ]] && [[ $EUID -eq 0 ]]; then
                    # remove sudo instruction if root user is running the script
                    cmd="${line##*sudo}"
                elif [[ ! $line =~ ^#.* ]]; then # if the line starts with "#" then it's a comment
                    cmd="$cmd $line"
                fi
            done <"$pkg"
            status_msg "Installing packages from ${cmdname}"
            # if [[ $_VERBOSE -eq 0 ]]; then
            #     cmd="$cmd"
            # fi
            verbose_msg "Using command $cmd"
            if ! eval "$cmd"; then
                error_msg "Fail to install packages from ${cmdname}"
                rc=1
            fi
        done
    fi
    return $rc
}

function version() {

    if [[ -f "${SCRIPT_PATH}/shell/banner" ]]; then
        cat "${SCRIPT_PATH}/shell/banner"
    fi

    cat <<EOF
Mike's install script

    Author   : Mike 8a
    Version  : ${VERSION}
    Date     : Fri 07 Jun 2019
EOF
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        --backup)
            BACKUP=1
            ;;
        --backup=*)
            _result=$(__parse_args "$key" "backup")
            if [[ $_result == "$key" ]]; then
                error_msg "Not a valid backupdir $_result"
                exit 1
            fi
            BACKUP=1
            BACKUP_DIR="$_result"
            ;;
        -p | --protocol)
            if [[ ! $2 =~ ^(git|https|ssh)$ ]]; then
                error_msg "Not a valid protocol $2"
                exit 1
            fi
            PROTOCOL="$2"
            shift
            ;;
        --protocol=*)
            _result=$(__parse_args "$key" "protocol" '(https|git|ssh)')
            if [[ $_result == "$key" ]]; then
                error_msg "Not a valid protocol $_result"
                exit 1
            fi
            PROTOCOL="$_result"
            ;;
        --host)
            GIT_HOST="$2"
            shift
            ;;
        --host=*)
            _result=$(__parse_args "$key" "host")
            if [[ $_result == "$key" ]]; then
                error_msg "Not a valid host $_result"
                exit 1
            fi
            GIT_HOST="$_result"
            ;;
        --user)
            GIT_USER="$2"
            shift
            ;;
        --user=*)
            _result=$(__parse_args "$key" "user")
            if [[ $_result == "$key" ]]; then
                error_msg "Not a valid gituser $_result"
                exit 1
            fi
            GIT_USER="$_result"
            ;;
        --url)
            if [[ ! $2 =~ ^(https://|git://|git@)[a-zA-Z0-9.:@_-/~]+$ ]]; then
                error_msg "Not a valid url $2"
                exit 1
            fi
            URL="$2"
            shift
            ;;
        --url=*)
            _result=$(__parse_args "$key" "url" '(https://|git://|git@)[a-zA-Z0-9.:@_-/~]+')
            if [[ $_result == "$key" ]]; then
                error_msg "Not a valid url $_result"
                exit 1
            fi
            URL="$_result"
            ;;
        -y | --systemd)
            SYSTEMD=1
            ALL=0
            ;;
        -t | --portable | --portables)
            PORTABLES=1
            ALL=0
            ;;
        --fonts | --powerline)
            COOL_FONTS=1
            ALL=0
            ;;
        -c | --copy)
            CMD="cp -rf"
            ;;
        -s | --shell)
            DOTCONFIGS=1
            ALL=0
            ;;
        --scripts | --shell_scripts)
            DOTCONFIGS=1
            SHELL_SCRIPTS=1
            ALL=0
            ;;
        --shell_frameworks=*)
            _result=$(__parse_args "$key" "shell_frameworks" '(ba|z)sh')
            if [[ $_result == "$key" ]]; then
                error_msg "Not a valid shell ${_result##*=}, available shell are bash and zsh"
                exit 1
            fi
            CURRENT_SHELL="$_result"
            # SHELL_FRAMEWORK=1
            ALL=0
            ;;
        # -w | --shell_frameworks)
        #     SHELL_FRAMEWORK=1
        #     ALL=0
        #     if [[ $2 =~ ^(ba|z)sh$ ]]; then
        #         CURRENT_SHELL="$2"
        #         shift
        #     fi
        #     ;;
        -f | --force)
            FORCE_INSTALL=1
            ;;
        -d | --dotfiles)
            DOTFILES=1
            ALL=0
            ;;
        -e | --emacs)
            EMACS=1
            ALL=0
            ;;
        -v | --vim)
            VIM=1
            ALL=0
            ;;
        --neovim=*)
            _result=$(__parse_args "$key" "neovim" '(dotfiles|stable|dev(elop(ment)?)?)')
            if [[ $_result == "$key" ]]; then
                error_msg "Not a valid neovim build type ${_result##*=}"
                exit 1
            fi
            if [[ $_result == 'dotfiles' ]]; then
                NEOVIM_DOTFILES=1
            elif [[ $_result =~ ^dev(elop(ment)?)?$ ]]; then
                NEOVIM_DEV=1
            else
                NEOVIM_DEV=0
            fi
            NVIM=1
            ALL=0
            ;;
        -n | --neovim | --nvim)
            NVIM=1
            ALL=0
            if [[ $2 =~ ^stable$ ]]; then
                NEOVIM_DEV=0
                shift
            elif [[ $2 =~ ^dotfiles$ ]]; then
                NEOVIM_DEV=0
                NEOVIM_DOTFILES=1
                shift
            elif [[ $2 =~ ^dev(elop(ment)?)?$ ]]; then
                NEOVIM_DEV=1
                shift
            fi
            ;;
        -b | --bin)
            BIN=1
            ALL=0
            ;;
        --python=*)
            _result=$(__parse_args "$key" "python" '(2|3)')
            if [[ $_result == "$key" ]]; then
                error_msg "Not a valid python version ${_result##*=}"
                exit 1
            fi
            PYTHON_VERSION="$_result"
            PYTHON=1
            ALL=0
            ;;
        --python)
            PYTHON=1
            ALL=0
            if [[ $2 =~ ^(2|3)$ ]]; then
                PYTHON_VERSION"$2"
                shift
            fi
            ;;
        -g | --git)
            GIT=1
            ALL=0
            ;;
        --pkgs=*)
            _result=$(__parse_args "$key" "pkgs")
            if [[ $_result == "$key" ]]; then
                error_msg "Not a valid package file ${_result##*=}"
                exit 1
            elif [[ ! -f $_result ]]; then
                error_msg "Package file $_result does not exists"
                exit 1
            elif [[ ! $_result =~ \.pkg$ ]]; then
                error_msg "$_result is not a valid package file, the file must have .pkg extention"
                exit 1
            fi
            PKG_FILE="$_result"
            PKGS=1
            if [[ $2 =~ ^--only$ ]]; then
                ALL=0
                shift
            fi
            ;;
        --packages=*)
            _result=$(__parse_args "$key" "packages")
            if [[ $_result == "$key" ]]; then
                error_msg "Not a valid package file ${_result##*=}"
                exit 1
            elif [[ ! -f $_result ]]; then
                error_msg "Package file $_result does not exists"
                exit 1
            elif [[ ! $_result =~ \.pkg$ ]] || [[ ! -f "${SCRIPT_PATH}/packages/${OS}/${_result}.pkg" ]]; then
                error_msg "$_result is not a valid package file, the file must have .pkg extention"
                exit 1
            fi
            PKG_FILE="$_result"
            PKGS=1
            if [[ $2 =~ ^--only$ ]]; then
                ALL=0
                shift
            fi
            ;;
        --pkgs | --packages)
            PKGS=1
            if [[ ! $2 =~ ^-(-)?.*$ ]]; then
                if [[ -f $2 ]] && [[ $2 =~ \.pkg$ ]]; then
                    PKG_FILE="$2"
                    shift
                elif [[ -f "${SCRIPT_PATH}/packages/${OS}/${2}.pkg" ]]; then
                    PKG_FILE="$2"
                    shift
                fi
            fi

            if [[ $2 =~ ^--only$ ]]; then
                ALL=0
                shift
            fi
            ;;
        --nolog)
            NOLOG=1
            ;;
        --verbose)
            VERBOSE=1
            ;;
        -h | --help)
            help_user
            exit 0
            ;;
        --nocolor)
            NOCOLOR=1
            ;;
        --version)
            version
            exit 0
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

[[ ! -d "$HOME/.local/bin" ]] && verbose_msg "Creating dir $HOME/.local/bin" && mkdir -p "$HOME/.local/bin"
[[ ! -d "$HOME/.local/lib" ]] && verbose_msg "Creating dir $HOME/.local/lib" && mkdir -p "$HOME/.local/lib"
[[ ! -d "$HOME/.config/" ]]   && verbose_msg "Creating dir $HOME/.config/" && mkdir -p "$HOME/.config/"

# Because the "cp -rf" means there are no symbolic links
# we must be sure we wont screw the shell host settings
if is_windows || [[ $CMD == "cp -rf" ]]; then
    verbose_msg "Activating backup"
    BACKUP=1
fi

if [[ $BACKUP -eq 1 ]]; then
    status_msg "Preparing backup dir ${BACKUP_DIR}"
    mkdir -p "${BACKUP_DIR}"
fi

if [[ -z $URL ]]; then
    case $PROTOCOL in
        ssh)
            URL="git@$GIT_HOST:$GIT_USER"
            ;;
        https | http)
            URL="$PROTOCOL://$GIT_HOST/$GIT_USER"
            ;;
        git)
            warn_message "Git protocol has not been tested, yet"
            URL="git://$GIT_HOST/$GIT_USER"
            ;;
        *)
            URL="https://$GIT_HOST/$GIT_USER"
            ;;
    esac
fi

verbose_msg "Using ${URL}"
verbose_msg "Protocol      : ${PROTOCOL}"
verbose_msg "User          : ${GIT_USER}"
verbose_msg "Host          : ${GIT_HOST}"
verbose_msg "Backup Enable : ${BACKUP}"
verbose_msg "Log Disable   : ${NOLOG}"
verbose_msg "Current Shell : ${CURRENT_SHELL}"
verbose_msg "Platform      : ${SHELL_PLATFORM}"
verbose_msg "OS Name       : ${OS}"
verbose_msg "Architecture  : ${ARCH}"

# If the user request the dotfiles or the script path doesn't have the full files
# (the command may be executed using `curl`)
if [[ $DOTFILES -eq 1 ]] || [[ ! -d "${SCRIPT_PATH}/shell" ]]; then
    if ! get_dotfiles; then
        error_msg "Could not install dotfiles"
        exit 1
    fi
fi

if [[ $ALL -eq 1 ]]; then
    verbose_msg 'Setting up everything'
    setup_bin
    setup_dotconfigs
    setup_shell_scripts
    # setup_shell_framework
    setup_git
    get_portables
    get_vim_dotfiles
    get_nvim_dotfiles
    get_emacs_dotfiles
    get_cool_fonts
    setup_systemd
    setup_python
else
    [[ $BIN -eq 1 ]] && setup_bin
    [[ $DOTCONFIGS -eq 1 ]] && setup_dotconfigs
    [[ $SHELL_SCRIPTS -eq 1 ]] && setup_shell_scripts
    # [[ $SHELL_FRAMEWORK -eq 1 ]] && setup_shell_framework
    [[ $GIT -eq 1 ]] && setup_git
    [[ $PORTABLES -eq 1 ]] && get_portables
    [[ $VIM -eq 1 ]] && get_vim_dotfiles
    [[ $NVIM -eq 1 ]] && get_nvim_dotfiles
    [[ $EMACS -eq 1 ]] && get_emacs_dotfiles
    [[ $COOL_FONTS -eq 1 ]] && get_cool_fonts
    [[ $SYSTEMD -eq 1 ]] && setup_systemd
    [[ $PYTHON -eq 1 ]] && setup_python
fi

if [[ $PKGS -eq 1 ]]; then
    setup_pkgs
fi

if [[ $ERR_COUNT -gt 0 ]]; then
    exit 1
fi

exit 0

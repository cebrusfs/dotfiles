# vim: syntax=sh:

function log() {
    local COLOR='\033[1;35m'
    local NO_COLOR='\033[0m'
    printf "${COLOR}>> ${1}${NO_COLOR}\n"
}

function error() {
    local COLOR='\033[1;31m'
    local NO_COLOR='\033[0m'
    printf "${COLOR}[ERROR] ${1}${NO_COLOR}\n"
    exit 1
}

function pushd() {
    command pushd "$@" > /dev/null
}

function popd() {
    command popd "$@" > /dev/null
}

function is_osx() {
    [[ "$OSTYPE" == darwin* ]]
}

function is_linux() {
    [[ "$OSTYPE" == linux* ]]
}

function is_x86_64() {
    local arch=`uname -m`
    [[ "$arch" == x86_64 ]]
}
function is_arm() {
    local arch=`uname -m`
    # TODO: arm32
    [[ "$arch" == aarch64* ]]
}

function check_command() {
    command -v "$1" &> /dev/null
}

function is_pkg_installed() {
    dpkg-query -W --showformat='${Status}\n' "$1" | \
        grep -q "install ok installed"
    # dpkg -l "$1" >/dev/null 2>&1
}

function linux_install() {
    if ! is_linux; then
        return 0
    fi
    log "Trying to install package '$1'"
    # Using apt-get / dpkg (ubuntu / debian)
    is_pkg_installed "$1" || sudo apt install -y "$1"
    # TODO: Support using pacman (archlinux)
}


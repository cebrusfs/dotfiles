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

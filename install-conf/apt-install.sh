# vim: syntax=sh:

set -e

BASEDIR="$(dirname "${BASH_SOURCE[0]}")"
source "${BASEDIR}/utils.sh"

function install_pkgs() {
    sudo apt install -y ripgrep fd-find
}

function main() {
    if ! is_linux; then
        exit 0
    fi

    if ! check_command apt; then
        exit 0
    fi
    install_pkgs
}

main

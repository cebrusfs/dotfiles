# vim: syntax=sh:

set -e

BASEDIR="$(dirname "${BASH_SOURCE[0]}")"
source "${BASEDIR}/utils.sh"

function install_pkgs() {
    linux_install ripgrep
    linux_install fd-find
}

function main() {
    if ! is_linux; then
        exit 0
    fi

    if ! check_command apt && ! check_command dnf; then
        exit 0
    fi
    install_pkgs
}

main

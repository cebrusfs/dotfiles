# vim: syntax=sh:

set -e

BASEDIR="$(dirname "${BASH_SOURCE[0]}")"
source "${BASEDIR}/utils.sh"

function homebrew_install() {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

    brew analytics off
}

function homebrew_install_pkgs() {
    brew bundle -v --no-lock --file="homebrew/Brewfile.min"
}

function main() {
    if ! is_osx; then
        exit 0
    fi

    if ! check_command brew; then
        homebrew_install
    fi
    homebrew_install_pkgs
}

main

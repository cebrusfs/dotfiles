#!/usr/bin/env bash
# vim: syntax=sh:

function log() {
    local COLOR='\033[1;35m'
    local NO_COLOR='\033[0m'
    printf "%b>> %s%b\n" "${COLOR}" "${1}" "${NO_COLOR}"
}

function error() {
    local COLOR='\033[1;31m'
    local NO_COLOR='\033[0m'
    printf "%b[ERROR] %s%b\n" "${COLOR}" "${1}" "${NO_COLOR}"
    exit 1
}

function pushd() {
    command pushd "$@" > /dev/null || return
}

function popd() {
    command popd "$@" > /dev/null || return
}

function is_osx() {
    [[ "$OSTYPE" == darwin* ]]
}

function is_linux() {
    [[ "$OSTYPE" == linux* ]]
}

function is_x86_64() {
    local arch
    arch=$(uname -m)
    [[ "$arch" == x86_64 ]]
}
function is_arm() {
    local arch
    arch=$(uname -m)
    # TODO: arm32
    [[ "$arch" == aarch64* ]]
}

function check_command() {
    command -v "$1" &>/dev/null
}

_PKG_MANAGER=""

function _detect_pkg_manager() {
    if [[ -n "$_PKG_MANAGER" ]]; then
        return 0
    fi

    if check_command apt && check_command dpkg-query; then
        _PKG_MANAGER="apt"
    elif check_command dnf && check_command rpm; then
        _PKG_MANAGER="dnf"
    else
        _PKG_MANAGER="unknown"
    fi
}

function is_pkg_installed() {
    _detect_pkg_manager

    if [[ "$_PKG_MANAGER" == "apt" ]]; then
        dpkg-query -W --showformat='${Status}\n' "$1" 2>/dev/null |
            grep -q "install ok installed"
    elif [[ "$_PKG_MANAGER" == "dnf" ]]; then
        rpm -q "$1" >/dev/null 2>&1
    else
        return 1
    fi
}

function linux_install() {
    if ! is_linux; then
        return 0
    fi
    log "Trying to install package '$1'"

    if is_pkg_installed "$1"; then
        return 0
    fi

    _detect_pkg_manager
    if [[ "$_PKG_MANAGER" == "apt" ]]; then
        sudo apt install -y "$1"
    elif [[ "$_PKG_MANAGER" == "dnf" ]]; then
        sudo dnf install -y "$1"
    else
        error "No supported package manager found (apt or dnf)"
    fi
    # TODO: Support using pacman (archlinux)
}

#!/bin/bash

# Cleanup script to remove legacy package installations that are now managed by mise.
# Run this once after upgrading to the new dotfiles architecture.

set -e

echo "Starting legacy package cleanup..."

if [[ "$OSTYPE" == darwin* ]]; then
    echo "[macOS] Cleaning up Brew..."
    # We leave jujutsu in Brew for Mac, so we don't uninstall it.
    # We remove the CLI tools & languages now managed by mise.
    brew uninstall node nvm pyenv rbenv rustup-init fzf ripgrep fd git-delta bun go ruby shellcheck shfmt 2>/dev/null || true
    brew autoremove || true
elif [[ -f /etc/glinux_version ]] || grep -q "go/glinux" /etc/os-release 2>/dev/null; then
    echo "[gLinux] Cleaning up APT..."
    sudo apt-get remove --purge -y nodejs npm python3-venv python3-pip ruby golang ripgrep fd-find fzf shellcheck shfmt 2>/dev/null || true
    sudo apt-get autoremove -y || true
else
    echo "[Personal Linux] Cleaning up APT..."
    sudo apt-get remove --purge -y nodejs npm python3-venv python3-pip ruby golang ripgrep fd-find fzf shellcheck shfmt 2>/dev/null || true
    sudo apt-get autoremove -y || true
fi

echo "Cleaning up legacy global version managers and directories..."

echo " -> Removing old Dotbot symlinks (e.g. ~/.config/mise)..."
if [[ -L ~/.config/mise ]]; then
    rm ~/.config/mise
fi

echo " -> Removing Node.js legacy environments (~/.nvm, ~/.npm, etc)..."
rm -rf ~/.nvm ~/.n-install ~/.n ~/.npm-global ~/.node-gyp ~/.npm || true

echo " -> Removing Python legacy environments (~/.pyenv)..."
rm -rf ~/.pyenv || true

echo " -> Removing Ruby legacy environments (~/.rbenv, ~/.rvm)..."
rm -rf ~/.rbenv ~/.rvm || true

echo " -> Removing Go legacy environments (~/.gvm, ~/.goenv)..."
rm -rf ~/.gvm ~/.goenv || true

echo " -> Removing Bun legacy environments (~/.bun)..."
rm -rf ~/.bun || true

echo " -> Removing Rust/Cargo legacy environments (~/.cargo, ~/.rustup)..."
# (Completely wipe legacy Rust environments. Mise will cleanly reinstall what it needs)
rm -rf ~/.cargo ~/.rustup || true

echo " -> Removing other local caches (virtualenv, gem)..."
# Other legacy environments (virtualenv, gem cache)
rm -rf ~/.local/share/virtualenv ~/.local/share/gem || true

echo "========================================="
echo "✅ Cleanup finished!"
echo "👉 Please run './install' to deploy the new architecture."

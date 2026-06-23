#!/bin/bash

# Cleanup script to remove legacy package installations that are now managed by mise.
# Run this once after upgrading to the new dotfiles architecture.

set -e

function remove_path() {
    local path="$1"

    if [[ -e "$path" || -L "$path" ]]; then
        echo "    rm -rf $path"
        rm -rf "$path"
    fi
}

function remove_vim_plug_file() {
    local path="$1"

    if [[ -L "$path" ]]; then
        remove_path "$path"
    elif [[ -f "$path" ]] && grep -q "vim-plug: Vim plugin manager" "$path"; then
        remove_path "$path"
    elif [[ -e "$path" ]]; then
        echo "    keeping $path (not a vim-plug file or symlink)"
    fi
}

function cleanup_vim_nvim_legacy() {
    local nvim_config="${HOME}/.config/nvim"
    local nvim_plug_autoload="${HOME}/.local/share/nvim/site/autoload/plug.vim"
    local target

    echo " -> Removing legacy Vim/Neovim config links..."

    if [[ -L "$nvim_config" ]]; then
        target="$(readlink "$nvim_config")"
        case "$target" in
            *config/vim|*config/vim/|*.vim|*.vim/)
                remove_path "$nvim_config"
                ;;
            *)
                echo "    keeping $nvim_config -> $target"
                ;;
        esac
    fi

    # Neovim now uses vim.pack from config/nvim/init.lua. Vim still uses
    # vim-plug, so do not remove ~/.vim/autoload/plug.vim or ~/.vim/plugged.
    remove_vim_plug_file "$nvim_plug_autoload"
    rmdir "${HOME}/.local/share/nvim/site/autoload" 2>/dev/null || true
    rmdir "${HOME}/.local/share/nvim/site" 2>/dev/null || true
}

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

cleanup_vim_nvim_legacy

echo " -> Removing Node.js legacy environments (~/.nvm, ~/.npm, etc)..."
rm -rf ~/.nvm ~/.n-install ~/.n ~/.npm-global ~/.node-gyp ~/.npm || true

echo " -> Removing legacy ~/.npmrc (clearing old prefixes and obsolete auth tokens)..."
rm -f ~/.npmrc || true

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

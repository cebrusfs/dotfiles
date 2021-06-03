#!/bin/sh

# Turn off the analytics
# https://github.com/Homebrew/brew/blob/master/docs/Analytics.md
brew analytics off

PS3='Please enter your choice: '
options=("Personal" "Work")
select opt in "${options[@]}"
do
    case $opt in
        "Personal")
            # TODO: use PREFIX instead of HOME
            file="$HOME/.dotfiles/homebrew/Brewfile.ctf"
            ;;
        "Work")
            file="$HOME/.dotfiles/homebrew/Brewfile.work"
            ;;
        *)
            echo Invalid Option
            exit 1
            ;;
    esac

    brew bundle cleanup -v --no-lock --file="$file" --force
    brew bundle -v --no-lock --file="$file"
    break
done

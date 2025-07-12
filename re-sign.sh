#!/bin/bash

GIT_COMMITTER_NAME="$(git config --global user.name)"
GIT_COMMITTER_EMAIL="$(git config --global user.email)"


git rebase --autostash -f -S --exec "git commit --amend --author=\"$GIT_COMMITTER_NAME <$GIT_COMMITTER_EMAIL>\" --no-edit" $1
git rebase --autostash -f -S $1

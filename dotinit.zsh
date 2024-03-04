#!/usr/bin/env zsh

STOW_FOLDERS="nvim,zsh"
DOTFILES="$HOME/.dotfiles"

pushd $DOTFILES
for folder in $(echo $STOW_FOLDERS | sed "s/,/ /g")
do
	stow -Dv $folder
	stow -v $folder
done
popd

#!/usr/bin/env zsh

# prerequisites: stow, zsh, nvim > 0.9

STOW_FOLDERS="nvim,zsh,tmux"
DOTFILES=$HOME/.dotfiles

pushd $DOTFILES
for folder in $(echo $STOW_FOLDERS | sed "s/,/ /g")
do
	stow -Dv $folder
	stow -v $folder
done
popd

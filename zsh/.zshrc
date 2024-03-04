# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/art/.zshrc'

autoload -Uz compinit
autoload -U colors && colors
PS1='%~: '

source /usr/share/zsh-antigen/antigen.zsh
antigen bundle jeffreytse/zsh-vi-mode
antigen apply

ZVM_VI_INSERT_ESCAPE_BINDKEY=jk

# Add ~/.local/bin to the path
export PATH=$HOME/.local/bin:$PATH


compinit
# End of lines added by compinstall

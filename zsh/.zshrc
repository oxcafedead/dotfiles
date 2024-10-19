# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename "$HOME/.zshrc"

autoload -Uz compinit
autoload -U colors && colors
PS1='%~: '

# Only for WSL
if [ -f /etc/wsl.conf ]; then
	notify-send() {
		wsl-notify-send.exe --category "$WSL_DISTRO_NAME" "Command has completed"
	}
fi


# for ubuntu, it's /usr/share/zsh-antigen/antigen.zsh
# for arch, it's /usr/share/zsh/.. whatever
# for other distros - hell knows
# so, we need to find it
antigen_path=$(find /usr/share/zsh* -name antigen.zsh | head -n 1)
source $antigen_path
antigen bundle jeffreytse/zsh-vi-mode
antigen bundle "MichaelAquilina/zsh-auto-notify"
antigen apply

ZVM_VI_INSERT_ESCAPE_BINDKEY=jk


# Add ~/.local/bin to the path
export PATH=$HOME/.local/bin:$PATH


compinit
# End of lines added by compinstall

# Fix my keyword ls
eval $(thefuck --alias)

# SSH
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent -t 1h > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi
if [[ ! -f "$SSH_AUTH_SOCK" ]]; then
    source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
fi

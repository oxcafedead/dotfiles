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
		if ! command -v wsl-notify-send.exe &> /dev/null; then
			return
		fi
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

# Add cargo to path
source $HOME/.cargo/env
# Add nvim to path
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

# Add .local/bin to path
if [[ -d "$HOME/.local/bin" ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

compinit
# End of lines added by compinstall

# SSH
eval `keychain --eval --agents 'ssh,gpg' --nogui -Q -q`

# Python development pain here:
# Wrap nvim command to source venv if there is venv detected in the current directory
detect_venv_dir() {
    if [[ "$VIRTUAL_ENV" != "" ]]; then
	return
    fi
    # Use find to safely locate all activate scripts
    venvs=( */bin/activate(N) )
    if [[ ${#venvs} -gt 0 ]]; then
        if [[ ${#venvs} -gt 1 ]]; then
            echo -e "\e[33mMultiple virtualenvs detected, taking the first one\e[0m"
        fi
        echo "Virtualenv detected"
	venv_dir="${venvs[1]%/bin/activate}"
	echo "Activate venv in $venv_dir? [Y/n]"
	read -r answer
	if [[ -z "$answer" || "$answer" == "Y" || "$answer" == "y" ]]; then
	    echo "Activating virtualenv $venv_dir"
	    source "$venv_dir/bin/activate"
	fi
    fi
}

nvim() {
    detect_venv_dir
    command nvim "$@"
    # after nvim exits, deactivate venv:
    if [[ "$VIRTUAL_ENV" != "" ]]; then
	echo "Deactivating virtualenv"
	deactivate
    fi
}

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

export EDITOR=nvim

function decode_jwt() {
    JWT=$(cat -)
    echo "$JWT" | awk -F. '{print $2}' | base64 --decode | jq .
}

# Playground...
[ -f "/home/art/.ghcup/env" ] && . "/home/art/.ghcup/env" # ghcup-env

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"
eval "$(pyenv virtualenv-init -)"

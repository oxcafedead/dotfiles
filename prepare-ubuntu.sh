#!/bin/bash
# This is very rough script to prepare the environment for the dotfiles, probably will not work since
# it was created retrospectively.

# Update the package lists
sudo apt-get update
# Install curl and other needed utilities
sudo apt-get install curl unzip xclip -y

sudo add-apt-repository ppa:neovim-ppa/unstable
source /etc/lsb-release
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/unstable/xUbuntu_${DISTRIB_RELEASE}/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:unstable.list
curl -L "https://download.opensuse.org/repositories/devel:kubic:libcontainers:unstable/xUbuntu_${DISTRIB_RELEASE}/Release.key" | sudo tee /etc/apt/trusted.gpg.d/devel_kubic_libcontainers_unstable.asc > /dev/null

sudo apt-get update
sudo apt-get install npm neovim git zsh ripgrep python3-pip podman \
	python3-venv \
	gcc lua5.3 \
	keychain \
	-y

mkdir ~/globalvenvs
python3 -m venv ~/globalvenvs/nvim
source "$HOME/globalvenvs/nvim/bin/activate"
pip install pynvim coverage=5.5
deactivate

# Install plugins manager for Neovim
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# Clone needed repositories for tmux plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
git clone https://github.com/tmux-plugins/tmux-resurrect ~/.tmux/plugins/tmux-resurrect
git clone https://github.com/tmux-plugins/tmux-continuum ~/.tmux/plugins/tmux-continuum

# Change default shell to ZSH
chsh -s $(which zsh)

# Print done
echo "Finished Installing. Re-login or reboot to use ZSH as your default shell. Then run ~/.dotfiles/dotinit.zsh"

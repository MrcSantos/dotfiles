#!/bin/bash
set -eu

OS=$(( lsb_release -ds || cat /etc/*release || uname -om ) 2>/dev/null | head -n1)

if [ $OS = '"Solus"' ]
then
	echo "[-] Updating system..."
	sudo eopkg upgrade -y 1>/dev/null
	
	echo "[-] Installing basic tools..."
	sudo eopkg install neofetch git tmux vim -y 1>/dev/null

	echo "[-] Installing and configuring ZShell..."
	sudo eopkg install zsh -y 1>/dev/null
	echo 'y' | sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
	chsh -s $(which zsh)

	clear

	neofetch
fi

if [ $OS = '"Debian"' ]
then
	sudo apt update && sudo apt upgrade -y && sudo apt dist-upgrade -y
	sudo apt install neofetch git tmux vim -y

	clear

	neofetch
fi

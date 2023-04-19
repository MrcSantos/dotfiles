#!/bin/bash
set -eu

OS=$(( lsb_release -ds || cat /etc/*release || uname -om ) 2>/dev/null | head -n1)
echo "[.] Enter the sudo password: "
read -s PASSWORD

if [ $OS = '"Solus"' ]
then
	echo "[-] Updating system..."
	echo $PASSWORD | sudo -S eopkg upgrade -y 1>/dev/null
	
	echo "[-] Installing basic tools..."
	echo $PASSWORD | sudo -S eopkg install neofetch git tmux vim -y 1>/dev/null

	echo "[-] Installing and configuring ZShell..."
	echo $PASSWORD | sudo -S eopkg install zsh -y 1>/dev/null
	echo 'y' | sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" 1>/dev/null
	git clone -q https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
	chsh -s $(which zsh) 1>/dev/null
	echo "[!] Remember to log out and login again"

	read  -n 1 -p "[.] Press Enter to continue..."

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

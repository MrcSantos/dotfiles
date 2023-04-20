#!/bin/bash
set -eu

OS=$(( lsb_release -ds || cat /etc/*release || uname -om ) 2>/dev/null | head -n1)
read -p "[.] Enter the sudo password: " -s PASSWORD
echo ""


solus() {
	echo "[-] Updating system..."
	eopkg upgrade -y 1>/dev/null
	
	echo "[-] Installing basic tools..."
	eopkg install neofetch git tmux vim -y 1>/dev/null

	echo "[-] Installing nnn..."
	eopkg install nnn -y 1> /dev/null

	echo "[-] Installing ZShell..."
	eopkg install zsh -y 1>/dev/null
}



if [ $OS = '"Solus"' ]
then
	echo $PASSWORD | sudo -S bash -c "$(declare -f solus); solus"

	echo 'y' | sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" 1>/dev/null
	git clone --quiet https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
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

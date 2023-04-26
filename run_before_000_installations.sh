#!/bin/bash
set -eu

NON_SUDO_USER=$USER
OS=$(( lsb_release -ds || cat /etc/*release || uname -om ) 2>/dev/null | head -n1)
read -p "[.] Enter the sudo password: " -s PASSWORD
echo ""



solus() {
	echo ""
	echo "[-] Updating system..."
	eopkg upgrade -y 1>/dev/null
	
	echo "[-] Installing basic tools..."
	eopkg install -c system.devel -y 1>/dev/null
	eopkg install neofetch git tmux vim cargo -y 1>/dev/null

	echo "[-] Installing nnn..."
	eopkg install nnn -y 1>/dev/null

	echo "[-] Installing ZShell..."
	eopkg install zsh -y 1>/dev/null
	chsh -s $(which zsh) $1 1>/dev/null
	chsh -s $(which zsh) 1>/dev/null

	echo "[-] Installing NerdFonts..."
	wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/Hasklig.zip -O /tmp/nerd_fonts.zip 1>/dev/null
	mkdir -p /home/$1/.local/share/fonts
	mkdir -p /root/.local/share/fonts
	mkdir -p /root/.config/nvim
	unzip /tmp/nerd_fonts.zip -d /home/$1/.local/share/fonts 1>/dev/null
	unzip /tmp/nerd_fonts.zip -d /root/.local/share/fonts 1>/dev/null
	chown -R $1 /home/$1/.local/share/fonts

	echo "[-] Installing nvim..."
	eopkg install neovim -y 1>/dev/null
	cargo install ripgrep 1>/dev/null
	sh -c "git clone https://github.com/NvChad/NvChad /root/.config/nvim --depth 1" 1>/dev/null
}

if [ $OS = '"Solus"' ]
then
	echo $PASSWORD | sudo -S bash -c "$(declare -f solus); solus $USER"

	echo 'y' | sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" 1>/dev/null
	sh -c "git clone --quiet https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" 1>/dev/null
	echo "[!] Remember to log out and login again"
	

	sh -c "git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1" 1>/dev/null

	read  -n 1 -p "[.] Press Enter to continue..."

	clear
	neofetch
fi

arch() {
	echo ""
	echo "[-] Updating system..."
	pacman -Syyu --noconfirm 1>/dev/null
	
	echo "[-] Installing basic tools..."
	pacman -S --noconfirm neofetch git tmux vim cargo 1>/dev/null

	echo "[-] Installing nnn..."
	pacman -S --noconfirm nnn 1>/dev/null

	echo "[-] Installing ZShell..."
	pacman -S --noconfirm zsh 1>/dev/null
	chsh -s $(which zsh) $1 1>/dev/null
	chsh -s $(which zsh) 1>/dev/null

	echo "[-] Installing NerdFonts..."
	wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/Hasklig.zip -O /tmp/nerd_fonts.zip 1>/dev/null
	mkdir -p /home/$1/.local/share/fonts
	mkdir -p /root/.local/share/fonts
	mkdir -p /root/.config/nvim
	unzip /tmp/nerd_fonts.zip -d /home/$1/.local/share/fonts 1>/dev/null
	unzip /tmp/nerd_fonts.zip -d /root/.local/share/fonts 1>/dev/null
	chown -R $1 /home/$1/.local/share/fonts

	echo "[-] Installing nvim..."
	pacman -S --noconfirm neovim 1>/dev/null
	cargo install ripgrep 1>/dev/null
	sh -c "git clone https://github.com/NvChad/NvChad /root/.config/nvim --depth 1" 1>/dev/null
}

if [ $OS = '"Arch"' ]
then
	echo $PASSWORD | sudo -S bash -c "$(declare -f arch); arch $USER"

	echo 'y' | sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" 1>/dev/null
	sh -c "git clone --quiet https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" 1>/dev/null
	echo "[!] Remember to log out and login again"
	

	sh -c "git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1" 1>/dev/null

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

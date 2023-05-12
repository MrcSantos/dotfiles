#!/bin/bash
set -eu

NON_SUDO_USER=$USER
OS=$(( lsb_release -ds || cat /etc/*release || uname -om ) 2>/dev/null | head -n1)
read -p "[.] Enter the sudo password: " -s PASSWORD
echo ""



solus() {
	echo ""
	echo "[-] Updating system... (It may take a long time)"
	eopkg upgrade -y &>/dev/null
	
	echo "[-] Installing basic tools... (It may take a long time)"
	eopkg install -c system.devel -y &>/dev/null
	eopkg install neofetch git git-flow tmux vim cargo -y &>/dev/null
	
	echo "[-] Installing NerdFonts..."
	sh -c "git clone --quiet https://github.com/ryanoasis/nerd-fonts /opt/nerd-fonts" &>/dev/null
	chmod a+x /opt/nerd-fonts/install.sh
	/opt/nerd-fonts/install.sh -q -S hasklig

	echo "[-] Installing ZShell..."
	eopkg install zsh -y &>/dev/null
	chsh -s $(which zsh) $1 &>/dev/null
	chsh -s $(which zsh) &>/dev/null
	
	echo "[-] Installing nnn with nerd fonts..."
	sh -c "git clone https://github.com/jarun/nnn.git /opt/nnn --quiet" &>/dev/null
	cd /opt/nnn
	make O_NERD=1 &>/dev/null
	cp /opt/nnn/nnn /bin/

	echo "[-] Installing nvim..."
	eopkg install neovim -y &>/dev/null
	cargo install -q ripgrep &>/dev/null
	sh -c "git clone --quiet https://github.com/NvChad/NvChad /root/.config/nvim --depth 1" &>/dev/null
}

if [ "$OS" = '"Solus"' ]
then
	echo $PASSWORD | sudo -S bash -c "$(declare -f solus); solus $USER"
	sh -c "git clone --quiet https://github.com/NvChad/NvChad ~/.config/nvim --depth 1" &>/dev/null
	echo 'y' | sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" &>/dev/null
	sh -c "git clone --quiet https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" &>/dev/null
	
	echo ""
	echo "[!] Remember these things:"
	echo "    - Logout and login again"
	echo "    - ZSH will be the default shell only for root and this user"
	echo ""

	read  -n 1 -p "[.] Press Enter to continue..."

	clear
	neofetch
fi

arch() {
	echo ""
	echo "[-] Updating system..."
	pacman-key --refresh-keys
	pacman -Sy archlinux-keyring --noconfirm && pacman -Syyu --noconfirm &>/dev/null
	
	echo "[-] Installing basic tools..."
	pacman -S --noconfirm wget unzip neofetch git tmux vim cargo &>/dev/null

	echo "[-] Installing nnn..."
	pacman -S --noconfirm nnn &>/dev/null

	echo "[-] Installing ZShell..."
	pacman -S --noconfirm zsh &>/dev/null
	chsh -s $(which zsh) $1 &>/dev/null
	chsh -s $(which zsh) &>/dev/null

	echo "[-] Installing NerdFonts..."
	wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/Hasklig.zip -O /tmp/nerd_fonts.zip &>/dev/null
	mkdir -p /home/$1/.local/share/fonts
	mkdir -p /root/.local/share/fonts
	mkdir -p /root/.config/nvim
	unzip /tmp/nerd_fonts.zip -d /home/$1/.local/share/fonts &>/dev/null
	unzip /tmp/nerd_fonts.zip -d /root/.local/share/fonts &>/dev/null
	chown -R $1 /home/$1/.local/share/fonts

	echo "[-] Installing nvim..."
	pacman -S --noconfirm neovim &>/dev/null
	cargo install ripgrep &>/dev/null
	sh -c "git clone https://github.com/NvChad/NvChad /root/.config/nvim --depth 1" &>/dev/null
}

if [ "$OS" = 'NAME="Arch Linux"' ]
then
	echo $PASSWORD | sudo -S bash -c "$(declare -f arch); arch $USER"

	echo 'y' | sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" &>/dev/null
	sh -c "git clone --quiet https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" &>/dev/null
	echo "[!] Remember to log out and login again"
	

	sh -c "git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1" &>/dev/null

	read  -n 1 -p "[.] Press Enter to continue..."

	clear
	neofetch
fi

if [ "$OS" = '"Void Linux"' ]
then
	echo "[!] Vecchio ma fatti una vita..."
	echo ""
	echo "[-] Updating system..."
	xbps-install -Su
	
	echo "[-] Installing basic tools..."
	xbps-install git neofetch wget gcc tmux vim cargo unzip

	echo "[-] Installing nnn..."
	xbps-install nnn

	echo "[-] Installing ZShell..."
	xbps-install zsh
	chsh -s $(which zsh)
	echo 'y' | sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
	sh -c "git clone --quiet https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
	echo "[!] Remember to log out and login again"

	echo "[-] Installing NerdFonts..."
	wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/Hasklig.zip -O /tmp/nerd_fonts.zip
	mkdir -p /root/.local/share/fonts
	mkdir -p /root/.config/nvim
	unzip /tmp/nerd_fonts.zip -d /root/.local/share/fonts

	echo "[-] Installing nvim..."
	xbps-install neovim
	cargo install ripgrep
	sh -c "git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1"
	
	read -n 1 -p "[.] Press Enter to continue..."

	clear

	neofetch
fi

kali() {
	echo ""
	echo "[-] Updating system..."
	apt update &>/dev/null
	apt upgrade -y &>/dev/null
	apt dist-upgrade -y &>/dev/null
	
	echo "[-] Installing basic tools..."
	apt install wget unzip neofetch git tmux vim cargo &>/dev/null

	echo "[-] Installing nnn..."
	apt install nnn &>/dev/null

	echo "[-] Installing ZShell..."
	apt install zsh &>/dev/null
	chsh -s $(which zsh) $1 &>/dev/null
	chsh -s $(which zsh) &>/dev/null

	echo "[-] Installing NerdFonts..."
	wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/Hasklig.zip -O /tmp/nerd_fonts.zip &>/dev/null
	mkdir -p /home/$1/.local/share/fonts
	mkdir -p /root/.local/share/fonts
	mkdir -p /root/.config/nvim
	unzip /tmp/nerd_fonts.zip -d /home/$1/.local/share/fonts &>/dev/null
	unzip /tmp/nerd_fonts.zip -d /root/.local/share/fonts &>/dev/null
	chown -R $1 /home/$1/.local/share/fonts

	echo "[-] Installing nvim..."
	apt install neovim &>/dev/null
	cargo install ripgrep &>/dev/null
	sh -c "git clone https://github.com/NvChad/NvChad /root/.config/nvim --depth 1" &>/dev/null
}

if [ "$OS" = 'PRETTY_NAME="Kali GNU/Linux Rolling"' ]
then
	echo $PASSWORD | sudo -S bash -c "$(declare -f kali); kali $USER"

	echo 'y' | sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" &>/dev/null
	sh -c "git clone --quiet https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" &>/dev/null
	echo "[!] Remember to log out and login again"
	

	sh -c "git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1" &>/dev/null

	read  -n 1 -p "[.] Press Enter to continue..."

	clear
	neofetch
fi

#!/bin/bash

# Super user check
if [[ $EUID -ne 0 ]]; then
    echo "[!] Sorry, this script must be run as root, aborting..."
    exit 1
fi

# Get OS
OS=$(( lsb_release -ds || cat /etc/*release || uname -om ) 2>/dev/null | head -n1)

# Get non-root users
USER_LIST=$(awk -F: '$3 >= 1000 && $7 != "/sbin/nologin" {print $1}' /etc/passwd)

# Other global variables declarations
UPGRADE_COMMAND=""
INSTALL_COMMAND=""
SYSTEM_DIR=""
WORKSTATION_TYPE=""

sinstall() {
# s(ilent)install
# This function silently installs a package from global variables
# Usage: install <packages> <optional flags>
    return "$INSTALL_COMMAND $2 $1 &>/dev/null"
}

is_os_known() {    
# The funtion assigns the global variables based on the detected OS.
# Returns the exit code number in order to use the funtion in a if statement.

    case $OS in
        *Solus*)
            OS="Solus OS"
            UPGRADE_COMMAND=""
            INSTALL_COMMAND="eopkg install -y"
            SYSTEM_DIR="/usr/bin"
            WORKSTATION_TYPE="Desktop"
        ;;
    
        *Kali*)
            OS="Kali Linux"
            UPGRADE_COMMAND="apt update && apt upgrade -y && apt dist-upgrade &>/dev/null"
            INSTALL_COMMAND="apt install -y"
            SYSTEM_DIR="/usr/local/bin"
            WORKSTATION_TYPE="Hacking"
        ;;
    
        *Ubuntu*)
            OS="Ubuntu"
            UPGRADE_COMMAND="apt update && apt upgrade -y && apt dist-upgrade &>/dev/null"
            INSTALL_COMMAND="apt install -y"
            SYSTEM_DIR="/usr/local/bin"
            WORKSTATION_TYPE="Desktop"
        ;;
    
        *Arch*)
            OS="Arch Linux"
            UPGRADE_COMMAND="pacman -Syu --noconfirm &>/dev/null"
            INSTALL_COMMAND="pacman -Syu --needed --noconfirm"
            SYSTEM_DIR="/usr/local/bin"
            WORKSTATION_TYPE="Desktop"
        ;;
    
        *Void*)
            OS="Void Linux"
            UPGRADE_COMMAND=""
            INSTALL_COMMAND="xbps-install"
            SYSTEM_DIR="/usr/local/bin"
            WORKSTATION_TYPE="Server"
        ;;
    
        *)
            echo
            echo "[!] Unknown OS, i detected $OS"

            # Return false (1 in bash, like exit codes)
            return 1
        ;;
    esac

    # Return true (0 in bash, like exit codes)
    return 0
}

# GUARD CLAUSE: If I don't recognize or know the OS i must exit
if ! is_os_known ; then exit 1

#--------------------------------------------------------------------------------------------------#

clear
echo
echo "██╗    ██╗ ███████╗ ██╗       ██████╗  ██████╗  ███╗   ███╗ ███████╗    ███████╗ ██╗ ██████╗ "
echo "██║    ██║ ██╔════╝ ██║      ██╔════╝ ██╔═══██╗ ████╗ ████║ ██╔════╝    ██╔════╝ ██║ ██╔══██╗"
echo "██║ █╗ ██║ █████╗   ██║      ██║      ██║   ██║ ██╔████╔██║ █████╗      ███████╗ ██║ ██████╔╝"
echo "██║███╗██║ ██╔══╝   ██║      ██║      ██║   ██║ ██║╚██╔╝██║ ██╔══╝      ╚════██║ ██║ ██╔══██╗"
echo "╚███╔███╔╝ ███████╗ ███████╗ ╚██████╗ ╚██████╔╝ ██║ ╚═╝ ██║ ███████╗    ███████║ ██║ ██║  ██║"
echo " ╚══╝╚══╝  ╚══════╝ ╚══════╝  ╚═════╝  ╚═════╝  ╚═╝     ╚═╝ ╚══════╝    ╚══════╝ ╚═╝ ╚═╝  ╚═╝"
echo
echo "Powered by: $OS"
echo
echo
echo

#--------------------------------------------------------------------------------------------------#

# Asks the user to update the system
read -n 1 -p "[?] Do you want to update the system? [y/N]" choice
case $choice in
    y|Y)
        echo "[.] Upgrading system... (This can take a while)"
        "$UPGRADE_COMMAND"
    ;;

echo "[.] Installing basic tools... (This can take a while)"

case $OS in
    Solus OS)
        sinstall "system.devel" "-c"
        sinstall "git git-flow tmux vim cargo"
    ;;

    Kali Linux|Ubuntu)
        sinstall "wget unzip git tmux vim cargo"
    ;;

    Arch Linux)
        sinstall "wget unzip git tmux vim cargo"
    ;;

    Void Linux)
        sinstall "git wget gcc tmux vim cargo unzip"
    ;;
esac

######################################################### FUNCTIONS

install_nerdFonts() {
    echo "[.] Installing Nerd Fonts..."

    mkdir -p /usr/share/fonts &>/dev/null
    mkdir -p /opt/nf &>/dev/null
    cd /opt/nf &>/dev/null
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip &>/dev/null
    unzip /opt/nf/JetBrainsMono.zip -d /usr/share/fonts &>/dev/null
    rm -rf /opt/nf &>/dev/null
    fc-cache -f -v &>/dev/null
    cd &>/dev/null
}

install_nnn() {
    echo "[!] Installing nnn..."

    cd /opt/ &>/dev/null
    git clone https://github.com/jarun/nnn.git &>/dev/null
    cd nnn &>/dev/null
    make O_NERD=1 &>/dev/null
    mv nnn $SYSTEM_DIR &>/dev/null
    chmod a+x $SYSTEM_DIR/nnn &>/dev/null
    rm -rf /opt/nnn &>/dev/null
    cd &>/dev/null
}

install_zsh() {
    echo "[!] Installing Zsh and all plugins for all users..."

    $INSTALL_COMMAND zsh &>/dev/null

    zsh_path=$(command -v zsh)

    set_zsh_with_plugins_for_user() {
        local username=$1

        chsh -s "$zsh_path" "$username" &>/dev/null

        [ "$username" = "root" ] && user_folder="/root" || user_folder="/home/$username"

        echo 'y' | su - $username -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" &>/dev/null
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $user_folder/.oh-my-zsh/custom/themes/powerlevel10k &>/dev/null
        git clone https://github.com/zsh-users/zsh-autosuggestions.git $user_folder/.oh-my-zsh/custom/plugins/zsh-autosuggestions &>/dev/null
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $user_folder/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting &>/dev/null

        sed -i 's/ZSH_THEME="[^"]*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' $user_folder/.zshrc &>/dev/null
        sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' $user_folder/.zshrc &>/dev/null
        echo "EDITOR=nvim" >> .zshrc
        echo 'alias v="nvim"' >> .zshrc
    }

    set_zsh_with_plugins_for_user "root"
    for user in $USER_LIST; do
        set_zsh_with_plugins_for_user "$user"
    done
}

install_nvchad() {
    echo "[!] Installing Nvim with NVChad..."
    # NVChad
    $INSTALL_COMMAND ripgrep neovim &>/dev/null

    install_nvchad_for_user() {
        local username=$1

        [ "$username" = "root" ] && user_folder="/root" || user_folder="/home/$username"

        su - $username -c "git clone https://github.com/NvChad/NvChad $user_folder/.config/nvim --depth 1" &>/dev/null
    }

    install_nvchad_for_user "root"
    for user in $USER_LIST; do
        install_nvchad_for_user "$user"
    done
}

install_ohmytmux() {
    echo "[!] Installing OhMyTmux..."

    git clone https://github.com/gpakosz/.tmux.git "/opt/.tmux" &>/dev/null

    install_ohmytmux_for_user() {
        local username=$1

        [ "$username" = "root" ] && user_folder="/root" || user_folder="/home/$username"

        echo 'TERM="xterm-256color"' >> $user_folder/.bashrc
        echo 'TERM="xterm-256color"' >> $user_folder/.zshrc

        mkdir -p $user_folder/.config/tmux

        ln -s /opt/.tmux/.tmux.conf $user_folder/.config/tmux/tmux.conf
        cp /opt/.tmux/.tmux.conf.local $user_folder/.config/tmux/tmux.conf.local
    }

    install_ohmytmux_for_user "root"
    for user in $USER_LIST; do
        install_ohmytmux_for_user "$user"
    done
}

#create_aliases() {
#    # TODO
#    echo alias ssh="ssh -t -- /bin/sh -c 'tmux has-session && exec tmux attach || exec tmux' >> .zshrc
#}


######################################## END OF FUNCTIONS

echo
echo "██╗    ██╗███████╗██╗      ██████╗ ██████╗ ███╗   ███╗███████╗    ███████╗██╗██████╗ "
echo "██║    ██║██╔════╝██║     ██╔════╝██╔═══██╗████╗ ████║██╔════╝    ██╔════╝██║██╔══██╗"
echo "██║ █╗ ██║█████╗  ██║     ██║     ██║   ██║██╔████╔██║█████╗      ███████╗██║██████╔╝"
echo "██║███╗██║██╔══╝  ██║     ██║     ██║   ██║██║╚██╔╝██║██╔══╝      ╚════██║██║██╔══██╗"
echo "╚███╔███╔╝███████╗███████╗╚██████╗╚██████╔╝██║ ╚═╝ ██║███████╗    ███████║██║██║  ██║"
echo " ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝    ╚══════╝╚═╝╚═╝  ╚═╝"
echo
echo Powered by: $OS
echo

PS3='> '
WORKSTATION_TYPES=("Programming" "Desktop" "Hacking")
USER_LIST=$(awk -F: '$3 >= 1000 && $7 != "/sbin/nologin" {print $1}' /etc/passwd)

echo "[?] Choose the workstation type:"
echo "0) Exit"

select option in "${WORKSTATION_TYPES[@]}"; do
    if [ "$REPLY" = "0" ]; then
        echo "[!] Terminating program..."
        exit 0
    fi

    echo
    echo "[!] Setting up for $option..."
    echo

    case $option in
        "Programming")
            install_nerdFonts
            install_nnn
            install_zsh
            install_nvchad
            install_ohmytmux
            #create_aliases
            break
        ;;

        "Desktop")
            install_nerdFonts
            install_nnn
            install_zsh
            install_nvchad
            install_ohmytmux
            #create_aliases
            break
        ;;

        "Hacking")
            install_nerdFonts
            install_nnn
            install_zsh
            install_nvchad
            install_ohmytmux
            #create_aliases
            break
        ;;

        *)
            echo "Invalid option $REPLY"
        ;;
    esac
done

clear
neofetch

echo
echo "[!] Remember:"
echo " -  Reboot the host"
echo " -  Change console font to JetBrains'"
echo " -  Change wallpaper"
echo " -  Change keybindings to open the terminal"
echo

    1  yay
    2  git
    3  pacman -Syu
    4  sudo pacman -Syu
    5  pacman -Syu git
    6  sudo pacman -Syu git
    7  git clone https://aur.archliux.org/librewolf-bin.git /opt/librewolf
    8  sudo su
    9  cd /opt/librewolf/
   10  makepkg -si
   11  sudo su
   12  makepkg -si
   13  sudo su
   14  cd ../yay
   15  makepkg -si
   16  yay
   17  yay -S librewolf-bin
   18  mkdir -p ~/.config/alacritty/
   19  curl -sS https://starship.rs/install.sh | sh
   20  curl -sS https://starship.rs/install.sh | sh
   21  pacman -Syu zsh
   22  sudo pacman -Syu zsh
   23  zsh
   24  alacritty migrate
   25  fc-list | grep "JetBrainsMono"
   26  echo "Nerd Font Symbols:     "
   27  vim ~/.config/starship.toml
   28  eval "$(starship init zsh)"  # Use `zsh` or your preferred shell
   29  eval "$(starship init zsh)"
   30  eval "$(starship init bash)"  # Use `zsh` or your preferred shell
   31  vim ~/.config/starship.toml
   32  sudo su
   33  makepkg -si
   34  cd /opt/yay
   35  makepkg -si
   36  history
[mrcsantos@arianna ~]$ sudo su
[sudo] password for mrcsantos:
[root@arianna mrcsantos]# history
    1  git clone https://aur.archliux.org/librewolf-bin.git /opt/librewolf
    2  git clone https://aur.archlinux.org/librewolf-bin.git /opt/librewolf
    3  cd $_
    4  ls
    5  makepkg -si
    6  chown mrcsantos /opt/librewolf/
    7  pacman -Syu base-devel
    8  git clone https://aur.archlinux.org/yay-bin.git /opt/yay
    9  chown mrcsantos /opt/yay
   10  mkdir -p ~/.config/alacritty/
   11  vim ~/.config/alacritty/alacritty.yml
   12  killall alacritty
   13  alacritty &
   14  alacritty migrate
   15  cat .bash_history
   16  cd
   17  history
   18  makepkg -si --noconfirm
   19  history

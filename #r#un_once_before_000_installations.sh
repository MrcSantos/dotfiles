#!/bin/bash

# Super user check
if [[ $EUID -ne 0 ]]; then
    echo "[!] Sorry, this script must be run as root, aborting..."
    exit 1
fi

#--------------------------------------------------------------------------------# USERS GLOBAL

# Populate the array from the command output
readarray -t temp_user_list < <(awk -F: '$3 >= 1000 && $7 != "/sbin/nologin" {print $1}' /etc/passwd)

# Create a new array without the item "nobody"
USER_LIST=()
for item in "${temp_user_list[@]}"; do
    if [[ "$item" != "nobody" ]]; then
        USER_LIST+=("$item")
    fi
done

#--------------------------------------------------------------------------------# OTHER GLOBALS

# Get OS
. /etc/os-release
OS=$ID
IS_WSL=$(uname -r | grep -qi WSL2)
IS_WSL_TEXT=""

if [[ $IS_WSL == 0 ]]; then
    IS_WSL_TEXT=" (WSL version)"
fi

# Other global variables declarations
UPGRADE_COMMAND=""
INSTALL_COMMAND_PREFIX=""
SYSTEM_DIR=""
WORKSTATION_TYPE=""

#--------------------------------------------------------------------------------# OS MANIPULATION

sinstall() {
# s(ilent)install
# This function silently installs a package from global variables
# Usage: install <packages> <optional flags>
    eval "$INSTALL_COMMAND_PREFIX $2 $1"
}

is_os_known() {
# The funtion assigns the global variables based on the detected OS.
# Returns the exit code number in order to use the funtion in a if statement.

    case $OS in
        *[sS]olus*)
            OS="Solus OS"
            UPGRADE_COMMAND=""
            INSTALL_COMMAND_PREFIX="eopkg install -y"
            SYSTEM_DIR="/usr/bin"
            WORKSTATION_TYPE="desktop"
        ;;

        *[kK]ali*)
            OS="Kali Linux"
            UPGRADE_COMMAND="apt update && apt upgrade -y && apt dist-upgrade"
            INSTALL_COMMAND_PREFIX="apt install -y"
            SYSTEM_DIR="/usr/local/bin"
            WORKSTATION_TYPE="hacking workstation"
        ;;

        *[uU]buntu*)
            OS="Ubuntu"
            UPGRADE_COMMAND="apt update && apt upgrade -y && apt dist-upgrade"
            INSTALL_COMMAND_PREFIX="apt install -y"
            SYSTEM_DIR="/usr/local/bin"
            WORKSTATION_TYPE="desktop"
        ;;
        
        *[dD]ebian*)
            OS="Debian"
            UPGRADE_COMMAND="apt update && apt upgrade -y && apt dist-upgrade"
            INSTALL_COMMAND_PREFIX="apt install -y"
            SYSTEM_DIR="/usr/local/bin"
            WORKSTATION_TYPE="desktop"
        ;;

        *[aA]rch*)
            OS="Arch Linux"
            UPGRADE_COMMAND="pacman -Syu --noconfirm"
            INSTALL_COMMAND_PREFIX="pacman -S --needed --noconfirm"
            SYSTEM_DIR="/usr/local/bin"
            WORKSTATION_TYPE="desktop"
        ;;

        *[vV]oid*)
            OS="Void Linux"
            UPGRADE_COMMAND=""
            INSTALL_COMMAND_PREFIX="xbps-install"
            SYSTEM_DIR="/usr/local/bin"
            WORKSTATION_TYPE="server"
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
if ! is_os_known ; then exit 1; fi

#--------------------------------------------------------------------------------------------------# BANNER

read -n 1 -s -r -p "[?] The installer is ready, press any key to continue"

clear
echo -e "\033[1;31m"
echo "               ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo "               ⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo "               ⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⣿⣧⣶⣶⣶⣦⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo "               ⠀⠀⠀⠀⠀⠀⣠⣾⢿⣿⣿⣿⣏⠉⠉⠛⠛⠿⣷⣕⠀⠀⠀⠀⠀⠀⢀⡀"
echo "               ⠀⠀⠀⠀⣠⣾⢝⠄⢀⣿⡿⠻⣿⣄⠀⠀⠀⠀⠈⢿⣧⡀⣀⣤⡾⠀⠀ "
echo "               ⠀⠀⠀⢰⣿⡡⠁⠀⠀⣿⡇⠀⠸⣿⣾⡆⠀⠀⣀⣤⣿⣿⠋⠁⠀⠀⠀⠀"
echo "               ⠀⠀⢀⣷⣿⠃⠀⠀⢸⣿⡇⠀⠀⠹⣿⣷⣴⡾⠟⠉⠸⣿⡇⠀⠀⠀⠀⠀"
echo "               ⠀⠀⢸⣿⠗⡀⠀⠀⢸⣿⠃⣠⣶⣿⠿⢿⣿⡀⠀⠀⢀⣿⡇⠀⠀⠀⠀⠀"
echo "               ⠀⠀⠘⡿⡄⣇⠀⣀⣾⣿⡿⠟⠋⠁⠀⠈⢻⣷⣆⡄⢸⣿⡇⠀⠀⠀⠀⠀"
echo "               ⠀⠀⠀⢻⣷⣿⣿⠿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠻⣿⣷⣿⡟⠀⠀⠀⠀⠀⠀"
echo "               ⢀⣰⣾⣿⠿⣿⣿⣾⣿⠇⠀⠀⠀⠀⠀⠀⠀⢀⣼⣿⣿⣅⠀⠀⠀⠀⠀⠀"
echo "               ⠀⠰⠊⠁⠀⠙⠪⣿⣿⣶⣤⣄⣀⣀⣀⣤⣶⣿⠟⠋⠙⢿⣷⡄⠀⠀⠀⠀"
echo "               ⠀⠀⠀⠀⠀⠀⢀⣿⡟⠺⠭⠭⠿⠿⠿⠟⠋⠁⠀⠀⠀⠀⠙⠏⣦⠀⠀⠀"
echo "               ⠀⠀⠀⠀⠀⠀⢸⡟⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo "               ⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo -e "\033[0m"
echo "                ██████╗   ██████╗   ██████╗  ██████╗                   "
echo "               ██╔════╝  ██╔═══██╗ ██╔═══██╗ ██╔══██╗                  "
echo "               ██║  ███╗ ██║   ██║ ██║   ██║ ██║  ██║                  "
echo "               ██║   ██║ ██║   ██║ ██║   ██║ ██║  ██║                  "
echo "               ╚██████╔╝ ╚██████╔╝ ╚██████╔╝ ██████╔╝                  "
echo "                ╚═════╝   ╚═════╝   ╚═════╝  ╚═════╝                   "
echo
echo "   ███╗   ███╗  ██████╗  ██████╗  ███╗   ██╗ ██╗ ███╗   ██╗  ██████╗   "
echo "   ████╗ ████║ ██╔═══██╗ ██╔══██╗ ████╗  ██║ ██║ ████╗  ██║ ██╔════╝   "
echo "   ██╔████╔██║ ██║   ██║ ██████╔╝ ██╔██╗ ██║ ██║ ██╔██╗ ██║ ██║  ███╗  "
echo "   ██║╚██╔╝██║ ██║   ██║ ██╔══██╗ ██║╚██╗██║ ██║ ██║╚██╗██║ ██║   ██║  "
echo "   ██║ ╚═╝ ██║ ╚██████╔╝ ██║  ██║ ██║ ╚████║ ██║ ██║ ╚████║ ╚██████╔╝  "
echo "   ╚═╝     ╚═╝  ╚═════╝  ╚═╝  ╚═╝ ╚═╝  ╚═══╝ ╚═╝ ╚═╝  ╚═══╝  ╚═════╝   "
echo
echo "                         ███████╗ ██╗ ██████╗                          "
echo "                         ██╔════╝ ██║ ██╔══██╗                         "
echo "                         ███████╗ ██║ ██████╔╝                         "
echo "                         ╚════██║ ██║ ██╔══██╗                         "
echo "                         ███████║ ██║ ██║  ██║                         "
echo "                         ╚══════╝ ╚═╝ ╚═╝  ╚═╝                         "
echo
echo "Automated anarchy"
echo "Powered by: $OS$IS_WSL_TEXT"
echo

#--------------------------------------------------------------------------------------------------# INIT OF OS TOOLS

# Asks the user to update the system
read -n 1 -p "[?] Do you want to update the system? [y/N] " choice
echo
case $choice in
    y|Y)
        echo "[.] Upgrading system... (This can take a while)"
        eval "$UPGRADE_COMMAND"
    ;;
esac

echo "[.] Installing basic tools... (This can take a while)"

case $OS in
    "Solus OS")
        sinstall "system.devel" "-c"
        sinstall "git git-flow tmux vim cargo"
    ;;

    "Kali Linux" | Debian | Ubuntu)
        sinstall "build-essential pkg-config libncursesw5-dev libreadline-dev curl wget unzip git git-flow tmux vim cargo"
    ;;

    "Arch Linux")
        sinstall "wget unzip git tmux vim rust nodejs npm flatpak"

        # Install AUR helper PARU
        echo "[.] Installing PARU and Librewolf... (This can take a while)"
        git clone https://aur.archlinux.org/paru.git /opt/paru
        cd /opt/paru

        install_paru_for_user() {
            local username=$1

            chown $username /opt/paru

            # Install PARU and librewolf as browser (Only for arch because I love it, ok?)
            su - $username -c "cd /opt/paru && makepkg -si"
        }

        # Not available for root user
        for user in $USER_LIST; do
            install_paru_for_user "$user"
        done
    ;;

    "Void Linux")
        sinstall "git wget gcc tmux vim cargo unzip"
    ;;
esac

#--------------------------------------------------------------------------------------------------# FUNCTIONS

install_nerdFonts() {
    echo "[.] Installing Nerd Fonts..."

    mkdir -p /usr/share/fonts
    mkdir -p /opt/nf
    cd /opt/nf
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
    unzip /opt/nf/JetBrainsMono.zip -d /usr/share/fonts
    rm -rf /opt/nf
    fc-cache -f -v
    cd
}

install_nnn() {
    echo "[.] Installing nnn..."

    cd /opt/
    git clone https://github.com/jarun/nnn.git
    cd nnn
    make O_NERD=1
    mv nnn $SYSTEM_DIR
    chmod a+x $SYSTEM_DIR/nnn
    rm -rf /opt/nnn
    cd
}

install_zsh() {
    echo "[.] Installing Zsh and all plugins for all users..."

    sinstall zsh

    zsh_path=$(command -v zsh)

    set_zsh_with_plugins_for_user() {
        local username=$1

        chsh -s "$zsh_path" "$username"

        [ "$username" = "root" ] && user_folder="/root" || user_folder="/home/$username"

        echo 'y' | su - $username -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $user_folder/.oh-my-zsh/custom/themes/powerlevel10k
        git clone https://github.com/zsh-users/zsh-autosuggestions.git $user_folder/.oh-my-zsh/custom/plugins/zsh-autosuggestions
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $user_folder/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

        sed -i 's/ZSH_THEME="[^"]*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' $user_folder/.zshrc
        sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' $user_folder/.zshrc
        echo "EDITOR=nvim" >> $user_folder/.zshrc
        echo 'alias v="nvim"' >> $user_folder/.zshrc
    }

    set_zsh_with_plugins_for_user "root"
    for user in $USER_LIST; do
        set_zsh_with_plugins_for_user "$user"
    done
}

install_nvchad() {
    echo "[.] Installing Nvim with NVChad..."

    sinstall "ripgrep"
    
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    rm -rf /opt/nvim-linux-x86_64
    tar -C /opt -xzf nvim-linux-x86_64.tar.gz

    install_nvchad_for_user() {
        local username=$1

        [ "$username" = "root" ] && user_folder="/root" || user_folder="/home/$username"

        su - $username -c "git clone https://github.com/NvChad/starter $user_folder/.config/nvim --depth 1"
        echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> $user_folder/.zshrc
    }

    install_nvchad_for_user "root"
    for user in $USER_LIST; do
        install_nvchad_for_user "$user"
    done
}

install_ohmytmux() {
    echo "[.] Installing OhMyTmux..."

    git clone https://github.com/gpakosz/.tmux.git "/opt/.tmux"

    install_ohmytmux_for_user() {
        local username=$1

        # If user is root then the user folder is /root, else the user folder is his home
        [ "$username" = "root" ] && user_folder="/root" || user_folder="/home/$username"

        echo 'TERM="xterm-256color"' >> $user_folder/.zshrc

        mkdir -p $user_folder/.config/tmux

        ln -s /opt/.tmux/.tmux.conf $user_folder/.config/tmux/tmux.conf
        cp /opt/.tmux/.tmux.conf.local $user_folder/.config/tmux/tmux.conf.local
    }

    install_ohmytmux_for_user "root"
    for user in $USER_LIST; do
        install_ohmytmux_for_user "$user"
        chown -R "$user":"$user" "/home/$user/.config"
    done
}

install_kitty() {
    echo "[.] Installing Kitty terminal..."
    sinstall "kitty"
    
    install_kitty_for_user() {
        local username=$1

        # If user is root then the user folder is /root, else the user folder is his home
        [ "$username" = "root" ] && user_folder="/root" || user_folder="/home/$username"

        echo 'alias icat="kitten icat"' >> $user_folder/.zshrc
    }

    install_kitty_for_user "root"
    for user in $USER_LIST; do
        install_ohmytmux_for_user "$user"
        chown -R "$user":"$user" "/home/$user/.config"
    done
}

install_lsd () {
    sinstall "lsd"
}

setup_permissions() {
    for user in $USER_LIST; do
        chown -R "$user":"$user" "/home/$user/"
    done
}

#--------------------------------------------------------------------------------------------------# END OF FUNCTIONS

case $WORKSTATION_TYPE in
    "programming")
        install_nerdFonts
        install_nnn
        install_zsh
        install_nvchad
        install_ohmytmux
        install_kitty
        install_lsd
    ;;

    "desktop")
        install_nerdFonts
        install_nnn
        install_zsh
        install_nvchad
        install_ohmytmux
        install_kitty
        install_lsd
    ;;

    "server")
        install_nerdFonts
        install_nnn
        install_zsh
        install_nvchad
        install_ohmytmux
        install_kitty
        install_lsd
    ;;

    "hacking")
        install_nerdFonts
        install_nnn
        install_zsh
        install_nvchad
        install_ohmytmux
        install_kitty
        install_lsd
    ;;
esac

setup_permissions

echo
echo "[.] Installation complete!"
echo
read -n 1 -s -r -p "[?] Press any key to continue..."

#--------------------------------------------------------------------------------------------------# LAST STEPS

clear
echo
echo "[.] Remember:"
echo " -  You MUST reboot the host if you want to see the changes"
echo " -  Change console font to JetBrains MONO if not using Alacritty"
echo " -  Personalize you distro with themes and wallpaper"
echo " -  Change keybindings to open the right terminal"
echo " -  Execute :MasonInstallAll in neovim after lazy installs all plugins"
echo " -  Use the command 'paru -Syu librewolf-bin' to install librewolf browser on users of choice"
echo " -  Always love yourself and others"
echo

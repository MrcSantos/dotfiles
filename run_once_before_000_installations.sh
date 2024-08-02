#!/bin/bash

# Super user check
if [[ $EUID -ne 0 ]]; then
    echo "[!] Sorry, this script must be run as root, aborting..."
    exit 1
fi

# Get OS
. /etc/os-release
OS=$ID

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
        *[sS]olus*)
            OS="Solus OS"
            UPGRADE_COMMAND=""
            INSTALL_COMMAND="eopkg install -y"
            SYSTEM_DIR="/usr/bin"
            WORKSTATION_TYPE="desktop"
        ;;

        *[kK]ali*)
            OS="Kali Linux"
            UPGRADE_COMMAND="apt update && apt upgrade -y && apt dist-upgrade &>/dev/null"
            INSTALL_COMMAND="apt install -y"
            SYSTEM_DIR="/usr/local/bin"
            WORKSTATION_TYPE="hacking workstation"
        ;;

        *[uU]buntu*)
            OS="Ubuntu"
            UPGRADE_COMMAND="apt update && apt upgrade -y && apt dist-upgrade &>/dev/null"
            INSTALL_COMMAND="apt install -y"
            SYSTEM_DIR="/usr/local/bin"
            WORKSTATION_TYPE="desktop"
        ;;

        *[aA]rch*)
            OS="Arch Linux"
            UPGRADE_COMMAND="pacman -Syu &>/dev/null"
            INSTALL_COMMAND="pacman -S --needed --noconfirm"
            SYSTEM_DIR="/usr/local/bin"
            WORKSTATION_TYPE="desktop"
        ;;

        *[vV]oid*)
            OS="Void Linux"
            UPGRADE_COMMAND=""
            INSTALL_COMMAND="xbps-install"
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
esac

echo "[.] Installing basic tools... (This can take a while)"

case $OS in
    "Solus OS")
        sinstall "system.devel" "-c"
        sinstall "git git-flow tmux vim cargo screenfetch"
    ;;

    "Kali Linux" | Ubuntu)
        sinstall "wget unzip git tmux vim cargo screenfetch"
    ;;

    "Arch Linux")
        sinstall "wget unzip git tmux vim cargo screenfetch"

        # Install AUR helper PARU
        echo "[.] Installing PARU..."
        git clone https://aur.archlinux.org/paru.git /opt/paru &>/dev/null
        cd /opt/paru

        install_pau_for_user() {
            local username=$1

            su - $username -c "makepkg -si && paru -Syu librewolf-bin"
        }

        # Not available for root user
        for user in $USER_LIST; do
            install_pau_for_user "$user"
        done
    ;;

    "Void Linux")
        sinstall "git wget gcc tmux vim cargo unzip screenfetch"
    ;;
esac

echo # Extra spacing

######################################################### FUNCTIONS

install_nerdFonts() {
    echo "[.] Installing Nerd Fonts..."

    mkdir -p /usr/share/fonts
    mkdir -p /opt/nf
    cd /opt/nf
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip &>/dev/null
    unzip /opt/nf/JetBrainsMono.zip -d /usr/share/fonts &>/dev/null
    rm -rf /opt/nf &>/dev/null
    fc-cache -f -v &>/dev/null
    cd
}

install_nnn() {
    echo "[.] Installing nnn..."

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
    echo "[.] Installing Zsh and all plugins for all users..."

    sinstall zsh

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
    echo "[.] Installing Nvim with NVChad..."

    sinstall "ripgrep neovim"

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
    echo "[.] Installing OhMyTmux..."

    git clone https://github.com/gpakosz/.tmux.git "/opt/.tmux" &>/dev/null

    install_ohmytmux_for_user() {
        local username=$1

        # If user is root then the user folder is /root, else the user folder is his home
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

install_alacritty() {
    echo "[.] Installing Alacritty..."

    git clone https://github.com/alacritty/alacritty /opt/alacritty &>/dev/null
    cd /opt/alacritty
    echo "opt-level = 1" >> Cargo.toml
    cargo build --release &>/dev/null

    install_alacritty_for_user() {
        local username=$1

        # If user is root then the user folder is /root, else the user folder is his home
        [ "$username" = "root" ] && user_folder="/root" || user_folder="/home/$username"

        mkdir -p $user_folder/.config/alacritty

            echo '
[font]
normal = { family = "JetBrainsMono Nerd Font", style = "Regular" }
bold = { family = "JetBrainsMono Nerd Font", style = "Bold" }
italic = { family = "JetBrainsMono Nerd Font", style = "Italic" }
bold_italic = { family = "JetBrainsMono Nerd Font", style = "Bold Italic" }
' > $user_folder/.config/alacritty/alacritty.toml
    }

    install_alacritty_for_user "root"
    for user in $USER_LIST; do
        install_alacritty_for_user "$user"
    done
}

#create_aliases() {
#    # TODO
#    echo alias ssh="ssh -t -- /bin/sh -c 'tmux has-session && exec tmux attach || exec tmux' >> .zshrc
#}

######################################## END OF FUNCTIONS

case $WORKSTATION_TYPE in
    "programming")
        install_nerdFonts
        install_nnn
        install_zsh
        install_nvchad
        install_ohmytmux
        install_alacritty
        #create_aliases
    ;;

    "desktop")
        install_nerdFonts
        install_nnn
        install_zsh
        install_nvchad
        install_ohmytmux
        install_alacritty
        #create_aliases
    ;;

    "server")
        install_nerdFonts
        install_nnn
        install_zsh
        install_nvchad
        install_ohmytmux
        install_alacritty
        #create_aliases
    ;;

    "hacking")
        install_nerdFonts
        install_nnn
        install_zsh
        install_nvchad
        install_ohmytmux
        install_alacritty
        #create_aliases
    ;;
esac

echo
echo "[!] Remember:"
echo " -  You must reboot the host if you want to see the changes"
echo " -  Change console font to JetBrains MONO"
echo " -  Personalize you distro with themes and wallpaper"
echo " -  Change keybindings to open the right terminal"
echo

read -n 1 -s -r -p "[?] Press any key to continue"

clear
screenfetch

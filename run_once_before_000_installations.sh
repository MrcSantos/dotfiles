#!/bin/bash

# Controllo lancio con sudo
if [[ $EUID -ne 0 ]]; then
    echo "[!] Sorry, this script must be run as root, aborting..."
    exit 1
fi

# Controllo OS
OS=$(( lsb_release -ds || cat /etc/*release || uname -om ) 2>/dev/null | head -n1)
INSTALL_COMMAND=""
SYSTEM_DIR="/usr/local/bin"

echo
echo "[!] Installing basic tools... (This can take a while)"
echo

case $OS in
    *Solus*)
        INSTALL_COMMAND="eopkg install -y"
        OS="Solus OS"
        SYSTEM_DIR="/usr/bin"

        eopkg install -c system.devel -y &>/dev/null
        eopkg install neofetch git git-flow tmux vim cargo -y &>/dev/null
    ;;

    *Kali*)
        INSTALL_COMMAND="apt install -y"
        OS="Kali Linux"
        apt install -y wget unzip neofetch git tmux vim cargo &>/dev/null
    ;;

    *Ubuntu*)
        INSTALL_COMMAND="apt install -y"
        OS="Ubuntu"
        apt install -y wget unzip neofetch git tmux vim cargo &>/dev/null
    ;;

    *Arch*)
        INSTALL_COMMAND="pacman -S --noconfirm"
        OS="Arch Linux (fatti una vita)"
        pacman -S --noconfirm wget unzip neofetch git tmux vim cargo &>/dev/null
    ;;

    *Void*)
        INSTALL_COMMAND="xbps-install"
        OS="Void Linux (fatti una vita)"
        xbps-install git neofetch wget gcc tmux vim cargo unzip
    ;;

    *)
        echo "Unknown OS: $OS"
        exit 1
    ;;
esac

######################################################### FUNCTIONS

install_nerdFonts() {
    echo "[!] Installing Nerd Fonts..."
    # Nerd Fonts
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
    # nnn
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
    echo "[!] Installing Zsh and all plugins..."
    # Zsh with plugins for all users
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

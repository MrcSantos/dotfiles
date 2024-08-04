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
    eval "$INSTALL_COMMAND_PREFIX $2 $1 &>/dev/null"
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
            UPGRADE_COMMAND="apt update && apt upgrade -y && apt dist-upgrade &>/dev/null"
            INSTALL_COMMAND_PREFIX="apt install -y"
            SYSTEM_DIR="/usr/local/bin"
            WORKSTATION_TYPE="hacking workstation"
        ;;

        *[uU]buntu*)
            OS="Ubuntu"
            UPGRADE_COMMAND="apt update && apt upgrade -y && apt dist-upgrade &>/dev/null"
            INSTALL_COMMAND_PREFIX="apt install -y"
            SYSTEM_DIR="/usr/local/bin"
            WORKSTATION_TYPE="desktop"
        ;;

        *[aA]rch*)
            OS="Arch Linux"
            UPGRADE_COMMAND="pacman -Syu --noconfirm &>/dev/null"
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
echo "Powered by: $OS"
echo
echo
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
        sinstall "git git-flow tmux vim cargo fastfetch"
    ;;

    "Kali Linux" | Ubuntu)
        sinstall "wget unzip git tmux vim cargo fastfetch"
    ;;

    "Arch Linux")
        sinstall "wget unzip git tmux vim cargo nodejs npm fastfetch"

        # Install AUR helper PARU
        echo "[.] Installing PARU and Librewolf... (This can take a while)"
        git clone https://aur.archlinux.org/paru.git /opt/paru &>/dev/null
        cd /opt/paru

        install_paru_for_user() {
            local username=$1

            chown $username /opt/paru

            # Install PARU and librewolf as browser (Only for arch because I love it, ok?)
            su - $username -c "cd /opt/paru && makepkg -si &>/dev/null && paru -Syu librewolf-bin &>/dev/null"
        }

        # Not available for root user
        for user in $USER_LIST; do
            install_paru_for_user "$user"
        done
    ;;

    "Void Linux")
        sinstall "git wget gcc tmux vim cargo unzip fastfetch"
    ;;
esac

#--------------------------------------------------------------------------------------------------# FUNCTIONS

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

        su - $username -c "git clone https://github.com/NvChad/starter $user_folder/.config/nvim --depth 1" &>/dev/null
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
    echo "[.] Installing Alacritty... (This can take a while)"

    git clone https://github.com/alacritty/alacritty /opt/alacritty &>/dev/null
    cd /opt/alacritty
    echo "opt-level = 1" >> Cargo.toml
    cargo build --release --quiet
    cp /opt/alacritty/target/release/alacritty $SYSTEM_DIR/alacritty
    cp /opt/alacritty/extra/logo/compat/alacritty-term+scanlines.png /usr/share/applications/alacritty.png

    echo '
[Desktop Entry]
Type=Application
Name=Alacritty
Comment=A fast, cross-platform, OpenGL terminal emulator
Icon=/usr/share/applications/alacritty.png
Exec=/usr/local/bin/alacritty
Categories=System Tools;
' > /usr/share/applications/alacritty.desktop

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

#--------------------------------------------------------------------------------------------------# END OF FUNCTIONS

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
echo " -  Always love yourself and others"
echo

fastfetch

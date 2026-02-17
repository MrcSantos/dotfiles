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

SCRIPT_PWD="$(pwd)/$(dirname $0)"

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
        *[uU]buntu*)
            OS="Ubuntu"
            UPGRADE_COMMAND="apt update && apt upgrade -y && apt dist-upgrade"
            INSTALL_COMMAND_PREFIX="apt install -y"
            SYSTEM_DIR="/usr/local/bin"
        ;;

        *[dD]ebian*)
            OS="Debian"
            UPGRADE_COMMAND="apt update && apt upgrade -y && apt dist-upgrade"
            INSTALL_COMMAND_PREFIX="apt install -y"
            SYSTEM_DIR="/usr/local/bin"
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
echo "                   ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo "                   ⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo "                   ⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⣿⣧⣶⣶⣶⣦⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo "                   ⠀⠀⠀⠀⠀⠀⣠⣾⢿⣿⣿⣿⣏⠉⠉⠛⠛⠿⣷⣕⠀⠀⠀⠀⠀⠀⢀⡀"
echo "                   ⠀⠀⠀⠀⣠⣾⢝⠄⢀⣿⡿⠻⣿⣄⠀⠀⠀⠀⠈⢿⣧⡀⣀⣤⡾⠀⠀ "
echo "                   ⠀⠀⠀⢰⣿⡡⠁⠀⠀⣿⡇⠀⠸⣿⣾⡆⠀⠀⣀⣤⣿⣿⠋⠁⠀⠀⠀⠀"
echo "                   ⠀⠀⢀⣷⣿⠃⠀⠀⢸⣿⡇⠀⠀⠹⣿⣷⣴⡾⠟⠉⠸⣿⡇⠀⠀⠀⠀⠀"
echo "                   ⠀⠀⢸⣿⠗⡀⠀⠀⢸⣿⠃⣠⣶⣿⠿⢿⣿⡀⠀⠀⢀⣿⡇⠀⠀⠀⠀⠀"
echo "                   ⠀⠀⠘⡿⡄⣇⠀⣀⣾⣿⡿⠟⠋⠁⠀⠈⢻⣷⣆⡄⢸⣿⡇⠀⠀⠀⠀⠀"
echo "                   ⠀⠀⠀⢻⣷⣿⣿⠿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠻⣿⣷⣿⡟⠀⠀⠀⠀⠀⠀"
echo "                   ⢀⣰⣾⣿⠿⣿⣿⣾⣿⠇⠀⠀⠀⠀⠀⠀⠀⢀⣼⣿⣿⣅⠀⠀⠀⠀⠀⠀"
echo "                   ⠀⠰⠊⠁⠀⠙⠪⣿⣿⣶⣤⣄⣀⣀⣀⣤⣶⣿⠟⠋⠙⢿⣷⡄⠀⠀⠀⠀"
echo "                   ⠀⠀⠀⠀⠀⠀⢀⣿⡟⠺⠭⠭⠿⠿⠿⠟⠋⠁⠀⠀⠀⠀⠙⠏⣦⠀⠀⠀"
echo "                  ⠀ ⠀⠀⠀⠀⠀⢸⡟⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo "                  ⠀⠀ ⠀⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
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
    Debian | Ubuntu)
        sinstall "build-essential pkg-config libncursesw5-dev libreadline-dev curl wget unzip git git-flow tmux vim cargo stow"
    ;;
esac

#--------------------------------------------------------------------------------------------------# FUNCTIONS

setup_permissions() {
    for user in $USER_LIST; do
        chown -h -R "$user":"$user" "/home/$user/"
    done
}

copy_dotfiles_folder_to_opt() {
    ORIG_PWD=$(pwd)
    SCRIPT_DIR=$(dirname $0)
    SCRIPT_PWD="$ORIG_PWD/$SCRIPT_DIR"

    cp -R "$SCRIPT_PWD" "/opt/dotfiles"
    chmod -R a+r /opt/dotfiles/
}

deploy_dotfiles_with_stow() {
    local dotfile_name=$1

    deploy_dotfiles_with_stow_for_user() {
        local username=$1
        local dotfile_name=$2

        [ "$username" = "root" ] && user_folder="/root" || user_folder="/home/$username"

        cd /opt/dotfiles/dots
        stow --adopt -t $user_folder $dotfile_name
        setup_permissions
    }

    deploy_dotfiles_with_stow_for_user "root" $dotfile_name
    for user in $USER_LIST; do
        deploy_dotfiles_with_stow_for_user "$user" $dotfile_name
    done
}

git_reset() {
    cd /opt/dotfiles
    git reset .
}

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
    }

    set_zsh_with_plugins_for_user "root"
    for user in $USER_LIST; do
        set_zsh_with_plugins_for_user "$user"
    done

    deploy_dotfiles_with_stow "zsh"
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
    }

    install_nvchad_for_user "root"
    for user in $USER_LIST; do
        install_nvchad_for_user "$user"
    done
}

install_kitty() {
    echo "[.] Installing Kitty terminal..."
    sinstall "kitty"

    deploy_dotfiles_with_stow "kitty"
}

install_lsd () {
    echo "[.] Installing lsd..."
    sinstall "lsd"
}

#--------------------------------------------------------------------------------------------------# END OF FUNCTIONS

copy_dotfiles_folder_to_opt

install_nerdFonts
install_nnn
install_zsh
install_nvchad
install_kitty
install_lsd

git_reset


echo
echo "[.] Installation complete!"
echo
read -n 1 -s -r -p "[?] Press any key to continue..."

#--------------------------------------------------------------------------------------------------# LAST STEPS

clear
echo
echo "[.] Remember:"
echo " -  You MUST reboot the host if you want to see the changes"
echo " -  Change console font to JetBrains MONO if not using Kitty"
echo " -  Personalize you distro with themes and wallpaper"
echo " -  Change keybindings to open the right terminal"
echo " -  Execute :MasonInstallAll in neovim after lazy installs all plugins"
echo " -  Always love yourself and others"
echo

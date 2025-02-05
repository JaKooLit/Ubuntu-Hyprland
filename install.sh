#!/bin/bash
# https://github.com/JaKooLit

# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
INFO="$(tput setaf 4)[INFO]$(tput sgr0)"
WARN="$(tput setaf 1)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
MAGENTA="$(tput setaf 5)"
ORANGE="$(tput setaf 214)"
WARNING="$(tput setaf 1)"
YELLOW="$(tput setaf 3)"
GREEN="$(tput setaf 2)"
BLUE="$(tput setaf 4)"
SKY_BLUE="$(tput setaf 6)"
RESET="$(tput sgr0)"


# Check if running as root. If root, script will exit
if [[ $EUID -eq 0 ]]; then
    echo "This script should ${WARNING}NOT${RESET} be executed as root! Exiting......."
    exit 1
fi

clear

printf "\n%.0s" {1..3}                            
echo -e "\e[32m   |  _.   |/  _   _  |  o _|_  \e[39m"
echo -e "\e[32m \_| (_| o |\ (_) (_) |_ |  |_  2025\e[39m"
printf "\n%.0s" {1..2} 

# Welcome message
echo "${SKY_BLUE}Welcome to JaKooLit's Ubuntu 24.04 Hyprland (2025) Install Script!${RESET}"
echo
echo "${WARNING}ATTENTION: Run a full system update and Reboot first!! (Highly Recommended) ${RESET}"
echo
echo "${YELLOW}NOTE: You will be required to answer some questions during the installation! ${RESET}"
echo
echo "${YELLOW}NOTE: If you are installing on a VM, ensure to enable 3D acceleration else Hyprland wont start! ${RESET}"
echo

printf "\n%.0s" {1..4}
echo "$(tput bold)$(tput setaf 3)ATTENTION!!!! VERY IMPORTANT NOTICE!!!! $(tput sgr0)" 
echo "$(tput bold)$(tput setaf 7)Latest Hyprland compatible with Ubuntu 24.04 is only up to v0.39.1 $(tput sgr0)"
echo "$(tput bold)$(tput setaf 7)This was due to old version is wayland-protocols available in Ubuntu Repo $(tput sgr0)"
echo "$(tput bold)$(tput setaf 7)Because of the above, the latest KooL's Hyprland-Dots may not be fully compatible $(tput sgr0)"
echo "$(tput bold)$(tput setaf 7)This would also mean that support for this project might be slow$(tput sgr0)"
echo "$(tput bold)$(tput setaf 7)Please be guided$(tput sgr0)"
printf "\n%.0s" {1..3}

read -p "$(tput setaf 6)Would you like to proceed? (y/n): $(tput sgr0)" proceed

if [ "$proceed" != "y" ]; then
    printf "\n%.0s" {1..2}
    echo "${INFO} Installation aborted. No changes in your system! ${MAGENTA}Goodbye!!!${RESET} "
    printf "\n%.0s" {1..2}
    exit 1
fi

# Create Directory for Install Logs
if [ ! -d Install-Logs ]; then
    mkdir Install-Logs
fi

printf "\n%.0s" {1..1}

# install pciutils if detected not installed. Necessary for detecting GPU
if ! dpkg -l | grep -w pciutils > /dev/null; then
    echo "pciutils is not installed. Installing..."
    sudo apt-get install -y pciutils
fi

printf "\n%.0s" {1..2}
# Function to colorize prompts
colorize_prompt() {
    local color="$1"
    local message="$2"
    echo -n "${color}${message}$(tput sgr0)"
}

# Set the name of the log file to include the current date and time
LOG="install-$(date +%d-%H%M%S).log"

# Export PKG_CONFIG_PATH for libinput
export PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig

# Define the directory where your scripts are located
script_directory=install-scripts

# Function to ask a yes/no question and set the response in a variable
ask_yes_no() {
    while true; do
        read -p "$(colorize_prompt "$CAT"  "$1 (y/n): ")" choice
        case "$choice" in
            [Yy]* ) eval "$2='Y'"; return 0;;
            [Nn]* ) eval "$2='N'"; return 1;;
            * ) echo "Please answer with y or n.";;
        esac
    done
}

# Function to ask a custom question with specific options and set the response in a variable
ask_custom_option() {
    local prompt="$1"
    local valid_options="$2"
    local response_var="$3"

    while true; do
        read -p "$(colorize_prompt "$CAT"  "$prompt ($valid_options): ")" choice
        if [[ " $valid_options " == *" $choice "* ]]; then
            eval "$response_var='$choice'"
            return 0
        else
            echo "Please choose one of the provided options: $valid_options"
        fi
    done
}
# Function to execute a script if it exists and make it executable
execute_script() {
    local script="$1"
    local script_path="$script_directory/$script"
    if [ -f "$script_path" ]; then
        chmod +x "$script_path"
        if [ -x "$script_path" ]; then
            "$script_path"
        else
            echo "Failed to make script '$script' executable."
        fi
    else
        echo "Script '$script' not found in '$script_directory'."
    fi
}

# Collect user responses to all questions
printf "\n"
# Check if nvidia is present
if lspci | grep -i "nvidia" &> /dev/null; then
    printf "${INFO} ${YELLOW}NVIDIA GPU${RESET} detected in your system \n"
    printf "${NOTE} Script will install ${YELLOW}nvidia-dkms nvidia-utils and nvidia-settings${RESET} \n"
    ask_yes_no "-Do you want script to configure ${YELLOW}NVIDIA${RESET} for you?" nvidia
fi
printf "\n"
ask_yes_no "-Install ${YELLOW}GTK themes${RESET} (required for Dark/Light function)?" gtk_themes
printf "\n"
ask_yes_no "-Do you want to configure ${YELLOW}Bluetooth${RESET}?" bluetooth
printf "\n"
ask_yes_no "-Do you want to install ${YELLOW}Thunar file manager${RESET}?" thunar
printf "\n"
ask_yes_no "-Install ${YELLOW}AGS (aylur's GTK shell) v1${RESET} for Desktop-Like Overview?" ags
printf "\n"
ask_yes_no "-Install & configure ${YELLOW}SDDM${RESET} login manager, plus (OPTIONAL) SDDM theme?" sddm
printf "\n"
ask_yes_no "-Install ${YELLOW}XDG-DESKTOP-PORTAL-HYPRLAND${RESET}? (For proper Screen Share, e.g., OBS)" xdph
printf "\n"
ask_yes_no "-Install ${YELLOW}nwg-look? (a GTK Theming app - lxappearance-like) ${RESET} $WARN! This Package Takes long time to build!" nwg
printf "\n"
ask_yes_no "-Installing on ${YELLOW}Asus ROG laptops${RESET}?" rog
printf "\n"
ask_yes_no "-Do you want to download pre-configured ${YELLOW}KooL Hyprland dotfiles${RESET}?" dots
printf "\n"

# Ensuring all in the scripts folder are made executable
chmod +x install-scripts/*

printf "\n%.0s" {1..2}
# check if any known login managers are active when users choose to install sddm
if [ "$sddm" == "y" ] || [ "$sddm" == "Y" ]; then
    # List of services to check
    services=("gdm.service" "gdm3.service" "lightdm.service" "xdm.service" "lxdm.service")

    # Loop through each service
    for svc in "${services[@]}"; do
        if systemctl is-active --quiet "$svc"; then
            echo "${ERROR} ${MAGENTA}$svc${RESET} is active.  stop or disable it first or ${YELLOW}DO NOT choose SDDM${RESET} to install."
            echo "${NOTE} If you have GDM, no need to install SDDM. GDM will work fine as Login Manager for Hyprland."
            printf "\n%.0s" {1..2}            
            exit 1  
        fi
    done
fi


sleep 1
sudo apt update

# Install hyprland packages
execute_script "00-dependencies.sh"
execute_script "01-hypr-pkgs.sh"

# install wallust
execute_script "wallust.sh"

execute_script "fonts.sh"
execute_script "swappy.sh"
execute_script "swww.sh"
execute_script "rofi-wayland.sh"

sleep 1
execute_script "hyprlang.sh"
execute_script "hyprcursor.sh"

sleep 1
execute_script "hyprland.sh"


if [ "$nvidia" == "Y" ]; then
    execute_script "nvidia.sh"
fi

if [ "$gtk_themes" == "Y" ]; then
    execute_script "gtk_themes.sh"
fi

if [ "$bluetooth" == "Y" ]; then
    execute_script "bluetooth.sh"
fi

if [ "$thunar" == "Y" ]; then
    execute_script "thunar.sh"
fi

if [ "$ags" == "Y" ]; then
    execute_script "ags.sh"
fi

if [ "$sddm" == "Y" ]; then
    execute_script "sddm.sh"
fi

if [ "$xdph" == "Y" ]; then
    execute_script "xdph.sh"
fi

if [ "$zsh" == "Y" ]; then
    execute_script "zsh.sh"
fi

if [ "$nwg" == "Y" ]; then
    execute_script "nwg-look.sh"
fi

if [ "$rog" == "Y" ]; then
    execute_script "rog.sh"
fi

# re-install scripts it failed in some occasions
execute_script "rofi-wayland.sh"
execute_script "hyprlock.sh"
execute_script "hypridle.sh"

# input
execute_script "InputGroup.sh"

if [ "$dots" == "Y" ]; then
    execute_script "dotfiles-branch.sh"
fi

# Clean up
printf "\n${OK} performing some clean up.\n"
if [ -e "JetBrainsMono.tar.xz" ]; then
    echo "JetBrainsMono.tar.xz found. Deleting..."
    rm JetBrainsMono.tar.xz
    echo "JetBrainsMono.tar.xz deleted successfully."
fi

clear

# copy fastfetch config if ubuntu is not present
if [ ! -f "$HOME/.config/fastfetch/ubuntu.png" ]; then
    cp -r assets/fastfetch "$HOME/.config/"
fi

printf "\n%.0s" {1..2}
# final check essential packages if it is installed
execute_script "03-Final-Check.sh"

printf "\n%.0s" {1..1}

# Check if either hyprland or Hyprland files exist in /usr/local/bin/
if [ -e /usr/local/bin/hyprland ] || [ -f /usr/local/bin/Hyprland ]; then
    printf "\n${OK} Hyprland is installed. However, some essential packages may not be installed. Please see above!"
    printf "\n${CAT} Ignore this message if it states ${YELLOW}All essential packages${RESET} are installed as per above\n"
    sleep 2
    printf "\n${NOTE} You can start Hyprland by typing ${MAGENTA}Hyprland${RESET} (IF SDDM is not installed) (note the capital H!).\n"
    printf "\n${NOTE} However, it is ${YELLOW}highly recommended to reboot${RESET} your system.\n\n"

    # Prompt user to reboot
    read -rp "${CAT} Would you like to reboot now? (y/n): " HYP

    # Normalize user input to lowercase
    HYP=$(echo "$HYP" | tr '[:upper:]' '[:lower:]')

    if [[ "$HYP" == "y" || "$HYP" == "yes" ]]; then
        echo "${INFO} Rebooting now..."
        systemctl reboot # Optionally reboot if the user agrees
    elif [[ "$HYP" == "n" || "$HYP" == "no" ]]; then
        echo "${INFO} You can reboot later at any time."
    else
        echo "${WARN} Invalid response. Please answer with 'y' or 'n'. Exiting."
        exit 1
    fi

    # Check if NVIDIA GPU is present
    if lspci | grep -i "nvidia" &> /dev/null; then
        echo "${INFO} ${YELLOW}NVIDIA GPU${RESET} detected. Reminder that you must REBOOT your SYSTEM..."
    else
        echo -e "\n${CAT} Thanks for using ${MAGENTA}KooL's Hyprland Dots${RESET}. Enjoy and Have a good day!"
        printf "\n%.0s" {1..3}
        exit 0
    fi
else
    # Print error message if neither package is installed
    printf "\n${WARN} Hyprland failed to install. Please check 00_CHECK-time_installed.log and other files in the Install-Logs/ directory...\n\n"
    printf "\n%.0s" {1..2}
    exit 1
fi


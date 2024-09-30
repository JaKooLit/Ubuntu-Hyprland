#!/bin/bash

# https://github.com/JaKooLit

# Check if running as root. If root, script will exit
if [[ $EUID -eq 0 ]]; then
    echo "This script should not be executed as root! Exiting......."
    exit 1
fi

clear

printf "\n%.0s" {1..3}                            
echo "   |  _.   |/  _   _  |  o _|_ "
echo " \_| (_| o |\ (_) (_) |_ |  |_ "
printf "\n%.0s" {1..2}  

# Welcome message
echo "$(tput setaf 6)Welcome to JaKooLit's Ubuntu 24.04 Hyprland Install Script!$(tput sgr0)"
echo
echo "$(tput setaf 166)ATTENTION: Run a full system update and Reboot first!! (Highly Recommended) $(tput sgr0)"
echo
echo "$(tput setaf 3)NOTE: You will be required to answer some questions during the installation! $(tput sgr0)"
echo
echo "$(tput setaf 3)NOTE: If you are installing on a VM, ensure to enable 3D acceleration else Hyprland wont start! $(tput sgr0)"
echo

printf "\n%.0s" {1..4}
echo "$(tput bold)$(tput setaf 3)ATTENTION!!!! VERY IMPORTANT NOTICE!!!! $(tput sgr0)" 
echo "$(tput bold)$(tput setaf 7)Latest Hyprland compatible with Ubuntu 24.04 is only up to v0.39.1 $(tput sgr0)"
echo "$(tput bold)$(tput setaf 7)This was due to old version is wayland-protocols available in Ubuntu Repo $(tput sgr0)"
echo "$(tput bold)$(tput setaf 7)Because of the above, the latest Hyprland-Dots compatible will only be v2.2.13 $(tput sgr0)"
echo "$(tput bold)$(tput setaf 7)Newer dots may not be compatible.$(tput sgr0)"
echo "$(tput bold)$(tput setaf 7)This would also mean that support for this project might slowdown$(tput sgr0)"
echo "$(tput bold)$(tput setaf 7)Please be guided$(tput sgr0)"
printf "\n%.0s" {1..3}

read -p "$(tput setaf 6)Would you like to proceed? (y/n): $(tput sgr0)" proceed

if [ "$proceed" != "y" ]; then
    echo "Installation aborted."
    exit 1
fi

# Create Directory for Install Logs
if [ ! -d Install-Logs ]; then
    mkdir Install-Logs
fi

# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
WARN="$(tput setaf 5)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
ORANGE=$(tput setaf 166)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

# Function to colorize prompts
colorize_prompt() {
    local color="$1"
    local message="$2"
    echo -n "${color}${message}$(tput sgr0)"
}

# Set the name of the log file to include the current date and time
LOG="install-$(date +%d-%H%M%S).log"

# Initialize variables to store user responses
bluetooth=""
dots=""
gtk_themes=""
nvidia=""
nwg=""
rog=""
sddm=""
thunar=""
xdph=""
zsh=""
add_patches=""

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
    local parameter="$2"
    local script_path="$script_directory/$script"
    if [ -f "$script_path" ]; then
        chmod +x "$script_path"
        if [ -x "$script_path" ]; then
            "$script_path" "$parameter"
        else
            echo "Failed to make script '$script' executable."
        fi
    else
        echo "Script '$script' not found in '$script_directory'."
    fi
}

# Collect user responses to all questions
printf "\n"
ask_yes_no "-Do you have any nvidia gpu in your system?" nvidia
printf "\n"
ask_yes_no "-Install GTK themes (required for Dark/Light function)?" gtk_themes
printf "\n"
ask_yes_no "-Do you want to configure Bluetooth?" bluetooth
printf "\n"
ask_yes_no "-Do you want to install Thunar file manager?" thunar
printf "\n"
ask_yes_no "-Install & configure SDDM log-in Manager plus (OPTIONAL) SDDM Theme?" sddm
printf "\n"
ask_yes_no "-Install XDG-DESKTOP-PORTAL-HYPRLAND? (For proper Screen Share ie OBS)" xdph
printf "\n"
ask_yes_no "-Install zsh & oh-my-zsh plus (OPTIONAL) pokemon-colorscripts for tty?" zsh
printf "\n"
ask_yes_no "-Install nwg-look? (a GTK Theming app - lxappearance-like) WARN! This Package Takes long time to build!" nwg
printf "\n"
ask_yes_no "-Installing on Asus ROG Laptops?" rog
printf "\n"
ask_yes_no "-Do you want to download and install pre-configured Hyprland-dotfiles?" dots
printf "\n"
ask_yes_no "-Do you want to add additional patches backported from upstream?" add_patches
printf "\n"

# Ensuring all in the scripts folder are made executable
chmod +x install-scripts/*

printf "\n%.0s" {1..3}
# check if any known login managers are active when users choose to install sddm
if [ "$sddm" == "Y" ]; then
    # List of services to check
    services=("gdm.service" "gdm3.service" "lightdm.service" "xdm.service" "lxdm.service")

    # Loop through each service
    for svc in "${services[@]}"; do
        if systemctl is-active --quiet "$svc"; then
            echo "${ERROR} $svc is active. Please stop or disable it first or do not choose SDDM to install."
            echo "${NOTE} If you have GDM, no need to install SDDM. GDM will work fine as Login Manager for Hyprland."
            printf "\n%.0s" {1..3}
            
            exit 1  
        fi
    done
fi


sleep 1
sudo apt update

# Install hyprland packages
execute_script "00-dependencies.sh"
execute_script "01-hypr-pkgs.sh"

#execute_script "imagemagick.sh" #this is for compiling from source. 07 Sep 2024

# install wallust
execute_script "wallust.sh"

execute_script "fonts.sh"
execute_script "swappy.sh"
execute_script "swww.sh"
execute_script "rofi-wayland.sh"
execute_script "ags.sh"

sleep 1
execute_script "hyprlang.sh"
execute_script "hyprcursor.sh"

sleep 1
execute_script "hyprland.sh" "$add_patches"


#execute_script "cliphist.sh"

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
execute_script "hyprlock.sh" "$add_patches"
execute_script "hypridle.sh"

# input
execute_script "InputGroup.sh"

if [ "$dots" == "Y" ]; then
    execute_script "dotfiles.sh"
fi

# Clean up
printf "\n${OK} performing some clean up.\n"
if [ -e "JetBrainsMono.tar.xz" ]; then
    echo "JetBrainsMono.tar.xz found. Deleting..."
    rm JetBrainsMono.tar.xz
    echo "JetBrainsMono.tar.xz deleted successfully."
fi

clear

printf "\n%.0s" {1..2}
# final check essential packages if it is installed
execute_script "03-Final-Check.sh"

printf "\n%.0s" {1..1}

# Check if either hyprland or Hyprland files exist in /usr/local/bin/
if [ -e /usr/local/bin/hyprland ] || [ -f /usr/local/bin/Hyprland ]; then
    printf "\n${OK} Hyprland is installed. However, some essential packages may not be installed Please see above!"
    printf "\n${CAT} Ignore this message if it states 'All essential packages are installed.'\n"
    sleep 2
    printf "\n${NOTE} You can start Hyprland by typing 'Hyprland' (IF SDDM is not installed) (note the capital H!).\n"
    printf "\n${NOTE} However, it is highly recommended to reboot your system.\n\n"

    # Prompt user to reboot
    read -rp "${CAT} Would you like to reboot now? (y/n): " HYP

    # Check if the user answered 'y' or 'Y'
    if [[ "$HYP" =~ ^[Yy]$ ]]; then
        if [[ "$nvidia" == "Y" ]]; then
            echo "${NOTE} NVIDIA GPU detected. Rebooting the system..."
        fi
        systemctl reboot
    fi
else
    # Print error message if neither package is installed
    printf "\n${WARN} Hyprland failed to install. Please check 00_CHECK-time_installed.log and other files Install-Logs/ directory...\n\n"
    exit 1
fi


#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# XDG-Desktop-Portals for hyprland #

xdg=(
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"
LOG="Install-Logs/install-$(date +%d-%H%M%S)_xdph.log"

# Check if the file exists and remove it
[[ -f "/usr/lib/xdg-desktop-portal-hyprland" ]] && sudo rm "/usr/lib/xdg-desktop-portal-hyprland"

printf "${NOTE} Installing xdg-desktop-portals...\n"  
for portal in "${xdg[@]}"; do
    install_package "$portal" 2>&1 | tee -a "$LOG"
    [ $? -ne 0 ] && { echo -e "\e[1A\e[K${ERROR} - $portal Package installation failed, Please check the installation logs"; exit 1; }
done

printf "\n\n${NOTE} Checking for other XDG-Desktop-Portal-Implementations...\n"
sleep 1
printf "${NOTE} XDG-desktop-portal-KDE & GNOME (if installed) should be manually disabled or removed! I can't remove it... sorry...\n"

while true; do
    read -rp "${CAT} Would you like to try to remove other XDG-Desktop-Portal-Implementations? (y/n) " XDPH1
    echo
    sleep 1

    case $XDPH1 in
      [Yy])
        printf "${NOTE} Clearing any other xdg-desktop-portal implementations...\n"
        for portal in xdg-desktop-portal-wlr xdg-desktop-portal-lxqt; do
            if dpkg -l | grep -q "$portal"; then
                echo "Removing $portal..."
                sudo apt-get remove -y "$portal" 2>&1 | tee -a "$LOG"
            fi
        done
        break
        ;;
      [Nn])
        echo "No other XDG-implementations will be removed." 2>&1 | tee -a "$LOG"
        break
        ;;
      *)
        echo "Invalid input. Please enter 'y' for yes or 'n' for no."
        ;;
    esac
done

clear

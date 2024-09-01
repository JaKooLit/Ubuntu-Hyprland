#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# XDG-Desktop-Portals #

xdg=(
    libpipewire-0.3-dev
    libspa-0.2-dev
    libdrm-dev
    libgbm-dev
    wayland-protocols  
    xdg-desktop-portal-gtk
)

#specific branch or release
xdph_tag="v1.3.2"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_xdph.log"
MLOG="install-$(date +%d-%H%M%S)_xdph2.log"

##
printf "${NOTE} Installing xdg-desktop-portal-gtk...\n"
for portal in "${xdg[@]}"; do
    install_package "$portal" 2>&1 | tee -a "$LOG"
    if [ $? -ne 0 ]; then
        echo -e "\e[1A\e[K${ERROR} - $portal Package installation failed, Please check the installation logs"
        exit 1
    fi
done

# Check if xdg-desktop-portal-hyprland folder exists and remove it
if [ -d "xdg-desktop-portal-hyprland" ]; then
    printf "${NOTE} Removing existing xdg-desktop-portal-hyprland folder...\n"
    rm -rf "xdg-desktop-portal-hyprland"
fi

# Clone and build xdg-desktop-portal-hyprland
printf "${NOTE} Installing xdg-desktop-portal-hyprland...\n"
if git clone --recursive -b $xdph_tag https://github.com/hyprwm/xdg-desktop-portal-hyprland; then
    cd xdg-desktop-portal-hyprland || exit 1
    cmake -DCMAKE_INSTALL_LIBEXECDIR=/usr/lib -DCMAKE_INSTALL_PREFIX=/usr -B build
    cmake --build build
    if sudo cmake --install build 2>&1 | tee -a "$MLOG"; then
        printf "${OK} xdg-desktop-portal-hyprland installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
        echo -e "${ERROR} Installation failed for xdg-desktop-portal-hyprland." 2>&1 | tee -a "$MLOG"
    fi
    # Moving the additional logs to Install-Logs directory
    mv "$MLOG" ../Install-Logs/ || true
    cd ..
else
    echo -e "${ERROR} Download failed for xdg-desktop-portal-hyprland." 2>&1 | tee -a "$LOG"
fi

printf "\n\n"
printf "${NOTE} Checking for other XDG-Desktop-Portal-Implementations....\n"
sleep 1
printf "\n"
printf "${NOTE} XDG-desktop-portal-KDE & GNOME (if installed) should be manually disabled or removed! I can't remove it... sorry...\n"
while true; do
    read -rp "${CAT} Would you like to try to remove other XDG-Desktop-Portal-Implementations? (y/n) " XDPH1
    echo
    sleep 1

    case $XDPH1 in
      [Yy])
        # Clean out other portals
        printf "${NOTE} Clearing any other xdg-desktop-portal implementations...\n"
        # Check if packages are installed and uninstall if present
        if sudo apt-get list installed xdg-desktop-portal-wlr &>> /dev/null; then
        echo "Removing xdg-desktop-portal-wlr..."
        sudo apt-get remove -y xdg-desktop-portal-wlr 2>&1 | tee -a "$LOG"
        fi
  
        if sudo apt-get list installed xdg-desktop-portal-lxqt &>> /dev/null; then
        echo "Removing xdg-desktop-portal-lxqt..."
        sudo apt-get remove -y xdg-desktop-portal-lxqt 2>&1 | tee -a "$LOG"
        fi
        break
        ;;
      [Nn])
        echo "no other XDG-implementations will be removed." 2>&1 | tee -a "$LOG"
        break
        ;;
        
      *)
        echo "Invalid input. Please enter 'y' for yes or 'n' for no."
        ;;
    esac
done

clear


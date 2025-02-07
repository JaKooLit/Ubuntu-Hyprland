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

printf "${NOTE} Installing ${SKY_BLUE}xdg-desktop-portal-hyprland dependencies${RESET} ...\n"
for portal in "${xdg[@]}"; do
    install_package "$portal" "$LOG"
done

# Check if xdg-desktop-portal-hyprland folder exists and remove it
if [ -d "xdg-desktop-portal-hyprland" ]; then
    rm -rf "xdg-desktop-portal-hyprland"
fi

# Clone and build xdg-desktop-portal-hyprland
printf "${NOTE} Installing ${SKY_BLUE}xdg-desktop-portal-hyprland $xdph_tag from source${RESET}"
if git clone --recursive -b $xdph_tag https://github.com/hyprwm/xdg-desktop-portal-hyprland; then
    cd xdg-desktop-portal-hyprland || exit 1
    cmake -DCMAKE_INSTALL_LIBEXECDIR=/usr/lib -DCMAKE_INSTALL_PREFIX=/usr -B build
    cmake --build build
    if sudo cmake --install build 2>&1 | tee -a "$MLOG"; then
        printf "${OK} ${MAGENTA}xdg-desktop-portal-hyprland $xdph_tag${RESET} installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
        echo -e "${ERROR} Installation failed for ${YELLOW}xdg-desktop-portal-hyprland $xdph_tag${RESET}" 2>&1 | tee -a "$MLOG"
    fi
    # Moving the additional logs to Install-Logs directory
    mv "$MLOG" ../Install-Logs/ || true
    cd ..
else
    echo -e "${ERROR} Download failed for ${YELLOW}xdg-desktop-portal-hyprland $xdph_tag${RESET}" 2>&1 | tee -a "$LOG"
fi

printf "\n%.0s" {1..2}

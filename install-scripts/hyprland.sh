#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Main Hyprland Package#


#specific branch or release
hyprland_tag="v0.39.1"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprland.log"
MLOG="install-$(date +%d-%H%M%S)_hyprland2.log"

ADD_PATCHES=$1

# Clone, build, and install Hyprland using Cmake
printf "${NOTE} Cloning Hyprland...\n"

# Check if Hyprland folder exists and remove it
if [ -d "Hyprland" ]; then
  printf "${NOTE} Removing existing Hyprland folder...\n"
  rm -rf "Hyprland" 2>&1 | tee -a "$LOG"
fi

if git clone --recursive -b $hyprland_tag "https://github.com/hyprwm/Hyprland"; then
  cd "Hyprland" || exit 1
  if [ "$ADD_PATCHES" == "Y" ]; then
    patch -p1 < "$PARENT_DIR"/patch/Hyprland-v0.39.4.patch
  fi
  make all
  if sudo make install 2>&1 | tee -a "$MLOG"; then
    printf "${OK} Hyprland installed successfully.\n" 2>&1 | tee -a "$MLOG"
  else
    echo -e "${ERROR} Installation failed for Hyprland." 2>&1 | tee -a "$MLOG"
  fi
  mv $MLOG ../Install-Logs/ || true   
  cd ..
else
  echo -e "${ERROR} Download failed for Hyprland." 2>&1 | tee -a "$LOG"
fi

wayland_sessions_dir=/usr/share/wayland-sessions
[ ! -d "$wayland_sessions_dir" ] && { printf "$CAT - $wayland_sessions_dir not found, creating...\n"; sudo mkdir -p "$wayland_sessions_dir" 2>&1 | tee -a "$LOG"; }
sudo cp assets/hyprland.desktop "$wayland_sessions_dir/" 2>&1 | tee -a "$LOG"

clear


#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Main Hyprland Package#


#specific branch or release
hyprland_tag="v0.39.1"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }

# Source the global functions script
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  echo "Failed to source Global_functions.sh"
  exit 1
fi

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprland.log"
MLOG="install-$(date +%d-%H%M%S)_hyprland2.log"

# Clone, build, and install Hyprland using Cmake
printf "${INFO} Compiling and Installing ${YELLOW}hyprland $hyprland_tag${RESET} from source ...\n"

# Check if Hyprland folder exists and remove it
if [ -d "Hyprland" ]; then
  rm -rf "Hyprland" 2>&1 | tee -a "$LOG"
fi

if git clone --recursive -b $hyprland_tag "https://github.com/hyprwm/Hyprland"; then
  cd "Hyprland" || exit 1
  make all
  if sudo make install 2>&1 | tee -a "$MLOG"; then
    printf "${OK} ${MAGENTA}hyprland $hyprland_tag${RESET} has been successfully installed.\n" 2>&1 | tee -a "$MLOG"
  else
    echo -e "${ERROR} Installation failed for ${YELLOW}hyprland $hyprland_tag${RESET}" 2>&1 | tee -a "$MLOG"
  fi
  mv $MLOG ../Install-Logs/ || true   
  cd ..
else
  echo -e "${ERROR} Download failed for ${YELLOW}hyprland $hyprland_tag${RESET}" 2>&1 | tee -a "$LOG"
fi

wayland_sessions_dir=/usr/share/wayland-sessions
[ ! -d "$wayland_sessions_dir" ] && { printf "$CAT - $wayland_sessions_dir not found, creating...\n"; sudo mkdir -p "$wayland_sessions_dir" 2>&1 | tee -a "$LOG"; }
sudo cp assets/hyprland.desktop "$wayland_sessions_dir/" 2>&1 | tee -a "$LOG"

printf "\n%.0s" {1..2}


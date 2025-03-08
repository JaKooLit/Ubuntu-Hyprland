#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Main Hyprland Package #

hypr=(
  hyprland-protocols
  hyprwayland-scanner
)

# forcing to reinstall. Had experience it says hyprland is already installed
f_hypr=(
  hyprland
)

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


# Hyprland
printf "${NOTE} Installing ${SKY_BLUE}Hyprland packages${RESET} .......\n"
 for HYPR in "${hypr[@]}"; do
   install_package "$HYPR" "$LOG"
done

# force
printf "${NOTE} Reinstalling ${SKY_BLUE}Hyprland packages${RESET}  .......\n"
 for HYPR1 in "${f_hypr[@]}"; do
   re_install_package "$HYPR1" "$LOG"
done

printf "\n%.0s" {1..2} 
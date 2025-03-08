#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Hyprland-Dots to download from main #

#specific branch or release
dots_tag="Ubuntu-24.04-Dots"

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

# Check if Hyprland-Dots exists
printf "${NOTE} Downloading KooL's Hyprland Dots for Ubuntu 24.04....\n"

if [ -d Hyprland-Dots-Ubuntu-24.04 ]; then
  cd Hyprland-Dots-Ubuntu-24.04
  git stash
  git pull
  git stash apply
  chmod +x copy.sh
  ./copy.sh 
else
  if git clone --depth=1 -b $dots_tag https://github.com/JaKooLit/Hyprland-Dots Hyprland-Dots-Ubuntu-24.04; then
    cd Hyprland-Dots-Ubuntu-24.04 || exit 1
    chmod +x copy.sh
    ./copy.sh 
  else
    echo -e "$ERROR Can't download Hyprland-Dots-Ubuntu-24.04"
  fi
fi

printf "\n%.0s" {1..2}

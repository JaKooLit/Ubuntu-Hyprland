#!/bin/bash

# This script is cleaning up previous manual installation files / directories

# 22 Aug 2024
# Files to be removed from /usr/local/bin

TARGET_DIR="/usr/local/bin"

# Define packages to manually remove (was manually installed previously)
PACKAGES=(
  hyprctl
  hyprpm
  hyprland
  Hyprland
  cliphist
  pypr
  swappy
  waybar
  magick
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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_pre-clean-up.log"

# Loop through the list of packages
for PKG_NAME in "${PACKAGES[@]}"; do
  # Construct the full path to the file
  FILE_PATH="$TARGET_DIR/$PKG_NAME"

  # Check if the file exists
  if [[ -f "$FILE_PATH" ]]; then
    # Delete the file
    sudo rm "$FILE_PATH"
    echo "Deleted: $FILE_PATH" 2>&1 | tee -a "$LOG"
  else
    echo "File not found: $FILE_PATH" 2>&1 | tee -a "$LOG"
  fi
done

clear
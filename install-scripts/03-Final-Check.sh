#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Final checking if packages are installed
# NOTE: These package checks are only the essentials

packages=(
  imagemagick
  sway-notification-center
  waybar
  wl-clipboard
  cliphist
  wlogout
  kitty
)

# Commands that should be available in PATH (regardless of /usr/bin or /usr/local/bin)
path_cmds=(
  hyprland
  hypridle
  hyprlock
  swww
  rofi
  wallust
  nwg-displays
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
LOG="Install-Logs/00_CHECK-$(date +%d-%H%M%S)_installed.log"

printf "\n%s - Final Check if Essential packages were installed \n" "${NOTE}"
# Initialize an empty array to hold missing packages
missing=()
path_missing=()

# Function to check if a package is installed using dpkg
is_installed_dpkg() {
    dpkg -l | grep -q "^ii  $1 "
}

# Loop through each package
for pkg in "${packages[@]}"; do
    # Check if the package is installed via dpkg
    if ! is_installed_dpkg "$pkg"; then
        missing+=("$pkg")
    fi
done

# Check that commands are available in PATH (covers both /usr/bin and /usr/local/bin)
for cmd in "${path_cmds[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        path_missing+=("$cmd")
    fi
done

# Log missing packages
if [ ${#missing[@]} -eq 0 ] && [ ${#path_missing[@]} -eq 0 ]; then
    echo "${OK} GREAT! All ${YELLOW}essential packages${RESET} have been successfully installed." | tee -a "$LOG"
else
    if [ ${#missing[@]} -ne 0 ]; then
        echo "${WARN} The following packages are not installed and will be logged:"
        for pkg in "${missing[@]}"; do
            echo "$pkg"
            echo "$pkg" >> "$LOG" # Log the missing package to the file
        done
    fi

    if [ ${#path_missing[@]} -ne 0 ]; then
        echo "${WARN} The following commands are missing from PATH and will be logged:"
        for cmd in "${path_missing[@]}"; do
            echo "$cmd is not installed or not in PATH"
            echo "$cmd" >> "$LOG" # Log the missing command to the file
        done
    fi

    # Add a timestamp when the missing packages were logged
    echo "${NOTE} Missing packages logged at $(date)" >> "$LOG"
fi

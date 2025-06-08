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
  hyprland
)

# Local packages that should be in /usr/local/bin/
local_pkgs_installed=(
  rofi
  hypridle
  hyprlock
  wallust 
)

local_pkgs_installed_2=(
  swww
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
local_missing=()
local_missing_2=()

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

# Check for local packages
for pkg1 in "${local_pkgs_installed[@]}"; do
    if ! [ -f "/usr/local/bin/$pkg1" ]; then
        local_missing+=("$pkg1")
    fi
done

# Check for local packages in /usr/bin
for pkg2 in "${local_pkgs_installed_2[@]}"; do
    if ! [ -f "/usr/bin/$pkg2" ]; then
        local_missing_2+=("$pkg2")
    fi
done

# Log missing packages
if [ ${#missing[@]} -eq 0 ] && [ ${#local_missing[@]} -eq 0 ] && [ ${#local_missing_2[@]} -eq 0 ]; then
    echo "${OK} GREAT! All ${YELLOW}essential packages${RESET} have been successfully installed." | tee -a "$LOG"
else
    if [ ${#missing[@]} -ne 0 ]; then
        echo "${WARN} The following packages are not installed and will be logged:"
        for pkg in "${missing[@]}"; do
            echo "$pkg"
            echo "$pkg" >> "$LOG" # Log the missing package to the file
        done
    fi

    if [ ${#local_missing[@]} -ne 0 ]; then
        echo "${WARN} The following local packages are missing from /usr/local/bin/ and will be logged:"
        for pkg1 in "${local_missing[@]}"; do
            echo "$pkg1 is not installed. can't find it in /usr/local/bin/"
            echo "$pkg1" >> "$LOG" # Log the missing local package to the file
        done
    fi

    if [ ${#local_missing_2[@]} -ne 0 ]; then
        echo "${WARN} The following local packages are missing from /usr/bin/ and will be logged:"
        for pkg2 in "${local_missing_2[@]}"; do
            echo "$pkg2 is not installed. can't find it in /usr/bin/"
            echo "$pkg2" >> "$LOG" # Log the missing local package to the file
        done
    fi

    # Add a timestamp when the missing packages were logged
    echo "${NOTE} Missing packages logged at $(date)" >> "$LOG"
fi

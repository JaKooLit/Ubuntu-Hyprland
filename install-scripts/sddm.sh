#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# SDDM with optional SDDM theme #

# installing with NO-recommends
sddm1=(
  sddm
)

sddm2=(
  libqt6svg6
  qt6-declarative-dev
  qt6-svg-dev
  qt6-virtualkeyboard-plugin
  libqt6multimedia6
  qml6-module-qtquick-controls
  qml6-module-qtquick-effects
)

# login managers to attempt to disable
login=(
  lightdm 
  gdm3 
  gdm 
  lxdm 
  lxdm-gtk3
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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_sddm.log"


# Install SDDM (no-recommends)
printf "\n%s - Installing ${SKY_BLUE}SDDM and dependencies${RESET} .... \n" "${NOTE}"
for PKG1 in "${sddm1[@]}" ; do
  sudo apt install --no-install-recommends -y "$PKG1" | tee -a "$LOG"
done

# Installation of additional sddm stuff
for PKG2 in "${sddm2[@]}"; do
  install_package "$PKG2"  "$LOG"
done

# Check if other login managers are installed and disable their service before enabling SDDM
for login_manager in "${login[@]}"; do
  if dpkg -l | grep -q "^ii  $login_manager"; then
    echo "Disabling $login_manager..."
    sudo systemctl disable "$login_manager.service" >> "$LOG" 2>&1 || echo "Failed to disable $login_manager" >> "$LOG"
    echo "$login_manager disabled."
  fi
done

# Double check with systemctl
for manager in "${login[@]}"; do
  if systemctl is-active --quiet "$manager.service" > /dev/null 2>&1; then
    echo "$manager.service is active, disabling it..." >> "$LOG" 2>&1
    sudo systemctl disable "$manager.service" --now >> "$LOG" 2>&1 || echo "Failed to disable $manager.service" >> "$LOG"
  else
    echo "$manager.service is not active" >> "$LOG" 2>&1
  fi
done

printf "\n%.0s" {1..1}
printf "${INFO} Activating sddm service........\n"
sudo systemctl set-default graphical.target 2>&1 | tee -a "$LOG"
sudo systemctl enable sddm.service 2>&1 | tee -a "$LOG"

wayland_sessions_dir=/usr/share/wayland-sessions
[ ! -d "$wayland_sessions_dir" ] && { printf "$CAT - $wayland_sessions_dir not found, creating...\n"; sudo mkdir -p "$wayland_sessions_dir" 2>&1 | tee -a "$LOG"; }
sudo cp assets/hyprland.desktop "$wayland_sessions_dir/" 2>&1 | tee -a "$LOG"

printf "\n%.0s" {1..2}
#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Add Hyprland PPA and install Hyprland stack from PPA

set -euo pipefail

# Discover repo root and source helpers
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "[ERROR] Failed to change directory to $PARENT_DIR"; exit 1; }

# Optional helper functions (not required for apt upgrades, but source if present)
if [ -f "$(dirname "$(readlink -f "$0")")/Global_functions.sh" ]; then
  # shellcheck disable=SC1090
  source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"
fi

LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprland-ppa.log"

printf "[INFO] Ensuring add-apt-repository is available...\n" | tee -a "$LOG"
sudo apt install -y software-properties-common | tee -a "$LOG"

# Add the PPA, then update package lists (required to see PPA versions)
printf "[INFO] Adding Hyprland PPA (cpiber/hyprland)...\n" | tee -a "$LOG"
sudo add-apt-repository -y ppa:cpiber/hyprland | tee -a "$LOG"

printf "[INFO] Running apt update after adding PPA...\n" | tee -a "$LOG"
sudo apt update | tee -a "$LOG"

# Install Hyprland first, then the rest
printf "[INFO] Installing Hyprland from PPA...\n" | tee -a "$LOG"
sudo apt install -y hyprland | tee -a "$LOG"

printf "[INFO] Installing remaining Hyprland-related packages from PPA...\n" | tee -a "$LOG"
sudo apt install -y \
  hypridle \
  hyprlock \
  hyprsunset \
  hyprpaper \
  hyprpicker \
  waybar \
  hyprutils \
  hyprwayland-scanner \
  hyprgraphics \
  hyprcursor \
  aquamarine \
  hyprland-qtutils \
  xdg-desktop-portal-hyprland | tee -a "$LOG"

printf "[OK] Hyprland PPA setup and package installation complete.\n" | tee -a "$LOG"

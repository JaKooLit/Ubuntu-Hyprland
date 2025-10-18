#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Install Hyprland and related packages from cppiber/hyprland PPA (prebuilt binaries)

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

# shellcheck source=install-scripts/Global_functions.sh
source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprland-ppa.log"

note() { echo -e "${NOTE} $*" | tee -a "$LOG"; }
info() { echo -e "${INFO} $*" | tee -a "$LOG"; }

install_package software-properties-common 2>&1 | tee -a "$LOG" || true

if ! grep -R "^deb .*cppiber.*hyprland" /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null | grep -q .; then
  note "Adding PPA: ppa:cppiber/hyprland"
  sudo add-apt-repository -y ppa:cppiber/hyprland 2>&1 | tee -a "$LOG" || true
else
  info "PPA already present; skipping add-apt-repository"
fi

info "Running apt update"
sudo apt update 2>&1 | tee -a "$LOG"

# Install hyprland first to satisfy dependencies cleanly
if apt-cache policy hyprland | grep -q "Candidate: \\S"; then
  info "Installing/Upgrading hyprland from apt"
  sudo apt install -y hyprland 2>&1 | tee -a "$LOG"
else
  note "hyprland not found in APT archives; skipping"
fi

# Install remaining PPA components (exclude hyprland-qtutils and hyprland-qt-support for now)
PKGS=(
  hypridle
  hyprlock
  hyprsunset
  hyprpaper
  hyprpicker
  waybar
  hyprutils
  hyprwayland-scanner
  hyprgraphics
  hyprcursor
  aquamarine
  xdg-desktop-portal-hyprland
)

for p in "${PKGS[@]}"; do
  if apt-cache policy "$p" | grep -q "Candidate: \\S"; then
    info "Installing/Upgrading $p from apt"
    sudo apt install -y "$p" 2>&1 | tee -a "$LOG"
  else
    note "$p not found in APT archives; skipping"
  fi
done

note "PPA-based Hyprland installation completed."

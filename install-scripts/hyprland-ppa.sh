#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Install Hyprland and related packages from Ubuntu repositories (remove PPA if present)

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

# shellcheck source=install-scripts/Global_functions.sh
source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprland-apt.log"

note() { echo -e "${NOTE} $*" | tee -a "$LOG"; }
info() { echo -e "${INFO} $*" | tee -a "$LOG"; }

# Ensure helper for PPA removal is available
install_package software-properties-common 2>&1 | tee -a "$LOG" || true

# Remove the outdated Hyprland PPA if present to prevent Release file errors on 26.04
if grep -R "^deb .*cppiber.*hyprland" /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null | grep -q .; then
  note "Removing PPA: ppa:cppiber/hyprland"
  sudo add-apt-repository -r -y ppa:cppiber/hyprland 2>&1 | tee -a "$LOG" || true
  sudo rm -f /etc/apt/sources.list.d/*cppiber*hyprland*.list 2>/dev/null || true
  sudo sed -i '/cppiber.*hyprland/d' /etc/apt/sources.list 2>/dev/null || true
fi

# Clean up any stale preferences that could pin PPA packages (best effort)
sudo rm -f /etc/apt/preferences.d/*hyprland* /etc/apt/preferences.d/*cppiber* 2>/dev/null || true

info "Running apt update"
sudo apt update 2>&1 | tee -a "$LOG"

# Ensure APT is not in a broken state before proceeding
sudo dpkg --configure -a 2>/dev/null | tee -a "$LOG" || true
sudo apt --fix-broken install -y 2>&1 | tee -a "$LOG" || true

# Attempt to replace any PPA-only packages with Ubuntu repo equivalents or purge if none exist
PPA_ONLY=(hyprutils hyprgraphics hyprcursor aquamarine hyprsunset)
for p in "${PPA_ONLY[@]}"; do
  if dpkg -l | grep -q "^ii  ${p} "; then
    if ! apt-cache policy "$p" | grep -q "Candidate: \\S"; then
      note "Purging stale PPA package with no Ubuntu candidate: $p"
      sudo apt -y purge "$p" 2>&1 | tee -a "$LOG" || true
    fi
  fi
done

# Install hyprland first to satisfy dependencies cleanly (Ubuntu 26.04 provides 0.52.x)
if apt-cache policy hyprland | grep -q "Candidate: \\S"; then
  info "Installing/Upgrading hyprland from Ubuntu repositories"
  sudo apt install -y hyprland 2>&1 | tee -a "$LOG"
else
  note "hyprland not found in APT archives; skipping"
fi

# Install remaining components available in Ubuntu repositories
PKGS=(
  hypridle
  hyprlock
  hyprpaper
  hyprpicker
  waybar
  hyprwayland-scanner
  hyprland-qtutils
  xdg-desktop-portal-hyprland
)

for p in "${PKGS[@]}"; do
  if apt-cache policy "$p" | grep -q "Candidate: \\S"; then
    info "Installing/Upgrading $p from Ubuntu repositories"
    sudo apt install -y "$p" 2>&1 | tee -a "$LOG"
  else
    note "$p not available in Ubuntu repositories; skipping"
  fi
done

note "Repository-based Hyprland installation completed."

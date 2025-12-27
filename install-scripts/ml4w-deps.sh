#!/bin/bash
# ml4w-deps.sh — install packages from the ML4W list that are missing from this repo's install-scripts
# Target: Ubuntu 25.10+/26.04+
# Usage: run from repo root: ./install-scripts/ml4w-deps.sh

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR"

# Obtain sudo once (foreground) and keep the timestamp alive for the duration of this script.
# Global_functions' install_package runs 'sudo apt install' in the background, which would fail
# without a cached sudo credential.
if ! sudo -v; then
  echo "Sudo authentication failed; cannot continue." >&2
  exit 1
fi
(
  while true; do
    sudo -n true 2>/dev/null || exit
    sleep 60
    kill -0 "$$" 2>/dev/null || exit
  done
) &
SUDO_KEEPALIVE_PID=$!
trap 'kill ${SUDO_KEEPALIVE_PID} 2>/dev/null || true' EXIT

# Source shared helpers (progress, logging, idempotent install)
# shellcheck source=install-scripts/Global_functions.sh
source "$SCRIPT_DIR/Global_functions.sh"

LOG="Install-Logs/install-$(date +%d-%H%M%S)_ml4w-deps.log"
mkdir -p "$(dirname "$LOG")"
export LOG

note() { echo -e "${NOTE} $*" | tee -a "$LOG"; }
warn() { echo -e "${WARN} $*" | tee -a "$LOG"; }
info() { echo -e "${INFO} $*" | tee -a "$LOG"; }

is_installed() {
  dpkg -s "$1" >/dev/null 2>&1
}

# Map Arch-style names in the ML4W list to Ubuntu package names
# - libnotify      -> libnotify-bin (for notify-send CLI)
# - qt5-wayland    -> qtwayland5
# - network-manager-applet -> network-manager-gnome (nm-applet)
# - polkit-gnome   -> policykit-1-gnome
# - python-pip     -> python3-pip (already installed by this repo)
# - python-gobject -> python3-gi
# - python-screeninfo -> python3-screeninfo (if available)
# - swaync         -> sway-notification-center (already installed here)
# - rofi-wayland   -> rofi
# - grimblast-git  -> grimblast (if available) or install script from hyprwm/contrib
# - otf-font-awesome -> fonts-font-awesome (already installed here)
# - ttf-fira-code  -> fonts-firacode (already installed here)

UBUNTU_PKGS=(
  rsync
  figlet
  libnotify-bin
  qtwayland5
  eza
  python3-gi
  python3-screeninfo
  nm-connection-editor
  network-manager-gnome
  xclip
  neovim
  htop
  policykit-1-gnome
  zsh-completions
  fzf
  papirus-icon-theme
  breeze
  flatpak
  waypaper
  bibata-cursor-theme
  fonts-fira-sans
  power-profiles-daemon
  python3-pywalfox
  rofi
)

# These are best-effort: may not exist in Ubuntu archives depending on release
BEST_EFFORT_APT=(
  gum
  nwg-dock-hyprland
  grimblast
)

info "Running apt update"
sudo apt update 2>&1 | tee -a "$LOG"

# Install definite packages (skip if already installed)
info "Installing ML4W additional packages (definite set)"
for pkg in "${UBUNTU_PKGS[@]}"; do
  if is_installed "$pkg"; then
    note "$pkg is already installed. Skipping."
  else
    install_package "$pkg"
  fi

done

# Try best-effort packages only if APT has a candidate
info "Installing best-effort packages when available in APT"
for pkg in "${BEST_EFFORT_APT[@]}"; do
  if apt-cache policy "$pkg" | grep -q "Candidate: \\S"; then
    if is_installed "$pkg"; then
      note "$pkg is already installed. Skipping."
    else
      install_package "$pkg"
    fi
  else
    warn "$pkg not found in Ubuntu archives; skipping APT install"
  fi
done

# If grimblast wasn't available in APT, fetch the script from hyprwm/contrib
if ! command -v grimblast >/dev/null 2>&1; then
  warn "grimblast not installed from APT; installing helper script from hyprwm/contrib"
  TMP_FILE=$(mktemp)
  if curl -fsSL -o "$TMP_FILE" https://raw.githubusercontent.com/hyprwm/contrib/master/grimblast/grimblast; then
    sudo install -m 0755 "$TMP_FILE" /usr/local/bin/grimblast
    rm -f "$TMP_FILE"
    note "Installed grimblast script to /usr/local/bin/grimblast"
  else
    warn "Failed to download grimblast helper; leaving as-is"
  fi
fi

# Handle eza vs lsd coexistence: nothing destructive; both can coexist

# Fonts: optional Nerd Font for FiraCode if not already present
install_fira_nerd_font() {
  local target_dir="$HOME/.local/share/fonts/FiraCodeNerd"
  if fc-list | grep -qi "FiraCode Nerd"; then
    note "FiraCode Nerd Font already present; skipping"
    return
  fi
  note "Installing FiraCode Nerd Font to ~/.local/share/fonts"
  mkdir -p "$target_dir"
  TMP_ZIP=$(mktemp)
  if curl -fsSL -o "$TMP_ZIP" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip; then
    unzip -o -q "$TMP_ZIP" -d "$target_dir"
    fc-cache -v | tee -a "$LOG" >/dev/null || true
    note "FiraCode Nerd Font installed"
  else
    warn "Failed to download FiraCode Nerd Font"
  fi
  rm -f "$TMP_ZIP" || true
}

install_fira_nerd_font

# Gum fallback: suggest Snap if APT had no candidate and gum still missing
if ! command -v gum >/dev/null 2>&1; then
  if ! apt-cache policy gum | grep -q "Candidate: \\S"; then
    warn "gum not available via APT on this release. If desired, install via Snap: 'sudo snap install charm-gum --classic' or use upstream .deb."
  fi
fi

# Ensure Flathub remote exists and install ML4W Dotfiles Installer
if command -v flatpak >/dev/null 2>&1; then
  info "Ensuring Flathub remote is configured"
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>&1 | tee -a "$LOG" || true
  if flatpak list --app --columns=application | grep -qx com.ml4w.dotfilesinstaller; then
    note "com.ml4w.dotfilesinstaller already installed. Skipping."
  else
    info "Installing com.ml4w.dotfilesinstaller from Flathub (user scope)"
    flatpak install -y --user flathub com.ml4w.dotfilesinstaller 2>&1 | tee -a "$LOG"
  fi
else
  warn "flatpak not available; skipping Flathub setup and com.ml4w.dotfilesinstaller. Re-run after Flatpak is installed."
fi

note "ML4W dependency pass completed. Review $LOG for details."

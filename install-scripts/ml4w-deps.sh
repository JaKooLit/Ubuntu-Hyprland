#!/bin/bash
# ml4w-deps.sh — install packages from the ML4W list that are missing from this repo's install-scripts
# Target: Ubuntu 25.10+/26.04+
# Usage: run from repo root: ./install-scripts/ml4w-deps.sh

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR"

# Source shared helpers (progress, logging, idempotent install)
# shellcheck source=install-scripts/Global_functions.sh
source "$SCRIPT_DIR/Global_functions.sh"

LOG="Install-Logs/install-$(date +%d-%H%M%S)_ml4w-deps.log"
mkdir -p "$(dirname "$LOG")"

note() { echo -e "${NOTE} $*" | tee -a "$LOG"; }
warn() { echo -e "${WARN} $*" | tee -a "$LOG"; }
info() { echo -e "${INFO} $*" | tee -a "$LOG"; }

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
  install_package "$pkg" "$LOG"
done

# Try best-effort packages only if APT has a candidate
info "Installing best-effort packages when available in APT"
for pkg in "${BEST_EFFORT_APT[@]}"; do
  if apt-cache policy "$pkg" | grep -q "Candidate: \\S"; then
    install_package "$pkg" "$LOG"
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

note "ML4W dependency pass completed. Review $LOG for details."

#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Hyprland-Dots Packages #
# edit your packages desired here. 
# WARNING! If you remove packages here, dotfiles may not work properly.
# and also, ensure that packages are present in Debian Official Repo

# add packages wanted here
Extra=(

)

# packages needed
hypr_package=(
    cliphist
    fastfetch
    grim
    gvfs
    gvfs-backends
    inxi
    imagemagick
    kitty
    nano
    pavucontrol
    playerctl
    polkit-kde-agent-1
    python3-requests
    python3-pip
    qt5ct
    qt5-style-kvantum
    qt5-style-kvantum-themes
    qt6ct
    slurp
    swappy
    sway-notification-center
    unzip
    waybar
    wget
    wl-clipboard
    wlogout
    xdg-user-dirs
    xdg-utils
    yad
)

# the following packages can be deleted. however, dotfiles may not work properly
hypr_package_2=(
    brightnessctl
    btop
    cava
    loupe
    gnome-system-monitor
    mousepad
    mpv
    mpv-mpris
    nwg-look
    nwg-displays
    nvtop
    pamixer
    qalculate-gtk
)

# packages to force reinstall 
force=(
  imagemagick
  wayland-protocols
)

# List of packages to uninstall as it conflicts with swaync or causing swaync to not function properly
uninstall=(
    dunst
    mako
    rofi
    cargo
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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hypr-pkgs.log"

# conflicting packages removal
overall_failed=0
printf "\n%s - ${SKY_BLUE}Removing some packages${RESET} as it conflicts with KooL's Hyprland Dots \n" "${NOTE}"
for PKG in "${uninstall[@]}"; do
  uninstall_package "$PKG" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    overall_failed=1
  fi
done

if [ $overall_failed -ne 0 ]; then
  echo -e "${ERROR} Some packages failed to uninstall. Please check the log."
fi

printf "\n%.0s" {1..1}

# Installation of main components
printf "\n%s - Installing ${SKY_BLUE}KooL's hyprland necessary packages${RESET} .... \n" "${NOTE}"

for PKG1 in "${hypr_package[@]}" "${hypr_package_2[@]}" "${Extra[@]}"; do
  install_package "$PKG1" "$LOG"
done

printf "\n%.0s" {1..1}

for PKG2 in "${force[@]}"; do
  re_install_package "$PKG2" "$LOG"
done

printf "\n%.0s" {1..1}

# Install up-to-date Rust
echo "${INFO} Installing most ${YELLOW}up to date Rust compiler${RESET} ..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y 2>&1 | tee -a "$LOG"
source "$HOME/.cargo/env"

## making brightnessctl work
sudo chmod +s $(which brightnessctl) 2>&1 | tee -a "$LOG" || true

printf "\n%.0s" {1..2}

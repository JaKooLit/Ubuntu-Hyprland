#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Hypr Ecosystem #
# hyprwayland-scanner #

scan_depend=(
    libpugixml-dev
)

#specific branch or release
tag="v0.4.5"
# Allow environment override
if [ -n "${HYPRWAYLAND_SCANNER_TAG:-}" ]; then tag="$HYPRWAYLAND_SCANNER_TAG"; fi

# Dry-run support
DO_INSTALL=1
if [ "${1:-}" = "--dry-run" ] || [ "${DRY_RUN:-0}" = "1" ] || [ "${DRY_RUN:-false}" = "true" ]; then
    DO_INSTALL=0
    echo "${NOTE} DRY RUN: install step will be skipped."
fi

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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprwayland-scanner.log"
MLOG="install-$(date +%d-%H%M%S)_hyprwayland-scanner2.log"

##
# Installation of dependencies
printf "\n%s - Installing hyprwayland-scanner dependencies.... \n" "${NOTE}"

for PKG1 in "${scan_depend[@]}"; do
  install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
    exit 1
  fi
done

printf "${NOTE} Installing hyprwayland-scanner...\n"  

# Clean previous clone
if [ -d "hyprwayland-scanner" ]; then
    printf "${NOTE} Removing existing hyprwayland-scanner folder...\n"
    rm -rf "hyprwayland-scanner"
fi

# Clone and build
printf "${NOTE} Installing hyprwayland-scanner $tag...\n"
if git clone --recursive -b "$tag" https://github.com/hyprwm/hyprwayland-scanner.git; then
    cd hyprwayland-scanner || exit 1
	cmake -DCMAKE_INSTALL_PREFIX=/usr -B build
	cmake --build build -j "$(nproc 2>/dev/null || getconf _NPROCESSORS_CONF)"
    if [ $DO_INSTALL -eq 1 ]; then
        if sudo cmake --install build 2>&1 | tee -a "$MLOG" ; then
            printf "${OK} hyprwayland-scanner installed successfully.\n" 2>&1 | tee -a "$MLOG"
        else
            echo -e "${ERROR} Installation failed for hyprwayland-scanner." 2>&1 | tee -a "$MLOG"
        fi
    else
        echo "${NOTE} DRY RUN: Skipping installation of hyprwayland-scanner $tag."
    fi
    [ -f "$MLOG" ] && mv "$MLOG" ../Install-Logs/ || true
    cd ..
else
    echo -e "${ERROR} Download failed for hyprwayland-scanner. Please check log." 2>&1 | tee -a "$LOG"
fi

printf "\n%.0s" {1..2}

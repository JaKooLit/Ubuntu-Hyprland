#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Hypr Ecosystem #
# hyprland-qt-support #

qt_support=(
    qt6-base-dev
    qt6-wayland
    qt6-declarative-dev
    qml6-module-qtcore
    qml6-module-qtquick-layouts
    qt6-tools-dev
    qt6-tools-dev-tools
    qt6-charts-dev
)

#specific branch or release
tag="v0.1.0"
# Allow environment override
if [ -n "${HYPRLAND_QT_SUPPORT_TAG:-}" ]; then tag="$HYPRLAND_QT_SUPPORT_TAG"; fi

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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprland-qt-support.log"
MLOG="install-$(date +%d-%H%M%S)_hyprland-qt-support2.log"

# Prefer locally built hyprlang/hyprutils in /usr/local
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:${PKG_CONFIG_PATH:-}"
export CMAKE_PREFIX_PATH="/usr/local:${CMAKE_PREFIX_PATH:-}"

# Installation of dependencies
printf "\n%s - Installing ${YELLOW}hyprland-qt-support dependencies${RESET} .... \n" "${INFO}"

for PKG1 in "${qt_support[@]}"; do
  re_install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - ${YELLOW}$PKG1${RESET} Package installation failed, Please check the installation logs"
    exit 1
  fi
done

printf "\n%.0s" {1..1}

# Check if hyprland-qt-support directory exists and remove it
if [ -d "hyprland-qt-support" ]; then
    rm -rf "hyprland-qt-support"
fi

# Clone and build 
printf "${INFO} Installing ${YELLOW}hyprland-qt-support $tag${RESET} ...\n"
if git clone --recursive -b "$tag" https://github.com/hyprwm/hyprland-qt-support.git; then
    cd hyprland-qt-support || exit 1
	cmake --no-warn-unused-cli \
	  -DCMAKE_BUILD_TYPE:STRING=Release \
	  -DCMAKE_INSTALL_PREFIX:PATH=/usr \
	  -DINSTALL_QMLDIR=/usr/lib/x86_64-linux-gnu/qt6/qml \
	  -S . -B ./build
	cmake --build ./build --config Release --target all -j"$(nproc 2>/dev/null || getconf NPROCESSORS_CONF)"
    if [ $DO_INSTALL -eq 1 ]; then
        if sudo cmake --install ./build 2>&1 | tee -a "$MLOG" ; then
            printf "${OK} ${MAGENTA}hyprland-qt-support $tag${RESET} installed successfully.\n" 2>&1 | tee -a "$MLOG"
        else
            echo -e "${ERROR} Installation failed for ${YELLOW}hyprland-qt-support $tag${RESET}" 2>&1 | tee -a "$MLOG"
        fi
    else
        echo "${NOTE} DRY RUN: Skipping installation of hyprland-qt-support $tag."
    fi
    [ -f "$MLOG" ] && mv "$MLOG" ../Install-Logs/ || true
    cd ..
else
    echo -e "${ERROR} Download failed for ${YELLOW}hyprland-qt-support $tag${RESET}" 2>&1 | tee -a "$LOG"
fi

printf "\n%.0s" {1..2}

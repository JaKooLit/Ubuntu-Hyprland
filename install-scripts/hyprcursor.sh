#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Hypr Ecosystem #
# hyprcursor #

cursor_deps=(
    libzip-dev
    librsvg2-dev
)

#specific branch or release
cursor_tag_default="v0.1.13"
cursor_tag="${HYPRCURSOR_TAG:-$cursor_tag_default}"

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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprcursor.log"
MLOG="install-$(date +%d-%H%M%S)_hyprcursor2.log"

# Installation of dependencies
printf "\n%s - Installing hyprcursor build dependencies.... \n" "${NOTE}"
for PKG1 in "${cursor_deps[@]}"; do
  install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 package installation failed. See logs."
    exit 1
  fi
done

# Clean src dir under shared build root
SRC_DIR="$SRC_ROOT/hyprcursor"
if [ -d "$SRC_DIR" ]; then
    printf "${NOTE} Removing existing hyprcursor folder...\n"
    rm -rf "$SRC_DIR"
fi

printf "${INFO} Installing ${YELLOW}hyprcursor $cursor_tag${RESET} ...\n"
if git clone --recursive -b "$cursor_tag" https://github.com/hyprwm/hyprcursor.git "$SRC_DIR"; then
    cd "$SRC_DIR" || exit 1
    BUILD_DIR="$BUILD_ROOT/hyprcursor"
    mkdir -p "$BUILD_DIR"
    cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr/local -S . -B "$BUILD_DIR"
    cmake --build "$BUILD_DIR" --config Release --target all -j"$(nproc 2>/dev/null || getconf _NPROCESSORS_CONF)"
    if [ $DO_INSTALL -eq 1 ]; then
        if sudo cmake --install "$BUILD_DIR" 2>&1 | tee -a "$MLOG" ; then
            sudo ldconfig 2>/dev/null || true
            printf "${OK} hyprcursor $cursor_tag installed successfully.\n" 2>&1 | tee -a "$MLOG"
        else
            echo -e "${ERROR} Installation failed for hyprcursor $cursor_tag." 2>&1 | tee -a "$MLOG"
        fi
    else
        echo "${NOTE} DRY RUN: Skipping installation of hyprcursor $cursor_tag."
    fi
    mv "$MLOG" "$PARENT_DIR/Install-Logs/" || true
    cd ..
else
    echo -e "${ERROR} Download failed for hyprcursor $cursor_tag." 2>&1 | tee -a "$LOG"
fi

printf "\n%.0s" {1..2}

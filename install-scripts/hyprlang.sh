#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# hyplang #


#specific branch or release
lang_tag_default="v0.6.8"
lang_tag="${HYPRLANG_TAG:-$lang_tag_default}"

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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprlang.log"
MLOG="install-$(date +%d-%H%M%S)_hyprlang2.log"

# Prefer locally built hyprutils in /usr/local
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:${PKG_CONFIG_PATH:-}"
export CMAKE_PREFIX_PATH="/usr/local:${CMAKE_PREFIX_PATH:-}"

# Installation of dependencies
printf "\n%s - Installing ${YELLOW}hyprlang dependencies${RESET} .... \n" "${INFO}"

# Check if hyprlang directory exists and remove it
if [ -d "hyprlang" ]; then
    rm -rf "hyprlang"
fi

# Clone and build 
printf "${INFO} Installing ${YELLOW}hyprlang $lang_tag${RESET} ...\n"
if git clone --recursive -b "$lang_tag" https://github.com/hyprwm/hyprlang.git; then
    cd hyprlang || exit 1
\tcmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr/local -S . -B ./build
    cmake --build ./build --config Release --target hyprlang -j"$(nproc 2>/dev/null || getconf _NPROCESSORS_CONF)"
    if [ $DO_INSTALL -eq 1 ]; then
        if sudo cmake --install ./build 2>&1 | tee -a "$MLOG" ; then
            sudo ldconfig 2>/dev/null || true
            printf "${OK} ${MAGENTA}hyprlang $lang_tag${RESET} installed successfully.\n" 2>&1 | tee -a "$MLOG"
        else
            echo -e "${ERROR} Installation failed for ${YELLOW}hyprlang $lang_tag${RESET}" 2>&1 | tee -a "$MLOG"
        fi
    else
        echo "${NOTE} DRY RUN: Skipping installation of hyprlang $lang_tag."
    fi
    #moving the addional logs to Install-Logs directory
    mv $MLOG ../Install-Logs/ || true 
    cd ..
else
    echo -e "${ERROR} Download failed for ${YELLOW}hyprlang $lang_tag${RESET}" 2>&1 | tee -a "$LOG"
fi

printf "\n%.0s" {1..2}
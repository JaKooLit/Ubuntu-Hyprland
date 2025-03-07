#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# hyprlock #

lock=(
	libpam0g-dev
	libgbm-dev
	libdrm-dev
    libmagic-dev
    libhyprlang-dev
    libhyprutils-dev
)

#specific branch or release
lock_tag="v0.4.0"

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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprlock.log"
MLOG="install-$(date +%d-%H%M%S)_hyprlock2.log"

# Installation of dependencies
printf "\n%s - Installing ${YELLOW}hyprlock dependencies${RESET} .... \n" "${INFO}"

for PKG1 in "${lock[@]}"; do
  re_install_package "$PKG1" "$LOG"
done

# Check if hyprlock folder exists and remove it
if [ -d "hyprlock" ]; then
    rm -rf "hyprlock"
fi

# Clone and build hyprlock
printf "${INFO} Installing ${YELLOW}hyprlock $lock_tag${RESET} ...\n"
if git clone --recursive -b $lock_tag https://github.com/hyprwm/hyprlock.git; then
    cd hyprlock || exit 1
	cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -S . -B ./build
	cmake --build ./build --config Release --target hyprlock -j`nproc 2>/dev/null || getconf _NPROCESSORS_CONF`
    if sudo cmake --install build 2>&1 | tee -a "$MLOG" ; then
        printf "${OK} ${YELLOW}hyprlock $lock_tag${RESET} installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
        echo -e "${ERROR} Installation failed for ${YELLOW}hyprlock $lock_tag${RESET}" 2>&1 | tee -a "$MLOG"
    fi
    #moving the addional logs to Install-Logs directory
    mv $MLOG ../Install-Logs/ || true 
    cd ..
else
    echo -e "${ERROR} Download failed for ${YELLOW}hyprlock $lock_tag${RESET}" 2>&1 | tee -a "$LOG"
fi

printf "\n%.0s" {1..2}


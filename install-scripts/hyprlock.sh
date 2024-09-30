#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# hyprlock #

lock=(
    libmagic-dev
)

#specific branch or release
lock_tag="v0.3.0"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprlock.log"
MLOG="install-$(date +%d-%H%M%S)_hyprlock2.log"

ADD_PATCHES=$1

# Installation of dependencies
printf "\n%s - Installing hyprlock dependencies.... \n" "${NOTE}"

for PKG1 in "${lock[@]}"; do
  install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
    exit 1
  fi
done

# Check if hyprlidle folder exists and remove it
if [ -d "hyprlock" ]; then
    printf "${NOTE} Removing existing hyprlock folder...\n"
    rm -rf "hyprlock"
fi

# Clone and build hyprlock
printf "${NOTE} Installing hyprlock...\n"
if git clone --recursive -b $lock_tag https://github.com/hyprwm/hyprlock.git; then
    cd hyprlock || exit 1
    if [ "$ADD_PATCHES" == "Y" ]; then
      patch -p1 < "$PARENT_DIR"/patch/hyprlock-v0.3.1.patch || exit 1
    fi
	cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -S . -B ./build
	cmake --build ./build --config Release --target hyprlock -j`nproc 2>/dev/null || getconf _NPROCESSORS_CONF`
    if sudo cmake --install build 2>&1 | tee -a "$MLOG" ; then
        printf "${OK} hyprlock installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
        echo -e "${ERROR} Installation failed for hyprlock." 2>&1 | tee -a "$MLOG"
    fi
    #moving the addional logs to Install-Logs directory
    mv $MLOG ../Install-Logs/ || true 
    cd ..
else
    echo -e "${ERROR} Download failed for hyprlock." 2>&1 | tee -a "$LOG"
fi

clear


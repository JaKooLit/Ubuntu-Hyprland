#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# hyprlang - hyprland and xdg-desktop-portal- dependencies #

#specific branch or release
lang_tag="v0.5.1"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprlang.log"
MLOG="install-$(date +%d-%H%M%S)_hyprlang2.log"

##
printf "${NOTE} Installing hyprlang...\n"  

# Check if hyprlang folder exists and remove it
if [ -d "hyprlang" ]; then
    printf "${NOTE} Removing existing hyprlang folder...\n"
    rm -rf "hyprlang"
fi

# Clone and build hyprlang
printf "${NOTE} Installing hyprlang...\n"
if git clone --recursive -b $lang_tag https://github.com/hyprwm/hyprlang.git; then
    cd hyprlang || exit 1
    cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
    cmake --build ./build --config Release --target hyprlang -j`nproc 2>/dev/null || getconf NPROCESSORS_CONF`
    if sudo cmake --install ./build 2>&1 | tee -a "$MLOG" ; then
        printf "${OK} hyprlang installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
        echo -e "${ERROR} Installation failed for hyprlang." 2>&1 | tee -a "$MLOG"
    fi
    #moving the addional logs to Install-Logs directory
    mv $MLOG ../Install-Logs/ || true 
    cd ..
else
    echo -e "${ERROR} Download failed for hyprlang." 2>&1 | tee -a "$LOG"
fi


clear


#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# hyprcursor #

cursor=(
  libzip-dev
  librsvg2-dev
)

#specific branch or release
cursor_tag="v0.1.8"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprcursor.log"
MLOG="install-$(date +%d-%H%M%S)_hyprcursor2.log"

# Installation of dependencies
printf "\n%s - Installing hyprcursor dependencies.... \n" "${NOTE}"

for PKG1 in "${cursor[@]}"; do
  install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
    exit 1
  fi
done

# Check if hyprcursor folder exists and remove it
if [ -d "hyprcursor" ]; then
    printf "${NOTE} Removing existing hyprcursor folder...\n"
    rm -rf "hyprcursor"
fi

# Clone and build 
printf "${NOTE} Installing hyprcursor...\n"
if git clone --recursive -b $cursor_tag https://github.com/hyprwm/hyprcursor.git; then
    cd hyprcursor || exit 1
		cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
		cmake --build ./build --config Release --target all -j`nproc 2>/dev/null || getconf NPROCESSORS_CONF`
    if sudo cmake --install ./build 2>&1 | tee -a "$MLOG" ; then
        printf "${OK} hyprcursor installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
        echo -e "${ERROR} Installation failed for hyprcursor." 2>&1 | tee -a "$MLOG"
    fi
    #moving the addional logs to Install-Logs directory
    mv $MLOG ../Install-Logs/ || true 
    cd ..
else
    echo -e "${ERROR} Download failed for hyprcursor." 2>&1 | tee -a "$LOG"
fi

clear



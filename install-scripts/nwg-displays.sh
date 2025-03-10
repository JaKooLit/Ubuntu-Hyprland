#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# nwg-displays ) #

# specific tags to download
nwg_dag="v0.3.22"

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
LOG="Install-Logs/install-$(date +'%d-%H%M%S')_nwg-display.log"
MLOG="install-$(date +'%d-%H%M%S')_nwg-display2.log"

printf "${NOTE} Compiling and Installing ${YELLOW}nwg-displays $nwg_dag${RESET} from source ...\n"

if [ -d "nwg-displays" ]; then
    rm -rf "nwg-displays"
fi

# Clone nwg-displays repository with the specified version
if git clone --recursive -b "$nwg_dag" --depth=1 https://github.com/nwg-piotr/nwg-displays.git; then
    cd nwg-displays || exit 1
    if sudo ./install.sh 2>&1 | tee -a "$MLOG"; then
        printf "${OK} ${MAGENTA}nwg-displays $nwg_dag${RESET} installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
        echo -e "${ERROR} Installation failed for ${YELLOW}nwg-displays $nwg_dag${RESET}" 2>&1 | tee -a "$MLOG"
    fi

    # Move logs to Install-Logs directory
    mv "$MLOG" ../Install-Logs/ || true
    cd ..
else
    echo -e "${ERROR} Failed to download ${YELLOW}nwg-displays $nwg_dag${RESET} Please check your connection" 2>&1 | tee -a "$LOG"
    mv "$MLOG" ../Install-Logs/ || true
    exit 1
fi

printf "\n%.0s" {1..2}

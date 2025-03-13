#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# nwg-look ) #

nwg_look=(
  golang
  libgtk-3-dev
  libcairo2-dev
  libglib2.0-bin
)

# specific tags to download
nwg_tag="v0.2.7"

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
LOG="Install-Logs/install-$(date +'%d-%H%M%S')_nwg-look.log"
MLOG="install-$(date +'%d-%H%M%S')_nwg-look2.log"

printf "${NOTE} Installing ${YELLOW}nwg-look $nwg_tag${RESET} dependencies ...\n"
# Installing NWG-Look Dependencies
for PKG1 in "${nwg_look[@]}"; do
  install_package "$PKG1" 2>&1 | tee -a "$LOG"
done

printf "\n%.0s" {1..1}

printf "${NOTE} Compiling and Installing ${YELLOW}nwg-look $nwg_tag${RESET} from source ...\n"
# Check if nwg-look directory exists and remove it
if [ -d "nwg-look" ]; then
    rm -rf "nwg-look"
fi

# Clone nwg-look repository with the specified tag
if git clone --recursive -b "$nwg_tag" --depth=1 https://github.com/nwg-piotr/nwg-look.git; then
    cd nwg-look || exit 1
    make build
    if sudo make install 2>&1 | tee -a "$MLOG"; then
        printf "${OK} ${MAGENTA}nwg-look $nwg_tag${RESET} installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
        echo -e "${ERROR} Installation failed for ${YELLOW}nwg-look $nwg_tag${RESET}" 2>&1 | tee -a "$MLOG"
    fi

    # Move logs to Install-Logs directory
    mv "$MLOG" ../Install-Logs/ || true
    cd ..
else
    echo -e "${ERROR} Failed to download ${YELLOW}nwg-look $nwg_tag${RESET} Please check your connection" 2>&1 | tee -a "$LOG"
    mv "$MLOG" ../Install-Logs/ || true
    exit 1
fi

printf "\n%.0s" {1..2}

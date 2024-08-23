#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# This is to be use for installing hyprland plugins
# Hyprland plugins: pyprland 

pypr_depend=( 
python3-aiofiles
python-is-python3
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hypr_eco.log"

# Pyprland
printf "${NOTE} Installing Pyprland Dependencies...\n"
 for PYPR in "${pypr_depend[@]}"; do
   install_package "$PYPR" 2>&1 | tee -a "$LOG"
   [ $? -ne 0 ] && { echo -e "\e[1A\e[K${ERROR} - $PYPR Package installation failed, Please check the installation logs"; exit 1; }
  done

  
# Check if the file exists and delete it
pypr="/usr/local/bin/pypr"
if [ -f "$pypr" ]; then
    sudo rm "$pypr"
fi

# Hyprland Plugins
# pyprland https://github.com/hyprland-community/pyprland installing using python
printf "${NOTE} Installing pyprland\n"

curl https://raw.githubusercontent.com/hyprland-community/pyprland/main/scripts/get-pypr | sh  2>&1 | tee -a "$LOG"

pip install pyprland --break-system-packages 2>&1 | tee -a "$LOG" 

clear

#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Cliphist install using go #

## This is to be be use for Ubuntu 23.10 only
# it is disabled by default. Enable it on install.sh #execute_script "cliphist.sh"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_cliphist.log"

# Install cliphist using go (for UBUNTU 23.10 users)
printf "\n%s - Installing cliphist using go.... \n" "${NOTE}"
export PATH=$PATH:/usr/local/bin
go install go.senan.xyz/cliphist@latest 2>&1 | tee -a "$LOG" 

# copy cliphist into /usr/local/bin for some reason it is installing in ~/go/bin
sudo cp -r "$HOME/go/bin/cliphist" "/usr/local/bin/" 2>&1 | tee -a "$LOG" 

clear

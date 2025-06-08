#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# SWWW - Wallpaper Utility #

# Check if 'swww' is installed
if command -v swww &>/dev/null; then
    SWWW_VERSION=$(swww -V | awk '{print $NF}')
    if [[ "$SWWW_VERSION" == "0.9.5" ]]; then
        echo -e "${OK} ${MAGENTA}swww v0.9.5${RESET} is already installed. Skipping installation."
        exit 0
    fi
else
    echo -e "${NOTE} ${MAGENTA}swww${RESET} is not installed. Proceeding with installation."
fi


swww=(
    liblz4-dev
)

# specific branch or release
swww_tag="v0.9.5"

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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_swww.log"
MLOG="install-$(date +%d-%H%M%S)_swww2.log"

# Installation of swww compilation needed
printf "\n%s - Installing ${SKY_BLUE}swww $swww_tag and dependencies${RESET} .... \n" "${NOTE}"

for PKG1 in "${swww[@]}"; do
    install_package "$PKG1" "$LOG"
done

printf "\n%.0s" {1..2}

# Check if swww directory exists
if [ -d "swww" ]; then
    cd swww || exit 1
    git pull origin main 2>&1 | tee -a "$MLOG"
else
    if git clone --recursive -b $swww_tag https://github.com/LGFae/swww.git; then
        cd swww || exit 1
    else
        echo -e "${ERROR} Download failed for ${YELLOW}swww $swww_tag${RESET}" 2>&1 | tee -a "$LOG"
        exit 1
    fi
fi

# Proceed with the rest of the installation steps
source "$HOME/.cargo/env" || true

cargo build --release 2>&1 | tee -a "$MLOG"

# Checking if swww is previously installed and delete before copying
file1="/usr/bin/swww"
file2="/usr/bin/swww-daemon"

# Check if file1 exists and delete if so
if [ -f "$file1" ]; then
    sudo rm -r "$file1"
fi

# Check if file2 exists and delete if so
if [ -f "$file2" ]; then
    sudo rm -r "$file2"
fi

# Copy binaries to /usr/bin/
sudo cp -r target/release/swww /usr/bin/ 2>&1 | tee -a "$MLOG" 
sudo cp -r target/release/swww-daemon /usr/bin/ 2>&1 | tee -a "$MLOG" 

# Copy bash completions
sudo mkdir -p /usr/share/bash-completion/completions 2>&1 | tee -a "$MLOG" 
sudo cp -r completions/swww.bash /usr/share/bash-completion/completions/swww 2>&1 | tee -a "$MLOG" 

# Copy zsh completions
sudo mkdir -p /usr/share/zsh/site-functions 2>&1 | tee -a "$MLOG" 
sudo cp -r completions/_swww /usr/share/zsh/site-functions/_swww 2>&1 | tee -a "$MLOG" 

# Moving logs into main Install-Logs
mv "$MLOG" ../Install-Logs/ || true 
cd - || exit 1

printf "\n%.0s" {1..2}

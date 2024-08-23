#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# SWWW - Wallpaper Utility #

swww=(
cargo
liblz4-dev
rustc
)

#specific branch or release
swww_tag="v0.9.5"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_swww2.log"
MLOG="install-$(date +%d-%H%M%S)_swww.log"

# Installation of swww compilation needed
printf "\n%s - Installing swww dependencies.... \n" "${NOTE}"

for PKG1 in "${swww[@]}"; do
  install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
    exit 1
  fi
done

printf "${NOTE} Force installing packages...\n"
 for FORCE in "${swww[@]}"; do
   sudo apt-get --reinstall install -y "$FORCE" 2>&1 | tee -a "$LOG"
   [ $? -ne 0 ] && { echo -e "\e[1A\e[K${ERROR} - $FORCE Package installation failed, Please check the installation logs"; exit 1; }
  done

printf "\n\n"

printf "${NOTE} Installing swww\n"

# Check if swww folder exists
if [ -d "swww" ]; then
  printf "${NOTE} swww folder exists. Pulling latest changes...\n"
  cd swww || exit 1
  git pull origin main 2>&1 | tee -a "$MLOG"
else
  printf "${NOTE} Cloning swww repository...\n"
  if git clone --recursive https://github.com/Horus645/swww.git; then
    cd swww || exit 1
  else
    echo -e "${ERROR} Download failed for swww" 2>&1 | tee -a "$LOG"
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

clear

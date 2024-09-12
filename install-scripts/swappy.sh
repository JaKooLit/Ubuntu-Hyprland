#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# swappy - for screenshot) #

swappy=(
  liblocale-msgfmt-perl
  gettext
  libgtk-3-dev
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_swappy.log"
MLOG="install-$(date +%d-%H%M%S)_swappy2.log"

printf "${NOTE} Installing swappy..\n"

for PKG1 in "${swappy[@]}"; do
  install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
    exit 1
  fi
done

# Force reinstall above as seems its giving issue as swappy cant be build
for PKG1 in "${swappy[@]}"; do
  sudo apt-get --reinstall install "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 Package re-installation failed, Please check the installation logs"
    exit 1
  fi
done

printf "${NOTE} Installing swappy from source...\n"  

# Check if folder exists and remove it
if [ -d "swappy" ]; then
    printf "${NOTE} deleting existing swappy folder...\n"
    rm -rf "swappy"
fi

# Clone and build swappy
printf "${NOTE} Installing swappy...\n"
if git clone --depth 1 https://github.com/jtheoof/swappy.git; then
    cd swappy || exit 1
	meson setup build
	ninja -C build
    if sudo ninja -C build install 2>&1 | tee -a "$MLOG" ; then
        printf "${OK} swappy installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
        echo -e "${ERROR} Installation failed for swappy." 2>&1 | tee -a "$MLOG"
    fi
    #moving the addional logs to Install-Logs directory
    mv $MLOG ../Install-Logs/ || true 
    cd ..
else
    echo -e "${ERROR} Download failed for swappy." 2>&1 | tee -a "$LOG"
fi

clear

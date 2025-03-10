#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# swappy - for screenshot) #

swappy=(
  liblocale-msgfmt-perl
  gettext
  libgtk-3-dev
)

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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_swappy.log"
MLOG="install-$(date +%d-%H%M%S)_swappy2.log"

printf "${NOTE} Installing ${SKY_BLUE}swappy dependencies${RESET} ..\n"

for PKG1 in "${swappy[@]}"; do
  re_install_package "$PKG1" "$LOG"
done

printf "${NOTE} Installing ${SKY_BLUE}swappy${RESET} from source...\n"  

# Check if folder exists and remove it
if [ -d "swappy" ]; then
    rm -rf "swappy"
fi

# Clone and build swappy
if git clone --depth=1 https://github.com/jtheoof/swappy.git; then
    cd swappy || exit 1
	meson setup build
	ninja -C build
    if sudo ninja -C build install 2>&1 | tee -a "$MLOG" ; then
        printf "${OK} ${MAGENTA}swappy${RESET} installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
        echo -e "${ERROR} Installation failed for ${YELLOW}swappy${RESET}" 2>&1 | tee -a "$MLOG"
    fi
    #moving the addional logs to Install-Logs directory
    mv $MLOG ../Install-Logs/ || true 
    cd ..
else
    echo -e "${ERROR} Download failed for ${YELLOW}swappy${RESET}" 2>&1 | tee -a "$LOG"
fi

printf "\n%.0s" {1..2}

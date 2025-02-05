#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Aylur's GTK Shell #

# Check if AGS is installed
if command -v ags &>/dev/null; then
    AGS_VERSION=$(ags -v | awk '{print $NF}') 
    if [[ "$AGS_VERSION" == "1.9.0" ]]; then
        echo -e "${OK} ${MAGENTA}Aylur's GTK Shell v1.9.0${RESET} is already installed. Skipping installation."
        exit 0
    fi
fi

ags=(
    node-typescript 
    npm 
    meson 
    libgjs-dev 
    gjs 
    libgtk-layer-shell-dev 
    libgtk-3-dev
    libpam0g-dev 
    libpulse-dev 
    libdbusmenu-gtk3-dev 
    libsoup-3.0-dev
)

f_ags=(
    npm
)

build_dep=(
    pam
)

# specific tags to download
ags_tag="v1.9.0"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_ags.log"
MLOG="install-$(date +%d-%H%M%S)_ags2.log"

# Installation of main components
printf "\n%s - Installing ${BLUE}Aylur's GTK shell $ags_tag${RESET} Dependencies \n" "${INFO}"

# Installing ags Dependencies
for PKG1 in "${ags[@]}"; do
  install_package "$PKG1" "$LOG"
done

for force_ags in "${f_ags[@]}"; do
   re_install_package "$force_ags" 2>&1 | tee -a "$LOG"
  done

printf "\n%.0s" {1..1}

for PKG1 in "${build_dep[@]}"; do
  build_dep "$PKG1" "$LOG"
done

#install typescript by npm
sudo npm install --global typescript 2>&1 | tee -a "$LOG"

# ags
printf "${INFO} Install and Compiling ${BLUE}Aylur's GTK shell $ags_tag${RESET} .. \n"

# Check if folder exists and remove it
if [ -d "ags" ]; then
    printf "${NOTE} Removing existing ags folder...\n"
    rm -rf "ags"
fi

# Clone nwg-look repository with the specified tag
if git clone --recursive -b "$ags_tag" --depth 1 https://github.com/Aylur/ags.git; then
    cd ags || exit 1
    # Build and install ags
	npm install
	meson setup build
    if sudo meson install -C build 2>&1 | tee -a "$MLOG"; then
        printf "${OK} ${YELLOW}Aylur's GTK shell $ags_tag${RESET} installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
        echo -e "${ERROR} Installation failed for ${YELLOW}Aylur's GTK shell $ags_tag${RESET}" 2>&1 | tee -a "$MLOG"
    fi

    # Move logs to Install-Logs directory
    mv "$MLOG" ../Install-Logs/ || true
    cd ..
else
    echo -e "${ERROR} Failed to download ${YELLOW}Aylur's GTK shell $ags_tag${RESET} . Please check your connection" 2>&1 | tee -a "$LOG"
    mv "$MLOG" ../Install-Logs/ || true
    exit 1
fi

printf "\n%.0s" {1..2}
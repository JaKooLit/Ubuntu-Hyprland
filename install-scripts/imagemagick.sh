#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# imagemagick from source #

depend=(
    build-essential
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_image.log"
MLOG="install-$(date +%d-%H%M%S)_image.log"

# Installing dependencies
for PKG1 in "${depend[@]}"; do
    install_package "$PKG1" 2>&1 | tee -a "$LOG"
    if [ $? -ne 0 ]; then
        echo -e "\033[1A\033[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
        exit 1
    fi
done

printf "${NOTE} Installing ImageMagick from source...\n"

# Check if folder exists and remove it
if [ -d "ImageMagick" ]; then
    printf "${NOTE} Removing existing ImageMagick folder...\n"
    rm -rf "ImageMagick"
fi

# Clone and build ImageMagick
printf "${NOTE} Installing ImageMagick...\n"
if git clone --depth 1 https://github.com/ImageMagick/ImageMagick.git; then
    cd ImageMagick || exit 1
    ./configure
    make
    if sudo make install 2>&1 | tee -a "$MLOG"; then
        sudo ldconfig /usr/local/lib
        printf "${OK} ImageMagick installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
        echo -e "${ERROR} Installation failed for ImageMagick." 2>&1 | tee -a "$MLOG"
    fi
    # Moving the additional logs to Install-Logs directory
    mv "$MLOG" ../Install-Logs/ || true
    cd ..
else
    echo -e "${ERROR} Download failed for ImageMagick." 2>&1 | tee -a "$LOG"
fi

clear

#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Rofi-Wayland) #

rofi=(
  bison
  flex
  pandoc
  doxygen
  cppcheck
  imagemagick
  libmpdclient-dev
  libnl-3-dev
  libasound2-dev
  libstartup-notification0-dev
  libwayland-client++1
  libwayland-dev
  libcairo-5c-dev
  libcairo2-dev
  libpango1.0-dev
  libgdk-pixbuf-2.0-dev
  libxcb-keysyms1-dev
  libwayland-client0
  libxcb-ewmh-dev
  libxcb-cursor-dev
  libxcb-icccm4-dev
  libxcb-randr0-dev
  libxcb-render-util0-dev
  libxcb-util-dev
  libxcb-xkb-dev
  libxcb-xinerama0-dev
  libxkbcommon-dev
  libxkbcommon-x11-dev
  ohcount
  wget
)

rofi_tag="1.7.8+wayland1"
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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_rofi_wayland.log"
MLOG="install-$(date +%d-%H%M%S)_rofi_wayland2.log"

# Installation of main components
printf "\n%s - Re-installing ${SKY_BLUE}rofi-wayland dependencies${RESET}.... \n" "${INFO}"

 for FORCE in "${rofi[@]}"; do
   re_install_package "$FORCE" "$LOG"
  done

printf "\n%.0s" {1..2}
# Clone and build rofi - wayland
printf "${NOTE} Installing ${SKY_BLUE}rofi-wayland${RESET}...\n"

# Check if rofi directory exists
if [ -d "rofi-$rofi_tag" ]; then
  rm -rf "rofi-$rofi_tag"
fi

# cloning rofi-wayland
printf "${NOTE} Downloading ${YELLOW}rofi-wayland $rofi_tag${RESET} from releases...\n"
wget https://github.com/lbonn/rofi/releases/download/1.7.8%2Bwayland1/rofi-1.7.8+wayland1.tar.gz

if [ -f "rofi-$rofi_tag.tar.gz" ]; then
  printf "${OK} ${YELLOW}rofi-wayland $rofi_tag${RESET} downloaded successfully.\n" 2>&1 | tee -a "$LOG"
  tar xf rofi-$rofi_tag.tar.gz
fi

cd rofi-$rofi_tag || exit 1

# Proceed with the installation steps
if meson setup build && ninja -C build ; then
  if sudo ninja -C build install 2>&1 | tee -a "$MLOG"; then
    printf "${OK} rofi-wayland installed successfully.\n" 2>&1 | tee -a "$MLOG"
  else
    echo -e "${ERROR} Installation failed for ${YELLOW}rofi-wayland $rofi_tag${RESET}" 2>&1 | tee -a "$MLOG"
  fi
else
  echo -e "${ERROR} Meson setup or ninja build failed for ${YELLOW}rofi-wayland $rofi_tag${RESET}" 2>&1 | tee -a "$MLOG"
fi

# Move logs to Install-Logs directory
mv "$MLOG" ../Install-Logs/ || true
cd .. || exit 1

# clean up
rm -rf rofi-$rofi_tag.tar.gz

printf "\n%.0s" {1..2}

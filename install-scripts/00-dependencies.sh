#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# main dependencies #

# packages neeeded
dependencies=(
  build-essential
  cmake
  cmake-extras
  curl
  findutils
  gawk
  gettext
  gir1.2-graphene-1.0
  git
  glslang-tools
  gobject-introspection
  golang
  hwdata
  jq
  libavcodec-dev
  libavformat-dev
  libavutil-dev
  libcairo2-dev
  libdeflate-dev
  libdisplay-info-dev
  libdrm-dev
  libegl-dev
  libegl1-mesa-dev
  libgbm-dev
  libgdk-pixbuf-2.0-dev
  libgdk-pixbuf2.0-bin
  libgirepository1.0-dev
  libgl1-mesa-dev
  libgraphene-1.0-0
  libgraphene-1.0-dev
  libgtk-3-dev
  libgulkan-dev
  libinih-dev
  libinput-dev
  libjbig-dev
  libjpeg-dev
  libjpeg62-dev
  liblerc-dev
  libliftoff-dev
  liblzma-dev
  libnotify-bin
  libpam0g-dev
  libpango1.0-dev
  libpipewire-0.3-dev
  libqt6svg6
  libseat-dev
  libstartup-notification0-dev
  libswresample-dev
  libsystemd-dev
  libtiff-dev
  libtiffxx6
  libtomlplusplus-dev
  libudev-dev
  libvkfft-dev
  libvulkan-dev
  libvulkan-volk-dev
  libwayland-dev
  libwebp-dev
  libxcb-composite0-dev
  libxcb-cursor-dev
  libxcb-dri3-dev
  libxcb-ewmh-dev
  libxcb-icccm4-dev
  libxcb-present-dev
  libxcb-render-util0-dev
  libxcb-res0-dev
  libxcb-util-dev
  libxcb-xinerama0-dev
  libxcb-xinput-dev
  libxcb-xkb-dev
  libxkbcommon-dev
  libxkbcommon-x11-dev
  libxkbregistry-dev
  libxml2-dev
  libxxhash-dev
  make
  meson
  ninja-build
  openssl
  psmisc
  python3-mako
  python3-markdown
  python3-markupsafe
  python3-yaml
  python3-pyquery
  qt6-base-dev
  scdoc
  seatd
  spirv-tools
  unzip
  vulkan-validationlayers
  wayland-protocols
  xdg-desktop-portal
  xwayland
  bc
)

build_dep=(
  wlroots
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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_dependencies.log"

# Installation of main dependencies
printf "\n%s - Installing ${SKY_BLUE}main dependencies....${RESET} \n" "${NOTE}"

for PKG1 in "${dependencies[@]}"; do
  install_package "$PKG1" "$LOG"
done

printf "\n%.0s" {1..1}

for PKG1 in "${build_dep[@]}"; do
  build_dep "$PKG1" "$LOG"
done

printf "\n%.0s" {1..2}

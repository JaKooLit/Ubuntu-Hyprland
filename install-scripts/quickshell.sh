#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Quickshell (QtQuick-based shell toolkit) - Ubuntu 26.04 builder

set -Eeuo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }

# Source the global functions script
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  echo "Failed to source Global_functions.sh"
  exit 1
fi

# Ensure logs dir exists at repo root (we cd into source later)
mkdir -p "$PARENT_DIR/Install-Logs"

LOG="$PARENT_DIR/Install-Logs/install-$(date +%d-%H%M%S)_quickshell.log"
MLOG="$PARENT_DIR/Install-Logs/install-$(date +%d-%H%M%S)_quickshell_build.log"

note() { echo -e "${NOTE} $*" | tee -a "$LOG"; }
info() { echo -e "${INFO} $*" | tee -a "$LOG"; }

# Build-time and runtime deps per upstream BUILD.md (Qt 6.6+)
# Many of these may already be present from 00-dependencies.sh; install_package is idempotent
DEPS=(
  cmake
  ninja-build
  pkg-config
  spirv-tools
  qt6-base-dev
  qt6-declarative-dev
  qt6-shadertools-dev
  qt6-tools-dev
  qt6-5compat-dev
  # Wayland + protocols
  libwayland-dev
  wayland-protocols
  # Screencopy/GBM/DRM
  libdrm-dev
  libgbm-dev
  # Optional integrations enabled by default
  libpipewire-0.3-dev
  libpam0g-dev
  libglib2.0-dev
  libpolkit-gobject-1-dev
  # X11 (optional but harmless)
  libxcb1-dev
  # SVG support recommended by upstream docs
  qt6-svg-dev
)

printf "\n%s - Installing ${SKY_BLUE}Quickshell build dependencies${RESET}....\n" "${NOTE}"
for PKG in "${DEPS[@]}"; do
  install_package "$PKG" 2>&1 | tee -a "$LOG"
done

# Ensure ninja is available (ninja-build provides /usr/bin/ninja)
if ! command -v ninja >/dev/null 2>&1; then
  install_package ninja-build 2>&1 | tee -a "$LOG"
fi

# Clone source (prefer upstream forgejo; mirror available at github:quickshell-mirror/quickshell)
SRC_DIR="quickshell-src"
if [ -d "$SRC_DIR" ]; then
  note "Removing existing $SRC_DIR"
  rm -rf "$SRC_DIR"
fi

note "Cloning Quickshell source..."
if git clone --depth=1 https://git.outfoxxed.me/quickshell/quickshell "$SRC_DIR" 2>&1 | tee -a "$LOG"; then
  cd "$SRC_DIR"
else
  echo "${ERROR} Failed to clone Quickshell repo" | tee -a "$LOG"
  exit 1
fi

# Configure with Ninja; enable RelWithDebInfo, leave features ON (deps installed above)
CMAKE_FLAGS=(
  -GNinja
  -B build
  -DCMAKE_BUILD_TYPE=RelWithDebInfo
  -DDISTRIBUTOR="Ubuntu-Hyprland installer"
)

note "Configuring Quickshell (CMake)..."
# Use explicit source/build dirs and preserve cmake exit code with pipefail
if ! cmake -S . -B build "${CMAKE_FLAGS[@]}" 2>&1 | tee -a "$MLOG"; then
  echo "${ERROR} CMake configure failed. See log: $MLOG" | tee -a "$LOG"
  exit 1
fi

# Ensure build files exist before invoking ninja
if [ ! -f build/build.ninja ]; then
  echo "${ERROR} build/build.ninja not generated; aborting build." | tee -a "$LOG"
  exit 1
fi

note "Building Quickshell (Ninja)..."
if ! cmake --build build 2>&1 | tee -a "$MLOG"; then
  echo "${ERROR} Build failed. See log: $MLOG" | tee -a "$LOG"
  exit 1
fi

note "Installing Quickshell..."
if ! sudo cmake --install build 2>&1 | tee -a "$MLOG"; then
  echo "${ERROR} Installation failed. See log: $MLOG" | tee -a "$LOG"
  exit 1
fi

echo "${OK} Quickshell installed successfully." | tee -a "$MLOG"

# Build logs already written to $PARENT_DIR/Install-Logs
# Keep source directory for reference in case user wants to rebuild later

printf "\n%.0s" {1..1}

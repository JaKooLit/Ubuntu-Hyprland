#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Quickshell (QtQuick-based shell toolkit) - Ubuntu 26.04 builder

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || {
    echo "${ERROR} Failed to change directory to $PARENT_DIR"
    exit 1
}

# Source the global functions script
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
    echo "Failed to source Global_functions.sh"
    exit 1
fi

# Prefer /usr/local for pkg-config and CMake (for locally built libs like Breakpad)
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:${PKG_CONFIG_PATH:-}"
export CMAKE_PREFIX_PATH="/usr/local:${CMAKE_PREFIX_PATH:-}"

# Ensure logs dir exists at repo root (we cd into source later)
mkdir -p "$PARENT_DIR/Install-Logs"

LOG="$PARENT_DIR/Install-Logs/install-$(date +%d-%H%M%S)_quickshell.log"
MLOG="$PARENT_DIR/Install-Logs/install-$(date +%d-%H%M%S)_quickshell_build.log"

# Refresh sudo credentials once (install_package uses sudo internally)
if command -v sudo >/dev/null 2>&1; then
    sudo -v 2>/dev/null || sudo -v
fi

note() { echo -e "${NOTE} $*" | tee -a "$LOG"; }
info() { echo -e "${INFO} $*" | tee -a "$LOG"; }

# Build-time and runtime deps per upstream BUILD.md (Qt 6.6+)
# Some may already be present from 00-dependencies.sh
DEPS=(
    build-essential
    git
    autoconf
    automake
    libtool
    zlib1g-dev
    libcurl4-openssl-dev
    cmake
    ninja-build
    pkg-config
    spirv-tools
    qt6-base-dev
    qt6-declarative-dev
    qt6-shadertools-dev
    qt6-tools-dev
    qt6-tools-dev-tools
    qt6-declarative-private-dev
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
    libpolkit-agent-1-dev
    libjemalloc-dev
    # X11 (optional but harmless)
    libxcb1-dev
    # SVG support (package name differs across releases; try both)
    qt6-svg-dev
    libqt6svg6-dev
    # Third-party libs used by Quickshell
    libcli11-dev
)

printf "\n%s - Installing ${SKY_BLUE}Quickshell build dependencies${RESET}....\n" "${NOTE}"
# Single apt transaction for speed and robustness
sudo apt update 2>&1 | tee -a "$LOG"
if ! sudo apt install -y "${DEPS[@]}" 2>&1 | tee -a "$LOG"; then
    echo "${ERROR} apt failed when installing Quickshell build dependencies." | tee -a "$LOG"
    exit 1
fi

# Validate critical tools
for bin in cmake ninja pkg-config; do
    if ! command -v "$bin" >/dev/null 2>&1; then
        echo "${ERROR} Required tool '$bin' not found after apt install." | tee -a "$LOG"
        exit 1
    fi
done

# Build Google Breakpad from source if pkg-config 'breakpad' is missing
if ! pkg-config --exists breakpad; then
  note "Building Google Breakpad from source..."
  BP_DIR="$PARENT_DIR/.thirdparty/breakpad"
  rm -rf "$BP_DIR"
  mkdir -p "$BP_DIR"
  (
    set -Eeuo pipefail
    cd "$BP_DIR"
    # Clone Breakpad into the root of BP_DIR (expected layout: ./src)
    git clone --depth=1 https://chromium.googlesource.com/breakpad/breakpad . 2>&1 | tee -a "$MLOG"
    # lss must live at src/third_party/lss relative to Breakpad root
    git clone --depth=1 https://chromium.googlesource.com/linux-syscall-support src/third_party/lss 2>&1 | tee -a "$MLOG" || true
    # Autotools bootstrap if needed (at Breakpad root)
    if [ ! -x ./configure ]; then
      autoreconf -fi 2>&1 | tee -a "$MLOG"
    fi
    ./configure --prefix=/usr/local 2>&1 | tee -a "$MLOG"
    make -j "$(nproc 2>/dev/null || getconf _NPROCESSORS_ONLN)" 2>&1 | tee -a "$MLOG"
    sudo make install 2>&1 | tee -a "$MLOG"
  ) || { echo "${ERROR} Breakpad build failed." | tee -a "$LOG"; exit 1; }

    # Provide pkg-config file if upstream didn't install one under the name 'breakpad'
    if ! pkg-config --exists breakpad; then
        if pkg-config --exists breakpad-client; then
            sudo mkdir -p /usr/local/lib/pkgconfig
            sudo ln -sf /usr/local/lib/pkgconfig/breakpad-client.pc /usr/local/lib/pkgconfig/breakpad.pc
        elif [ -f /usr/local/lib/libbreakpad_client.a ] || [ -f /usr/local/lib/libbreakpad_client.so ]; then
            TMP_PC="/tmp/breakpad.pc.$$"
            cat >"$TMP_PC" <<'PCEOF'
prefix=/usr/local
exec_prefix=${prefix}
includedir=${prefix}/include
libdir=${exec_prefix}/lib
Name: breakpad
Description: Google Breakpad client library
Version: 0
Libs: -L${libdir} -lbreakpad_client
Cflags: -I${includedir}
PCEOF
            sudo mkdir -p /usr/local/lib/pkgconfig
            sudo mv "$TMP_PC" /usr/local/lib/pkgconfig/breakpad.pc
        fi
    fi

    if ! pkg-config --exists breakpad; then
        echo "${ERROR} breakpad pkg-config entry not found after installation." | tee -a "$LOG"
        exit 1
    fi
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

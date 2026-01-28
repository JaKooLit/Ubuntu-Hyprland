#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Main Hyprland Package#
#
# Ensure our source-built libs take precedence
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:${PKG_CONFIG_PATH:-}"
export LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH:-}"
export LIBRARY_PATH="/usr/local/lib:${LIBRARY_PATH:-}"
export CMAKE_PREFIX_PATH="/usr/local:${CMAKE_PREFIX_PATH:-}"

#specific branch or release
# Default to v0.51.1, allow environment override via HYPRLAND_TAG
HYPRLAND_TAG_DEFAULT="v0.51.1"
tag="${HYPRLAND_TAG:-$HYPRLAND_TAG_DEFAULT}"

# Dry-run support
DO_INSTALL=1
if [ "${1:-}" = "--dry-run" ] || [ "${DRY_RUN:-0}" = "1" ] || [ "${DRY_RUN:-false}" = "true" ]; then
    DO_INSTALL=0
    echo "${NOTE} DRY RUN: install step will be skipped."
fi

# Additional build deps (Ubuntu)
hyprland_extra_deps=(
    clang
    llvm
    libxcb-errors-dev
    libre2-dev
    libudis86-dev
    libglaze-dev
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

# Source the global functions script
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
    echo "Failed to source Global_functions.sh"
    exit 1
fi

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprland.log"
MLOG="install-$(date +%d-%H%M%S)_hyprland2.log"

# Installation of additional dependencies (if available)
printf "\n%s - Installing hyprland additional dependencies.... \n" "${NOTE}"
for PKG1 in "${hyprland_extra_deps[@]}"; do
    install_package "$PKG1" 2>&1 | tee -a "$LOG"
    if [ $? -ne 0 ]; then
        echo -e "\e[1A\e[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
        exit 1
    fi
done

printf "\n%.0s" {1..1}

# Optional glaze install (only if asset exists)
printf "\n%s - Checking for optional glaze headers.... \n" "${NOTE}"
if [ ! -d /usr/include/glaze ]; then
    if [ -f assets/libglaze-dev_4.4.3-1_all.deb ]; then
        echo "${INFO} ${YELLOW}Glaze${RESET} not found. Installing ${YELLOW}glaze from assets${RESET} ..."
        sudo dpkg -i assets/libglaze-dev_4.4.3-1_all.deb 2>&1 | tee -a "$LOG" || true
        sudo apt-get install -f -y 2>&1 | tee -a "$LOG" || true
        echo "${INFO} ${YELLOW}libglaze-dev from assets${RESET} handled."
    else
        echo "${INFO} glaze headers not found and no asset present; proceeding without explicit glaze package."
    fi
fi

printf "\n%.0s" {1..1}

# Clone, build, and install Hyprland using CMake
printf "${NOTE} Cloning and Installing ${YELLOW}Hyprland $tag${RESET} ...\n"

# Check if Hyprland folder exists and remove it
if [ -d "Hyprland" ]; then
    printf "${NOTE} Removing existing Hyprland folder...\n"
    rm -rf "Hyprland" 2>&1 | tee -a "$LOG"
fi

if git clone --recursive -b "$tag" "https://github.com/hyprwm/Hyprland"; then
    cd "Hyprland" || exit 1

    # Apply optional patch if present and applicable
    if [ -f ../assets/0001-fix-hyprland-compile-issue.patch ]; then
        if patch -p1 --dry-run <../assets/0001-fix-hyprland-compile-issue.patch >/dev/null 2>&1; then
            patch -p1 <../assets/0001-fix-hyprland-compile-issue.patch
        else
            echo "${NOTE} Hyprland compile patch does not apply on $tag; skipping."
        fi
    fi

    # Default: use system hyprutils/hyprlang if available; allow override via USE_SYSTEM_HYPRLIBS
    USE_SYSTEM=${USE_SYSTEM_HYPRLIBS:-1}
    if [ "$USE_SYSTEM" = "1" ]; then
        export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:${PKG_CONFIG_PATH:-}"
        export CMAKE_PREFIX_PATH="/usr/local:${CMAKE_PREFIX_PATH:-}"
        SYSTEM_FLAGS=("-DUSE_SYSTEM_HYPRUTILS=ON" "-DUSE_SYSTEM_HYPRLANG=ON")
    else
        unset PKG_CONFIG_PATH || true
        SYSTEM_FLAGS=("-DUSE_SYSTEM_HYPRUTILS=OFF" "-DUSE_SYSTEM_HYPRLANG=OFF")
    fi

    # Ensure submodules exist when building bundled deps
    git submodule update --init --recursive || true

    # Use clang toolchain
    export CC="${CC:-clang}"
    export CXX="${CXX:-clang++}"
    CONFIG_FLAGS=(
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_C_COMPILER="${CC}"
        -DCMAKE_CXX_COMPILER="${CXX}"
        -DCMAKE_CXX_STANDARD=26
        -DCMAKE_CXX_STANDARD_REQUIRED=ON
        -DCMAKE_CXX_EXTENSIONS=ON
        "${SYSTEM_FLAGS[@]}"
    )
    cmake -S . -B build "${CONFIG_FLAGS[@]}"
    cmake --build build -j "$(nproc 2>/dev/null || getconf _NPROCESSORS_CONF)"

    if [ $DO_INSTALL -eq 1 ]; then
        if sudo cmake --install build 2>&1 | tee -a "$MLOG"; then
            printf "${OK} ${MAGENTA}Hyprland $tag${RESET} installed successfully.\n" 2>&1 | tee -a "$MLOG"
        else
            echo -e "${ERROR} Installation failed for ${YELLOW}Hyprland $tag${RESET}" 2>&1 | tee -a "$MLOG"
        fi
    else
        echo "${NOTE} DRY RUN: Skipping installation of Hyprland $tag."
    fi
    [ -f "$MLOG" ] && mv "$MLOG" ../Install-Logs/ || true
    cd ..
else
    echo -e "${ERROR} Download failed for ${YELLOW}Hyprland $tag${RESET}" 2>&1 | tee -a "$LOG"
fi

printf "\n%.0s" {1..2}

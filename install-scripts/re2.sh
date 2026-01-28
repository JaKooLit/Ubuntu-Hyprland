#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Build google/re2 from source so Hyprland links against the required features

RE2_TAG_DEFAULT="2025-11-05"
tag="${RE2_TAG:-$RE2_TAG_DEFAULT}"

# Dry-run support
DO_INSTALL=1
if [ "${1:-}" = "--dry-run" ] || [ "${DRY_RUN:-0}" = "1" ] || [ "${DRY_RUN:-false}" = "true" ]; then
    DO_INSTALL=0
    echo "${NOTE} DRY RUN: install step will be skipped."
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }

if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  echo "Failed to source Global_functions.sh"
  exit 1
fi

LOG="Install-Logs/install-$(date +%d-%H%M%S)_re2.log"
MLOG="install-$(date +%d-%H%M%S)_re2-build.log"

printf "${NOTE} Cloning and building ${YELLOW}re2 $tag${RESET} ...\n"

SRC_DIR="$SRC_ROOT/re2"
if [ -d "$SRC_DIR" ]; then
    rm -rf "$SRC_DIR"
fi

if git clone --depth=1 -b "$tag" https://github.com/google/re2.git "$SRC_DIR"; then
    BUILD_DIR="$BUILD_ROOT/re2"
    rm -rf "$BUILD_DIR"
    cmake -S "$SRC_DIR" -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DBUILD_SHARED_LIBS=ON 2>&1 | tee -a "$LOG"
    cmake --build "$BUILD_DIR" -j"$(nproc 2>/dev/null || getconf _NPROCESSORS_CONF)" 2>&1 | tee -a "$LOG"
    if [ $DO_INSTALL -eq 1 ]; then
        if sudo cmake --install "$BUILD_DIR" 2>&1 | tee -a "$MLOG"; then
            sudo ldconfig 2>/dev/null || true
            printf "${OK} re2 $tag installed successfully.\n" | tee -a "$MLOG"
            BACKUP_DIR="/usr/lib/x86_64-linux-gnu/hyprland-re2-backup"
            if [ ! -d "$BACKUP_DIR" ]; then
                echo "${INFO} Backing up distro libre2 artifacts to $BACKUP_DIR" | tee -a "$MLOG"
                sudo mkdir -p "$BACKUP_DIR"
                sudo cp -a /usr/lib/x86_64-linux-gnu/libre2.so* "$BACKUP_DIR"/ 2>/dev/null || true
            fi
            echo "${INFO} Replacing distro libre2 with source-built version" | tee -a "$MLOG"
            sudo cp -a /usr/local/lib/libre2.so* /usr/lib/x86_64-linux-gnu/ || true
            sudo ldconfig 2>/dev/null || true
        else
            echo -e "${ERROR} Installation failed for re2 $tag" | tee -a "$MLOG"
        fi
    else
        echo "${NOTE} DRY RUN: Skipping installation of re2 $tag."
    fi
    [ -f "$MLOG" ] && mv "$MLOG" Install-Logs/ || true
else
    echo -e "${ERROR} Failed to clone google/re2 repository." | tee -a "$LOG"
fi

printf "\n%.0s" {1..1}

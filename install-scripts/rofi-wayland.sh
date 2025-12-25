#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Install rofi (Wayland-capable) from Ubuntu repositories

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }

# Source the global functions script
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  echo "Failed to source Global_functions.sh"
  exit 1
fi

LOG="Install-Logs/install-$(date +%d-%H%M%S)_rofi.log"

printf "\n%s Installing ${SKY_BLUE}rofi${RESET} from Ubuntu repositories...\n" "${INFO}"

if apt-cache policy rofi | grep -q "Candidate: \\S"; then
  install_package rofi 2>&1 | tee -a "$LOG"
else
  echo "${WARN} 'rofi' package not found in apt; skipping." | tee -a "$LOG"
fi

printf "\n%.0s" {1..1}

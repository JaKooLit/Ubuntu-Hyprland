#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Hyprland-Dots to download a specific release #

# Define the specific release version to download
specific_version="v2.3.3-DebUntu"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

printf "${NOTE} Downloading / Checking for existing Hyprland-Dots-${specific_version}.tar.gz...\n"

# Check if the specific release tarball exists
if [ -f "Hyprland-Dots-${specific_version}.tar.gz" ]; then
  printf "${NOTE} Hyprland-Dots-${specific_version}.tar.gz found.\n"
  echo -e "${OK} Hyprland-Dots-${specific_version}.tar.gz is already downloaded."
  exit 0
fi

printf "${NOTE} Downloading the Hyprland-Dots-${specific_version} source code release...\n"

# Fetch the tag name for the specific release using the GitHub API
release_info=$(curl -s "https://api.github.com/repos/JaKooLit/Hyprland-Dots/releases/tags/${specific_version}")
if [ -z "$release_info" ]; then
  echo -e "${ERROR} Unable to fetch information for release ${specific_version}." 2>&1 | tee -a "../Install-Logs/install-$(date +'%d-%H%M%S')_dotfiles.log"
  exit 1
fi

# Get the tarball URL for the specific release
tarball_url=$(echo "$release_info" | grep "tarball_url" | cut -d '"' -f 4)

# Check if the URL is obtained successfully
if [ -z "$tarball_url" ]; then
  echo -e "${ERROR} Unable to fetch the tarball URL for release ${specific_version}." 2>&1 | tee -a "../Install-Logs/install-$(date +'%d-%H%M%S')_dotfiles.log"
  exit 1
fi

# Download the specific release source code tarball to the current directory
if curl -L "$tarball_url" -o "Hyprland-Dots-${specific_version}.tar.gz"; then
  # Extract the contents of the tarball
  tar -xzf "Hyprland-Dots-${specific_version}.tar.gz" || exit 1

  # Delete existing Hyprland-Dots
  rm -rf JaKooLit-Hyprland-Dots

  # Identify the extracted directory
  extracted_directory=$(tar -tf "Hyprland-Dots-${specific_version}.tar.gz" | grep -o '^[^/]\+' | uniq)

  # Rename the extracted directory to JaKooLit-Hyprland-Dots
  mv "$extracted_directory" JaKooLit-Hyprland-Dots || exit 1

  cd "JaKooLit-Hyprland-Dots" || exit 1

  # Set execute permission for copy.sh and execute it
  chmod +x copy.sh
  ./copy.sh 

  echo -e "${OK} Hyprland-Dots-${specific_version} release downloaded, extracted, and processed successfully. Check JaKooLit-Hyprland-Dots folder for more detailed install logs" 2>&1 | tee -a "../Install-Logs/install-$(date +'%d-%H%M%S')_dotfiles.log"
else
  echo -e "${ERROR} Failed to download Hyprland-Dots-${specific_version} release." 2>&1 | tee -a "../Install-Logs/install-$(date +'%d-%H%M%S')_dotfiles.log"
  exit 1
fi

clear

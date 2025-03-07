#!/bin/bash
# https://github.com/JaKooLit

Distro="Ubuntu-Hyprland"
Github_URL="https://github.com/JaKooLit/$Distro.git"
Github_URL_Branch="25.04"
Distro_DIR="$HOME/$Distro-$Github_URL_Branch"

printf "\n%.0s" {1..1}

if ! command -v git &> /dev/null
then
    sudo apt update && sudo apt install -y git
fi

printf "\n%.0s" {1..1}

if [ -d "$Distro_DIR" ]; then
    cd "$Distro_DIR"
    git stash && git pull
    chmod +x install.sh
    if [ -f "install.sh" ]; then
        ./install.sh
    else
        echo "install.sh not found in $Distro_DIR. Exiting."
        exit 1
    fi
else
    git clone --depth=1 -b "$Github_URL_Branch" "$Github_URL" "$Distro_DIR"
    cd "$Distro_DIR"
    chmod +x install.sh
    if [ -f "install.sh" ]; then
        ./install.sh
    else
        echo "install.sh not found in $Distro_DIR. Exiting."
        exit 1
    fi
fi

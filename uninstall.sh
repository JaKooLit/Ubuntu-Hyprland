#!/bin/bash

# Greet the user
echo "Ubuntu-Hyprland Uninstall program for 24.10"
echo "-----------------------"
# YOU! YES YOU! EDIT THE 'packages' VARIABLE SO THAT YOU DON'T MESS YOUR SYSTEM BY REMOVING THE WRONG ONE!
## Note: ALL THESE PACKAGES ARE INSTALLED BY THE SCRIPT. THIS IS TESTED ON A FRESTLY INSTALLED UBUNUTO DISTRO.
### DO NOT USE IT ON A DIFFERENT DISTRO WITHOUT BEING SURE WHICH PACKAGES YOU ARE USING.

# List of packages to remove
# Important Non-Core Packages excluded are : Curl, zsh, file-roller, pavucontrol, zsh-common
# Script tested on Ubunuto 24.10
allow_remove_packages=0
allow_remove_wallpapers=0 
packages=(
    "bison"
    "blueman"
    "brightnessctl"
    "cava"
    "cliphist"
    "cppcheck"
    "doxygen"
    "exo-utils"
    "fastfetch"
    "fonts-font-awesome"
    "fonts-firacode"
    "gawk"
    "grim"
    "golang"
    "hyprcursor-util"
    "hyprland"
    "hyprland-protocols"
    "hyprwayland-scanner"
    "inxi"
    "kitty"
    "libatk-bridge2.0-dev"
    "libatk1.0-dev"
    "libatspi2.0-dev"
    "libasound2-dev"
    "libdatrie-dev"
    "libdbus-1-dev"
    "libdbusmenu-glib-dev"
    "libdbusmenu-gtk3-dev"
    "libepoxy-dev"
    "libffmpegthumbnailer4v5"
    "libgdk-pixbuf-2.0-dev"
    "libgbm-dev"
    "libgjs-dev"
    "libgraphite2-dev"
    "libgtk-3-dev"
    "libgtk-layer-shell-dev"
    "libharfbuzz-cairo0"
    "libharfbuzz-dev"
    "libhyprcursor-dev"
    "libhyprlang-dev"
    "libhyprutils-dev"
    "libjpeg-dev"
    "libjpeg-turbo8-dev"
    "libjpeg8-dev"
    "libjbig-dev"
    "libmagic-dev"
    "libmpdclient-dev"
    "libnl-3-dev"
    "libnghttp2-dev"
    "libnvidia-vaapi-driver"
    "libpipewire-0.3-dev"
    "libpsl-dev"
    "libpulse-dev"
    "libpango1.0-dev"
    "libpango1.0-tools"
    "libsharpyuv-dev"
    "libspa-0.2-dev"
    "libsqlite3-dev"
    "libsystemd-dev"
    "libthai-dev"
    "libtiff-dev"
    "libtiffxx6"
    "libubis86-0"
    "libvulkan-validationlayers"
    "libvulkan-utility-libraries-dev"
    "libwayland-bin"
    "libwayland-dev"
    "libwebp-dev"
    "libwebpdecoder3"
    "libxfce4panel-2.0-4"
    "libxfce4ui-2-0"
    "libxfce4ui-common"
    "libxfce4util-bin"
    "libxfce4util-common"
    "libxfce4util7"
    "libxfce4windowing-0-0"
    "libxfce4windowing-common"
    "libxinerama-dev"
    "libxkbcommon-dev"
    "libxkbcommon-x11-dev"
    "libxcomposite-dev"
    "libxcursor-dev"
    "libxdamage-dev"
    "libxfixes-dev"
    "libxi-dev"
    "libxinerama-dev"
    "libxft-dev"
    "libxrandr-dev"
    "libxtst-dev"
    "libzstd-dev"
    "mousepad"
    "mpv"
    "mpv-mpris"
    "nwg-look"
    "nvtop"
    "playerctl"
    "polkit-kde-agent-1"
    "python3-gi-cairo"
    "python3-mako"
    "python3-pyquery"
    "qt5-style-kvantum"
    "qt5ct"
    "qt6-base-dev"
    "qt6ct"
    "qalculate-gtk"
    "sway-notification-center"
    "swappy"
    "thunar"
    "thunar-archive-plugin"
    "thunar-data"
    "thunar-volman"
    "tumbler"
    "tumbler-common"
    "vulkan-validationlayers"
    "vulkan-utility-libraries-dev"
    "waybar"
    "wayland-protocols"
    "wlogout"
    "xarchiver"
    "xfconf"
    "yad"
    "zplug"
)

function list_packages() {
    # List all selected packages
    for package in "${packages[@]}"; do
        echo "$package"
    done

    echo "-----------------------"
    echo "* The following packages listed above will be uninstalled."
    echo "* If you don't want a specific package to be uninstalled, find uninstall.sh and edit 'packages' variable"
    echo "-----------------------"
}

# Getting all user response once rather than waiting for process to end.
function get_user_response() {
    
    # Remove Packages?
    list_packages
    while true; do
        read -p "Do you wish to remove all non-core packages? (Yy/Nn): " yn
        case $yn in
            [Yy]* ) allow_remove_packages=1; break;;
            [Nn]* ) break;;
            * ) echo "Invalid Command. Please type either yes(y) or no(n)"
                echo; continue;;
        esac
    done

    # Remove Wallpapers?
    while true; do
        read -p "Do you wish to remove all downloadeded wallpapers? (Yy/Nn): " yn
        case $yn in
            [Yy]* ) allow_remove_wallpapers=1; break;;
            [Nn]* ) break;;
            * ) echo "Invalid Command. Please type either yes(y) or no(n)"
                echo; continue;;
        esac
    done
}

# Function to check if a package is installed
function is_package_installed() {
    dpkg -l | grep "^ii" | grep "$1" > /dev/null
    if [ $? -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

# Loop through the packages and remove them
function remove_package() {
	for package in "${packages[@]}"; do
		if is_package_installed "$package"; then
			echo "Removing $package..."
			sudo apt remove "$package" -y
		else
			echo "$package is not installed."
		fi
	done
}

function main() {
    # Update Variables
    get_user_response

    # Remove package
    if [ $allow_remove_packages -eq 1 ]; then
        remove_package
    fi

    # Remove wallpapers
    if [ $allow_remove_wallpapers -eq 1 ]; then
        if [[ -d ~/Pictures/wallpapers ]]; then
            echo "Performing a 'sudo rm -r' command. Auth required."
            sudo rm -r ~/Pictures/wallpapers;
        else
            echo "Directory Not Found. Skipping Wallpaper Deletion"
        fi
    fi
}

main

# TO DO: Remove pokemon-colorscripts by either accessing its directory from Ubuntu-Hyprland or doing it manually
# TO DO: Give users the purge option. Once selected, it will remove all config files related to packages.
# TO DO: Remove Hypridle, Rofi, swwww etc. from system 

# Remainder to User for after actions
echo "-----------------------"
if [ $allow_remove_packages -eq 1 ] || [ $allow_remove_wallpapers -eq 1 ]; then
    echo "Uninstaller work is completed. Please run 'sudo apt autoremove' to get rid of leftovers"
else
    echo "Uninstall work aborted."
fi

echo "pokemon-colorscripts, rofi, hypridle, swww etc. are not removed yet. You can remove pokemon-colorscripts via your cloned Ubuntu-Hyprland directory."


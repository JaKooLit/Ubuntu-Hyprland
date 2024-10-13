#!/bin/bash

# Opening prints
echo "Ubuntu-Hyprland Uninstall program for 24.10"

# YOU! YES YOU! EDIT THIS VARIABLE SO THAT YOU DON'T MESS YOUR SYSTEM BY REMOVING THE WRONG ONE!
# Note: ALL THESE PACKAGES ARE INSTALLED BY THE SCRIPT. THIS IS TESTED ON A FRESTLY INSTALLED UBUNUTO DISTRO.
# DO NOT USE IT ON A DIFFERENT DISTRO WITHOUT BEING SURE WHICH PACKAGES YOU ARE USING.

# List of packages to remove
# Important Non-Core Packages excluded are : Curl, zsh, file-roller, pavucontrol, zsh-common
# Script tested on Ubunuto 24.10

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

# List all selected packages
echo "The following packages will be uninstalled."
echo "If you don't want a specific package to be uninstalled, edit uninstaller.sh and edit 'packages' variable"
echp "Wallpapers are not going to be uninstalled."
echo "--------------"
for package in "${packages[@]}"; do
	echo "$package"
done

echo "--------------"


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
function runtime() {
	for package in "${packages[@]}"; do
		if is_package_installed "$package"; then
			echo "Removing $package..."
			sudo apt remove "$package" -y
		else
			echo "$package is not installed."
		fi
	done
}

# Ask for Prompt
while true; do
	read -p "Do you wish to excuete? (Yy/Nn): " yn
	case $yn in
		[Yy]* ) runtime; break;;
		[Nn]* ) exit;;
		* ) echo "Invalid Command. Please type either yes(y) or no(n)"
			echo; continue;;
	esac
done

# Remainder to User for after actions
echo
echo "Uninstaller work is completed. Please run 'sudo apt autoremove' to get rid of leftovers"

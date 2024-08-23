#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Nvidia - Check Readme for more details for the drivers #
# UBUNTU USERS, FOLLOW README!

nvidia_pkg=(
    libva-wayland2
    libnvidia-egl-wayland1
    nvidia-vaapi-driver
)

# for ubuntu-nvidia owners! just delete #
sudo ubuntu-drivers install

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_nvidia.log"
MLOG="install-$(date +%d-%H%M%S)_nvidia2.log"

# Function to add a value to a configuration file if not present
add_to_file() {
    local config_file="$1"
    local value="$2"
    
    if ! sudo grep -q "$value" "$config_file"; then
        echo "Adding $value to $config_file"
        sudo sh -c "echo '$value' >> '$config_file'"
    else
        echo "$value is already present in $config_file."
    fi
}

# Install additional Nvidia packages
printf "${YELLOW} Installing Nvidia packages...\n"
for NVIDIA in "${nvidia_pkg[@]}"; do
    install_package "$NVIDIA" 2>&1 | tee -a "$LOG"
done

printf "${YELLOW} nvidia-stuff to /etc/default/grub...\n"

# Additional options to add to GRUB_CMDLINE_LINUX
additional_options="rd.driver.blacklist=nouveau modprobe.blacklist=nouveau nvidia-drm.modeset=1 rcutree.rcu_idle_gp_delay=1"

# Check if additional options are already present in GRUB_CMDLINE_LINUX
if grep -q "GRUB_CMDLINE_LINUX.*$additional_options" /etc/default/grub; then
    echo "GRUB_CMDLINE_LINUX already contains the additional options"
else
    # Append the additional options to GRUB_CMDLINE_LINUX
    sudo sed -i "s/GRUB_CMDLINE_LINUX=\"/GRUB_CMDLINE_LINUX=\"$additional_options /" /etc/default/grub
    echo "Added the additional options to GRUB_CMDLINE_LINUX"
fi

# Update GRUB configuration
sudo update-grub 2>&1 | tee -a "$LOG"

# Define the configuration file and the line to add
config_file="/etc/modprobe.d/nvidia.conf"
line_to_add="""
options nvidia-drm modeset=1 fbdev=1
options nvidia NVreg_PreserveVideoMemoryAllocations=1
"""

# Check if the config file exists
if [ ! -e "$config_file" ]; then
    echo "Creating $config_file"
    sudo touch "$config_file" 2>&1 | tee -a "$LOG"
fi

add_to_file "$config_file" "$line_to_add"

# Add NVIDIA modules to initramfs configuration
modules_to_add="nvidia nvidia_modeset nvidia_uvm nvidia_drm"
modules_file="/etc/initramfs-tools/modules"

if [ -e "$modules_file" ]; then
    add_to_file "$modules_file" "$modules_to_add" 2>&1 | tee -a "$LOG"
    sudo update-initramfs -u 2>&1 | tee -a "$LOG"
else
    echo "Modules file ($modules_file) not found." 2>&1 | tee -a "$LOG"
fi

clear

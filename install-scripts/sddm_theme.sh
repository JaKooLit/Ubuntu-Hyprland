#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# SDDM themes for ubuntu 24.04 #

printf "\n%s - Installing ${SKY_BLUE}Simple SDDM Theme${RESET}\n" "${NOTE}"

# Set the theme variable
theme="simple-sddm"

# Check if /usr/share/sddm/themes/$theme exists and remove if it does
if [ -d "/usr/share/sddm/themes/$theme" ]; then
  sudo rm -rf "/usr/share/sddm/themes/$theme"
  echo -e "\e[1A\e[K${OK} - Removed existing '$theme' directory." 2>&1 | tee -a "$LOG"
fi

# Check if $theme directory exists in the current directory and remove if it does
if [ -d "$theme" ]; then
  rm -rf "$theme"
  echo -e "\e[1A\e[K${OK} - Removed existing '$theme' directory from the current location." 2>&1 | tee -a "$LOG"
fi

# Clone the repository if it's not already cloned
if git clone https://github.com/JaKooLit/simple-sddm.git; then
  # Wait until the directory is fully cloned
  while [ ! -d "$theme" ]; do
    sleep 1
  done

  # Ensure /usr/share/sddm/themes exists
  if [ ! -d "/usr/share/sddm/themes" ]; then
    sudo mkdir -p /usr/share/sddm/themes
    echo -e "\e[1A\e[K${OK} - Directory '/usr/share/sddm/themes' created." 2>&1 | tee -a "$LOG"
  fi

  # Move the cloned theme to /usr/share/sddm/themes
  sudo mv "$theme" /usr/share/sddm/themes/

  # Set up new theme
  echo -e "${NOTE} Setting up the login screen."

  # Define sddm config directory
  sddm_conf_dir="/etc/sddm.conf.d"
  
  # Ensure the sddm config directory exists
  if [ ! -d "$sddm_conf_dir" ]; then
    echo -e "$CAT - $sddm_conf_dir not found, creating..." | tee -a "$LOG"
    sudo mkdir -p "$sddm_conf_dir" 2>&1 | tee -a "$LOG"
  fi

  # Write to theme.conf.user
  echo -e "[Theme]\nCurrent=$theme" | sudo tee "$sddm_conf_dir/theme.conf.user" > /dev/null

  # Check if the file exists and is not empty, otherwise write the default content
  if [ -f "$sddm_conf_dir/theme.conf.user" ]; then
    # If the file is empty, write the default content
    if [ ! -s "$sddm_conf_dir/theme.conf.user" ]; then
      echo -e "[Theme]\nCurrent=$theme" | sudo tee "$sddm_conf_dir/theme.conf.user" > /dev/null
      echo -e "${OK} - $sddm_conf_dir/theme.conf.user was empty, so default content has been written." | tee -a "$LOG"
    else
      # File exists and is not empty, check if it contains the correct content
      if grep -q "^[[:space:]]*Current=$theme" "$sddm_conf_dir/theme.conf.user"; then
        echo -e "${OK} - $sddm_conf_dir/theme.conf.user already contains the correct content." | tee -a "$LOG"
      else
        echo -e "${ERROR} - $sddm_conf_dir/theme.conf.user exists but does not contain the expected content." | tee -a "$LOG"
      fi
    fi
  else
    echo -e "${ERROR} - $sddm_conf_dir/theme.conf.user does not exist." | tee -a "$LOG"
  fi
else
  echo -e "\e[1A\e[K${ERROR} - Failed to clone the theme repository. Please check your internet connection or repository availability." | tee -a "$LOG" >&2
fi

printf "\n%.0s" {1..2}
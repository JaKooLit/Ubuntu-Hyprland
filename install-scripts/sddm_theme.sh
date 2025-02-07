#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# SDDM themes for ubuntu 24.04 #

printf "\n%s - Installing ${SKY_BLUE}Simple SDDM Theme${RESET}\n" "${NOTE}"

# Check if /usr/share/sddm/themes/simple-sddm exists and remove if it does
if [ -d "/usr/share/sddm/themes/simple-sddm" ]; then
  sudo rm -rf "/usr/share/sddm/themes/simple-sddm"
  echo -e "\e[1A\e[K${OK} - Removed existing 'simple-sddm' directory." 2>&1 | tee -a "$LOG"
fi

# Check if simple-sddm directory exists in the current directory and remove if it does
if [ -d "simple-sddm" ]; then
  rm -rf "simple-sddm"
  echo -e "\e[1A\e[K${OK} - Removed existing 'simple-sddm' directory from the current location." 2>&1 | tee -a "$LOG"
fi

if git clone https://github.com/JaKooLit/simple-sddm.git; then
  while [ ! -d "simple-sddm" ]; do
    sleep 1
  done


  if [ ! -d "/usr/share/sddm/themes" ]; then
    sudo mkdir -p /usr/share/sddm/themes
    echo -e "\e[1A\e[K${OK} - Directory '/usr/share/sddm/themes' created." 2>&1 | tee -a "$LOG"
  fi

  sudo mv simple-sddm /usr/share/sddm/themes/

  # Set up new theme
  echo -e "${NOTE} Setting up the login screen."
  sddm_conf_dir=/etc/sddm.conf.d
  [ ! -d "$sddm_conf_dir" ] && { printf "$CAT - $sddm_conf_dir not found, creating...\n"; sudo mkdir -p "$sddm_conf_dir" 2>&1 | tee -a "$LOG"; }
  
  echo -e "[Theme]\nCurrent=simple-sddm" | sudo tee "$sddm_conf_dir/theme.conf.user" &>> "$LOG"
else
  echo -e "\e[1A\e[K${ERROR} - Failed to clone the theme repository. Please check your internet connection or repository availability." | tee -a "$LOG" >&2
fi
          		

printf "\n%.0s" {1..2}
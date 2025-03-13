<div align="center">

# 💌 KooL's Ubuntu Hyprland Install Script 💌
## For Ubuntu 24.04 Noble Numbat

<p align="center">
  <img src="https://raw.githubusercontent.com/JaKooLit/Hyprland-Dots/main/assets/latte.png" width="400" />
</p>

![GitHub Repo stars](https://img.shields.io/github/stars/JaKooLit/Ubuntu-Hyprland?style=for-the-badge&color=cba6f7) ![GitHub last commit](https://img.shields.io/github/last-commit/JaKooLit/Ubuntu-Hyprland?style=for-the-badge&color=b4befe) ![GitHub repo size](https://img.shields.io/github/repo-size/JaKooLit/Ubuntu-Hyprland?style=for-the-badge&color=cba6f7) <a href="https://discord.gg/kool-tech-world"> <img src="https://img.shields.io/discord/1151869464405606400?style=for-the-badge&logo=discord&color=cba6f7&link=https%3A%2F%2Fdiscord.gg%kool-tech-world"> </a>

<br/>
</div>

<div align="center">
<br> 
  <a href="#-announcement-"><kbd> <br> Read this First <br> </kbd></a>&ensp;&ensp;
  <a href="#-to-use-this-script"><kbd> <br> How to Use this Script <br> </kbd></a>&ensp;&ensp;
  <a href="#gallery-and-videos"><kbd> <br> Gallery <br> </kbd></a>&ensp;&ensp;
 </div><br>


> [!NOTE]
> Ubuntu 24.04 LTS specific
- Latest Hyprland version that is compatible with Ubuntu 24.04 is Hyprland v0.39.1. Reason is that some dependencies are old so newer Hyprland wont build on it. 
- This is the reason why I have to set a specific release version on Hyprland packages including its eco-system and pre-configured DOTS as it is most likely wayland protocol wont be updated since its an LTS version.

<p align="center">
  <img src="https://raw.githubusercontent.com/JaKooLit/Hyprland-Dots/main/assets/latte.png" width="200" />
</p>

<div align="center">
👇 KOOL's Hyprland-Dots related Links 👇
<br/>
</div>
<div align="center">
<br>
  <a href="https://github.com/JaKooLit/Hyprland-Dots/tree/Ubuntu-24.04-Dots"><kbd> <br> Hyprland-Dots Ubuntu 24.04 repo <br> </kbd></a>&ensp;&ensp;
  <a href="https://www.youtube.com/playlist?list=PLDtGd5Fw5_GjXCznR0BzCJJDIQSZJRbxx"><kbd> <br> Youtube <br> </kbd></a>&ensp;&ensp;
  <a href="https://github.com/JaKooLit/Hyprland-Dots/wiki"><kbd> <br> Wiki <br> </kbd></a>&ensp;&ensp;
  <a href="https://github.com/JaKooLit/Hyprland-Dots/wiki/Keybinds"><kbd> <br> Keybinds <br> </kbd></a>&ensp;&ensp;
  <a href="https://github.com/JaKooLit/Hyprland-Dots/wiki/FAQ"><kbd> <br> FAQ <br> </kbd></a>&ensp;&ensp;
  <a href="https://discord.gg/kool-tech-world"><kbd> <br> Discord <br> </kbd></a>
</div><br>

<p align="center">
  <img src="https://raw.githubusercontent.com/JaKooLit/Hyprland-Dots/main/assets/latte.png" width="200" />
</p>

<h3 align="center">
	<img src="https://github.com/JaKooLit/Telegram-Animated-Emojis/blob/main/Activity/Sparkles.webp" alt="Sparkles" width="38" height="38" />
	KooL Hyprland-Dotfiles Showcase 
	<img src="https://github.com/JaKooLit/Telegram-Animated-Emojis/blob/main/Activity/Sparkles.webp" alt="Sparkles" width="38" height="38" />
</h3>

<div align="center">

https://github.com/user-attachments/assets/49bc12b2-abaf-45de-a21c-67aacd9bb872

</div>

> [!IMPORTANT]
> install a backup tool like `snapper` or `timeshift`. and Backup your system before installing hyprland using this script (HIGHLY RECOMMENDED).

> [!CAUTION]
> Download this script on a directory where you have write permissions. ie. HOME. Or any directory within your home directory. Else script will fail

#### ⚠️ Pre-requisites and VERY Important! ### 
- Do not run this installer as sudo or as root
- This Installer requires a user with a priviledge to install packages
- This is only 24.04 LTS Noble Numbat. Check [`MAIN BRANCH`](https://github.com/JaKooLit/Ubuntu-Hyprland/tree/main) for other Ubuntu Versions 

### Gallery and Videos
#### 🎥 Feb 2025 Video explanation of installation with preset
- [YOUTUBE-LINK](https://youtu.be/wQ70lo7P6vA?si=_QcbrNKh_Bg0L3wC)
- [YOUTUBE-Hyprland-Playlist](https://youtube.com/playlist?list=PLDtGd5Fw5_GjXCznR0BzCJJDIQSZJRbxx&si=iaNjLulFdsZ6AV-t)

### 🪧🪧🪧 ANNOUNCEMENT 🪧🪧🪧
- This Repo does not contain Hyprland Dots or configs! Dotfiles can be checked here [`Hyprland-Dots`](https://github.com/JaKooLit/Hyprland-Dots/tree/Ubuntu-24.04-Dots) . During installation, if you opt to copy pre-configured dots, it will be downloaded from that centralized repo.
- For Ubuntu 24.04, specific Hyprland-dots that are guaranted to work is [`LINK`](https://github.com/JaKooLit/Hyprland-Dots/tree/Ubuntu-24.04-Dots) . This is also the dots which will be set to installed on this script.
- Newer dots may not work properly.
- Hyprland-Dots use are constantly evolving / improving. you can check CHANGELOGS here [`Hyprland-Dots-Changelogs`](https://github.com/JaKooLit/Hyprland-Dots/wiki/Changelogs)
- Since the Hyprland-Dots are evolving, some of the screenshots maybe old
- the wallpaper offered to be downloaded towards the end is from this [`REPO`](https://github.com/JaKooLit/Wallpaper-Bank)
- The dotfiles that will be pulled by this installer is only specific. Since newer dotfiles might not work properly

#### ✨  Some notes on this installer / Prerequisites
- This script is meant to install Hyprland in Ubuntu 24.04 LTS ONLY!!
- 🕯️ network-manager-gnome (nm-applet) has been removed from the packages to install. This is because it is known to restart the networkmanager causing issues in the installation process. After you boot up, inorder to get the network-manager applet, install network-manager-gnome. `sudo apt install network-manager-gnome` See below if your network or wifi became unmanaged after installation
- If you have nvidia, and wanted to use proprietary drivers, uninstall nouveau first (if installed). This script will be installing proprietary nvidia drivers and will not deal with removal of nouveau.
- NVIDIA users / owners, after installation, check [`THIS`](https://github.com/JaKooLit/Hyprland-Dots/wiki/Notes_to_remember#--for-nvidia-gpu-users)
 
#### ⚠️ WARNING! nwg-look takes long time to install. 
- nwg-look is a utility to costumize your GTK theme. It's a LXAppearance like. Its a good tool though but this package is entirely optional

#### ✨ Costumize the packages to be installed
- inside the install-scripts directory, you can edit 00-hypr-pkgs.sh. Do not edit 00-dependencies.sh unless you know what you are doing. Care though as the Hyprland Dots may not work properly!

### 🚩 changing login manager to SDDM
- if you really want to change login manager, there are couple of things you need to carry out before running this install script
- first install sddm. the no-install-recommends is suggested else it will pull lots of plasma depencies.
```bash
sudo apt install --no-install-recommends -y sddm
```
- then ran `sudo dpkg-reconfigure sddm` choose sddm and then reboot.
- once reboot done, you can ran the script and choose sddm & sddm theme
- [LINK](https://www.simplified.guide/ubuntu/switch-to-gdm) for some guide

#### 💫 SDDM and GTK Themes offered
- If you opted to install SDDM theme, here's the [`LINK`](https://github.com/JaKooLit/simple-sddm)
- If you opted to install GTK Themes, Icons, here's the [`LINK`](https://github.com/JaKooLit/GTK-themes-icons) & Bibata Cursor Modern Ice (assets directory)

## ✨ Auto clone and install
- you can use this command to automatically clone the installer and ran the script for you
- NOTE: `curl` package is required before running this command
```bash
sh <(curl -L https://raw.githubusercontent.com/JaKooLit/Ubuntu-Hyprland/24.04/auto-install.sh)
```
- if you are using say fish or a non-POSIX compliant
```bash
curl -sL https://raw.githubusercontent.com/JaKooLit/Ubuntu-Hyprland/24.04/auto-install.sh | bash
```

## ✨ to use this script
> clone this repo (latest commit only) by using git. Change directory, make executable and run the script
```bash
git clone -b 24.04 --depth=1 https://github.com/JaKooLit/Ubuntu-Hyprland.git ~/Ubuntu-Hyprland-24.04
cd ~/Ubuntu-Hyprland-24.04
chmod +x install.sh
./install.sh
```

### 💥 💥  UNINSTALL SCRIPT / Removal of Config Files
- 11 March 2025, due to popular request, created a guided `uninstall.sh` script. USE this with caution as it may render your system unstable.
- I will not be responsible if your system breaks
- The best still to revert to previous state of your system is via timeshift of snapper

### ❇️ Nvidia Drivers & 🔔 NOTICE TO NVIDIA OWNERS
- If you choose to configure nvidia, driver will be installed via automatic detection / install. See [NVIDIA guide](https://documentation.ubuntu.com/server/how-to/graphics/install-nvidia-drivers/index.html#installing-the-drivers-for-generic-use-e-g-desktop-and-gaming)
- The command will be executed will be `sudo ubuntu-drivers install`
- Note that `nouveau` is installed, you need to uninstall it first or DO NOT choose to configure `nvidia`
- NOTE: that script is also designed to install some other nvidia stuff including blacklist of nouvea. Verify and review `install-scripts/nvidia.sh` or DO not choose to configure nvidia on the option

> [!IMPORTANT]
> If you want to use nouveau driver, dont choose nvidia in the option. This is because the nvidia installer part, it will blacklist nouveau. Hyprland will still be installed but it will skip blacklisting nouveau.

#### ✨ for ZSH and OH-MY-ZSH installation
> installer should auto change your default shell to zsh. However, if it does not, do this
```bash
chsh -s $(which zsh)
zsh
source ~/.zshrc
```
- reboot or logout
- by default `agnosterzak` theme is installed. Which is from external oh-my-zsh theme. You can find more themes from this [`OH-MY-ZSH-THEMES`](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes)
- to change the theme, `SUPER SHIFT O` , choose  desired theme, and close and open terminal. 
- or manually edit `~/.zshrc` . Look for ZSH_THEME="desired theme"

#### ✨ TO DO once installation done and dotfiles copied
- SUPER H for HINT or click on the waybar HINT! Button 
- Head over to [FAQ](https://github.com/JaKooLit/Hyprland-Dots/wiki/FAQ) and [TIPS](https://github.com/JaKooLit/Hyprland-Dots/wiki/TIPS)


- if you installed in your laptop and Brightness and Keyboard brightness does not work you can execute this command `sudo chmod +s $(which brightnessctl)`

#### ✨ Packages that are manually downloaded and build. These packages will not be updated by apt and have to be manually updated
- Hyprland [`LINK`](https://github.com/hyprwm/Hyprland)
- nwg-look [`LINK`](https://github.com/nwg-piotr/nwg-look)
- Asus ROG asusctl [`LINK`](https://gitlab.com/asus-linux/asusctl) and superfxctl [`LINK`](https://gitlab.com/asus-linux/supergfxctl)
- swww [`LINK`](https://github.com/Horus645/swww)
- hyprlock [`LINK`](https://github.com/hyprwm/hyprlock)
- hypridle [`LINK`](https://github.com/hyprwm/hypridle)
- hyprlang [`LINK`](https://github.com/hyprwm/hyprlang)
- hyprcursor [`LINK`](https://github.com/hyprwm/hyprcursor)
- swappy [`LINK`](https://github.com/jtheoof/swappy)
- xdg-desktop-portal-hyprland [`LINK`](https://github.com/hyprwm/xdg-desktop-portal-hyprland)
- rofi-wayland [`LINK`](https://github.com/lbonn/rofi)
> [!TIP]
> To update to latest packages, re-running this script will auto update all. Script is configured to pull latest packages build for you.

#### 🤬 FAQ
#### Most common question I got is, Hey Ja, Why the heck it is taking long time to install? Other distro like Arch its only a minute or two. Why here takes like forever?!?!?!
- Well, most of the core packages are downloaded and Build and compiled from SOURCE. There are no pre-built binary (yet) for Debian and Ubuntu. Unlike Other distros, they already have prepacked binary that can just download and install.

> [!NOTE] 
> This script does not setup audio. Kindly set up. If you have not, I recommend pipewire. `sudo apt install -y pipewire`


## 🛎 *** DEBIAN and UBUNTU Hyprland Dots UPDATING NOTES ***
> [!IMPORTANT]
> This is very Important for Debian and Ubuntu Dots
- Some parts of KooL's Hyprland Dots [`LINK`](https://github.com/JaKooLit/Hyprland-Dots) are not compatible on Debian and Ubuntu especially the hyprland settings. 
- That is the reason the DOTS for those distro's are "fixed" and they are being pulled on different branch of KooL Dots.

- To update your KooL's Dots follow this [WIKI](https://github.com/JaKooLit/Hyprland-Dots/wiki/Install_&_Update#%EF%B8%8F%EF%B8%8F%EF%B8%8F%EF%B8%8F---debian-and-ubuntu-hyprland-dots-updating-notes--%EF%B8%8F%EF%B8%8F%EF%B8%8F%EF%B8%8F%EF%B8%8F)


### 🚩 changing login manager to SDDM
- if you really want to change login manager, there are couple of things you need to carry out before running this install script
- first install sddm. the no-install-recommends is suggested else it will pull lots of plasma depencies.
```bash
sudo apt install --no-install-recommends -y sddm
```
- then ran `sudo dpkg-reconfigure sddm` choose sddm and then reboot.
- once reboot done, you can ran the script and choose sddm & sddm theme
- [LINK](https://www.simplified.guide/ubuntu/switch-to-gdm) for some guide


#### ❗ some known issues on this Installer
- some users reported that they have to install some packages. It is in the install-scripts/force-install.sh
- At this time the packages force to install are the following `imagemagick`

#### 🎞️ AGS Overview DEMO
- in case you wonder, here is a short demo of AGS overview [Youtube LINK](https://youtu.be/zY5SLNPBJTs)

#### ✨ TO DO once installation done and dotfiles copied
- SUPER H for HINT or click on the waybar HINT! Button 
- Head over to [KooL Hyprland WIKI](https://github.com/JaKooLit/Hyprland-Dots/wiki)

#### 🙋 Got a questions regarding the Hyprland Dots or configurations? 🙋
- Head over to wiki Link [`WIKI`](https://github.com/JaKooLit/Hyprland-Dots/wiki)

#### ⌨ Keybinds
- Keybinds [`CLICK`](https://github.com/JaKooLit/Hyprland-Dots/wiki/Keybinds)

> [!TIP]
> KooL Hyprland has a searchable keybind function via rofi. (SUPER SHIFT K) or right click the `HINTS` waybar button

#### 🙋 👋 Having issues or questions? 
- for the install part, kindly open issue on this repo
- for the Pre-configured Hyprland dots / configuration, submit issue [`here`](https://github.com/JaKooLit/Hyprland-Dots/issues)

#### 🔧 Proper way to re-installing a particular script from install-scripts directory
- CD into Ubuntu-Hyprland Folder and then ran the below command. 
- i.e. `./install-scripts/gtk-themes.sh` - For reinstall GTK Themes or
- `./install-scripts/sddm.sh` - For reinstall sddm
> [!IMPORTANT]
> DO NOT cd into install-scripts directory as script will most likely to fail

#### 🛣️ Roadmap:
- [ ] possibly adding gruvbox themes, cursors, icons

#### ❗ some known issues for nvidia
- reports from members of my discord, states that some users of nvidia are getting stuck on sddm login. credit  to @Kenni Fix stated was 
```  
 while in sddm press ctrl+alt+F2 or F3
log into your account
`lspci -nn`, find the id of your nvidia card
`ls /dev/dri/by-path` find the matching id
`ls -l /dev/dri/by-path` to check where the symlink points to 
)
```
- add "env = WLR_DRM_DEVICES,/dev/dri/cardX" to the ENVvariables config `~/.config/hypr/UserConfigs/ENVariables.conf`  ; X being where the symlink of the gpu points to

- more info from the hyprland wiki [`Hyprland Wiki Link`](https://wiki.hyprland.org/FAQ/#my-external-monitor-is-blank--doesnt-render--receives-no-signal-laptop)


- reports from a member of discord for Nvidia for additional env's
- remove # from the following env's on 
```
env = GBM_BACKEND,nvidia-drm
env = WLR_RENDERER_ALLOW_SOFTWARE,1
```

#### ❗ other known issues
> [!NOTE]
> Auto start of Hyprland after login (no SDDM or GDM or any login managers)
- [ ] This was disabled a few days ago. (19 May 2024). This was because some users, after they used the Distro-Hyprland scripts with other DE (gnome-wayland or plasma-wayland), if they choose to login into gnome-wayland for example, Hyprland is starting. 
- [ ] to avoid this, I disabled it. You can re-enable again by editing `~/.zprofile` . Remove all the # on the first lines
- [ ] ROFI issues (scaling, unexplained scaling etc). This is most likely to experience if you are installing on a system where rofi is currently installed. To fix it uninstall rofi and install rofi-wayland . `sudo apt autoremove rofi` . 
- Install rofi-wayland with 
```bash
cd ~/Ubuntu-Hyprland
./install-scripts/rofi-wayland.sh
```
- [ ] Rofi-wayland is compatible with x11 so no need to worry.
- [ ] Does not work in Ubuntu 23.10 and older
- [ ] sddm blackscreen when log-out
- [ ] Installing SDDM if or any other Login Manager installed. See [`Issue 2 - SDDM`](https://github.com/JaKooLit/Debian-Hyprland/issues/2)
- [ ] network is down or become unmanaged [`This`](https://askubuntu.com/questions/71159/network-manager-says-device-not-managed) might help
- [ ] See note above about Hyprland-Dots newer version incompatibility

#### 🫥 Improving performance for Older Nvidia Cards using driver 470
  - [`SEE HERE`](https://github.com/JaKooLit/Hyprland-Dots/discussions/123#discussion-6035205)
  
#### 📒 Final Notes
- join my discord channel [`Discord`](https://discord.com/invite/kool-tech-world)
- Feel free to copy, re-distribute, and use this script however you want. Would appreciate if you give me some loves by crediting my work :)


#### ⏩ Contributing
- As stated above, these script does not contain actual config files. These are only the installer of packages
- The development branch of this script is pulling the latest "stable" releases of the Hyprland-Dotfiles.
- If you want to contribute and/or test the Hyprland-Dotfiles (development branch), [`Hyprland-Dots-Development`](https://github.com/JaKooLit/Hyprland-Dots/tree/development) 


#### 👍👍👍 Thanks and Credits!
- [`Hyprland`](https://hyprland.org/) Of course to Hyprland and @vaxerski for this awesome Dynamic Tiling Manager.


### 💖 Support
- a Star on my Github repos would be nice 🌟

- Subscribe to my Youtube Channel [YouTube](https://www.youtube.com/@Ja.KooLit) 

- you can also give support through coffee's or btc 😊

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/jakoolit)

or

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/JaKooLit)

Or you can donate cryto on my btc wallet :)  
> 1N3MeV2dsX6gQB42HXU6MF2hAix1mqjo8i

![Bitcoin](https://github.com/user-attachments/assets/7ed32f8f-c499-46f0-a53c-3f6fbd343699)



#### 📹 Youtube videos (Click to view and watch the playlist) 📹
[![Youtube Playlist Thumbnail](https://raw.githubusercontent.com/JaKooLit/screenshots/main/Youtube.png)](https://youtube.com/playlist?list=PLDtGd5Fw5_GjXCznR0BzCJJDIQSZJRbxx&si=iaNjLulFdsZ6AV-t)


                        
## 🥰🥰 💖💖 👍👍👍
[![Stargazers over time](https://starchart.cc/JaKooLit/Ubuntu-Hyprland.svg?variant=adaptive)](https://starchart.cc/JaKooLit/Ubuntu-Hyprland)

                    

# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

Project scope
- Purpose: Interactive installer/uninstaller for a Hyprland desktop stack on Ubuntu 25.04 (Plucky Puffin).
- Tech: Bash scripts only. No compiled project here; scripts orchestrate apt installs and source builds.

Common commands
- Run installer (interactive)
  ```bash path=null start=null
  ./install.sh
  ```
- Run installer with a preset file (skips manual selections)
  ```bash path=null start=null
  ./install.sh --preset ./preset.sh
  ```
- Re-run a specific component installer from repo root (do NOT cd into install-scripts/)
  ```bash path=null start=null
  ./install-scripts/gtk_themes.sh
  ./install-scripts/sddm.sh
  ./install-scripts/rofi-wayland.sh
  ./install-scripts/03-Final-Check.sh
  ```
- Uninstall (interactive removal of packages/configs)
  ```bash path=null start=null
  ./uninstall.sh
  ```
- Hyprland-only build: dry-run and tag override
  ```bash path=null start=null
  # Dry-run (no install)
  ./install-scripts/hyprland.sh --dry-run
  # or
  DRY_RUN=1 ./install-scripts/hyprland.sh

  # Pin version (default v0.51.1)
  HYPRLAND_TAG=v0.51.1 ./install-scripts/hyprland.sh
  ```
- System logs created by scripts
  ```bash path=null start=null
  # List and tail the latest log
  ls -1t Install-Logs | head -n 5
  tail -f Install-Logs/<latest>.log
  ```
- Lint and format shell scripts locally (no test suite in repo)
  ```bash path=null start=null
  # Static analysis
  find . -type f -name "*.sh" -print0 | xargs -0 -n1 shellcheck -x

  # Syntax check (bash)
  find . -type f -name "*.sh" -print0 | xargs -0 -n1 bash -n

  # Format (requires shfmt)
  shfmt -w .
  ```

Architecture overview
- Orchestrator: install.sh
  - Presents whiptail-driven checklists; enforces non-root execution; sets up Install-Logs/; optionally loads ./hypr-tags.env for version pins.
  - Executes a fixed sequence to build Hyprland prerequisites from source in correct order, then Hyprland itself, then optional desktop components.
  - Key sequence (order matters):
    1) wayland-protocols-src.sh
    2) hyprland-protocols.sh
    3) hyprutils.sh
    4) hyprlang.sh
    5) aquamarine.sh
    6) hyprgraphics.sh
    7) hyprwayland-scanner.sh
    8) hyprland-qt-support.sh
    9) hyprland-qtutils.sh
    10) hyprland.sh
    11) wallust.sh, swww.sh, rofi-wayland.sh, hyprlock.sh, hypridle.sh
  - After core installs, applies user-selected options (sddm, bluetooth, thunar, ags, xdph, zsh, rog, dotfiles, etc.) via matching scripts.

- Shared library: install-scripts/Global_functions.sh
  - Common helpers used across installers: apt install with progress spinner, build-dep, cargo install, reinstall/uninstall helpers.
  - Consumes LOG env var set by callers to append to Install-Logs/.

- Component installers: install-scripts/*.sh
  - Each script is a unit for a package or feature (e.g., sddm.sh, thunar.sh, gtk_themes.sh, wallust.sh).
  - Expect to be launched from repo root; rely on relative paths and shared functions.

- Hyprland build module: install-scripts/hyprland.sh
  - Clones hyprwm/Hyprland at tag (HYPRLAND_TAG; default v0.51.1), optional patching from assets/.
  - Uses clang toolchain and CMake; can build against system hyprutils/hyprlang (default) or bundled.
  - Flags:
    - DRY_RUN=1 or --dry-run: build only, skip install.
    - USE_SYSTEM_HYPRLIBS=1 (default) to prefer system-installed hyprlibs; set to 0 to use bundled.
    - HYPRLAND_TAG to pin version.

- Presets and tags
  - Preset flow: ./install.sh --preset <path> sources a shell file (e.g., preset.sh) that sets option variables (e.g., gtk_themes="Y").
  - Version pinning: If ./hypr-tags.env exists, install.sh sources and exports tags such as HYPRLAND_TAG, AQUAMARINE_TAG, HYPRUTILS_TAG, HYPRLANG_TAG, HYPRGRAPHICS_TAG, HYPRWAYLAND_SCANNER_TAG, HYPRLAND_PROTOCOLS_TAG, HYPRLAND_QT_SUPPORT_TAG, HYPRLAND_QTUTILS_TAG, WAYLAND_PROTOCOLS_TAG for downstream scripts.

- Uninstaller: uninstall.sh
  - whiptail-driven interactive selector for packages and ~/.config subdirectories; uses apt remove and rm -rf of configs; warns of instability, requires confirmations.

Usage constraints and notes
- Run from repo root and as a normal user (non-root). Scripts will exit if run as root.
- Do NOT cd into install-scripts/ when executing component scripts; run them from the repository root (they rely on relative paths and logging conventions).
- Targeted at Ubuntu 25.04; older Ubuntu versions are not supported by these scripts.
- Auto-clone helper (auto-install.sh) is meant for convenience but is not recommended on fish shell; use ./install.sh instead as noted in README.
- Some components are built from source; installations can be lengthy. Logs are in Install-Logs/ for troubleshooting.

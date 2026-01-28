# Ubuntu-Hyprland Install & Upgrade Guide (26.04)

> [!WARNING]
> This document applies **only** to Ubuntu 26.04 “Resolute Raccoon”. The tooling on this branch enforces that release because the stock Ubuntu archive currently ships Hyprland 0.52.2. Earlier Ubuntu versions should use the main branch; Debian-based systems should remain on the Debian-Hyprland project.

## Table of Contents

1. [Overview](#overview)
2. [What's new in the 26.04 branch](#whats-new-in-the-2604-branch)
3. [Flags Reference](#flags-reference)
4. [Central Version Management](#central-version-management)
5. [Installation Paths](#installation-paths)
6. [Upgrade Workflows](#upgrade-workflows)
7. [Dry-Run Testing](#dry-run-testing)
8. [Log Locations](#log-locations)
9. [Advanced Usage](#advanced-usage)
10. [Troubleshooting](#troubleshooting)

## Overview

Ubuntu 26.04 ships Hyprland 0.52.2 in the official repositories. This project keeps that path available, but now exposes a first-class **source build** workflow (Hyprland ≥0.53) using the same module stack as Debian-Hyprland. The key components are:

- `install.sh` now lets you pick between the Ubuntu archive build or a from-source build (default recommendation). Choosing source automatically removes Ubuntu’s Hyprland packages before compiling.
- `update-hyprland.sh` orchestrates upgrades/dry-runs for the Hyprland stack without running the full interactive installer.
- `dry-run-build.sh` compiles everything with `DRY_RUN=1` so you can verify tag combos safely.
- `hypr-tags.env` centralizes every Hyprland-related version tag for both the installer and update tooling.

## What's new in the 26.04 branch

### Guided Ubuntu 26.04 detection
- `install.sh` refuses to run on non-26.04 systems and shows a warning banner explaining why.

### Source-build toggle
- After confirming you want to proceed, a whiptail dialog asks whether to keep the Ubuntu repo build (0.52.2) or build from source. Environment variable `HYPR_FROM_SOURCE=1` or the `--from-source` CLI flag can pre-select the option.
- When *Source build* is chosen, the script automatically purges any Ubuntu Hyprland/Aquamarine/portal packages and wipes `/usr/local` Hyprland artifacts before compiling the latest tags.

### New helper scripts
- `update-hyprland.sh`: mirrors the Debian tooling but tailored to the Ubuntu module set (no Debian Trixie overrides needed).
- `dry-run-build.sh`: provides a succinct PASS/FAIL summary for each module and reports the current versions pulled from `hypr-tags.env`.
- `install-scripts/hyprwire.sh`: added to keep Hyprwire in sync with upstream (required by Hyprland >=0.53).

## Flags Reference

### install.sh
- `--from-source`: Skip the Ubuntu repo build and compile the stack (also accessible via the new whiptail prompt).
- `--preset <file>`: Apply predefined option selections.

Environment overrides:

```bash
HYPR_FROM_SOURCE=1 ./install.sh        # force source build without prompt
HYPR_FROM_SOURCE=0 ./install.sh        # force Ubuntu repo build
```

### update-hyprland.sh
- `--install` / `--dry-run`: install vs compile-only.
- `--fetch-latest`: pull the newest GitHub release tags for all Hypr* components (respects pinned values unless `--force-update` or `FORCE=1` is supplied).
- `--set HYPRLAND=v0.53.3`: override specific tags inline.
- `--only hyprland,hyprwire` / `--skip hyprland-qt-support`: build a subset.
- `--bundled` / `--system`: toggle whether Hyprland uses bundled or system hyprutils/hyprlang libs (default: system).
- `--with-deps`: rerun dependency installation before compiling.
- `--via-helper`: send the plan to `dry-run-build.sh` for summary output.

### dry-run-build.sh
- `--with-deps`: install dependencies before the dry-run.
- `--only ...` / `--skip ...`: same semantics as update-hyprland.

## Central Version Management

`hypr-tags.env` now matches the Debian stack defaults (Hyprland v0.53.3 at the time of writing). Both `install.sh` (source path) and `update-hyprland.sh` load/export these tags so you have a single source of truth.

Refreshing tags:

```bash
./update-hyprland.sh --fetch-latest --dry-run
# If you like the output, install:
./update-hyprland.sh --fetch-latest --install

# Force overriding pinned values:
./update-hyprland.sh --fetch-latest --force-update --install
```

You can also edit `hypr-tags.env` manually or keep multiple copies (e.g., `hypr-tags-stable.env`) and swap them in as needed.

## Installation Paths

1. **Ubuntu archive build (Hyprland 0.52.2)**  
   - Select “Ubuntu repo” in the new whiptail prompt (or set `HYPR_FROM_SOURCE=0`).  
   - Runs existing install scripts plus `install-scripts/hyprland-ppa.sh`.

2. **Source build (recommended)**  
   - Select “Source build” or pass `--from-source`.  
   - The installer removes Ubuntu’s Hyprland packages, cleans `/usr/local` copies, then builds:
     `wayland-protocols-src → hyprland-protocols → hyprutils → hyprlang → hyprwayland-scanner → aquamarine → hyprgraphics → hyprland-qt-support → hyprland-qtutils → hyprwire → hyprland`.
   - After a successful build, it re-runs the package purge to guarantee the repo packages remain absent.

3. **Headless stack maintenance**  
   - Skip the interactive installer entirely:
     ```bash
     ./update-hyprland.sh --install
     ./update-hyprland.sh --fetch-latest --dry-run
     ```

## Upgrade Workflows

### Staying on Ubuntu’s 0.52.2 build
- Re-run `install.sh` (choose Ubuntu repo) to reapply optional components or dotfiles.

### Moving to upstream Hyprland ≥0.53
1. Refresh or pin tags:
    ```bash
    ./update-hyprland.sh --set HYPRLAND=v0.53.3 --dry-run
    ```
2. Install if dry-run passes:
    ```bash
    ./update-hyprland.sh --install --only hyprland
    ```
   The helper automatically inserts prerequisites (wayland-protocols, hyprutils, hyprlang, aquamarine, hyprwire).

### Selective component refresh
- Update only supporting libs:
  ```bash
  ./update-hyprland.sh --fetch-latest --install --only hyprutils,hyprlang,aquamarine
  ```

### Using the installer’s source mode
- If you previously stayed on the repo build, simply rerun `install.sh`, choose “Source build”, and let the script remove Ubuntu packages and rebuild the stack.

## Dry-Run Testing

Why dry-run?
- Validate tag combinations with the current system toolchain.
- Catch build errors before modifying `/usr/local`.
- Useful for CI or for verifying future Ubuntu SRU changes.

Commands:

```bash
./dry-run-build.sh
./update-hyprland.sh --fetch-latest --dry-run
./dry-run-build.sh --only hyprland --with-deps
```

## Log Locations

All scripts write to `Install-Logs/`:

```
Install-Logs/
├── 01-Hyprland-Install-Scripts-*.log   # install.sh master logs
├── install-*_module-name.log           # per-module installer logs
├── update-hypr-YYYY-MM-DD-HHMMSS.log   # update-hyprland summary
└── build-dry-run-YYYY-MM-DD-HHMMSS.log # dry-run summary
```

To inspect recent output:

```bash
ls -t Install-Logs/*.log | head -1 | xargs less
grep -i "error" Install-Logs/install-*hyprland*.log
```

## Advanced Usage

- **Multiple tag sets**: keep `hypr-tags-stable.env` and `hypr-tags-experimental.env` to swap quickly.
- **Bundled libs fallback**: `./update-hyprland.sh --auto --install` retries with bundled hyprlibs if system packages are outdated.
- **Custom PKG_CONFIG_PATH / MAKEFLAGS**: export before running `update-hyprland.sh` or `install.sh`.
- **CI integration**: use `dry-run-build.sh` in pipelines to ensure new commits still compile against Ubuntu 26.04 toolchains.

## Troubleshooting

1. **Hyprland not detected after install**
   - Check `Install-Logs/install-*_hyprland.log` for linker errors.
   - Ensure `/usr/local/lib` is in `/etc/ld.so.conf.d/usr-local.conf` (install scripts add it automatically, but verify).

2. **CMake dependency failures**
   - Run `./update-hyprland.sh --install --only wayland-protocols-src,hyprutils,hyprlang`.
   - Confirm `sudo apt install build-essential clang pkg-config cmake ninja-build` succeeded (handled by `00-dependencies.sh`).

3. **Accidentally installed repo packages again**
   - Run `sudo apt purge hyprland hyprutils hyprgraphics ...` or simply rerun `install.sh` in source mode (it purges automatically).

4. **Need to revert to Ubuntu repo build**
   - Set `HYPR_FROM_SOURCE=0` (or choose “Ubuntu repo”) and rerun `install.sh`. You can later switch back to source by selecting that option again.

For additional Q&A on dotfiles, refer to the main README and the Hyprland-Dots wiki.

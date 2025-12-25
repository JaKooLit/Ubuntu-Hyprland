# Building Quickshell from source (Ubuntu/Debian)

This document records the exact requirements and steps we used to build Quickshell from source on Ubuntu 26.04, and how it integrates with this repository’s installer. It’s intended to be reusable for other Ubuntu/Debian versions that follow the same install layout and script logic.

## What this adds
- Optional “quickshell” install path in `install.sh` that builds Quickshell from source and installs it into `/usr/local`.
- A standalone builder at `install-scripts/quickshell.sh` that you can run directly.

## Upstream references
- Quickshell source: https://git.outfoxxed.me/quickshell/quickshell
- Google Breakpad: https://chromium.googlesource.com/breakpad/breakpad
- Linux Syscall Support (LSS): https://chromium.googlesource.com/linux-syscall-support

## Install-time behavior (high level)
1. Installs toolchain and development headers with apt in a single transaction.
2. Builds and installs Google Breakpad to `/usr/local` when not available via pkg-config.
3. Configures, builds, and installs Quickshell with CMake+Ninja to `/usr/local`.
4. Verifies errors at each stage and logs to `Install-Logs/`.

## Required packages (Ubuntu/Debian)
Install these with apt (names verified on Ubuntu 26.04; Debian names typically match):

- Toolchain and build helpers
  - `build-essential`, `git`, `cmake`, `ninja-build`, `pkg-config`
  - Autotools for Breakpad: `autoconf`, `automake`, `libtool`, `zlib1g-dev`, `libcurl4-openssl-dev`

- Qt 6 stack
  - `qt6-base-dev`, `qt6-declarative-dev`, `qt6-declarative-private-dev`, `qt6-shadertools-dev`, `qt6-tools-dev`, `qt6-tools-dev-tools`
  - SVG module (one or both may be needed depending on the distro): `qt6-svg-dev`, `libqt6svg6-dev`

- Wayland/graphics headers
  - `libwayland-dev`, `wayland-protocols`, `libdrm-dev`, `libgbm-dev`

- Desktop integrations used by Quickshell
  - PipeWire/Polkit: `libpipewire-0.3-dev`, `libpolkit-gobject-1-dev`, `libpolkit-agent-1-dev`
  - PAM/GLib/XCB: `libpam0g-dev`, `libglib2.0-dev`, `libxcb1-dev`

- Third-party libraries detected by CMake
  - CLI11: `libcli11-dev`
  - jemalloc: `libjemalloc-dev`

Notes:
- On some Debian releases, `qt6-svg-dev` may be absent; `libqt6svg6-dev` is sufficient.
- If a dependency is present but pkg-config cannot find it, check that the corresponding `-dev` package is installed.

## Breakpad (when not shipped by your distro)
Breakpad is required by Quickshell for crash handling. If `pkg-config --exists breakpad` fails:

1. Clone and build at a fixed location so CMake can find it via `/usr/local`:
   ```bash
   # create a workspace
   mkdir -p ~/.thirdparty && cd ~/.thirdparty
   git clone --depth=1 https://chromium.googlesource.com/breakpad/breakpad breakpad
   cd breakpad
   # lss must be under src/third_party/lss
   git clone --depth=1 https://chromium.googlesource.com/linux-syscall-support src/third_party/lss
   # bootstrap and build
   autoreconf -fi
   ./configure --prefix=/usr/local
   make -j"$(nproc || getconf _NPROCESSORS_ONLN)"
   sudo make install
   ```
2. Ensure pkg-config can discover it:
   - Make sure a `.pc` file exists as `/usr/local/lib/pkgconfig/breakpad.pc`.
   - If only `breakpad-client.pc` exists, symlink it: `sudo ln -sf /usr/local/lib/pkgconfig/breakpad-client.pc /usr/local/lib/pkgconfig/breakpad.pc`.
   - Export search paths for this shell or script:
     ```bash
     export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:$PKG_CONFIG_PATH
     export CMAKE_PREFIX_PATH=/usr/local:$CMAKE_PREFIX_PATH
     ```

## Builder script (what `install-scripts/quickshell.sh` does)
- Prepares logging under `Install-Logs/`.
- Installs all required apt packages in one transaction and validates `cmake`, `ninja`, and `pkg-config` are on `PATH`.
- If `pkg-config --exists breakpad` fails, builds Breakpad from source (see steps above) and verifies a working `breakpad.pc`.
- Configures Quickshell with:
  ```
  cmake -S . -B build \
    -GNinja \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DDISTRIBUTOR="Ubuntu-Hyprland installer"
  ```
- Builds and installs with:
  ```
  cmake --build build
  sudo cmake --install build
  ```
- Fails fast with clear log lines on configure/build/install errors.

## Integration with `install.sh`
- The installer’s checklist includes a new option: `quickshell` — “Install Quickshell (QtQuick-based shell toolkit)”.
- When selected, `install.sh` executes `./install-scripts/quickshell.sh` from the repo root like other modules.
- Logging follows the repository convention under `Install-Logs/` and does not depend on the current working directory of child processes.

## Cross-distro notes (Ubuntu/Debian)
- Package names generally match between Ubuntu and Debian. If CMake errors cite missing modules, install the corresponding `-dev` package and re-run.
- Qt private headers (e.g. `Qt6::QuickPrivate`) require `qt6-declarative-private-dev` matching the version of `qt6-declarative-dev`.
- If your distro uses a different SSL flavor, `libcurl4-gnutls-dev` can be used instead of `libcurl4-openssl-dev`.

## Verification and troubleshooting
- Verify library discovery:
  ```bash
  pkg-config --exists breakpad && echo OK: breakpad
  pkg-config --modversion Qt6Core Qt6Quick Qt6Gui
  ```
- Common CMake errors and fixes:
  - `Could not find package configuration file provided by "CLI11"` → `sudo apt install -y libcli11-dev`
  - `required packages were not found: polkit-agent-1` → `sudo apt install -y libpolkit-agent-1-dev`
  - `required packages were not found: jemalloc` → `sudo apt install -y libjemalloc-dev`
  - `Qt6::QuickPrivate includes non-existent path .../QtQuick/<ver>` → `sudo apt install -y qt6-declarative-private-dev` (ensure versions match your Qt6 packages)
- Clean rebuild if needed:
  ```bash
  rm -rf quickshell-src/build
  ./install-scripts/quickshell.sh
  ```

## Non-interactive/CI hints
- Set `DEBIAN_FRONTEND=noninteractive` to suppress prompts during apt operations.
- Ensure `/usr/local` appears in `PKG_CONFIG_PATH` and `CMAKE_PREFIX_PATH` in the build environment.

## Maintenance
- If Quickshell bumps required dependencies or adds new optional modules, update the DEPS list in `install-scripts/quickshell.sh` and this document in tandem.
- If Breakpad publishes a proper Debian/Ubuntu package in your target release, prefer that over source-building and remove the Breakpad build block.

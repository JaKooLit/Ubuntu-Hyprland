#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Hypr Ecosystem
# hyprwire

# Specific branch or release (honor env override)
tag="v0.2.1"
# Auto-source centralized tags if env is unset
if [ -z "${HYPRWIRE_TAG:-}" ]; then
  TAGS_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/hypr-tags.env"
  [ -f "$TAGS_FILE" ] && source "$TAGS_FILE"
fi
if [ -n "${HYPRWIRE_TAG:-}" ]; then tag="$HYPRWIRE_TAG"; fi

# Dry-run support + shim controls
DO_INSTALL=1
FORCE_SHIM=0
NO_SHIM=0

for arg in "$@"; do
  case "$arg" in
    --dry-run)
      DO_INSTALL=0
      ;;
    # Force the compatibility shim used on Debian 13 (trixie) toolchains.
    # This is intentionally distro-named so it's obvious what it does for most users.
    --build-trixie|--force-shim)
      FORCE_SHIM=1
      ;;
    # For testing/sid (or any toolchain that supports std::vector::append_range), allow opting out.
    --no-shim)
      NO_SHIM=1
      ;;
  esac
done

if [ "${DRY_RUN}" = "1" ] || [ "${DRY_RUN}" = "true" ]; then
  DO_INSTALL=0
fi

if [ $DO_INSTALL -eq 0 ]; then
  echo "${NOTE} DRY RUN: install step will be skipped."
fi

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }

# Source the global functions script
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  echo "Failed to source Global_functions.sh"
  exit 1
fi

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprwire.log"
MLOG="install-$(date +%d-%H%M%S)_hyprwire2.log"

printf "${NOTE} Installing hyprwire $tag...\\n"

# Remove existing tree if present (under build/src)
SRC_DIR="$SRC_ROOT/hyprwire"
if [ -d "$SRC_DIR" ]; then
  printf "${NOTE} Removing existing hyprwire folder...\\n"
  rm -rf "$SRC_DIR" 2>&1 | tee -a "$LOG"
fi

# Clone and build
if git clone --recursive -b "$tag" https://github.com/hyprwm/hyprwire.git "$SRC_DIR"; then
  cd "$SRC_DIR" || exit 1
  BUILD_DIR="$BUILD_ROOT/hyprwire"
  mkdir -p "$BUILD_DIR"

  # Decide whether we need the append_range compatibility shim.
  # On Debian 13 (trixie), libstdc++ typically lacks std::vector::append_range, so we patch.
  # On newer toolchains (testing/sid), prefer building upstream unmodified.
  NEED_SHIM=0
  if [ "$NO_SHIM" -eq 1 ]; then
    NEED_SHIM=0
  elif [ "$FORCE_SHIM" -eq 1 ]; then
    NEED_SHIM=1
  else
    CXX_TEST="${CXX:-c++}"
    TMPD="$(mktemp -d)"
    cat >"$TMPD/append_range_test.cpp" <<'EOF'
#include <vector>
int main() {
  std::vector<unsigned char> v;
  v.append_range(std::vector<unsigned char>{1,2,3});
  return 0;
}
EOF
    if "$CXX_TEST" -std=c++23 -c "$TMPD/append_range_test.cpp" -o /dev/null >/dev/null 2>&1; then
      NEED_SHIM=0
    else
      NEED_SHIM=1
    fi
    rm -rf "$TMPD"
  fi

  if [ "$NEED_SHIM" -eq 1 ]; then
    echo "${NOTE} Applying append_range compatibility shim (use --no-shim to disable; --build-trixie to force)."

    # Temporary compatibility shim for toolchains where libstdc++ lacks std::vector::append_range (C++23 library feature).
    # Note: append_range in upstream accepts temporaries (e.g. encodeVarInt(...) returns a temporary vector). To support that,
    # we bind the expression to a named auto&& first.
    cat > append_range_compat.hpp <<'EOF'
#pragma once
#include <iterator>

// Append any begin/end range to a container, supporting temporaries by binding to auto&&.
#define APPEND_RANGE(vec, ...) do { \
  auto&& _r = (__VA_ARGS__); \
  (vec).insert((vec).end(), std::begin(_r), std::end(_r)); \
} while(0)
EOF

    # Replace X.(.|->)append_range(Y) -> APPEND_RANGE(X, Y) only where it appears
    PATCH_FILES=$(grep -RIl --exclude-dir=.git -F 'append_range(' . || true)
    if [ -n "$PATCH_FILES" ]; then
      # LHS: identifiers and common member/ptr chains (this->obj, ns::obj.member)
      echo "$PATCH_FILES" | xargs -r sed -ri 's/([A-Za-z_][A-Za-z0-9_:>.\\-]+)\\s*(\\.|->)\\s*append_range\\s*\\(/APPEND_RANGE(\\1, /g'
      # Show any remaining occurrences
      REMAIN=$(grep -RIn --exclude-dir=.git -E '(\\.|->)[[:space:]]*append_range[[:space:]]*\\(' $PATCH_FILES || true)
      if [ -n "$REMAIN" ]; then
        echo "[WARN] Some append_range() calls remain unpatched:" >&2
        echo "$REMAIN" >&2
      fi
    fi

    # Absolute path for forced include
    APPEND_HDR="$(pwd)/append_range_compat.hpp"

    cmake -S . -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_CXX_STANDARD=23 -DCMAKE_CXX_FLAGS="-include ${APPEND_HDR}"
  else
    echo "${NOTE} Toolchain supports std::vector::append_range; building hyprwire without shim."
    cmake -S . -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_CXX_STANDARD=23
  fi
  cmake --build "$BUILD_DIR" -j "$(nproc 2>/dev/null || getconf _NPROCESSORS_CONF)"
  if [ $DO_INSTALL -eq 1 ]; then
    if sudo cmake --install "$BUILD_DIR" 2>&1 | tee -a "$MLOG" ; then
      printf "${OK} hyprwire $tag installed successfully.\\n" 2>&1 | tee -a "$MLOG"
    else
      echo -e "${ERROR} Installation failed for hyprwire $tag" 2>&1 | tee -a "$MLOG"
    fi
  else
    echo "${NOTE} DRY RUN: Skipping installation of hyprwire $tag."
  fi
  [ -f "$MLOG" ] && mv "$MLOG" "$PARENT_DIR/Install-Logs/"
  cd ..
else
  echo -e "${ERROR} Download failed for hyprwire $tag" 2>&1 | tee -a "$LOG"
fi

printf "\\n%.0s" {1..2}

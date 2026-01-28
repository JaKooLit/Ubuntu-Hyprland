#!/usr/bin/env bash
# dry-run-build.sh (Ubuntu 26.04)
# Compile the Hyprland stack using DRY_RUN=1 for each module script and emit a
# concise PASS/FAIL summary. Useful for verifying tag combinations before
# actually installing.
#
# Usage:
#   chmod +x ./dry-run-build.sh
#   ./dry-run-build.sh
#   ./dry-run-build.sh --with-deps
#   ./dry-run-build.sh --only hyprland,hyprwire
#   ./dry-run-build.sh --skip hyprland-qt-support

set -u
set -o pipefail

REPO_ROOT=$(pwd)
LOG_DIR="$REPO_ROOT/Install-Logs"
mkdir -p "$LOG_DIR"
TS=$(date +%F-%H%M%S)
SUMMARY_LOG="$LOG_DIR/build-dry-run-$TS.log"

DEFAULT_MODULES=(
  wayland-protocols-src
  hyprland-protocols
  hyprutils
  hyprlang
  hyprgraphics
  aquamarine
  hyprwayland-scanner
  hyprland-qt-support
  hyprland-qtutils
  hyprwire
  hyprland
)

WITH_DEPS=0
ONLY_LIST=""
SKIP_LIST=""

usage() {
  grep '^# ' "$0" | sed 's/^# \{0,1\}//'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --with-deps) WITH_DEPS=1; shift ;;
    --only) ONLY_LIST=${2:-}; shift 2 ;;
    --skip) SKIP_LIST=${2:-}; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

MODULES=()
if [[ -n "$ONLY_LIST" ]]; then
  IFS=',' read -r -a MODULES <<<"$ONLY_LIST"
else
  MODULES=("${DEFAULT_MODULES[@]}")
fi

if [[ -n "$SKIP_LIST" ]]; then
  IFS=',' read -r -a _SKIPS <<<"$SKIP_LIST"
  FILTERED=()
  for m in "${MODULES[@]}"; do
    skip_it=0
    for s in "${_SKIPS[@]}"; do
      if [[ "$m" == "$s" ]]; then
        skip_it=1
        break
      fi
    done
    if [[ $skip_it -eq 0 ]]; then
      FILTERED+=("$m")
    fi
  done
  MODULES=("${FILTERED[@]}")
fi

if [[ $WITH_DEPS -eq 1 ]]; then
  echo "[INFO] Installing dependencies via 00-dependencies.sh" | tee -a "$SUMMARY_LOG"
  if ! "$REPO_ROOT/install-scripts/00-dependencies.sh"; then
    echo "[ERROR] Dependencies installation failed. See Install-Logs/." | tee -a "$SUMMARY_LOG"
    exit 1
  fi
fi

declare -A RESULTS

echo "[INFO] Starting dry-run build at $TS" | tee -a "$SUMMARY_LOG"

for mod in "${MODULES[@]}"; do
  script_path="$REPO_ROOT/install-scripts/$mod.sh"
  echo -e "\n=== $mod (DRY RUN) ===" | tee -a "$SUMMARY_LOG"
  if [[ ! -x "$script_path" ]]; then
    if [[ -f "$script_path" ]]; then
      chmod +x "$script_path" || true
    fi
  fi
  if [[ ! -f "$script_path" ]]; then
    echo "[WARN] Missing script: $script_path" | tee -a "$SUMMARY_LOG"
    RESULTS[$mod]="MISSING"
    continue
  fi
  if DRY_RUN=1 "$script_path"; then
    RESULTS[$mod]="PASS"
  else
    RESULTS[$mod]="FAIL"
  fi
done

{
  printf "\nSummary (dry-run):\n"
  for mod in "${MODULES[@]}"; do
    printf "%-24s %s\n" "$mod" "${RESULTS[$mod]:-SKIPPED}"
  done
  if [[ -f "$REPO_ROOT/hypr-tags.env" ]]; then
    printf "\nCurrent versions (from %s):\n" "$REPO_ROOT/hypr-tags.env"
    grep -E '^[A-Z0-9_]+=' "$REPO_ROOT/hypr-tags.env" | sort
  fi
  printf "\nLogs: individual module logs are under Install-Logs/. This summary: %s\n" "$SUMMARY_LOG"
} | tee -a "$SUMMARY_LOG"

failed=0
for mod in "${MODULES[@]}"; do
  if [[ "${RESULTS[$mod]:-}" == "FAIL" ]]; then
    failed=1
  fi
done
exit $failed

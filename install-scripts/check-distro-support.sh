#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Check current distro against a blocklist before using the Hyprland PPA.
#
# How to add more blocked distros:
#   1) Open distro-blocklist.json in the repo root.
#   2) Append an object to the "blocked" array with:
#        - "id": short unique handle
#        - "match": map of /etc/os-release keys to values that must ALL match
#        - "reason": human-readable explanation that will be shown to the user
#   Example with multiple entries:
#   {
#     "blocked": [
#       { "id": "rhino-linux-mainline",
#         "match": { "NAME": "Rhino Linux", "VERSION_CODENAME": "devel" },
#         "reason": "PPA not published for this codename." },
#       { "id": "example-oracular",
#         "match": { "ID": "ubuntu", "UBUNTU_CODENAME": "oracular" },
#         "reason": "PPA has no oracular builds yet." }
#     ]
#   }
#
# You can override the blocklist path with: BLOCKLIST_FILE=/path/to/file ./check-distro-support.sh

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$SCRIPT_DIR/.."
cd "$REPO_ROOT"

mkdir -p Install-Logs
LOG="${LOG:-Install-Logs/distro-check-$(date +%d-%H%M%S).log}"

# Tee all output to log when LOG is set
if [ -n "${LOG:-}" ]; then
  exec > >(tee -a "$LOG") 2>&1
fi

BLOCKLIST_FILE="${BLOCKLIST_FILE:-$REPO_ROOT/distro-blocklist.json}"

if [ ! -f "$BLOCKLIST_FILE" ]; then
  echo "[INFO] No blocklist found at $BLOCKLIST_FILE; continuing."
  exit 0
fi

python3 - <<'PYCODE'
import json
import os
import sys
from pathlib import Path

blocklist_path = Path(os.environ.get("BLOCKLIST_FILE", "distro-blocklist.json")).expanduser()
os_release_path = Path("/etc/os-release")

def load_os_release():
    data = {}
    with os_release_path.open() as f:
        for line in f:
            line = line.strip()
            if not line or "=" not in line:
                continue
            key, val = line.split("=", 1)
            data[key] = val.strip().strip('"')
    return data

RED = "\033[31m"
YELLOW = "\033[33m"
CYAN = "\033[36m"
GREEN = "\033[32m"
RESET = "\033[0m"

try:
    blocklist = json.loads(blocklist_path.read_text())
except Exception as exc:
    print(f"{RED}❌ Failed to read blocklist ({blocklist_path}): {exc}{RESET}", file=sys.stderr)
    sys.exit(1)

blocked = blocklist.get("blocked", [])
if not isinstance(blocked, list):
    print(f"[ERROR] {blocklist_path} must contain a 'blocked' array.", file=sys.stderr)
    sys.exit(1)

os_release = load_os_release()

for entry in blocked:
    if not isinstance(entry, dict):
        continue
    match = entry.get("match", {})
    if not isinstance(match, dict):
        continue
    if all(os_release.get(k) == v for k, v in match.items()):
        reason = entry.get("reason", "Unsupported distribution for Hyprland PPA.")
        ident = entry.get("id", "unknown")
        print(f"{RED}❌ Distro blocked{RESET}")
        print(f"   {CYAN}ID     :{RESET} {ident}")
        print(f"   {CYAN}Reason :{RESET} {reason}")
        print(f"   {CYAN}Matched:{RESET} {match}")
        print(f"\n{YELLOW}🛈 The Hyprland PPA cannot be used on this distribution.{RESET}")
        print()
        sys.exit(12)
print(f"{GREEN}✅ Distro not on the Hyprland PPA blocklist.{RESET}\n")
print(f"{GREEN}✅ Distro not on the Hyprland PPA blocklist.{RESET}")
PYCODE

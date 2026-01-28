#!/usr/bin/env bash
# update-hyprland.sh (Ubuntu 26.04 edition)
# Compile or dry-run the Hyprland stack (Hyprland + core libraries) using the
# same install-scripts/ modules leveraged by install.sh.
#
# Highlights:
#   - Centralized version control via hypr-tags.env
#   - Optional tag refresh (--fetch-latest) and selective overrides (--set)
#   - Dry-run support for CI/testing
#   - Module subset selection (--only/--skip) and dependency enforcement
#   - Compatible with Ubuntu 26.04 source-build workflow
#
# Usage examples:
#   chmod +x ./update-hyprland.sh
#   ./update-hyprland.sh --dry-run
#   ./update-hyprland.sh --install
#   ./update-hyprland.sh --fetch-latest --dry-run
#   ./update-hyprland.sh --set HYPRLAND=v0.53.3 --install
#   ./update-hyprland.sh --only hyprland,hyprwire --install
#   ./update-hyprland.sh --skip hyprland-qt-support --dry-run

set -euo pipefail

REPO_ROOT=$(pwd)
TAGS_FILE="$REPO_ROOT/hypr-tags.env"
LOG_DIR="$REPO_ROOT/Install-Logs"
mkdir -p "$LOG_DIR"
TS=$(date +%F-%H%M%S)
SUMMARY_LOG="$LOG_DIR/update-hypr-$TS.log"

# Default module order for Ubuntu Hyprland stack
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
DO_INSTALL=0
DO_DRY_RUN=0
FETCH_LATEST=0
RESTORE=0
VIA_HELPER=0
NO_FETCH=0
USE_SYSTEM_LIBS=1
AUTO_FALLBACK=0
MINIMAL=0
FORCE_UPDATE=0
ONLY_LIST=""
SKIP_LIST=""
SET_ARGS=()

usage() {
    sed -n '2,80p' "$0" | sed -n '/^#/p' | sed 's/^#\s\{0,1\}//'
    cat <<EOF

Options:
  -h, --help            Show this help and exit
      --with-deps       Run install-scripts/00-dependencies.sh first
      --dry-run         Compile only; skip installation
      --install         Compile + install
      --fetch-latest    Query GitHub for the newest release tags
      --force-update    Override pinned values in hypr-tags.env
      --restore         Restore the most recent hypr-tags.env backup
      --only LIST       Build a comma-separated subset of modules
      --skip LIST       Skip modules (comma-separated)
      --bundled         Build Hyprland with bundled hypr* libs
      --system          Prefer system-installed hypr* libs (default)
      --via-helper      Use dry-run-build.sh for summary output
      --minimal         Build a short stack (core deps + Hyprland)
      --no-fetch        Skip auto tag refresh on install runs
      --auto            Retry with bundled libs if system libs fail
      --set K=V [...]   Override specific tags (e.g., HYPRLAND=v0.53.3)
EOF
}

ensure_tags_file() {
    if [[ ! -f "$TAGS_FILE" ]]; then
        cat >"$TAGS_FILE" <<'EOF'
# Default Hyprland stack versions (Ubuntu 26.04)
HYPRLAND_TAG=v0.53.3
AQUAMARINE_TAG=v0.10.0
HYPRUTILS_TAG=v0.11.0
HYPRLANG_TAG=v0.6.8
HYPRGRAPHICS_TAG=v0.5.0
HYPRWAYLAND_SCANNER_TAG=v0.4.5
HYPRLAND_PROTOCOLS_TAG=v0.7.0
HYPRLAND_QT_SUPPORT_TAG=v0.1.0
HYPRLAND_QTUTILS_TAG=v0.1.5
HYPRWIRE_TAG=v0.2.1
WAYLAND_PROTOCOLS_TAG=1.46
EOF
    fi
}

backup_tags() {
    ensure_tags_file
    cp "$TAGS_FILE" "$TAGS_FILE.bak-$TS"
    echo "[INFO] Backed up $TAGS_FILE to $TAGS_FILE.bak-$TS" | tee -a "$SUMMARY_LOG"
}

restore_tags() {
    latest_bak=$(ls -1t "$TAGS_FILE".bak-* 2>/dev/null | head -n1 || true)
    if [[ -z "$latest_bak" ]]; then
        echo "[ERROR] No backup tags file found." | tee -a "$SUMMARY_LOG"
        exit 1
    fi
    cp "$latest_bak" "$TAGS_FILE"
    echo "[INFO] Restored tags from $latest_bak" | tee -a "$SUMMARY_LOG"
}

set_tags_from_args() {
    ensure_tags_file
    backup_tags
    declare -A map
    while IFS='=' read -r k v; do
        [[ -z "$k" || "$k" =~ ^# ]] && continue
        map[$k]="$v"
    done <"$TAGS_FILE"

    for kv in "${SET_ARGS[@]}"; do
        key="${kv%%=*}"
        val="${kv#*=}"
        case "$key" in
            HYPRLAND|hyprland) key=HYPRLAND_TAG ;;
            AQUAMARINE|aquamarine) key=AQUAMARINE_TAG ;;
            HYPRUTILS|hyprutils) key=HYPRUTILS_TAG ;;
            HYPRLANG|hyprlang) key=HYPRLANG_TAG ;;
            HYPRGRAPHICS|hyprgraphics) key=HYPRGRAPHICS_TAG ;;
            HYPRWAYLAND_SCANNER|hyprwayland-scanner|hyprwayland_scanner) key=HYPRWAYLAND_SCANNER_TAG ;;
            HYPRLAND_PROTOCOLS|hyprland-protocols|hyprland_protocols) key=HYPRLAND_PROTOCOLS_TAG ;;
            HYPRLAND_QT_SUPPORT|hyprland-qt-support) key=HYPRLAND_QT_SUPPORT_TAG ;;
            HYPRLAND_QTUTILS|hyprland-qtutils) key=HYPRLAND_QTUTILS_TAG ;;
            HYPRWIRE|hyprwire) key=HYPRWIRE_TAG ;;
            WAYLAND_PROTOCOLS|wayland-protocols) key=WAYLAND_PROTOCOLS_TAG ;;
        esac
        map[$key]="$val"
    done

    {
        for k in "${!map[@]}"; do
            printf "%s=%s\n" "$k" "${map[$k]}"
        done | sort
    } >"$TAGS_FILE"
    echo "[INFO] Updated $TAGS_FILE with provided tags" | tee -a "$SUMMARY_LOG"
}

fetch_latest_tags() {
    ensure_tags_file
    backup_tags
    CHANGES_FILE="$LOG_DIR/update-delta-$TS.log"
    : >"$CHANGES_FILE"

    if ! command -v curl >/dev/null 2>&1; then
        echo "[ERROR] curl is required." | tee -a "$SUMMARY_LOG"
        exit 1
    fi

    declare -A existing
    while IFS='=' read -r k v; do
        [[ -z "$k" || "$k" =~ ^# ]] && continue
        existing[$k]="$v"
    done <"$TAGS_FILE"

    declare -A repos=(
        [HYPRLAND_TAG]="hyprwm/Hyprland"
        [AQUAMARINE_TAG]="hyprwm/aquamarine"
        [HYPRUTILS_TAG]="hyprwm/hyprutils"
        [HYPRLANG_TAG]="hyprwm/hyprlang"
        [HYPRGRAPHICS_TAG]="hyprwm/hyprgraphics"
        [HYPRWAYLAND_SCANNER_TAG]="hyprwm/hyprwayland-scanner"
        [HYPRLAND_PROTOCOLS_TAG]="hyprwm/hyprland-protocols"
        [HYPRLAND_QT_SUPPORT_TAG]="hyprwm/hyprland-qt-support"
        [HYPRLAND_QTUTILS_TAG]="hyprwm/hyprland-qtutils"
        [HYPRWIRE_TAG]="hyprwm/hyprwire"
    )

    declare -A tags
    for key in "${!repos[@]}"; do
        repo="${repos[$key]}"
        url="https://api.github.com/repos/$repo/releases/latest"
        echo "[INFO] Fetching latest tag for $repo" | tee -a "$SUMMARY_LOG"
        body=$(curl -fsSL "$url" || true)
        if [[ -z "$body" ]]; then
            echo "[WARN] Empty response for $repo; leaving $key unchanged" | tee -a "$SUMMARY_LOG"
            continue
        fi
        if command -v jq >/dev/null 2>&1; then
            tag=$(printf '%s' "$body" | jq -r '.tag_name // empty')
        else
            tag=$(printf '%s' "$body" | grep -m1 '"tag_name"' | sed -E 's/.*"tag_name"\s*:\s*"([^"]+)".*/\1/')
        fi
        [[ -n "$tag" ]] && tags[$key]="$tag"
    done

    declare -A map
    while IFS='=' read -r k v; do
        [[ -z "$k" || "$k" =~ ^# ]] && continue
        map[$k]="$v"
    done <"$TAGS_FILE"

    changes=()
    for k in "${!tags[@]}"; do
        if [[ $FORCE_UPDATE -eq 1 ]]; then
            map[$k]="${tags[$k]}"
            changes+=("$k: ${existing[$k]:-unset} -> ${tags[$k]}")
        else
            if [[ "${existing[$k]:-}" =~ ^(auto|latest)$ ]] || [[ -z "${existing[$k]:-}" ]]; then
                map[$k]="${tags[$k]}"
                changes+=("$k: ${existing[$k]:-unset} -> ${tags[$k]}")
            fi
        fi
    done

    if [[ -t 0 && ${#changes[@]} -gt 0 ]]; then
        printf "\nPlanned tag updates:\n"
        printf "%s\n" "${changes[@]}"
        printf "\nWrite changes to %s? [Y/n]: " "$TAGS_FILE"
        read -r ans || true
        ans=${ans:-Y}
        case "$ans" in
            [nN]*) echo "[INFO] Tag update aborted." | tee -a "$SUMMARY_LOG"; return 0 ;;
        esac
    else
        printf "%s\n" "${changes[@]}" >>"$CHANGES_FILE" || true
    fi

    {
        for k in "${!map[@]}"; do
            printf "%s=%s\n" "$k" "${map[$k]}"
        done | sort
    } >"$TAGS_FILE"
    echo "[INFO] Refreshed tags written to $TAGS_FILE" | tee -a "$SUMMARY_LOG"
}

run_stack() {
    # shellcheck disable=SC1090
    source "$TAGS_FILE"
    while IFS='=' read -r _k _v; do
        [[ -z "${_k:-}" || "$_k" =~ ^# ]] && continue
        if [[ "$_k" == *"_TAG" || "$_k" == "WAYLAND_PROTOCOLS_TAG" ]]; then
            export "$_k"
        fi
    done <"$TAGS_FILE"

    export PATH="/usr/local/bin:${PATH}"
    export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:${PKG_CONFIG_PATH:-}"
    export CMAKE_PREFIX_PATH="/usr/local:${CMAKE_PREFIX_PATH:-}"

    if [[ $USE_SYSTEM_LIBS -eq 1 ]]; then
        export USE_SYSTEM_HYPRLIBS=1
    else
        export USE_SYSTEM_HYPRLIBS=0
    fi

    if [[ $WITH_DEPS -eq 1 ]]; then
        echo "[INFO] Installing dependencies via 00-dependencies.sh" | tee -a "$SUMMARY_LOG"
        if ! "$REPO_ROOT/install-scripts/00-dependencies.sh"; then
            echo "[ERROR] Dependencies installation failed." | tee -a "$SUMMARY_LOG"
            exit 1
        fi
    fi

    local modules
    if [[ -n "$ONLY_LIST" ]]; then
        IFS=',' read -r -a modules <<<"$ONLY_LIST"
    else
        if [[ $MINIMAL -eq 1 ]]; then
            modules=(wayland-protocols-src hyprland-protocols hyprutils hyprlang aquamarine hyprgraphics hyprwayland-scanner hyprwire hyprland)
        else
            modules=("${DEFAULT_MODULES[@]}")
        fi
    fi

    if [[ -n "$SKIP_LIST" ]]; then
        IFS=',' read -r -a _skips <<<"$SKIP_LIST"
        local filtered=()
        for m in "${modules[@]}"; do
            skip_it=0
            for s in "${_skips[@]}"; do
                [[ "$m" == "$s" ]] && skip_it=1
            done
            [[ $skip_it -eq 0 ]] && filtered+=("$m")
        done
        modules=("${filtered[@]}")
    fi

    if [[ $DO_INSTALL -eq 1 ]]; then
        if [[ $NO_FETCH -eq 0 ]]; then
            need_fetch=0
            for m in "${modules[@]}"; do
                [[ "$m" == "hyprland" ]] && need_fetch=1
            done
            if [[ $need_fetch -eq 1 ]]; then
                echo "[INFO] Auto-fetching latest tags for Hyprland stack" | tee -a "$SUMMARY_LOG"
                fetch_latest_tags
            fi
        fi
        local has_wp=0 has_hlprot=0 has_utils=0 has_lang=0 has_aqua=0 has_wire=0
        for m in "${modules[@]}"; do
            [[ "$m" == "wayland-protocols-src" ]] && has_wp=1
            [[ "$m" == "hyprland-protocols" ]] && has_hlprot=1
            [[ "$m" == "hyprutils" ]] && has_utils=1
            [[ "$m" == "hyprlang" ]] && has_lang=1
            [[ "$m" == "aquamarine" ]] && has_aqua=1
            [[ "$m" == "hyprwire" ]] && has_wire=1
        done
        if [[ $has_wire -eq 0 ]]; then
            modules=("hyprwire" "${modules[@]}")
        fi
        if [[ $has_aqua -eq 0 ]]; then
            modules=("aquamarine" "${modules[@]}")
        fi
        if [[ $has_lang -eq 0 ]]; then
            modules=("hyprlang" "${modules[@]}")
        fi
        if [[ $has_utils -eq 0 ]]; then
            modules=("hyprutils" "${modules[@]}")
        fi
        if [[ $has_hlprot -eq 0 ]]; then
            modules=("hyprland-protocols" "${modules[@]}")
        fi
        if [[ $has_wp -eq 0 ]]; then
            modules=("wayland-protocols-src" "${modules[@]}")
        fi
    fi

    declare -A results
    for mod in "${modules[@]}"; do
        local script="$REPO_ROOT/install-scripts/$mod.sh"
        echo -e "\n=== $mod ===" | tee -a "$SUMMARY_LOG"
        [[ -f "$script" ]] || { echo "[WARN] Missing $script" | tee -a "$SUMMARY_LOG"; results[$mod]="MISSING"; continue; }
        chmod +x "$script" || true
        if [[ $DO_DRY_RUN -eq 1 ]]; then
            if DRY_RUN=1 "$script"; then results[$mod]="PASS"; else results[$mod]="FAIL"; fi
        else
            if "$script"; then results[$mod]="INSTALLED"; else results[$mod]="FAIL"; fi
        fi
    done

    if [[ $DO_INSTALL -eq 1 ]]; then
        echo "[INFO] Ensuring /usr/local/lib is in dynamic linker path" | tee -a "$SUMMARY_LOG"
        if ! sudo grep -qxF "/usr/local/lib" /etc/ld.so.conf.d/usr-local.conf 2>/dev/null; then
            echo "/usr/local/lib" | sudo tee -a /etc/ld.so.conf.d/usr-local.conf >/dev/null
        fi
        sudo ldconfig || true
    fi

    {
        printf "\nSummary:\n"
        for mod in "${modules[@]}"; do
            printf "%-24s %s\n" "$mod" "${results[$mod]:-SKIPPED}"
        done
        if [[ -f "$TAGS_FILE" ]]; then
            printf "\nVersions (from %s):\n" "$TAGS_FILE"
            grep -E '^[A-Z0-9_]+=' "$TAGS_FILE" | sort
        fi
        if [[ -f "$LOG_DIR/update-delta-$TS.log" ]]; then
            printf "\nChanges applied this run:\n"
            cat "$LOG_DIR/update-delta-$TS.log"
        fi
        printf "\nLogs under: %s. This run: %s\n" "$LOG_DIR" "$SUMMARY_LOG"
    } | tee -a "$SUMMARY_LOG"

    local failed=0
    for mod in "${modules[@]}"; do
        [[ "${results[$mod]:-}" == FAIL ]] && failed=1
    done
    return $failed
}

# Parse CLI args
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) usage; exit 0 ;;
        --with-deps) WITH_DEPS=1; shift ;;
        --dry-run) DO_DRY_RUN=1; shift ;;
        --install) DO_INSTALL=1; shift ;;
        --fetch-latest) FETCH_LATEST=1; shift ;;
        --force-update) FORCE_UPDATE=1; shift ;;
        --restore) RESTORE=1; shift ;;
        --via-helper) VIA_HELPER=1; shift ;;
        --no-fetch) NO_FETCH=1; shift ;;
        --only) ONLY_LIST=${2:-}; shift 2 ;;
        --bundled) USE_SYSTEM_LIBS=0; shift ;;
        --system) USE_SYSTEM_LIBS=1; shift ;;
        --auto) AUTO_FALLBACK=1; shift ;;
        --minimal) MINIMAL=1; shift ;;
        --skip) SKIP_LIST=${2:-}; shift 2 ;;
        --set)
            shift
            while [[ $# -gt 0 && "$1" != --* ]]; do
                SET_ARGS+=("$1")
                shift
            done
            ;;
        *) echo "Unknown argument: $1" >&2; exit 2 ;;
    esac
done

if [[ $DO_INSTALL -eq 1 && $DO_DRY_RUN -eq 1 ]]; then
    echo "[ERROR] Use either --dry-run or --install, not both." | tee -a "$SUMMARY_LOG"
    exit 2
fi

ensure_tags_file
[[ ${FORCE:-0} -eq 1 ]] && FORCE_UPDATE=1

[[ $RESTORE -eq 1 ]] && restore_tags
[[ ${#SET_ARGS[@]} -gt 0 ]] && set_tags_from_args
[[ $FETCH_LATEST -eq 1 ]] && fetch_latest_tags

if [[ $DO_DRY_RUN -eq 0 && $DO_INSTALL -eq 0 ]]; then
    echo "[INFO] No build option specified. Defaulting to --dry-run." | tee -a "$SUMMARY_LOG"
    DO_DRY_RUN=1
fi

if [[ $VIA_HELPER -eq 1 ]]; then
    if [[ $DO_INSTALL -eq 1 ]]; then
        echo "[ERROR] --via-helper cannot be combined with --install." | tee -a "$SUMMARY_LOG"
        exit 2
    fi
    # shellcheck disable=SC1090
    source "$TAGS_FILE"
    while IFS='=' read -r _k _v; do
        [[ -z "${_k:-}" || "$_k" =~ ^# ]] && continue
        if [[ "$_k" == *"_TAG" || "$_k" == "WAYLAND_PROTOCOLS_TAG" ]]; then
            export "$_k"
        fi
    done <"$TAGS_FILE"
    helper="$REPO_ROOT/dry-run-build.sh"
    if [[ ! -x "$helper" ]]; then
        echo "[ERROR] dry-run-build.sh not found or not executable at $helper" | tee -a "$SUMMARY_LOG"
        exit 1
    fi
    args=()
    [[ $WITH_DEPS -eq 1 ]] && args+=(--with-deps)
    [[ -n "$ONLY_LIST" ]] && args+=(--only "$ONLY_LIST")
    [[ -n "$SKIP_LIST" ]] && args+=(--skip "$SKIP_LIST")
    echo "[INFO] Delegating to dry-run-build.sh ${args[*]}" | tee -a "$SUMMARY_LOG"
    "$helper" "${args[@]}"
    exit $?
fi

if run_stack; then
    exit 0
else
    rc=$?
    if [[ $AUTO_FALLBACK -eq 1 && $USE_SYSTEM_LIBS -eq 1 ]]; then
        echo "[WARN] Build failed with system libs. Retrying with bundled subprojects..." | tee -a "$SUMMARY_LOG"
        USE_SYSTEM_LIBS=0
        if run_stack; then
            exit 0
        else
            exit $?
        fi
    else
        exit $rc
    fi
fi

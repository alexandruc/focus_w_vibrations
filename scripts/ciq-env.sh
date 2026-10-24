#!/usr/bin/env bash

# Project-local Connect IQ environment. Source this file from the project root
# or invoke it by its path; SDK/JDK/device packs are installed separately.
_CIQ_SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CIQ_PROJECT_ROOT="$(cd -- "$_CIQ_SCRIPT_DIR/.." && pwd)"
CIQ_TOOLS_HOME="${CIQ_TOOLS_HOME:-$CIQ_PROJECT_ROOT/.ciq-tools}"
CIQ_DEVICE_FR245="${CIQ_DEVICE_FR245:-fr245}"
CIQ_DEVICE_FR970="${CIQ_DEVICE_FR970:-fr970}"

# Find an SDK Manager home and its selected SDK unless the caller supplied CIQ_HOME.
if [ -z "${CIQ_HOME:-}" ]; then
    if [ -n "${CIQ_USER_HOME:-}" ]; then
        _CIQ_HOME_CANDIDATES=("$CIQ_USER_HOME")
    else
        _CIQ_HOME_CANDIDATES=("$CIQ_TOOLS_HOME/home" "${HOME:-}")
    fi
    for _candidate_home in "${_CIQ_HOME_CANDIDATES[@]}"; do
        [ -n "$_candidate_home" ] || continue
        _sdk_config="$_candidate_home/.Garmin/ConnectIQ/current-sdk.cfg"
        if [ -r "$_sdk_config" ]; then
            CIQ_USER_HOME="$_candidate_home"
            CIQ_HOME="$(python3 -c 'from pathlib import Path; import sys; print(Path(sys.argv[1]).read_text().strip())' "$_sdk_config")"
            break
        fi
    done
fi

CIQ_USER_HOME="${CIQ_USER_HOME:-$CIQ_TOOLS_HOME/home}"
if [ -z "${CIQ_HOME:-}" ] || [ ! -x "$CIQ_HOME/bin/monkeyc" ]; then
    printf 'Connect IQ SDK not found. Set CIQ_HOME to the SDK root, or install/select an SDK in CIQ_USER_HOME.\n' >&2
    return 1 2>/dev/null || exit 1
fi

if [ -z "${JAVA_HOME:-}" ]; then
    if [ -x "$CIQ_TOOLS_HOME/java/temurin-21/bin/java" ]; then
        JAVA_HOME="$CIQ_TOOLS_HOME/java/temurin-21"
    elif command -v java >/dev/null 2>&1; then
        _java_bin="$(readlink -f "$(command -v java)")"
        JAVA_HOME="${_java_bin%/bin/java}"
    fi
fi
if [ -z "${JAVA_HOME:-}" ] || [ ! -x "$JAVA_HOME/bin/java" ]; then
    printf 'Java not found. Set JAVA_HOME to a supported JDK (Connect IQ SDK 9 requires JDK 21).\n' >&2
    return 1 2>/dev/null || exit 1
fi

mkdir -p "$CIQ_USER_HOME"
HOME="$CIQ_USER_HOME"
JAVA_TOOL_OPTIONS="${JAVA_TOOL_OPTIONS:+$JAVA_TOOL_OPTIONS }-Duser.home=$CIQ_USER_HOME"
CIQ_KEY="${CIQ_KEY:-$CIQ_TOOLS_HOME/developer_key.der}"
CIQ_MANAGER="${CIQ_MANAGER:-$CIQ_TOOLS_HOME/sdk-manager-cli/connect-iq-sdk-manager}"
CIQ_SIMULATOR_LIBS="${CIQ_SIMULATOR_LIBS:-$CIQ_TOOLS_HOME/runtime-libs/ubuntu-jammy/usr/lib/x86_64-linux-gnu}"
PATH="$JAVA_HOME/bin:$CIQ_HOME/bin${CIQ_MANAGER:+:$(dirname -- "$CIQ_MANAGER")}:$PATH"
export CIQ_PROJECT_ROOT CIQ_TOOLS_HOME CIQ_USER_HOME CIQ_HOME JAVA_HOME JAVA_TOOL_OPTIONS
export CIQ_KEY CIQ_MANAGER CIQ_SIMULATOR_LIBS CIQ_DEVICE_FR245 CIQ_DEVICE_FR970 HOME PATH
hash -r 2>/dev/null || true

ciq_manager() {
    if [ ! -x "$CIQ_MANAGER" ]; then
        printf 'SDK Manager CLI not found at %s; set CIQ_MANAGER to its executable.\n' "$CIQ_MANAGER" >&2
        return 1
    fi
    HOME="$CIQ_USER_HOME" "$CIQ_MANAGER" "$@"
}

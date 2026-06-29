#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UNAME_S="$(uname -s)"
MODEL_PRESET_ARG="${1:-}"

case "$UNAME_S" in
  Linux)
    if [[ -n "$MODEL_PRESET_ARG" ]]; then
      exec "$ROOT_DIR/scripts/ubuntu/install_startup_service.sh" "$MODEL_PRESET_ARG"
    fi

    exec "$ROOT_DIR/scripts/ubuntu/install_startup_service.sh"
    ;;
  Darwin)
    printf 'Autostart installer is not set up for macOS yet.\n' >&2
    printf 'Ubuntu/Linux systemd is supported right now via scripts/ubuntu/install_startup_service.sh.\n' >&2
    exit 1
    ;;
  *)
    printf 'Unsupported platform for autostart installer: %s\n' "$UNAME_S" >&2
    exit 1
    ;;
esac

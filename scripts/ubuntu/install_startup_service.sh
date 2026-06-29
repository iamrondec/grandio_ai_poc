#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="grandio-startup.service"
SERVICE_TEMPLATE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$SERVICE_NAME"
INSTALL_PATH="/etc/systemd/system/$SERVICE_NAME"
RUN_USER="${SUDO_USER:-${USER:-admin}}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MODEL_PRESET_TO_INSTALL="${1:-${MODEL_PRESET:-qwen2.5-7b}}"

source "$ROOT_DIR/scripts/shared/model_config.sh"

MODEL_PRESET="$MODEL_PRESET_TO_INSTALL"
resolve_model_config

if [[ ! -f "$SERVICE_TEMPLATE" ]]; then
  printf 'Missing service template: %s\n' "$SERVICE_TEMPLATE" >&2
  exit 1
fi

TMP_FILE="$(mktemp)"
trap 'rm -f "$TMP_FILE"' EXIT

sed \
  -e "s|^User=.*|User=$RUN_USER|" \
  -e "s|^WorkingDirectory=.*|WorkingDirectory=$ROOT_DIR|" \
  -e "s|^Environment=.*|Environment=MODEL_PRESET=$MODEL_PRESET|" \
  -e "s|^ExecStart=.*|ExecStart=$ROOT_DIR/start_server.sh|" \
  "$SERVICE_TEMPLATE" > "$TMP_FILE"

sudo install -m 0644 "$TMP_FILE" "$INSTALL_PATH"
sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"
sudo systemctl restart "$SERVICE_NAME"

printf 'Installed and started %s\n' "$SERVICE_NAME"
printf 'Model preset: %s\n' "$MODEL_PRESET"
printf 'Check status with: sudo systemctl status %s\n' "$SERVICE_NAME"

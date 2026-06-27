#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$ROOT_DIR/logs"
LOG_FILE="$LOG_DIR/llama-server.log"

cd "$ROOT_DIR"

if [[ -f "$ROOT_DIR/venv/bin/activate" ]]; then
  # Support the existing venv name first.
  source "$ROOT_DIR/venv/bin/activate"
elif [[ -f "$ROOT_DIR/.venv/bin/activate" ]]; then
  source "$ROOT_DIR/.venv/bin/activate"
fi

mkdir -p "$LOG_DIR"

exec make serve 2>&1 | tee -a "$LOG_FILE"

#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

MODEL_FILE="${MODEL_FILE:-Qwen2.5-14B-Instruct-Q4_K_M.gguf}" \
  "$ROOT_DIR/scripts/ubuntu/run_qwen.sh" "$@"

#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

MODEL_PRESET="${MODEL_PRESET:-qwen2.5-14b}" \
  "$ROOT_DIR/scripts/ubuntu/run_qwen.sh" "$@"

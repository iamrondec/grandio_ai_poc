#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

MODEL_REPO="${MODEL_REPO:-bartowski/Qwen2.5-14B-Instruct-GGUF}" \
MODEL_FILE="${MODEL_FILE:-Qwen2.5-14B-Instruct-Q4_K_M.gguf}" \
  "$ROOT_DIR/scripts/ubuntu/setup_llama_cpp_qwen.sh" "$@"

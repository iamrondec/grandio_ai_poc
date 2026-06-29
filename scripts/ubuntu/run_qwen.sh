#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LLAMA_CPP_DIR="${LLAMA_CPP_DIR:-$ROOT_DIR/vendor/llama.cpp}"
source "$ROOT_DIR/scripts/shared/model_config.sh"
THREADS="${THREADS:-$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)}"
CONTEXT_SIZE="${CONTEXT_SIZE:-4096}"
N_GPU_LAYERS="${N_GPU_LAYERS:-99}"
LLAMA_CLI="$LLAMA_CPP_DIR/build/bin/llama-cli"

if [[ ! -x "$LLAMA_CLI" ]]; then
  printf 'llama-cli not found at %s\n' "$LLAMA_CLI" >&2
  printf 'Run ./scripts/ubuntu/setup_llama_cpp_qwen.sh first.\n' >&2
  exit 1
fi

ensure_selected_model

if [[ $# -gt 0 ]]; then
  "$LLAMA_CLI" \
    -m "$MODEL_PATH" \
    -t "$THREADS" \
    -c "$CONTEXT_SIZE" \
    -ngl "$N_GPU_LAYERS" \
    -p "$*"
else
  "$LLAMA_CLI" \
    -m "$MODEL_PATH" \
    -t "$THREADS" \
    -c "$CONTEXT_SIZE" \
    -ngl "$N_GPU_LAYERS" \
    -cnv
fi

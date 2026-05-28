#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LLAMA_CPP_DIR="${LLAMA_CPP_DIR:-$ROOT_DIR/vendor/llama.cpp}"
MODEL_DIR="${MODEL_DIR:-$ROOT_DIR/models}"
MODEL_FILE="${MODEL_FILE:-Qwen2.5-7B-Instruct-Q4_K_S.gguf}"
THREADS="${THREADS:-$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)}"
CONTEXT_SIZE="${CONTEXT_SIZE:-4096}"
N_GPU_LAYERS="${N_GPU_LAYERS:-99}"
HOST="${HOST:-127.0.0.1}"
PORT="${PORT:-8080}"
MODEL_PATH="$MODEL_DIR/$MODEL_FILE"
LLAMA_SERVER="$LLAMA_CPP_DIR/build/bin/llama-server"

if [[ ! -x "$LLAMA_SERVER" ]]; then
  printf 'llama-server not found at %s\n' "$LLAMA_SERVER" >&2
  printf 'Run ./scripts/ubuntu/setup_llama_cpp_qwen.sh first.\n' >&2
  exit 1
fi

if [[ ! -f "$MODEL_PATH" ]]; then
  printf 'Model file not found at %s\n' "$MODEL_PATH" >&2
  printf 'Run ./scripts/ubuntu/setup_llama_cpp_qwen.sh first.\n' >&2
  exit 1
fi

"$LLAMA_SERVER" \
  -m "$MODEL_PATH" \
  -t "$THREADS" \
  -c "$CONTEXT_SIZE" \
  -ngl "$N_GPU_LAYERS" \
  --host "$HOST" \
  --port "$PORT"

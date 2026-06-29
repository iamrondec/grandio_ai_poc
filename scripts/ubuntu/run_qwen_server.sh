#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LLAMA_CPP_DIR="${LLAMA_CPP_DIR:-$ROOT_DIR/vendor/llama.cpp}"
source "$ROOT_DIR/scripts/shared/model_config.sh"
SYSTEM_PROMPT_FILE="${SYSTEM_PROMPT_FILE:-$ROOT_DIR/prompts/system_prompt.txt}"
THREADS="${THREADS:-$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)}"
CONTEXT_SIZE="${CONTEXT_SIZE:-4096}"
N_GPU_LAYERS="${N_GPU_LAYERS:-99}"
HOST="${HOST:-127.0.0.1}"
PORT="${PORT:-8080}"
LLAMA_SERVER="$LLAMA_CPP_DIR/build/bin/llama-server"
SERVER_ARGS=()

supports_system_prompt_file() {
  "$LLAMA_SERVER" --help 2>&1 | grep -q -- '--system-prompt-file'
}

if [[ ! -x "$LLAMA_SERVER" ]]; then
  printf 'llama-server not found at %s\n' "$LLAMA_SERVER" >&2
  printf 'Run ./scripts/ubuntu/setup_llama_cpp_qwen.sh first.\n' >&2
  exit 1
fi

ensure_selected_model

if [[ -f "$SYSTEM_PROMPT_FILE" ]] && supports_system_prompt_file; then
  SERVER_ARGS+=(--system-prompt-file "$SYSTEM_PROMPT_FILE")
fi

"$LLAMA_SERVER" \
  -m "$MODEL_PATH" \
  -t "$THREADS" \
  -c "$CONTEXT_SIZE" \
  -ngl "$N_GPU_LAYERS" \
  --host "$HOST" \
  --port "$PORT" \
  "${SERVER_ARGS[@]}"

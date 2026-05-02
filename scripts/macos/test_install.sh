#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
VENV_DIR="${VENV_DIR:-$ROOT_DIR/.venv}"
LLAMA_CPP_DIR="${LLAMA_CPP_DIR:-$ROOT_DIR/vendor/llama.cpp}"
MODEL_DIR="${MODEL_DIR:-$ROOT_DIR/models}"
MODEL_FILE="${MODEL_FILE:-Qwen2.5-7B-Instruct-Q4_K_S.gguf}"
LLAMA_CLI="$LLAMA_CPP_DIR/build/bin/llama-cli"
LLAMA_SERVER="$LLAMA_CPP_DIR/build/bin/llama-server"
MODEL_PATH="$MODEL_DIR/$MODEL_FILE"

fail() {
  printf '[test] %s\n' "$1" >&2
  exit 1
}

printf '[test] Checking virtualenv...\n'
[[ -x "$VENV_DIR/bin/python" ]] || fail "Missing virtualenv Python at $VENV_DIR/bin/python"

printf '[test] Checking huggingface-cli...\n'
[[ -x "$VENV_DIR/bin/huggingface-cli" ]] || fail "Missing huggingface-cli in $VENV_DIR/bin"

printf '[test] Checking llama.cpp build...\n'
[[ -x "$LLAMA_CLI" ]] || fail "Missing llama-cli at $LLAMA_CLI"
[[ -x "$LLAMA_SERVER" ]] || fail "Missing llama-server at $LLAMA_SERVER"

printf '[test] Checking model file...\n'
[[ -f "$MODEL_PATH" ]] || fail "Missing model file at $MODEL_PATH"

printf '[test] Verifying llama-cli responds...\n'
"$LLAMA_CLI" --help >/dev/null || fail "llama-cli --help failed"

printf '\n[test] All checks passed.\n'
printf '[test] Launch with: %s\n' "$ROOT_DIR/scripts/macos/run_qwen.sh"
printf '[test] Web UI with: %s\n' "$ROOT_DIR/scripts/macos/run_qwen_server.sh"

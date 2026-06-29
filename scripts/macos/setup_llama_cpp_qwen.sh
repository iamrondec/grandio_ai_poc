#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
VENV_DIR="${VENV_DIR:-$ROOT_DIR/.venv}"
VENDOR_DIR="$ROOT_DIR/vendor"
LLAMA_CPP_DIR="${LLAMA_CPP_DIR:-$VENDOR_DIR/llama.cpp}"
source "$ROOT_DIR/scripts/shared/model_config.sh"

log() {
  printf '\n[%s] %s\n' "setup" "$1"
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$1" >&2
    exit 1
  fi
}

build_llama_cpp() {
  cd "$LLAMA_CPP_DIR"
  log "Building llama.cpp with Metal enabled"
  cmake -B build -DGGML_METAL=ON
  cmake --build build --config Release -j
}

main() {
  require_cmd git
  require_cmd python3
  require_cmd cmake

  resolve_model_config

  mkdir -p "$VENDOR_DIR" "$MODEL_DIR"

  if [[ ! -d "$VENV_DIR" ]]; then
    log "Creating virtual environment at $VENV_DIR"
    python3 -m venv "$VENV_DIR"
  else
    log "Using existing virtual environment at $VENV_DIR"
  fi

  log "Installing Python dependencies"
  "$VENV_DIR/bin/python" -m pip install --upgrade pip
  "$VENV_DIR/bin/pip" install --upgrade "huggingface_hub[cli]"

  if [[ ! -d "$LLAMA_CPP_DIR/.git" ]]; then
    log "Cloning llama.cpp into $LLAMA_CPP_DIR"
    git clone https://github.com/ggml-org/llama.cpp "$LLAMA_CPP_DIR"
  else
    log "Using existing llama.cpp checkout at $LLAMA_CPP_DIR"
  fi

  build_llama_cpp
  download_selected_model

  log "Setup complete"
  printf 'Selected model: %s\n' "$MODEL_LABEL"
  printf 'Model path: %s\n' "$MODEL_PATH"
  printf 'Run with: %s\n' "$ROOT_DIR/scripts/macos/run_qwen.sh"
}

main "$@"

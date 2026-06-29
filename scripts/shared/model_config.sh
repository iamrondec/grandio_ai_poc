#!/usr/bin/env bash

if [[ -z "${ROOT_DIR:-}" ]]; then
  ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi

VENV_DIR="${VENV_DIR:-$ROOT_DIR/.venv}"
MODEL_DIR="${MODEL_DIR:-$ROOT_DIR/models}"
MODEL_PRESET="${MODEL_PRESET:-qwen2.5-7b}"
MODEL_LABEL="${MODEL_LABEL:-}"
MODEL_REPO="${MODEL_REPO:-}"
MODEL_FILE="${MODEL_FILE:-}"
MODEL_GGUF_GLOB="${MODEL_GGUF_GLOB:-}"
MODEL_MENU_PRESETS=(
  "gemma3-12b"
  "qwen2.5-14b"
  "qwen3-8b"
  "deepseek-r1-distill-qwen-14b"
  "qwen2.5-7b"
)

model_log() {
  printf '\n[%s] %s\n' "${1:-model}" "$2"
}

model_menu_label() {
  case "$1" in
    gemma3-12b)
      printf '%s\n' "Gemma 3 12B"
      ;;
    qwen2.5-14b)
      printf '%s\n' "Qwen2.5 14B"
      ;;
    qwen3-8b)
      printf '%s\n' "Qwen3 8B"
      ;;
    deepseek-r1-distill-qwen-14b)
      printf '%s\n' "DeepSeek-R1-Distill-Qwen-14B"
      ;;
    qwen2.5-7b)
      printf '%s\n' "Qwen2.5 7B"
      ;;
    *)
      printf '%s\n' "$1"
      ;;
  esac
}

find_hf_cli() {
  if [[ -x "$VENV_DIR/bin/hf" ]]; then
    printf '%s\n' "$VENV_DIR/bin/hf"
    return
  fi

  if [[ -x "$VENV_DIR/bin/huggingface-cli" ]]; then
    printf '%s\n' "$VENV_DIR/bin/huggingface-cli"
    return
  fi

  printf 'Missing Hugging Face CLI in %s/bin. Run make setup first.\n' "$VENV_DIR" >&2
  exit 1
}

resolve_model_preset() {
  local preset_key

  if [[ -n "$MODEL_REPO" ]]; then
    MODEL_LABEL="${MODEL_LABEL:-Custom model}"

    if [[ -z "$MODEL_FILE" && -z "$MODEL_GGUF_GLOB" ]]; then
      printf 'Custom model selection requires MODEL_FILE or MODEL_GGUF_GLOB when MODEL_REPO is set.\n' >&2
      exit 1
    fi

    return
  fi

  preset_key="$(printf '%s' "$MODEL_PRESET" | tr '[:upper:]' '[:lower:]')"

  case "$preset_key" in
    qwen2.5-7b|qwen25-7b|qwen-7b)
      MODEL_LABEL="Qwen2.5 7B Instruct"
      MODEL_REPO="bartowski/Qwen2.5-7B-Instruct-GGUF"
      MODEL_GGUF_GLOB="Qwen2.5-7B-Instruct-*Q4_K_S.gguf"
      ;;
    qwen2.5-14b|qwen25-14b|qwen-14b)
      MODEL_LABEL="Qwen2.5 14B Instruct"
      MODEL_REPO="bartowski/Qwen2.5-14B-Instruct-GGUF"
      MODEL_GGUF_GLOB="Qwen2.5-14B-Instruct-*Q4_K_M.gguf"
      ;;
    qwen3-8b|qwen3)
      MODEL_LABEL="Qwen3 8B"
      MODEL_REPO="bartowski/Qwen3-8B-GGUF"
      MODEL_GGUF_GLOB="Qwen3-8B-*Q4_K_M.gguf"
      ;;
    deepseek-r1-distill-qwen-14b|deepseek-r1-14b|deepseek-14b)
      MODEL_LABEL="DeepSeek R1 Distill Qwen 14B"
      MODEL_REPO="bartowski/DeepSeek-R1-Distill-Qwen-14B-GGUF"
      MODEL_GGUF_GLOB="DeepSeek-R1-Distill-Qwen-14B-*Q4_K_M.gguf"
      ;;
    gemma3-12b|gemma-3-12b|gemma3)
      MODEL_LABEL="Gemma 3 12B IT"
      MODEL_REPO="bartowski/Gemma-3-12B-IT-GGUF"
      MODEL_GGUF_GLOB="Gemma-3-12B-IT-*Q4_K_M.gguf"
      ;;
    *)
      printf 'Unknown MODEL_PRESET: %s\n' "$MODEL_PRESET" >&2
      printf 'Supported presets: qwen2.5-7b, qwen2.5-14b, qwen3-8b, deepseek-r1-distill-qwen-14b, gemma3-12b\n' >&2
      exit 1
      ;;
  esac
}

resolve_model_file_from_glob() {
  local -a matches=()

  [[ -n "$MODEL_GGUF_GLOB" ]] || return 1
  mkdir -p "$MODEL_DIR"

  shopt -s nullglob
  matches=("$MODEL_DIR"/$MODEL_GGUF_GLOB)
  shopt -u nullglob

  if (( ${#matches[@]} == 1 )); then
    MODEL_FILE="$(basename "${matches[0]}")"
    return 0
  fi

  if (( ${#matches[@]} > 1 )); then
    printf 'Multiple model files matched %s in %s. Set MODEL_FILE explicitly.\n' "$MODEL_GGUF_GLOB" "$MODEL_DIR" >&2
    exit 1
  fi

  return 1
}

resolve_model_config() {
  resolve_model_preset

  if [[ -z "$MODEL_FILE" ]]; then
    resolve_model_file_from_glob || true
  fi

  if [[ -n "$MODEL_FILE" ]]; then
    MODEL_PATH="$MODEL_DIR/$MODEL_FILE"
  else
    MODEL_PATH=""
  fi

  export MODEL_PRESET MODEL_LABEL MODEL_REPO MODEL_FILE MODEL_GGUF_GLOB MODEL_DIR MODEL_PATH VENV_DIR
}

download_selected_model() {
  local hf_cli
  local include_pattern

  resolve_model_config
  mkdir -p "$MODEL_DIR"

  if [[ -n "$MODEL_PATH" && -f "$MODEL_PATH" ]]; then
    model_log "model" "$MODEL_LABEL already present at $MODEL_PATH"
    return
  fi

  hf_cli="$(find_hf_cli)"
  include_pattern="${MODEL_FILE:-$MODEL_GGUF_GLOB}"

  model_log "model" "Downloading $MODEL_LABEL from $MODEL_REPO"
  "$hf_cli" download \
    "$MODEL_REPO" \
    --include "$include_pattern" \
    --local-dir "$MODEL_DIR"

  if [[ -z "$MODEL_FILE" ]]; then
    resolve_model_file_from_glob
    MODEL_PATH="$MODEL_DIR/$MODEL_FILE"
    export MODEL_FILE MODEL_PATH
  fi
}

ensure_selected_model() {
  resolve_model_config

  if [[ -n "$MODEL_PATH" && -f "$MODEL_PATH" ]]; then
    return
  fi

  download_selected_model

  if [[ -z "$MODEL_PATH" || ! -f "$MODEL_PATH" ]]; then
    printf 'Model file is still missing after download. Check MODEL_REPO / MODEL_FILE / MODEL_GGUF_GLOB.\n' >&2
    exit 1
  fi
}

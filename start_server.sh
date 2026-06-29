#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$ROOT_DIR/logs"
LOG_FILE="$LOG_DIR/llama-server.log"
source "$ROOT_DIR/scripts/shared/model_config.sh"

choose_model_preset() {
  local choice
  local index=1
  local preset
  local timeout_seconds=15

  printf 'Select a model to load:\n'
  for preset in "${MODEL_MENU_PRESETS[@]}"; do
    printf '  %d. %s (%s)\n' "$index" "$(model_menu_label "$preset")" "$preset"
    index=$((index + 1))
  done

  while true; do
    printf 'Enter number [1-%d] within %d seconds (default: %s): ' "${#MODEL_MENU_PRESETS[@]}" "$timeout_seconds" "$MODEL_PRESET"
    if ! read -r -t "$timeout_seconds" choice; then
      printf '\n[start] No selection received after %d seconds. Using default %s.\n' "$timeout_seconds" "$MODEL_PRESET"
      export MODEL_PRESET
      return
    fi

    if [[ -z "$choice" ]]; then
      printf '[start] No selection entered. Using default %s.\n' "$MODEL_PRESET"
      export MODEL_PRESET
      return
    fi

    if [[ "$choice" =~ ^[1-9][0-9]*$ ]] && (( choice >= 1 && choice <= ${#MODEL_MENU_PRESETS[@]} )); then
      MODEL_PRESET="${MODEL_MENU_PRESETS[$((choice - 1))]}"
      export MODEL_PRESET
      printf '[start] Selected %s (%s)\n' "$(model_menu_label "$MODEL_PRESET")" "$MODEL_PRESET"
      return
    fi

    printf 'Invalid selection. Please enter a number from 1 to %d.\n' "${#MODEL_MENU_PRESETS[@]}"
  done
}

cd "$ROOT_DIR"

case "${1:-}" in
  --choose|choose|--select-model)
    if [[ -t 0 ]]; then
      choose_model_preset
    else
      printf 'Model selection menu requires an interactive terminal.\n' >&2
      exit 1
    fi
    ;;
  "")
    ;;
  *)
    if [[ -z "${MODEL_PRESET:-}" ]]; then
      export MODEL_PRESET="$1"
    fi
    ;;
esac

if [[ -f "$ROOT_DIR/venv/bin/activate" ]]; then
  # Support the existing venv name first.
  source "$ROOT_DIR/venv/bin/activate"
elif [[ -f "$ROOT_DIR/.venv/bin/activate" ]]; then
  source "$ROOT_DIR/.venv/bin/activate"
fi

mkdir -p "$LOG_DIR"

if [[ -n "${MODEL_PRESET:-}" ]]; then
  printf '[start] MODEL_PRESET=%s\n' "$MODEL_PRESET" | tee -a "$LOG_FILE"
fi

exec make serve 2>&1 | tee -a "$LOG_FILE"

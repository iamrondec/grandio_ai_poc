#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  SUDO="sudo"
else
  SUDO=""
fi

log() {
  printf '\n[%s] %s\n' "install" "$1"
}

APT_PACKAGES=(
  build-essential
  cmake
  curl
  git
  python3
  python3-pip
  python3-venv
)

log "Refreshing apt package index"
$SUDO apt-get update

log "Installing required packages"
$SUDO apt-get install -y "${APT_PACKAGES[@]}"

cat <<'EOF'

[install] Base requirements are installed.
[install] For NVIDIA GPU acceleration, also install:
[install]   1. A current NVIDIA driver
[install]   2. The CUDA toolkit so `nvcc` is available on PATH
[install] Then rerun setup with:
[install]   LLAMA_BACKEND=cuda make setup
EOF

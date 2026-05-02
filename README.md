# Local Qwen 7B with llama.cpp

This project sets up a local `llama.cpp` environment, downloads a Qwen 7B GGUF model, and runs it from the terminal on macOS or Windows.

## What it does

- Creates a Python virtual environment in `.venv`
- Installs `huggingface_hub[cli]` for model downloads
- Clones and builds `llama.cpp`
- Downloads a default Qwen 7B GGUF model
- Runs Qwen in terminal mode or local web server mode
- Provides separate scripts and docs for macOS and Windows

## Quick start

macOS:

```bash
make setup
make test
make run
make serve
```

Windows:

```powershell
make install-windows-requirements
make setup
make test
make run
make serve
```

On Windows, `make setup`, `make test`, and `make run` now auto-select the Windows PowerShell scripts. On macOS, those same targets auto-select the shell scripts.

## Default model

The setup script defaults to:

- Model repo: `bartowski/Qwen2.5-7B-Instruct-GGUF`
- Model file: `Qwen2.5-7B-Instruct-Q4_K_S.gguf`

You can override both at runtime:

```bash
MODEL_REPO="Qwen/Qwen2-7B-Instruct-GGUF" \
MODEL_FILE="qwen2-7b-instruct-q4_0.gguf" \
make setup
```

## Project layout

```text
.
├── Makefile
├── README.md
└── scripts/
    ├── macos/
    │   ├── SETUP_AND_TEST.md
    │   ├── run_qwen.sh
    │   ├── run_qwen_server.sh
    │   ├── setup_llama_cpp_qwen.sh
    │   └── test_install.sh
    └── windows/
        ├── SETUP_AND_TEST.md
        ├── install_requirements.ps1
        ├── run_qwen.ps1
        ├── run_qwen_server.ps1
        ├── setup_llama_cpp_qwen.ps1
        └── test_install.ps1
```

## More detail

See [scripts/macos/SETUP_AND_TEST.md](/Users/admin/grandio/grandio_ai_poc/scripts/macos/SETUP_AND_TEST.md) and [scripts/windows/SETUP_AND_TEST.md](/Users/admin/grandio/grandio_ai_poc/scripts/windows/SETUP_AND_TEST.md) for setup notes, requirements, and troubleshooting.

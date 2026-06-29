# Local GGUF Models with llama.cpp

This project sets up a local `llama.cpp` environment, downloads a GGUF model on demand, and runs it from the terminal or as a local server on macOS, Ubuntu, or Windows.

## What it does

- Creates a Python virtual environment in `.venv`
- Installs `huggingface_hub[cli]` for model downloads via `hf`
- Clones and builds `llama.cpp`
- Downloads a default GGUF model and can switch presets later
- Runs the selected model in terminal mode or local web server mode
- Provides separate scripts and docs for macOS, Ubuntu, and Windows

## Quick start

macOS:

```bash
make setup
make test
make run
make serve
```

Ubuntu:

```bash
make install-ubuntu-requirements
LLAMA_BACKEND=cuda make setup
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

On Windows, `make setup`, `make test`, and `make run` auto-select the PowerShell scripts. On macOS and Ubuntu, those same targets auto-select the matching shell scripts for the current platform.

On newer `llama.cpp` builds, `make serve` will also load a default system prompt from `prompts/system_prompt.txt` when that file exists. You can override it with `SYSTEM_PROMPT_FILE=/path/to/file`.

On macOS and Ubuntu, `run` and `serve` now auto-download the selected model if it is missing locally, as long as you have already run `make setup` once and the Hugging Face CLI is available in `.venv`.

For Ubuntu load testing, [scripts/ubuntu/SETUP_AND_TEST.md](/Users/admin/grandio/grandio_ai_poc/scripts/ubuntu/SETUP_AND_TEST.md) also includes optional `k6` installation steps.

## Model selection

The default preset is:

- `MODEL_PRESET=qwen2.5-7b`

Built-in presets:

- `qwen2.5-7b`
- `qwen2.5-14b`
- `qwen3-8b`
- `deepseek-r1-distill-qwen-14b`
- `gemma3-12b`

Examples:

```bash
./start_server.sh
./start_server.sh --choose
MODEL_PRESET=qwen2.5-14b make serve
MODEL_PRESET=qwen3-8b make run
MODEL_PRESET=deepseek-r1-distill-qwen-14b ./start_server.sh
./start_server.sh gemma3-12b
```

Running `./start_server.sh` with no model preset keeps the default `qwen2.5-7b`, which is safer for autostart and systemd.

Running `./start_server.sh --choose` opens a numbered menu so you can pick the model interactively.

If the selected preset is not present in `models/`, the macOS and Ubuntu scripts will download it automatically before launching.

## Autostart install

For Ubuntu/Linux with `systemd`, you can install autostart like this:

```bash
./install_autostart.sh
```

That installs and starts a `systemd` service pinned to the default preset:

- `qwen2.5-7b`

To pin a different preset in the service:

```bash
./install_autostart.sh gemma3-12b
./install_autostart.sh qwen2.5-14b
```

You can also use:

```bash
make install-autostart
```

You can still use a custom model repo instead of a preset:

```bash
MODEL_REPO="Qwen/Qwen2-7B-Instruct-GGUF" \
MODEL_FILE="qwen2-7b-instruct-q4_0.gguf" \
make setup
```

For custom models, set `MODEL_FILE` directly, or set `MODEL_GGUF_GLOB` if you want the scripts to resolve the exact downloaded filename from a pattern.

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
    ├── ubuntu/
    │   ├── SETUP_AND_TEST.md
    │   ├── install_requirements.sh
    │   ├── k6_chat_completions.js
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

See [scripts/macos/SETUP_AND_TEST.md](/Users/admin/grandio/grandio_ai_poc/scripts/macos/SETUP_AND_TEST.md), [scripts/ubuntu/SETUP_AND_TEST.md](/Users/admin/grandio/grandio_ai_poc/scripts/ubuntu/SETUP_AND_TEST.md), and [scripts/windows/SETUP_AND_TEST.md](/Users/admin/grandio/grandio_ai_poc/scripts/windows/SETUP_AND_TEST.md) for setup notes, requirements, and troubleshooting.

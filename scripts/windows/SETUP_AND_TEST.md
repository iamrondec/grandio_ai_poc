# Windows Setup and Test Guide

## Requirements

- `winget`
- Visual Studio Build Tools with C++ support
- PowerShell
- Enough free disk space for `llama.cpp` build files and the GGUF model

## Install requirements

Run this first in PowerShell:

```powershell
make install-windows-requirements
```

That installs:

- `Git.Git`
- `Python.Python.3.12`
- `Kitware.CMake`
- `GnuWin32.Make`
- `Microsoft.VisualStudio.2022.BuildTools` with the Desktop C++ workload

After the installs finish, open a fresh terminal so `make`, `git`, `python`, and `cmake` are available on `PATH`.

## Setup

Run in PowerShell:

```powershell
make setup
```

The script will:

1. Create `.venv` if needed
2. Install `huggingface_hub[cli]`
3. Clone `llama.cpp` into `vendor\llama.cpp`
4. Build `llama.cpp` with CMake
5. Download the default Qwen GGUF model into `models\`

## Test

```powershell
make test
```

## Run

Interactive chat:

```powershell
make run
```

One prompt:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\windows\run_qwen.ps1 -Prompt "Explain recursion simply."
```

## Run Web UI

Start the local `llama.cpp` server:

```powershell
make serve
```

Or:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\windows\run_qwen_server.ps1
```

Then open:

```text
http://127.0.0.1:8080
```

## Test Web UI

1. Run `make test`
2. Start the server with `make serve`
3. Open `http://127.0.0.1:8080` in your browser
4. Confirm the page loads and the model is available
5. Optional API check from another terminal:

```powershell
curl http://127.0.0.1:8080/health
```

6. Optional completion test:

```powershell
curl -Method POST http://127.0.0.1:8080/completion `
  -ContentType "application/json" `
  -Body '{"prompt":"Say hello in one sentence.","n_predict":32}'
```

## Defaults

- `MODEL_REPO=bartowski/Qwen2.5-7B-Instruct-GGUF`
- `MODEL_FILE=Qwen2.5-7B-Instruct-Q4_K_S.gguf`

## Customize

```powershell
$env:MODEL_FILE="Qwen2.5-7B-Instruct-IQ4_XS.gguf"
powershell -ExecutionPolicy Bypass -File .\scripts\windows\setup_llama_cpp_qwen.ps1
$env:PORT="8081"
make serve
```

## Troubleshooting

If CMake cannot find a generator or compiler, install Visual Studio Build Tools and C++ components.

If PowerShell blocks the script, keep using `-ExecutionPolicy Bypass` for the launch command.

If `make` is still not found after installation, open a new PowerShell window and retry.

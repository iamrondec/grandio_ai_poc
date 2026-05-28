# Windows Setup and Test Guide

## Requirements

- `winget`
- Visual Studio Build Tools with C++ support
- PowerShell
- Enough free disk space for `llama.cpp` build files and the GGUF model
- For NVIDIA GPUs like an RTX 5050: NVIDIA CUDA Toolkit

## Where to get the prerequisites

- `winget`: Microsoft documents it here: <https://learn.microsoft.com/en-us/windows/package-manager/winget/>
  On current Windows 10 and Windows 11 systems, `winget` is typically provided through App Installer.
- Visual Studio Build Tools: download from Microsoft's official Visual Studio downloads page here: <https://visualstudio.microsoft.com/downloads/>
  On that page, look for `Build Tools for Visual Studio` and install the Desktop C++ workload.

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
- `Nvidia.CUDA`

After the installs finish, open a fresh terminal so `make`, `git`, `python`, and `cmake` are available on `PATH`.

If you want to skip CUDA on a CPU-only machine:

```powershell
$env:SKIP_NVIDIA_CUDA="1"
make install-windows-requirements
```

## Setup

Run in PowerShell:

```powershell
make setup
```

For an RTX 5050 or other NVIDIA GPU, use:

```powershell
$env:LLAMA_BACKEND="cuda"
make setup
```

The script will:

1. Create `.venv` if needed
2. Install `huggingface_hub[cli]`
3. Clone `llama.cpp` into `vendor\llama.cpp`
4. Build `llama.cpp` with CMake
5. Download the default Qwen GGUF model into `models\`

If the CUDA toolkit is detected, `make setup` will build a CUDA-enabled `llama.cpp` binary. If not, it falls back to a CPU-only build.

## Test

```powershell
make test
```

The test output now reports whether the current `llama.cpp` build has CUDA enabled.

## Run

Interactive chat:

```powershell
make run
```

One prompt:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\windows\run_qwen.ps1 -Prompt "Explain recursion simply."
```

The run script always uses CPU threads with `-t` and requests GPU offload with `-ngl`. On a CUDA-enabled build, that means both CPU and GPU are used together.

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

By default, `make serve` loads a system prompt from `prompts\system_prompt.txt` if that file exists. Override it with:

```powershell
$env:SYSTEM_PROMPT_FILE="C:\path\to\your_prompt.txt"
make serve
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

For an NVIDIA GPU:

```powershell
$env:LLAMA_BACKEND="cuda"
$env:N_GPU_LAYERS="99"
make setup
make run
```

## Troubleshooting

If CMake cannot find a generator or compiler, install Visual Studio Build Tools and C++ components.

If you have an NVIDIA GPU but the build still reports CPU-only, confirm the CUDA toolkit is installed and reopen PowerShell before rerunning `make setup`.

If PowerShell blocks the script, keep using `-ExecutionPolicy Bypass` for the launch command.

If `make` is still not found after installation, open a new PowerShell window and retry.

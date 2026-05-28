# Ubuntu Server Setup and Test Guide

## Requirements

- Ubuntu Server with `apt`
- `git`
- `python3`
- `python3-venv`
- `cmake`
- C/C++ build tools such as `build-essential`
- Enough free disk space for `llama.cpp` build files and the GGUF model
- For NVIDIA GPUs like an RTX 5050: a working NVIDIA driver and CUDA toolkit

## Install requirements

Run this first:

```bash
make install-ubuntu-requirements
```

That installs the base packages needed for a CPU build:

- `build-essential`
- `cmake`
- `curl`
- `git`
- `python3`
- `python3-pip`
- `python3-venv`

## Install NVIDIA driver and CUDA

If you want to use the RTX 5050 instead of CPU-only mode, install both:

- An NVIDIA driver so the OS can use the GPU
- The CUDA toolkit so `llama.cpp` can be built with CUDA support

Typical Ubuntu Server flow:

```bash
sudo ubuntu-drivers autoinstall
sudo reboot
```

After reboot, confirm the driver is active:

```bash
nvidia-smi
```

Then install the CUDA toolkit using NVIDIA's official Ubuntu package for your server's Ubuntu release. After that, confirm:

```bash
nvcc --version
```

You need both commands to work for this repo's GPU setup:

- `nvidia-smi` proves the driver is installed
- `nvcc --version` proves the CUDA toolkit is installed

For an RTX 5050 or other NVIDIA GPU, also make sure:

1. `nvidia-smi` works
2. `nvcc --version` works

If `nvcc` is not available yet, install the CUDA toolkit and reopen your shell before running setup.

## Setup

CPU-only:

```bash
make setup
```

For an RTX 5050 or other NVIDIA GPU:

```bash
LLAMA_BACKEND=cuda make setup
```

Or directly:

```bash
./scripts/ubuntu/setup_llama_cpp_qwen.sh
```

The script will:

1. Create `.venv` if needed
2. Install `huggingface_hub[cli]`
3. Clone `llama.cpp` into `vendor/llama.cpp`
4. Build `llama.cpp` with CUDA when available or requested
5. Download the default Qwen GGUF model into `models/`

If `LLAMA_BACKEND=auto` is used, setup chooses CUDA when `nvcc` is available and falls back to CPU otherwise.

## Test

```bash
make test
```

Or:

```bash
./scripts/ubuntu/test_install.sh
```

The test output reports whether the current `llama.cpp` build has CUDA enabled.

## Run

Interactive chat:

```bash
make run
```

One prompt:

```bash
./scripts/ubuntu/run_qwen.sh "Explain recursion simply."
```

The run script always uses CPU threads with `-t` and requests GPU offload with `-ngl`. On a CUDA-enabled build, that means both CPU and GPU are used together.

## Run Web UI

Start the local `llama.cpp` server:

```bash
make serve
```

Or:

```bash
./scripts/ubuntu/run_qwen_server.sh
```

Then open:

```text
http://127.0.0.1:8080
```

By default, `make serve` loads a system prompt from `prompts/system_prompt.txt` if that file exists. Override it with:

```bash
SYSTEM_PROMPT_FILE="/absolute/path/to/your_prompt.txt" make serve
```

If you need remote access from another machine on your network:

```bash
HOST=0.0.0.0 PORT=8080 make serve
```

## Test Web UI

1. Run `make test`
2. Start the server with `make serve`
3. Open `http://127.0.0.1:8080` in your browser
4. Confirm the page loads and the model is available
5. Optional API check from another terminal:

```bash
curl http://127.0.0.1:8080/health
```

6. Optional completion test:

```bash
curl -s http://127.0.0.1:8080/completion \
  -H "Content-Type: application/json" \
  -d '{"prompt":"Say hello in one sentence.","n_predict":32}'
```

## Defaults

- `MODEL_REPO=bartowski/Qwen2.5-7B-Instruct-GGUF`
- `MODEL_FILE=Qwen2.5-7B-Instruct-Q4_K_S.gguf`

## Customize

```bash
MODEL_FILE="Qwen2.5-7B-Instruct-IQ4_XS.gguf" make setup
THREADS=8 CONTEXT_SIZE=8192 N_GPU_LAYERS=99 make run
HOST=0.0.0.0 PORT=8081 make serve
```

For an NVIDIA GPU:

```bash
LLAMA_BACKEND=cuda N_GPU_LAYERS=99 make setup
make run
```

## Troubleshooting

If `cmake` or compiler tools are missing, rerun `make install-ubuntu-requirements`.

If you have an NVIDIA GPU but setup still reports a CPU build, confirm `nvcc --version` works in the same shell where you run `make setup`.

If `nvidia-smi` works but `nvcc` does not, the NVIDIA driver is installed but the CUDA toolkit is still missing.

If setup fails with `nvcc fatal : Unsupported gpu architecture 'compute_120a'`, your CUDA toolkit is older than the architecture that `llama.cpp` auto-detected for the GPU. NVIDIA's Blackwell compatibility guide says older toolkits can still work if the build includes forward-compatible PTX, and `llama.cpp` also supports manually overriding CUDA architectures through CMake.

Try:

```bash
cd ~/grandio/grandio_ai_poc
rm -rf vendor/llama.cpp/build
CMAKE_CUDA_ARCHITECTURES=90 LLAMA_BACKEND=cuda make setup
```

If that still fails, the better fix is to upgrade to a newer CUDA toolkit. Also check:

```bash
nvcc --version
```

References:

- `llama.cpp` CUDA build docs: <https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md>
- NVIDIA Blackwell compatibility guide: <https://docs.nvidia.com/cuda/blackwell-compatibility-guide/>

If you expose the server on `0.0.0.0`, make sure your firewall allows the selected port.

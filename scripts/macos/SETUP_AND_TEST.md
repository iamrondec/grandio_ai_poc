# macOS Setup and Test Guide

## Requirements

- `git`
- `python3`
- `cmake`
- Xcode Command Line Tools or another C/C++ compiler
- Enough free disk space for `llama.cpp` build files and the GGUF model

## Setup

Run:

```bash
make setup
```

Or directly:

```bash
./scripts/macos/setup_llama_cpp_qwen.sh
```

The script will:

1. Create `.venv` if needed
2. Install `huggingface_hub[cli]` so the `hf` CLI is available
3. Clone `llama.cpp` into `vendor/llama.cpp`
4. Build `llama.cpp` with Metal enabled
5. Download the default Qwen GGUF model into `models/`

## Test

```bash
make test
```

Or:

```bash
./scripts/macos/test_install.sh
```

## Run

Interactive chat:

```bash
make run
```

One prompt:

```bash
./scripts/macos/run_qwen.sh "Explain recursion simply."
```

## Run Web UI

Start the local `llama.cpp` server:

```bash
make serve
```

Or:

```bash
./scripts/macos/run_qwen_server.sh
```

Then open:

```text
http://127.0.0.1:8080
```

By default, `make serve` loads a system prompt from `prompts/system_prompt.txt` if that file exists. Override it with:

```bash
SYSTEM_PROMPT_FILE="/absolute/path/to/your_prompt.txt" make serve
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
PORT=8081 make serve
```

## Troubleshooting

If `cmake` or compiler tools are missing, install them first and rerun setup.

If the download target changes, pass explicit `MODEL_REPO` and `MODEL_FILE` values.

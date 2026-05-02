param(
    [string]$Prompt = ""
)

$ErrorActionPreference = "Stop"

$RootDir = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$LlamaCppDir = if ($env:LLAMA_CPP_DIR) { $env:LLAMA_CPP_DIR } else { Join-Path $RootDir "vendor\llama.cpp" }
$ModelDir = if ($env:MODEL_DIR) { $env:MODEL_DIR } else { Join-Path $RootDir "models" }
$ModelFile = if ($env:MODEL_FILE) { $env:MODEL_FILE } else { "Qwen2.5-7B-Instruct-Q4_K_S.gguf" }
$Threads = if ($env:THREADS) { $env:THREADS } else { [Environment]::ProcessorCount }
$ContextSize = if ($env:CONTEXT_SIZE) { $env:CONTEXT_SIZE } else { "4096" }
$GpuLayers = if ($env:N_GPU_LAYERS) { $env:N_GPU_LAYERS } else { "99" }
$ModelPath = Join-Path $ModelDir $ModelFile
$LlamaCli = Join-Path $LlamaCppDir "build\bin\Release\llama-cli.exe"

if (-not (Test-Path $LlamaCli)) {
    throw "llama-cli not found at $LlamaCli. Run .\scripts\windows\setup_llama_cpp_qwen.ps1 first."
}

if (-not (Test-Path $ModelPath)) {
    throw "Model file not found at $ModelPath. Run .\scripts\windows\setup_llama_cpp_qwen.ps1 first."
}

if ($Prompt) {
    & $LlamaCli -m $ModelPath -t $Threads -c $ContextSize -ngl $GpuLayers -p $Prompt
} else {
    & $LlamaCli -m $ModelPath -t $Threads -c $ContextSize -ngl $GpuLayers -cnv
}

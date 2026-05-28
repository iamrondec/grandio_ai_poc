param()

$ErrorActionPreference = "Stop"

$RootDir = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$LlamaCppDir = if ($env:LLAMA_CPP_DIR) { $env:LLAMA_CPP_DIR } else { Join-Path $RootDir "vendor\llama.cpp" }
$ModelDir = if ($env:MODEL_DIR) { $env:MODEL_DIR } else { Join-Path $RootDir "models" }
$ModelFile = if ($env:MODEL_FILE) { $env:MODEL_FILE } else { "Qwen2.5-7B-Instruct-Q4_K_S.gguf" }
$SystemPromptFile = if ($env:SYSTEM_PROMPT_FILE) { $env:SYSTEM_PROMPT_FILE } else { Join-Path $RootDir "prompts\system_prompt.txt" }
$Threads = if ($env:THREADS) { $env:THREADS } else { [Environment]::ProcessorCount }
$ContextSize = if ($env:CONTEXT_SIZE) { $env:CONTEXT_SIZE } else { "4096" }
$GpuLayers = if ($env:N_GPU_LAYERS) { $env:N_GPU_LAYERS } else { "99" }
$HostName = if ($env:HOST) { $env:HOST } else { "127.0.0.1" }
$Port = if ($env:PORT) { $env:PORT } else { "8080" }
$ModelPath = Join-Path $ModelDir $ModelFile
$LlamaServer = Join-Path $LlamaCppDir "build\bin\Release\llama-server.exe"
$ServerArgs = @()
$SupportsSystemPromptFile = $false

if (-not (Test-Path $LlamaServer)) {
    throw "llama-server not found at $LlamaServer. Run .\scripts\windows\setup_llama_cpp_qwen.ps1 first."
}

if (-not (Test-Path $ModelPath)) {
    throw "Model file not found at $ModelPath. Run .\scripts\windows\setup_llama_cpp_qwen.ps1 first."
}

try {
    $HelpText = & $LlamaServer --help 2>&1 | Out-String
    $SupportsSystemPromptFile = $HelpText -match "--system-prompt-file"
} catch {
    $SupportsSystemPromptFile = $false
}

if ((Test-Path $SystemPromptFile) -and $SupportsSystemPromptFile) {
    $ServerArgs += @("--system-prompt-file", $SystemPromptFile)
}

& $LlamaServer -m $ModelPath -t $Threads -c $ContextSize -ngl $GpuLayers --host $HostName --port $Port @ServerArgs

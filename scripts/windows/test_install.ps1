$ErrorActionPreference = "Stop"

$RootDir = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$VenvDir = if ($env:VENV_DIR) { $env:VENV_DIR } else { Join-Path $RootDir ".venv" }
$LlamaCppDir = if ($env:LLAMA_CPP_DIR) { $env:LLAMA_CPP_DIR } else { Join-Path $RootDir "vendor\llama.cpp" }
$ModelDir = if ($env:MODEL_DIR) { $env:MODEL_DIR } else { Join-Path $RootDir "models" }
$ModelFile = if ($env:MODEL_FILE) { $env:MODEL_FILE } else { "Qwen2.5-7B-Instruct-Q4_K_S.gguf" }
$VenvPython = Join-Path $VenvDir "Scripts\python.exe"
$HfCli = Join-Path $VenvDir "Scripts\hf.exe"
$LegacyHfCli = Join-Path $VenvDir "Scripts\huggingface-cli.exe"
$LlamaCli = Join-Path $LlamaCppDir "build\bin\Release\llama-cli.exe"
$LlamaServer = Join-Path $LlamaCppDir "build\bin\Release\llama-server.exe"
$ModelPath = Join-Path $ModelDir $ModelFile
$CmakeCache = Join-Path $LlamaCppDir "build\CMakeCache.txt"

function Fail([string]$Message) {
    throw "[test] $Message"
}

Write-Host "[test] Checking virtualenv..."
if (-not (Test-Path $VenvPython)) { Fail "Missing virtualenv Python at $VenvPython" }

Write-Host "[test] Checking Hugging Face CLI..."
if ((-not (Test-Path $HfCli)) -and (-not (Test-Path $LegacyHfCli))) {
    Fail "Missing Hugging Face CLI in $VenvDir\Scripts"
}

Write-Host "[test] Checking llama.cpp build..."
if (-not (Test-Path $LlamaCli)) { Fail "Missing llama-cli at $LlamaCli" }
if (-not (Test-Path $LlamaServer)) { Fail "Missing llama-server at $LlamaServer" }

Write-Host "[test] Checking model file..."
if (-not (Test-Path $ModelPath)) { Fail "Missing model file at $ModelPath" }

if (Test-Path $CmakeCache) {
    $CacheContent = Get-Content $CmakeCache -Raw
    if ($CacheContent -match "GGML_CUDA:BOOL=ON") {
        Write-Host "[test] Backend: CUDA enabled"
    } else {
        Write-Host "[test] Backend: CPU-only build detected"
    }
}

Write-Host "[test] Verifying llama-cli responds..."
& $LlamaCli --help | Out-Null

Write-Host ""
Write-Host "[test] All checks passed."
Write-Host "[test] Launch with: $RootDir\scripts\windows\run_qwen.ps1"
Write-Host "[test] Web UI with: $RootDir\scripts\windows\run_qwen_server.ps1"

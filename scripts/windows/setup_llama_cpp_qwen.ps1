$ErrorActionPreference = "Stop"

$RootDir = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$VenvDir = if ($env:VENV_DIR) { $env:VENV_DIR } else { Join-Path $RootDir ".venv" }
$VendorDir = Join-Path $RootDir "vendor"
$LlamaCppDir = if ($env:LLAMA_CPP_DIR) { $env:LLAMA_CPP_DIR } else { Join-Path $VendorDir "llama.cpp" }
$ModelDir = if ($env:MODEL_DIR) { $env:MODEL_DIR } else { Join-Path $RootDir "models" }
$ModelRepo = if ($env:MODEL_REPO) { $env:MODEL_REPO } else { "bartowski/Qwen2.5-7B-Instruct-GGUF" }
$ModelFile = if ($env:MODEL_FILE) { $env:MODEL_FILE } else { "Qwen2.5-7B-Instruct-Q4_K_S.gguf" }
$LlamaBackend = if ($env:LLAMA_BACKEND) { $env:LLAMA_BACKEND.ToLowerInvariant() } else { "auto" }
$CudaArchitectures = if ($env:CMAKE_CUDA_ARCHITECTURES) { $env:CMAKE_CUDA_ARCHITECTURES } else { $null }

function Log([string]$Message) {
    Write-Host ""
    Write-Host "[setup] $Message"
}

function Require-Cmd([string]$Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Missing required command: $Name"
    }
}

function Has-CudaToolkit {
    if (Get-Command nvcc -ErrorAction SilentlyContinue) {
        return $true
    }

    return -not [string]::IsNullOrWhiteSpace($env:CUDA_PATH)
}

Require-Cmd git
Require-Cmd python
Require-Cmd cmake

New-Item -ItemType Directory -Force -Path $VendorDir | Out-Null
New-Item -ItemType Directory -Force -Path $ModelDir | Out-Null

if (-not (Test-Path $VenvDir)) {
    Log "Creating virtual environment at $VenvDir"
    python -m venv $VenvDir
} else {
    Log "Using existing virtual environment at $VenvDir"
}

$VenvPython = Join-Path $VenvDir "Scripts\python.exe"
$VenvPip = Join-Path $VenvDir "Scripts\pip.exe"
$HfCli = Join-Path $VenvDir "Scripts\hf.exe"
$LegacyHfCli = Join-Path $VenvDir "Scripts\huggingface-cli.exe"

Log "Installing Python dependencies"
& $VenvPython -m pip install --upgrade pip
& $VenvPip install --upgrade "huggingface_hub[cli]"

if (-not (Test-Path (Join-Path $LlamaCppDir ".git"))) {
    Log "Cloning llama.cpp into $LlamaCppDir"
    git clone https://github.com/ggml-org/llama.cpp $LlamaCppDir
} else {
    Log "Using existing llama.cpp checkout at $LlamaCppDir"
}

$ResolvedHfCli = if (Test-Path $HfCli) {
    $HfCli
} elseif (Test-Path $LegacyHfCli) {
    $LegacyHfCli
} else {
    throw "Missing Hugging Face CLI in $VenvDir\Scripts. Expected hf.exe."
}

Push-Location $LlamaCppDir
try {
    Log "Building llama.cpp"
    $CmakeArgs = @("-B", "build")
    $SelectedBackend = "cpu"

    switch ($LlamaBackend) {
        "cuda" {
            if (-not (Has-CudaToolkit)) {
                throw "LLAMA_BACKEND=cuda was requested, but the CUDA toolkit was not detected. Install it first and reopen PowerShell."
            }

            $CmakeArgs += "-DGGML_CUDA=ON"
            if ($CudaArchitectures) {
                $CmakeArgs += "-DCMAKE_CUDA_ARCHITECTURES=$CudaArchitectures"
            }
            $SelectedBackend = "cuda"
        }
        "cpu" {
            $SelectedBackend = "cpu"
        }
        "auto" {
            if (Has-CudaToolkit) {
                $CmakeArgs += "-DGGML_CUDA=ON"
                if ($CudaArchitectures) {
                    $CmakeArgs += "-DCMAKE_CUDA_ARCHITECTURES=$CudaArchitectures"
                }
                $SelectedBackend = "cuda"
            }
        }
        default {
            throw "Unsupported LLAMA_BACKEND value: $LlamaBackend. Use auto, cpu, or cuda."
        }
    }

    Log "Selected backend: $SelectedBackend"
    cmake @CmakeArgs
    cmake --build build --config Release
} finally {
    Pop-Location
}

$ModelPath = Join-Path $ModelDir $ModelFile
if (-not (Test-Path $ModelPath)) {
    Log "Downloading model $ModelRepo :: $ModelFile"
    & $ResolvedHfCli download $ModelRepo --include $ModelFile --local-dir $ModelDir
} else {
    Log "Model already present at $ModelPath"
}

Log "Setup complete"
Write-Host "Model path: $ModelPath"
Write-Host "Run with: $RootDir\scripts\windows\run_qwen.ps1"

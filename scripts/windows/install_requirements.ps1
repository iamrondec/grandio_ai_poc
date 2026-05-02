$ErrorActionPreference = "Stop"

$WingetArgs = @(
    "--exact",
    "--source", "winget",
    "--accept-source-agreements",
    "--accept-package-agreements"
)

function Log([string]$Message) {
    Write-Host ""
    Write-Host "[requirements] $Message"
}

function Require-Cmd([string]$Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Missing required command: $Name"
    }
}

function Install-Package([string]$Id) {
    Log "Installing $Id"
    winget install @WingetArgs --id $Id
}

Require-Cmd winget

Log "Installing Git"
Install-Package "Git.Git"

Log "Installing Python"
Install-Package "Python.Python.3.12"

Log "Installing CMake"
Install-Package "Kitware.CMake"

Log "Installing GNU Make"
Install-Package "GnuWin32.Make"

Log "Installing Visual Studio Build Tools with the Desktop C++ workload"
winget install @WingetArgs `
    --id "Microsoft.VisualStudio.2022.BuildTools" `
    --override "--passive --wait --norestart --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"

Log "Requirements install complete"
Write-Host "If this is a new machine setup, open a fresh terminal before running make."

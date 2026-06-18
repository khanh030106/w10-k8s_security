# Script cài Helm cho Windows
# Chạy: powershell -ExecutionPolicy Bypass -File install-helm.ps1

$ErrorActionPreference = "Stop"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Installing Helm v3.14.0 for Windows" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Tạo thư mục temp
$tempDir = "$env:TEMP\helm-install"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

# Download Helm
$helmUrl = "https://get.helm.sh/helm-v3.14.0-windows-amd64.zip"
$zipFile = "$tempDir\helm.zip"

Write-Host "Downloading Helm..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $helmUrl -OutFile $zipFile -UseBasicParsing
    Write-Host "✓ Downloaded successfully" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to download: $_" -ForegroundColor Red
    exit 1
}

# Extract
Write-Host "Extracting..." -ForegroundColor Yellow
Expand-Archive -Path $zipFile -DestinationPath $tempDir -Force
Write-Host "✓ Extracted successfully" -ForegroundColor Green

# Copy to Program Files
$installDir = "C:\Program Files\Helm"
Write-Host "Installing to $installDir..." -ForegroundColor Yellow

try {
    # Tạo thư mục nếu chưa có
    if (-not (Test-Path $installDir)) {
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    }
    
    # Copy helm.exe
    Copy-Item "$tempDir\windows-amd64\helm.exe" "$installDir\helm.exe" -Force
    Write-Host "✓ Installed to $installDir" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to install: $_" -ForegroundColor Red
    Write-Host "Trying to copy to user directory instead..." -ForegroundColor Yellow
    
    # Fallback: copy to user bin
    $userBin = "$env:USERPROFILE\bin"
    if (-not (Test-Path $userBin)) {
        New-Item -ItemType Directory -Path $userBin -Force | Out-Null
    }
    Copy-Item "$tempDir\windows-amd64\helm.exe" "$userBin\helm.exe" -Force
    $installDir = $userBin
    Write-Host "✓ Installed to $installDir" -ForegroundColor Green
}

# Add to PATH
Write-Host "Adding to PATH..." -ForegroundColor Yellow
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$installDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$installDir", "User")
    $env:Path += ";$installDir"
    Write-Host "✓ Added to PATH" -ForegroundColor Green
} else {
    Write-Host "✓ Already in PATH" -ForegroundColor Green
}

# Cleanup
Remove-Item -Path $tempDir -Recurse -Force

# Verify
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Verifying installation..." -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

$helmPath = Get-Command helm -ErrorAction SilentlyContinue
if ($helmPath) {
    & helm version --short
    Write-Host ""
    Write-Host "✓ Helm installed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now use 'helm' commands." -ForegroundColor Yellow
    Write-Host "If 'helm' is not recognized, restart your terminal." -ForegroundColor Yellow
} else {
    Write-Host "⚠ Helm installed but not found in PATH" -ForegroundColor Yellow
    Write-Host "Please restart your terminal and try again." -ForegroundColor Yellow
    Write-Host "Or run: " -NoNewline -ForegroundColor Yellow
    Write-Host "`$env:Path += ';$installDir'" -ForegroundColor Cyan
}

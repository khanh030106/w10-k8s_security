# Simple Helm installer for Windows
$ErrorActionPreference = "Stop"

Write-Host "Installing Helm..." -ForegroundColor Cyan

# Download
$url = "https://get.helm.sh/helm-v3.14.0-windows-amd64.zip"
$zip = "$env:TEMP\helm.zip"
$extract = "$env:TEMP\helm"

Write-Host "Downloading from $url"
Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing

Write-Host "Extracting..."
Expand-Archive -Path $zip -DestinationPath $extract -Force

# Install to user bin
$binDir = "$env:USERPROFILE\bin"
if (-not (Test-Path $binDir)) {
    New-Item -ItemType Directory -Path $binDir | Out-Null
}

Write-Host "Installing to $binDir"
Copy-Item "$extract\windows-amd64\helm.exe" "$binDir\helm.exe" -Force

# Add to PATH for current session
$env:Path = "$binDir;$env:Path"

# Add to PATH permanently
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$binDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$binDir", "User")
    Write-Host "Added to PATH" -ForegroundColor Green
}

# Cleanup
Remove-Item $zip -Force
Remove-Item $extract -Recurse -Force

# Verify
Write-Host ""
Write-Host "Checking installation..." -ForegroundColor Cyan
& "$binDir\helm.exe" version --short

Write-Host ""
Write-Host "SUCCESS! Helm installed." -ForegroundColor Green
Write-Host "Location: $binDir\helm.exe" -ForegroundColor Yellow

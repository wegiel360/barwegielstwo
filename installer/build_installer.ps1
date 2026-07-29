$ErrorActionPreference = "Stop"

$isccPath = "C:\Users\wegiel\AppData\Local\Programs\Inno Setup 7\ISCC.exe"
if (-not (Test-Path $isccPath)) {
    $isccPath = (Get-Command iscc -ErrorAction SilentlyContinue).Source
    if (-not $isccPath) {
        Write-Host "Inno Setup is not installed. Please install it first." -ForegroundColor Red
        Write-Host "Download from: https://jrsoftware.org/isdownload.php" -ForegroundColor Yellow
        exit 1
    }
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $scriptDir
$issFile = Join-Path $scriptDir "bar_wegielstwo.iss"

Write-Host "Building installer with Inno Setup..." -ForegroundColor Cyan
Write-Host "Inno Setup: $isccPath" -ForegroundColor Gray
Write-Host "Script: $issFile" -ForegroundColor Gray
Write-Host "Root dir: $rootDir" -ForegroundColor Gray

& $isccPath "/DRootDir=$rootDir" $issFile

if ($LASTEXITCODE -eq 0) {
    Write-Host "Installer built successfully!" -ForegroundColor Green
} else {
    Write-Host "Installer build failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}
